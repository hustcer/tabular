///|
/// Measure a line excluding terminal control sequences, including OSC links.
pub fn get_line_width(text : String) -> Int {
  string_display_width(text)
}

///|
/// Measure the widest line in a string.
pub fn get_text_width(text : String) -> Int {
  split_lines(text).fold(init=0, (width, line) => {
    Int::max(width, get_line_width(line))
  })
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
