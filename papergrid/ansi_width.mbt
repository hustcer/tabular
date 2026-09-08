///|
// Ported from tabled and ansi-str. See THIRD_PARTY_NOTICES.md.
// Positions are Unicode scalar counts; all cut points are character boundaries.
fn ansi_cut(text : String, lower : Int, upper : Int?) -> String {
  let state = SgrState::new()
  let out = StringBuilder()
  let mut index = 0
  for token in ansi_tokens(text) {
    match token.kind {
      Text => {
        let chars = token.text.to_array()
        let end_index = index + chars.length()
        if lower > end_index {
          index = end_index
          continue
        }
        let start = Int::max(0, lower - index)
        let end_ = match upper {
          Some(limit) if limit >= index && limit < end_index => limit - index
          _ => chars.length()
        }
        let done = end_ < chars.length()
        let part = String::from_array(chars[start:end_])
        index = end_index
        if done && index == end_ - start && !state.has_any() {
          return part
        }
        out.write_string(part)
        if done {
          break
        }
      }
      Sgr => {
        out.write_string(token.text)
        state.update(token.text)
      }
      _ => out.write_string(token.text)
    }
  }
  out.write_string(state.suffix())
  out.to_string()
}

///|
// The extraction state deliberately matches tabled, including unterminated
// OSC8 prefixes and its treatment of multiple links and BEL terminators.
fn strip_osc(text : String) -> (String, String?) {
  let out = StringBuilder()
  let mut state = 0
  let mut first : String? = None
  for token in ansi_tokens(text) {
    match token.kind {
      Osc =>
        match state {
          0 => {
            first = Some(token.text)
            state = 1
          }
          2 => state = 3
          _ => state = 4
        }
      Sgr | Csi => out.write_string(token.text)
      Esc => ()
      Text => {
        out.write_string(token.text)
        state = match state {
          1 | 2 => 2
          _ => 4
        }
      }
    }
  }
  let url = match first {
    Some(raw) if state != 4 &&
      raw.has_prefix("\u001b]8;;") &&
      raw.has_suffix("\u001b") => Some(raw[5:raw.length() - 1].to_owned())
    _ => None
  }
  (out.to_string(), url)
}

///|
fn link_boundaries(url : String?) -> (String, String) {
  match url {
    Some(url) => ("\u001b]8;;" + url + "\u001b\\", "\u001b]8;;\u001b\\")
    None => ("", "")
  }
}

///|
fn split_at_width(text : String, limit : Int) -> (Int, Int, Bool) {
  let mut length = 0
  let mut width = 0
  for ch in text {
    if width == limit {
      break
    }
    if ch == '\n' {
      width = 0
      length += 1
      continue
    }
    let size = Int::max(1, char_display_width(ch))
    if width + size > limit {
      return (length, width, true)
    }
    width += size
    length += 1
  }
  (length, width, false)
}

///|
/// Cut text at a terminal width, preserving ANSI styling and a single OSC8 link.
/// A partially fitting wide character is replaced by U+FFFD.
///
/// ```mbt check
/// test {
///   assert_eq(
///     cut_str("\u001b[31m中文\u001b[39m", 3),
///     "\u001b[31m中\u001b[39m�",
///   )
/// }
/// ```
pub fn cut_str(text : String, width : Int) -> String {
  let width = Int::max(0, width)
  let (cleaned, url) = strip_osc(text)
  let plain = strip_ansi(cleaned)
  let (length, used, partial) = split_at_width(plain, width)
  let mut result = if text.length() == plain.length() {
    String::from_array(text.to_array()[:length])
  } else {
    ansi_cut(cleaned, 0, Some(length))
  }
  if partial {
    result += String::make(width - used, '�')
  }
  let (prefix, suffix) = link_boundaries(url)
  if !prefix.is_empty() {
    result = get_lines(result).map(line => prefix + line + suffix).join("\n")
  }
  result
}

///|
/// Wrap text by visible width, closing and reopening ANSI styles per line.
/// A single OSC8 hyperlink is repeated around every resulting line.
///
/// ```mbt check
/// test {
///   assert_eq(wrap_text("ab中", 2), "ab\n中")
/// }
/// ```
pub fn wrap_text(
  text : String,
  width : Int,
  placeholder? : String = "�",
  keep_words? : Bool = false,
) -> String {
  guard width > 0 && !text.is_empty() else { return "" }
  let (cleaned, url) = strip_osc(text)
  let (line_prefix, line_suffix) = link_boundaries(url)
  if keep_words {
    return wrap_words(cleaned, width, line_prefix, line_suffix, placeholder~)
  }
  wrap_basic(cleaned, width, line_prefix, line_suffix, placeholder~)
}

///|
fn wrap_basic(
  cleaned : String,
  width : Int,
  line_prefix : String,
  line_suffix : String,
  placeholder? : String = "�",
) -> String {
  guard width > 0 && !cleaned.is_empty() else { return "" }
  let out = StringBuilder()
  let state = SgrState::new()
  let mut used = 0
  let mut pending = ""
  out.write_string(line_prefix)
  for token in ansi_tokens(cleaned) {
    match token.kind {
      Sgr => state.update(token.text)
      Text => {
        let block = pending + token.text
        pending = ""
        if block.is_empty() {
          continue
        }
        if used == width {
          out.write_char('\n')
          used = 0
        }
        let prefix = if state.has_any() { state.prefix() } else { "" }
        let suffix = if state.has_any() { state.suffix() } else { "" }
        out.write_string(prefix)
        for ch in block {
          if ch == '\n' {
            out.write_string(suffix + line_suffix + "\n" + line_prefix + prefix)
            used = 0
            continue
          }
          let size = Int::max(1, char_display_width(ch))
          if used + size <= width {
            out.write_char(ch)
            used += size
            continue
          }
          if size <= width || used == width {
            out.write_string(suffix + line_suffix + "\n" + line_prefix + prefix)
            used = 0
          }
          if size <= width {
            out.write_char(ch)
            used += size
          } else {
            let count = width - used
            for _ in 0..<count {
              out.write_string(cut_str(placeholder, 1))
            }
            used += count
          }
        }
        if used > 0 {
          out.write_string(suffix)
        }
      }
      _ => pending += token.text
    }
  }
  if used > 0 {
    out.write_string(line_suffix)
  }
  out.to_string()
}
