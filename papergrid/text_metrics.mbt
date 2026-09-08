///|
/// Measure a line excluding terminal control sequences, including OSC links.
pub fn get_line_width(text : String) -> Int {
  string_display_width(text)
}

///|
/// Measure the widest line in a string.
pub fn get_text_width(text : String) -> Int {
  let lines = split_lines(text)
  let mut width = 0
  for index, line in lines {
    // Rust's str::lines removes one CR only when it precedes a newline.
    let line = if line.has_suffix("\r") && index + 1 < lines.length() {
      line[:line.length() - 1].to_owned()
    } else {
      line
    }
    width = Int::max(width, get_line_width(line))
  }
  width
}

///|
/// Return the number of logical lines and the maximum visible line width.
pub fn get_text_dimension(text : String) -> (Int, Int) {
  let lines = get_lines(text)
  (
    lines.length(),
    lines.fold(init=0, (width, line) => Int::max(width, get_line_width(line))),
  )
}

///|
pub fn count_lines(text : String) -> Int {
  text
  .iter()
  .fold(init=1, (count, ch) => if ch == '\n' { count + 1 } else { count })
}

///|
pub fn count_tabs(text : String) -> Int {
  text
  .iter()
  .fold(init=0, (count, ch) => if ch == '\t' { count + 1 } else { count })
}

///|
/// Replace literal tabs with spaces. The upstream four-space fast path replaces
/// every tab; other sizes preserve a tab immediately preceded by a backslash.
pub fn replace_tab(text : String, size : Int) -> String {
  let fill = String::make(Int::max(0, size), ' ')
  let out = StringBuilder()
  let mut escaped = false
  for ch in text {
    if ch == '\t' && (size == 4 || !escaped) {
      out.write_string(fill)
    } else {
      out.write_char(ch)
    }
    escaped = ch == '\\'
  }
  out.to_string()
}
