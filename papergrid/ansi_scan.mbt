///|
// The token boundary rules follow ansitok's VTE-based iterator. Keeping text
// separate from control sequences also handles OSC hyperlinks and DCS strings.
// Ported algorithms retain their notices in THIRD_PARTY_NOTICES.md.
priv enum AnsiKind {
  Text
  Sgr
  Csi
  Osc
  Esc
}

///|
priv struct AnsiToken {
  kind : AnsiKind
  text : String
}

///|
priv enum AnsiMode {
  Ground
  Escape
  EscapeIntermediate
  Csi(Int, Bool)
  CsiIntermediate(Int)
  CsiIgnore
  Osc
  DcsHeader
  DcsBody
  StringIgnore
}

///|
priv struct AnsiParser {
  chars : Array[Char]
  mut mode : AnsiMode
  mut position : Int
  mut start : Int
  mut text_length : Int
  mut pending : AnsiKind?
  mut previous_escape : Bool
  mut parameters : Int
}

///|
fn AnsiParser::new(text : String) -> AnsiParser {
  {
    chars: text.to_array(),
    mode: Ground,
    position: 0,
    start: 0,
    text_length: 0,
    pending: None,
    previous_escape: false,
    parameters: 0,
  }
}

///|
fn AnsiParser::advance(self : AnsiParser, ch : Char) -> Unit {
  self.position += 1
  if ch == '\u001b' {
    if self.mode is Osc {
      self.pending = Some(Osc)
    }
    self.mode = Escape
    return
  }
  if ch == '\u0018' || ch == '\u001a' {
    self.mode = Ground
    self.text_length += 1
    return
  }
  match self.mode {
    Ground => if ch != '\u007f' { self.text_length += 1 }
    Escape | EscapeIntermediate =>
      if ch < ' ' {
        self.text_length += 1
      } else if ch >= ' ' && ch <= '/' {
        self.mode = EscapeIntermediate
      } else if ch >= '0' && ch <= '~' {
        let initial = self.mode is Escape
        self.mode = if initial {
          match ch {
            '[' => {
              self.parameters = 1
              Csi(0, false)
            }
            ']' => Osc
            'P' => DcsHeader
            'X' | '^' | '_' => StringIgnore
            _ => {
              self.pending = Some(Esc)
              Ground
            }
          }
        } else {
          self.pending = Some(Esc)
          Ground
        }
      }
    Csi(intermediates, collected) =>
      if ch < ' ' {
        self.text_length += 1
      } else if ch >= ' ' && ch <= '/' {
        self.mode = CsiIntermediate(intermediates + 1)
      } else if ch >= '0' && ch <= '?' {
        if ch >= '<' && collected {
          self.mode = CsiIgnore
        } else if ch >= '<' {
          self.mode = Csi(intermediates + 1, true)
        } else {
          if ch == ';' || ch == ':' {
            self.parameters += 1
          }
          self.mode = Csi(intermediates, true)
        }
      } else if ch >= '@' && ch <= '~' {
        self.mode = Ground
        if intermediates <= 1 && self.parameters <= 32 {
          self.pending = Some(
            if ch == 'm' && intermediates == 0 {
              Sgr
            } else {
              Csi
            },
          )
        }
      }
    CsiIntermediate(intermediates) =>
      if ch < ' ' {
        self.text_length += 1
      } else if ch >= ' ' && ch <= '/' {
        self.mode = CsiIntermediate(intermediates + 1)
      } else if ch >= '0' && ch <= '?' {
        self.mode = CsiIgnore
      } else if ch >= '@' && ch <= '~' {
        self.mode = Ground
        if intermediates <= 1 && self.parameters <= 32 {
          self.pending = Some(Csi)
        }
      }
    CsiIgnore => {
      if ch < ' ' {
        self.text_length += 1
      }
      if ch >= '@' && ch <= '~' {
        self.mode = Ground
      }
    }
    Osc =>
      if ch == '\u0007' {
        self.pending = Some(Osc)
        self.mode = Ground
      }
    DcsHeader => if ch >= '@' && ch <= '~' { self.mode = DcsBody }
    DcsBody | StringIgnore => ()
  }
}

///|
fn AnsiParser::token(
  self : AnsiParser,
  kind : AnsiKind,
  start : Int,
  end_ : Int,
) -> AnsiToken {
  { kind, text: String::from_array(self.chars[start:end_]), }
}

///|
fn AnsiParser::next(self : AnsiParser) -> AnsiToken? {
  let mut escape_started = false
  while self.pending is None && self.position < self.chars.length() {
    let ch = self.chars[self.position]
    self.advance(ch)
    if ch == '\u001b' {
      if self.previous_escape {
        let start = self.start
        self.start += 1
        return Some(self.token(Esc, start, self.start))
      }
      escape_started = true
      self.previous_escape = true
      if self.text_length > 0 {
        let start = self.start
        self.start += self.text_length
        self.text_length = 0
        return Some(self.token(Text, start, self.start))
      }
    } else {
      self.previous_escape = false
    }
  }
  if self.pending is Some(kind) {
    if self.text_length > 0 {
      let start = self.start
      self.start += self.text_length
      self.text_length = 0
      return Some(self.token(Text, start, self.start))
    }
    self.pending = None
    let start = self.start
    self.start = self.position
    return Some(self.token(kind, start, self.position))
  }
  if self.text_length > 0 {
    self.text_length = 0
    return Some(self.token(Text, self.start, self.position))
  }
  if self.previous_escape {
    let start = self.start
    self.start += 1
    self.previous_escape = false
    return Some(self.token(Esc, start, self.start))
  }
  if escape_started {
    let start = self.start
    self.start += 1
    self.text_length = self.position - self.start
    return Some(self.token(Esc, start, self.start))
  }
  None
}

///|
fn ansi_tokens(text : String) -> Array[AnsiToken] {
  let parser = AnsiParser::new(text)
  let tokens = []
  while parser.next() is Some(token) {
    tokens.push(token)
  }
  tokens
}

///|
/// Return the visible parts of text, excluding terminal escape sequences.
pub fn strip_ansi(text : String) -> String {
  let out = StringBuilder()
  for token in ansi_tokens(text) {
    if token.kind is Text {
      out.write_string(token.text)
    }
  }
  out.to_string()
}

///|
/// Trim visible whitespace while retaining the original terminal sequences.
pub fn trim_ansi_whitespace(text : String) -> String {
  let tokens = ansi_tokens(text)
  if tokens.all(token => token.kind is Text) {
    return text.trim().to_owned()
  }
  let out = StringBuilder()
  let mut pending = ""
  let mut trimmed = false
  for token in tokens {
    match token.kind {
      Text => {
        out.write_string(pending)
        pending = ""
        let part = if trimmed {
          token.text
        } else {
          token.text.trim_start().to_owned()
        }
        if !part.is_empty() {
          trimmed = true
        }
        out.write_string(part)
      }
      _ => pending += token.text
    }
  }
  out.to_string().trim_end().to_owned() + pending
}
