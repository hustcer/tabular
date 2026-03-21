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
pub fn Borders::extended() -> Borders {
  {
    top: Some('═'),
    top_left: Some('╔'),
    top_right: Some('╗'),
    top_intersection: Some('╦'),
    bottom: Some('═'),
    bottom_left: Some('╚'),
    bottom_right: Some('╝'),
    bottom_intersection: Some('╩'),
    horizontal: Some('═'),
    vertical: Some('║'),
    left: Some('║'),
    right: Some('║'),
    intersection: Some('╬'),
    left_intersection: Some('╠'),
    right_intersection: Some('╣'),
  }
}

///|
pub fn Borders::dots() -> Borders {
  {
    top: Some('.'),
    top_left: None,
    top_right: None,
    top_intersection: Some('.'),
    bottom: Some('.'),
    bottom_left: None,
    bottom_right: None,
    bottom_intersection: Some('.'),
    horizontal: Some('.'),
    vertical: Some(':'),
    left: Some(':'),
    right: Some(':'),
    intersection: Some(':'),
    left_intersection: Some(':'),
    right_intersection: Some(':'),
  }
}

///|
pub fn Borders::re_structured_text() -> Borders {
  {
    top: Some('='),
    top_left: None,
    top_right: None,
    top_intersection: Some(' '),
    bottom: Some('='),
    bottom_left: None,
    bottom_right: None,
    bottom_intersection: Some(' '),
    horizontal: None,
    vertical: Some(' '),
    left: None,
    right: None,
    intersection: Some(' '),
    left_intersection: None,
    right_intersection: None,
  }
}

///|
pub fn Borders::ascii_rounded() -> Borders {
  {
    ..Borders::empty(),
    top: Some('-'),
    top_left: Some('.'),
    top_right: Some('.'),
    bottom: Some('-'),
    bottom_left: Some('\''),
    bottom_right: Some('\''),
    vertical: Some('|'),
    left: Some('|'),
    right: Some('|'),
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
fn first_char(chars : Array[Char?]) -> Char? {
  for index = 0; index < chars.length(); index = index + 1 {
    match chars[index] {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
pub fn Borders::with_top(self : Borders, ch : Char) -> Borders {
  { ..self, top: Some(ch) }
}

///|
pub fn Borders::with_bottom(self : Borders, ch : Char) -> Borders {
  { ..self, bottom: Some(ch) }
}

///|
pub fn Borders::with_left(self : Borders, ch : Char) -> Borders {
  { ..self, left: Some(ch), top_left: Some(ch), bottom_left: Some(ch) }
}

///|
pub fn Borders::with_right(self : Borders, ch : Char) -> Borders {
  { ..self, right: Some(ch), top_right: Some(ch), bottom_right: Some(ch) }
}

///|
pub fn Borders::with_horizontal(self : Borders, ch : Char) -> Borders {
  {
    ..self,
    horizontal: Some(ch),
    left_intersection: Some(ch),
    right_intersection: Some(ch),
    intersection: Some(ch),
  }
}

///|
pub fn Borders::with_vertical(self : Borders, ch : Char) -> Borders {
  {
    ..self,
    vertical: Some(ch),
    top_intersection: Some(ch),
    bottom_intersection: Some(ch),
    intersection: Some(ch),
  }
}

///|
pub fn Borders::with_top_left(self : Borders, ch : Char) -> Borders {
  { ..self, top_left: Some(ch) }
}

///|
pub fn Borders::with_top_right(self : Borders, ch : Char) -> Borders {
  { ..self, top_right: Some(ch) }
}

///|
pub fn Borders::with_bottom_left(self : Borders, ch : Char) -> Borders {
  { ..self, bottom_left: Some(ch) }
}

///|
pub fn Borders::with_bottom_right(self : Borders, ch : Char) -> Borders {
  { ..self, bottom_right: Some(ch) }
}

///|
pub fn Borders::with_top_intersection(self : Borders, ch : Char) -> Borders {
  { ..self, top_intersection: Some(ch) }
}

///|
pub fn Borders::with_bottom_intersection(self : Borders, ch : Char) -> Borders {
  { ..self, bottom_intersection: Some(ch) }
}

///|
pub fn Borders::with_left_intersection(self : Borders, ch : Char) -> Borders {
  { ..self, left_intersection: Some(ch) }
}

///|
pub fn Borders::with_right_intersection(self : Borders, ch : Char) -> Borders {
  { ..self, right_intersection: Some(ch) }
}

///|
pub fn Borders::with_intersection(self : Borders, ch : Char) -> Borders {
  { ..self, intersection: Some(ch) }
}

///|
pub fn Borders::remove_top(self : Borders) -> Borders {
  { ..self, top: None, top_left: None, top_right: None, top_intersection: None }
}

///|
pub fn Borders::remove_bottom(self : Borders) -> Borders {
  {
    ..self,
    bottom: None,
    bottom_left: None,
    bottom_right: None,
    bottom_intersection: None,
  }
}

///|
pub fn Borders::remove_left(self : Borders) -> Borders {
  { ..self, left: None, top_left: None, bottom_left: None }
}

///|
pub fn Borders::remove_right(self : Borders) -> Borders {
  { ..self, right: None, top_right: None, bottom_right: None }
}

///|
pub fn Borders::remove_vertical(self : Borders) -> Borders {
  {
    ..self,
    vertical: None,
    top_intersection: None,
    bottom_intersection: None,
    intersection: None,
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
