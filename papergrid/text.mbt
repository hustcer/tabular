///|
pub enum WidthMode {
  None
  Wrap(Int, String)
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
  Wrap(width, ".")
}

///|
pub fn WidthMode::wrap_with(width : Int, placeholder : String) -> WidthMode {
  Wrap(width, placeholder)
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
/// Zero-width characters: combining marks, joiners, variation selectors,
/// bidi controls, etc.
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
  (code >= 0xFE20 && code <= 0xFE2F) || // Combining Half Marks
  (code >= 0x200E && code <= 0x200F) || // LTR/RTL Marks
  (code >= 0x202A && code <= 0x202E) || // Bidi control characters
  (code >= 0x2066 && code <= 0x2069) || // Bidi Isolate characters
  (code >= 0xE0100 && code <= 0xE01EF) // Variation Selectors Supplement
}

///|
/// East Asian Wide characters: CJK, Hangul, fullwidth forms, emoji, etc.
/// Based on Unicode East Asian Width property (UAX #11).
fn is_wide_char(ch : Char) -> Bool {
  let code = ch.to_int()
  // Hangul Jamo
  (code >= 0x1100 && code <= 0x115F) ||
  // Miscellaneous Technical (wide emoji)
  code == 0x231A ||
  code == 0x231B ||
  code == 0x2329 ||
  code == 0x232A ||
  (code >= 0x23E9 && code <= 0x23F3) ||
  (code >= 0x23F8 && code <= 0x23FA) ||
  // Miscellaneous Symbols (wide emoji)
  code == 0x25FD ||
  code == 0x25FE ||
  code == 0x2614 ||
  code == 0x2615 ||
  (code >= 0x2648 && code <= 0x2653) ||
  code == 0x267F ||
  code == 0x2693 ||
  code == 0x26A1 ||
  code == 0x26AA ||
  code == 0x26AB ||
  code == 0x26BD ||
  code == 0x26BE ||
  code == 0x26C4 ||
  code == 0x26C5 ||
  code == 0x26D4 ||
  code == 0x26EA ||
  code == 0x26F2 ||
  code == 0x26F3 ||
  code == 0x26F5 ||
  code == 0x26FA ||
  code == 0x26FD ||
  // Dingbats (wide emoji)
  code == 0x2702 ||
  code == 0x2705 ||
  (code >= 0x2708 && code <= 0x270D) ||
  code == 0x270F ||
  code == 0x2712 ||
  code == 0x2714 ||
  code == 0x2716 ||
  code == 0x271D ||
  code == 0x2721 ||
  code == 0x2728 ||
  code == 0x2733 ||
  code == 0x2734 ||
  code == 0x2744 ||
  code == 0x2747 ||
  code == 0x274C ||
  code == 0x274E ||
  (code >= 0x2753 && code <= 0x2755) ||
  code == 0x2757 ||
  code == 0x2763 ||
  code == 0x2764 ||
  (code >= 0x2795 && code <= 0x2797) ||
  code == 0x27A1 ||
  code == 0x27B0 ||
  code == 0x27BF ||
  // Supplemental Arrows-B
  code == 0x2934 ||
  code == 0x2935 ||
  // Misc Symbols and Arrows
  (code >= 0x2B05 && code <= 0x2B07) ||
  code == 0x2B1B ||
  code == 0x2B1C ||
  code == 0x2B50 ||
  code == 0x2B55 ||
  // CJK Radicals through CJK Unified Ideographs Extension A
  (code >= 0x2E80 && code <= 0x4DBF) ||
  // CJK Unified Ideographs and Yi (skip Yijing Hexagram Symbols 0x4DC0-0x4DFF)
  (code >= 0x4E00 && code <= 0xA4CF) ||
  // Hangul Syllables
  (code >= 0xAC00 && code <= 0xD7A3) ||
  // CJK Compatibility Ideographs
  (code >= 0xF900 && code <= 0xFAFF) ||
  // Vertical Forms and CJK Compatibility Forms
  (code >= 0xFE10 && code <= 0xFE19) ||
  (code >= 0xFE30 && code <= 0xFE6F) ||
  // Fullwidth Forms
  (code >= 0xFF00 && code <= 0xFF60) ||
  (code >= 0xFFE0 && code <= 0xFFE6) ||
  // CJK-related wide symbols
  code == 0x3030 ||
  code == 0x303D ||
  code == 0x3297 ||
  code == 0x3299 ||
  // Emoji and Supplementary Ideographic Plane
  (code >= 0x1F300 && code <= 0x1FAFF) ||
  // CJK Unified Ideographs Extension B and beyond
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
    if used + ch_width > width {
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
fn chunk_line(
  line : String,
  width : Int,
  placeholder : String,
) -> Array[String] {
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
      parts.push(take_prefix_by_width(placeholder, width))
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
    Wrap(width, placeholder) => {
      let result = []
      lines.each(line => {
        chunk_line(line, width, placeholder).each(part => result.push(part))
      })
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
