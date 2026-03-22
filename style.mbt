///|
pub fn Style::ascii() -> Style {
  {
    borders: @papergrid.Borders::ascii(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::modern() -> Style {
  {
    borders: @papergrid.Borders::modern(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::rounded() -> Style {
  {
    borders: @papergrid.Borders::rounded(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::empty() -> Style {
  {
    borders: @papergrid.Borders::empty(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::blank() -> Style {
  Style::empty()
}

///|
pub fn Style::extended() -> Style {
  {
    borders: @papergrid.Borders::extended(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::dots() -> Style {
  {
    borders: @papergrid.Borders::dots(),
    horizontal_lines: @papergrid.HorizontalLines::all(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::re_structured_text() -> Style {
  {
    borders: @papergrid.Borders::re_structured_text(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [
      (1, @papergrid.HorizontalLine::new('=').with_intersection(' ')),
    ],
  }
}

///|
pub fn Style::ascii_rounded() -> Style {
  {
    borders: @papergrid.Borders::ascii_rounded(),
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::markdown() -> Style {
  {
    borders: @papergrid.Borders::markdown(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::psql() -> Style {
  {
    borders: @papergrid.Borders::psql(),
    horizontal_lines: @papergrid.HorizontalLines::header_only(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::borders(self : Style) -> @papergrid.Borders {
  self.borders
}

///|
pub fn Style::horizontal_lines(self : Style) -> @papergrid.HorizontalLines {
  self.horizontal_lines
}

///|
pub fn Style::custom_horizontal_lines(
  self : Style,
) -> Array[(Int, @papergrid.HorizontalLine)] {
  self.custom_horizontal_lines
}

///|
pub fn HorizontalLine::new(ch : Char) -> HorizontalLine {
  { line: @papergrid.HorizontalLine::new(ch) }
}

///|
pub fn HorizontalLine::filled(ch : Char) -> HorizontalLine {
  HorizontalLine::new(ch)
}

///|
pub fn HorizontalLine::full(
  main : Char,
  left? : Char = main,
  intersection? : Char = main,
  right? : Char = main,
) -> HorizontalLine {
  { line: @papergrid.HorizontalLine::full(main, left, intersection, right) }
}

///|
pub fn HorizontalLine::left(self : HorizontalLine, ch : Char) -> HorizontalLine {
  { line: self.line.with_left(ch) }
}

///|
pub fn HorizontalLine::intersection(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { line: self.line.with_intersection(ch) }
}

///|
pub fn HorizontalLine::right(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { line: self.line.with_right(ch) }
}

///|
pub fn HorizontalLine::from_style(style : Style) -> HorizontalLine {
  {
    line: @papergrid.HorizontalLine::from_chars(
      style.borders.horizontal,
      style.borders.left_intersection,
      style.borders.intersection,
      style.borders.right_intersection,
    ),
  }
}

///|
pub fn Style::top(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top(ch) }
}

///|
pub fn Style::bottom(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom(ch) }
}

///|
pub fn Style::left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_left(ch) }
}

///|
pub fn Style::right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_right(ch) }
}

///|
pub fn Style::horizontal(self : Style, ch : Char) -> Style {
  {
    ..self,
    borders: self.borders.with_horizontal(ch),
    horizontal_lines: @papergrid.HorizontalLines::all(),
  }
}

///|
pub fn Style::vertical(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_vertical(ch) }
}

///|
pub fn Style::corner_top_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_left(ch) }
}

///|
pub fn Style::corner_top_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_right(ch) }
}

///|
pub fn Style::corner_bottom_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_left(ch) }
}

///|
pub fn Style::corner_bottom_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_right(ch) }
}

///|
pub fn Style::intersection_top(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_top_intersection(ch) }
}

///|
pub fn Style::intersection_bottom(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_bottom_intersection(ch) }
}

///|
pub fn Style::intersection_left(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_left_intersection(ch) }
}

///|
pub fn Style::intersection_right(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_right_intersection(ch) }
}

///|
pub fn Style::intersection(self : Style, ch : Char) -> Style {
  { ..self, borders: self.borders.with_intersection(ch) }
}

///|
pub fn Style::remove_top(self : Style) -> Style {
  { ..self, borders: self.borders.remove_top() }
}

///|
pub fn Style::remove_bottom(self : Style) -> Style {
  { ..self, borders: self.borders.remove_bottom() }
}

///|
pub fn Style::remove_left(self : Style) -> Style {
  { ..self, borders: self.borders.remove_left() }
}

///|
pub fn Style::remove_right(self : Style) -> Style {
  { ..self, borders: self.borders.remove_right() }
}

///|
pub fn Style::remove_horizontal(self : Style) -> Style {
  { ..self, horizontal_lines: @papergrid.HorizontalLines::none() }
}

///|
pub fn Style::remove_horizontals(self : Style) -> Style {
  {
    ..self,
    horizontal_lines: @papergrid.HorizontalLines::none(),
    custom_horizontal_lines: [],
  }
}

///|
pub fn Style::remove_vertical(self : Style) -> Style {
  { ..self, borders: self.borders.remove_vertical() }
}

///|
pub fn Style::horizontals(
  self : Style,
  lines : Array[(Int, HorizontalLine)],
) -> Style {
  { ..self, custom_horizontal_lines: lines.map(line => (line.0, line.1.line)) }
}
