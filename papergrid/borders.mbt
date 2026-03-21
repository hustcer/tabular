///|
pub struct Borders {
  top : Char?
  top_left : Char?
  top_right : Char?
  top_intersection : Char?
  bottom : Char?
  bottom_left : Char?
  bottom_right : Char?
  bottom_intersection : Char?
  horizontal : Char?
  vertical : Char?
  left : Char?
  right : Char?
  intersection : Char?
  left_intersection : Char?
  right_intersection : Char?
}

///|
pub fn Borders::empty() -> Borders {
  {
    top: None,
    top_left: None,
    top_right: None,
    top_intersection: None,
    bottom: None,
    bottom_left: None,
    bottom_right: None,
    bottom_intersection: None,
    horizontal: None,
    vertical: None,
    left: None,
    right: None,
    intersection: None,
    left_intersection: None,
    right_intersection: None,
  }
}

///|
pub fn Borders::ascii() -> Borders {
  {
    top: Some('-'),
    top_left: Some('+'),
    top_right: Some('+'),
    top_intersection: Some('+'),
    bottom: Some('-'),
    bottom_left: Some('+'),
    bottom_right: Some('+'),
    bottom_intersection: Some('+'),
    horizontal: Some('-'),
    vertical: Some('|'),
    left: Some('|'),
    right: Some('|'),
    intersection: Some('+'),
    left_intersection: Some('+'),
    right_intersection: Some('+'),
  }
}

///|
pub fn Borders::modern() -> Borders {
  {
    top: Some('─'),
    top_left: Some('┌'),
    top_right: Some('┐'),
    top_intersection: Some('┬'),
    bottom: Some('─'),
    bottom_left: Some('└'),
    bottom_right: Some('┘'),
    bottom_intersection: Some('┴'),
    horizontal: Some('─'),
    vertical: Some('│'),
    left: Some('│'),
    right: Some('│'),
    intersection: Some('┼'),
    left_intersection: Some('├'),
    right_intersection: Some('┤'),
  }
}

///|
pub fn Borders::rounded() -> Borders {
  {
    ..Borders::modern(),
    top_left: Some('╭'),
    top_right: Some('╮'),
    bottom_left: Some('╰'),
    bottom_right: Some('╯'),
  }
}

///|
pub fn Borders::markdown() -> Borders {
  {
    ..Borders::empty(),
    horizontal: Some('-'),
    vertical: Some('|'),
    left: Some('|'),
    right: Some('|'),
    intersection: Some('|'),
    left_intersection: Some('|'),
    right_intersection: Some('|'),
  }
}

///|
pub fn Borders::psql() -> Borders {
  {
    ..Borders::empty(),
    horizontal: Some('-'),
    vertical: Some('|'),
    intersection: Some('+'),
    left_intersection: Some('-'),
    right_intersection: Some('-'),
  }
}

///|
fn char_to_string(ch : Char?) -> String {
  match ch {
    Some(value) => value.to_string()
    None => ""
  }
}

///|
pub fn Borders::build_line(
  _self : Borders,
  left : Char?,
  fill : Char?,
  intersection : Char?,
  right : Char?,
  widths : Array[Int],
) -> String {
  if widths.is_empty() {
    return ""
  }

  let mut out = char_to_string(left)
  for i = 0; i < widths.length(); i = i + 1 {
    let width = widths[i]
    for j = 0; j < width; j = j + 1 {
      ignore(j)
      out = out + char_to_string(fill)
    }
    if i + 1 < widths.length() {
      out = out + char_to_string(intersection)
    }
  }
  out + char_to_string(right)
}
