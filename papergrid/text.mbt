///|
pub enum WidthMode {
  None
  Wrap(Int)
  Truncate(Int, String)
}

///|
pub enum HeightMode {
  None
  Increase(Int)
  Limit(Int)
}

///|
pub fn WidthMode::none() -> WidthMode {
  None
}

///|
pub fn WidthMode::wrap(width : Int) -> WidthMode {
  Wrap(width)
}

///|
pub fn WidthMode::truncate(width : Int, suffix : String) -> WidthMode {
  Truncate(width, suffix)
}

///|
pub fn HeightMode::none() -> HeightMode {
  None
}

///|
pub fn HeightMode::increase(size : Int) -> HeightMode {
  Increase(size)
}

///|
pub fn HeightMode::limit(size : Int) -> HeightMode {
  Limit(size)
}

///|
pub fn split_lines(content : String) -> Array[String] {
  let lines = content.split("\n").map(StringView::to_string).collect()
  if lines.is_empty() {
    [""]
  } else {
    lines
  }
}

///|
/// Zero-width characters: combining marks, joiners, variation selectors, etc.
fn is_zero_width_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code == 0x00AD || // Soft Hyphen
  code == 0x200B || // Zero Width Space
  code == 0x200C || // Zero Width Non-Joiner
  code == 0x200D || // Zero Width Joiner (Emoji ZWJ sequences)
  code == 0x2060 || // Word Joiner
  code == 0xFEFF || // BOM / Zero Width No-Break Space
  (code >= 0x0300 && code <= 0x036F) || // Combining Diacritical Marks
  (code >= 0x1AB0 && code <= 0x1AFF) || // Combining Diacritical Marks Extended
  (code >= 0x1DC0 && code <= 0x1DFF) || // Combining Diacritical Marks Supplement
  (code >= 0x20D0 && code <= 0x20FF) || // Combining Diacritical Marks for Symbols
  (code >= 0xFE00 && code <= 0xFE0F) || // Variation Selectors
  (code >= 0xFE20 && code <= 0xFE2F) // Combining Half Marks
}

///|
/// East Asian Wide characters: CJK, Hangul, fullwidth forms, emoji, etc.
/// Based on Unicode East Asian Width property (UAX #11).
fn is_wide_char(ch : Char) -> Bool {
  let code = ch.to_int()
  (code >= 0x1100 && code <= 0x115F) ||
  (code >= 0x2329 && code <= 0x232A) ||
  (code >= 0x2E80 && code <= 0xA4CF) ||
  (code >= 0xAC00 && code <= 0xD7A3) ||
  (code >= 0xF900 && code <= 0xFAFF) ||
  (code >= 0xFE10 && code <= 0xFE19) ||
  (code >= 0xFE30 && code <= 0xFE6F) ||
  (code >= 0xFF00 && code <= 0xFF60) ||
  (code >= 0xFFE0 && code <= 0xFFE6) ||
  (code >= 0x1F300 && code <= 0x1FAFF) ||
  (code >= 0x20000 && code <= 0x3FFFD)
}

///|
fn char_display_width(ch : Char) -> Int {
  if is_zero_width_char(ch) {
    0
  } else if is_wide_char(ch) {
    2
  } else {
    1
  }
}

///|
fn string_display_width(line : String) -> Int {
  let mut width = 0
  for ch in line {
    width += char_display_width(ch)
  }
  width
}

///|
fn take_prefix_by_width(line : String, width : Int) -> String {
  if width <= 0 {
    return ""
  }
  let sb = StringBuilder::new()
  let mut used = 0
  for ch in line {
    let ch_width = char_display_width(ch)
    if used + ch_width > width && used > 0 {
      break
    }
    if ch_width > width && used == 0 {
      break
    }
    sb.write_char(ch)
    used += ch_width
    if used >= width {
      break
    }
  }
  sb.to_string()
}

///|
fn chunk_line(line : String, width : Int) -> Array[String] {
  if width <= 0 {
    return [""]
  }
  if string_display_width(line) <= width {
    return [line]
  }
  let parts = []
  let mut current = StringBuilder::new()
  let mut current_width = 0
  for ch in line {
    let ch_width = char_display_width(ch)
    if current_width > 0 && current_width + ch_width > width {
      parts.push(current.to_string())
      current = StringBuilder::new()
      current_width = 0
    }
    if current_width == 0 && ch_width > width {
      parts.push(ch.to_string())
      continue
    }
    current.write_char(ch)
    current_width += ch_width
  }
  if current_width > 0 || parts.is_empty() {
    parts.push(current.to_string())
  }
  parts
}

///|
pub fn apply_width(content : String, mode : WidthMode) -> Array[String] {
  let lines = split_lines(content)
  match mode {
    None => lines
    Wrap(width) => {
      let result = []
      lines.each(line => chunk_line(line, width).each(part => result.push(part)))
      if result.is_empty() {
        [""]
      } else {
        result
      }
    }
    Truncate(width, suffix) => {
      let result = []
      let suffix_width = string_display_width(suffix)
      lines.each(line => {
        if width <= 0 {
          result.push("")
        } else if string_display_width(line) <= width {
          result.push(line)
        } else if suffix_width >= width {
          result.push(take_prefix_by_width(suffix, width))
        } else {
          let keep = width - suffix_width
          result.push(take_prefix_by_width(line, keep) + suffix)
        }
      })
      if result.is_empty() {
        [""]
      } else {
        result
      }
    }
  }
}

///|
pub fn apply_height(lines : Array[String], mode : HeightMode) -> Array[String] {
  match mode {
    None => lines
    Increase(size) => {
      let result = lines.copy()
      while result.length() < size {
        result.push("")
      }
      result
    }
    Limit(size) =>
      if size <= 0 {
        []
      } else if lines.length() <= size {
        lines
      } else {
        lines[:size].to_array()
      }
  }
}

///|
pub fn processed_lines(
  content : String,
  width_mode : WidthMode,
  height_mode : HeightMode,
) -> Array[String] {
  apply_height(apply_width(content, width_mode), height_mode)
}
