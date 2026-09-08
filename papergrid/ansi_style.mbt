///|
// Canonical SGR state and emission order follow ansi-str 0.9, used by tabled.
// See THIRD_PARTY_NOTICES.md for the original license notices.
priv struct SgrState {
  flags : Array[Bool]
  mut foreground : String?
  mut background : String?
  mut underline_color : String?
  mut font : Int?
  mut reset : Bool
  mut unknown : Bool
}

///|
fn SgrState::new() -> SgrState {
  {
    flags: Array::make(76, false),
    foreground: None,
    background: None,
    underline_color: None,
    font: None,
    reset: false,
    unknown: false,
  }
}

///|
fn SgrState::has_any(self : SgrState) -> Bool {
  self.foreground is Some(_) ||
  self.background is Some(_) ||
  self.underline_color is Some(_) ||
  self.flags.any(value => value) ||
  (self.reset && self.unknown)
}

///|
fn sgr_number(text : String) -> Int? {
  guard !text.is_empty() else { return None }
  let chars = text.to_array()
  let start = if chars[0] == '+' { 1 } else { 0 }
  guard start < chars.length() else { return None }
  let mut value = 0
  for index in start..<chars.length() {
    let ch = chars[index]
    guard ch >= '0' && ch <= '9' else { return None }
    value = value * 10 + ch.to_int() - '0'.to_int()
    guard value <= 255 else { return None }
  }
  Some(value)
}

///|
fn sgr_extended(
  parts : Array[String],
  index : Int,
  code : Int,
) -> (String?, Int) {
  guard index < parts.length() else { return (None, index) }
  let count = match parts[index] {
    "2" => 3
    "5" => 1
    _ => 0
  }
  guard count > 0 else { return (None, index + 1) }
  guard index + count < parts.length() else { return (None, parts.length()) }
  let values = Array::makei(count, offset => {
    sgr_number(parts[index + offset + 1]).unwrap_or(0).to_string()
  })
  (Some("\{code};\{parts[index]};" + values.join(";")), index + count + 1)
}

///|
fn SgrState::update(self : SgrState, sequence : String) -> Unit {
  guard sequence.has_prefix("\u001b[") && sequence.has_suffix("m") else {
    return
  }
  let parts = sequence[2:sequence.length() - 1]
    .split(";")
    .map(StringView::to_owned)
    .collect()
  let mut index = 0
  while index < parts.length() {
    let part = parts[index]
    index += 1
    let code = match sgr_number(part) {
      Some(code) if part == code.to_string() => code
      _ => {
        self.unknown = true
        continue
      }
    }
    match code {
      0 => {
        for i in 0..<self.flags.length() {
          self.flags[i] = false
        }
        self.foreground = None
        self.background = None
        self.underline_color = None
        self.font = None
        self.reset = true
        self.unknown = false
      }
      1..=9 | 20 | 21 | 26 | 51..=53 | 60..=64 | 73 | 74 =>
        self.flags[code] = true
      10 => self.font = None
      11..=19 => self.font = Some(code)
      22 => {
        self.flags[1] = false
        self.flags[2] = false
      }
      23 => self.flags[3] = false
      24 => {
        self.flags[4] = false
        self.flags[21] = false
      }
      25 => {
        self.flags[5] = false
        self.flags[6] = false
      }
      27..=29 => self.flags[code - 20] = false
      30..=37 | 90..=97 => self.foreground = Some(part)
      40..=47 | 100..=107 => self.background = Some(part)
      38 | 48 | 58 => {
        let (color, next) = sgr_extended(parts, index, code)
        index = next
        if color is Some(_) {
          match code {
            38 => self.foreground = color
            48 => self.background = color
            _ => self.underline_color = color
          }
        }
      }
      39 => self.foreground = None
      49 => self.background = None
      50 => self.flags[26] = false
      54 => {
        self.flags[51] = false
        self.flags[52] = false
      }
      55 => self.flags[53] = false
      59 => self.underline_color = None
      65 =>
        for flag in 60..<=64 {
          self.flags[flag] = false
        }
      75 => {
        self.flags[73] = false
        self.flags[74] = false
      }
      _ => self.unknown = true
    }
  }
}

///|
fn sgr(code : String) -> String {
  "\u001b[" + code + "m"
}

///|
fn SgrState::prefix(self : SgrState) -> String {
  let out = StringBuilder()
  for code in [1, 2, 3, 4, 5, 6, 7, 8, 9] {
    if self.flags[code] {
      out.write_string(sgr(code.to_string()))
    }
  }
  if self.font is Some(font) {
    out.write_string(sgr(font.to_string()))
  }
  for code in [20, 21, 26] {
    if self.flags[code] {
      out.write_string(sgr(code.to_string()))
    }
  }
  for color in [self.foreground, self.background, self.underline_color] {
    if color is Some(code) {
      out.write_string(sgr(code))
    }
  }
  for code in [51, 52, 53, 60, 61, 62, 63, 64, 73, 74] {
    if self.flags[code] {
      out.write_string(sgr(code.to_string()))
    }
  }
  out.to_string()
}

///|
fn SgrState::suffix(self : SgrState) -> String {
  let out = StringBuilder()
  let codes = [
    (self.unknown && self.reset, 0),
    (self.font is Some(_), 10),
    (self.flags[1] || self.flags[2], 22),
    (self.flags[3] || self.flags[20], 23),
    (self.flags[4] || self.flags[21], 24),
    (self.flags[5] || self.flags[6], 25),
    (self.flags[7], 27),
    (self.flags[8], 28),
    (self.flags[9], 29),
    (self.foreground is Some(_), 39),
    (self.background is Some(_), 49),
    (self.flags[26], 50),
    (self.flags[51] || self.flags[52], 54),
    (self.flags[53], 55),
    (
      self.flags[60] ||
      self.flags[61] ||
      self.flags[62] ||
      self.flags[63] ||
      self.flags[64],
      65,
    ),
    (self.underline_color is Some(_), 59),
    (self.flags[73] || self.flags[74], 75),
    (self.unknown, 0),
  ]
  for pair in codes {
    if pair.0 {
      out.write_string(sgr(pair.1.to_string()))
    }
  }
  out.to_string()
}

///|
/// Extract the canonical style of the first text block, as in tabled.
/// Empty input or input containing only control sequences has no text block.
pub fn ANSIBuf::try_parse(text : String) -> Result[ANSIBuf, Unit] {
  let state = SgrState::new()
  for token in ansi_tokens(text) {
    match token.kind {
      Sgr => state.update(token.text)
      Text =>
        return Ok(
          if state.has_any() {
            ANSIBuf::new(state.prefix(), state.suffix())
          } else {
            ANSIBuf::empty()
          },
        )
      _ => ()
    }
  }
  Err(())
}

///|
/// Split lines while closing and reopening active SGR styles at each boundary.
/// Empty lines stay empty, and trailing newlines produce a final empty line.
pub fn get_lines(text : String) -> Array[String] {
  let state = SgrState::new()
  split_lines(text).map(raw => {
    if raw.is_empty() {
      return raw
    }
    let part = if state.has_any() { state.prefix() + raw } else { raw }
    for token in ansi_tokens(part) {
      if token.kind is Sgr {
        state.update(token.text)
      }
    }
    if state.has_any() {
      part + state.suffix()
    } else {
      part
    }
  })
}
