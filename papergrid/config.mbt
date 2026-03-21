///|
pub enum AlignmentHorizontal {
  Left
  Right
  Center
}

///|
pub enum AlignmentVertical {
  Top
  Bottom
  Center
}

///|
pub enum HorizontalLines {
  All
  HeaderOnly
  None
}

///|
pub struct HorizontalLine {
  main : Char?
  left : Char?
  intersection : Char?
  right : Char?
}

///|
pub fn AlignmentHorizontal::left() -> AlignmentHorizontal {
  Left
}

///|
pub fn AlignmentHorizontal::right() -> AlignmentHorizontal {
  Right
}

///|
pub fn AlignmentHorizontal::center() -> AlignmentHorizontal {
  Center
}

///|
pub fn AlignmentVertical::top() -> AlignmentVertical {
  Top
}

///|
pub fn AlignmentVertical::bottom() -> AlignmentVertical {
  Bottom
}

///|
pub fn AlignmentVertical::center() -> AlignmentVertical {
  Center
}

///|
pub fn HorizontalLines::all() -> HorizontalLines {
  All
}

///|
pub fn HorizontalLines::header_only() -> HorizontalLines {
  HeaderOnly
}

///|
pub fn HorizontalLines::none() -> HorizontalLines {
  None
}

///|
pub fn HorizontalLine::new(ch : Char) -> HorizontalLine {
  { main: Some(ch), left: None, intersection: None, right: None }
}

///|
pub fn HorizontalLine::filled(ch : Char) -> HorizontalLine {
  HorizontalLine::new(ch)
}

///|
pub fn HorizontalLine::full(
  main : Char,
  left : Char,
  intersection : Char,
  right : Char,
) -> HorizontalLine {
  {
    main: Some(main),
    left: Some(left),
    intersection: Some(intersection),
    right: Some(right),
  }
}

///|
pub fn HorizontalLine::from_chars(
  main : Char?,
  left : Char?,
  intersection : Char?,
  right : Char?,
) -> HorizontalLine {
  { main, left, intersection, right }
}

///|
pub fn HorizontalLine::with_left(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, left: Some(ch) }
}

///|
pub fn HorizontalLine::with_intersection(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, intersection: Some(ch) }
}

///|
pub fn HorizontalLine::with_right(
  self : HorizontalLine,
  ch : Char,
) -> HorizontalLine {
  { ..self, right: Some(ch) }
}

///|
pub struct SpannedConfig {
  mut borders : Borders
  mut padding_left : Int
  mut padding_right : Int
  mut padding_top : Int
  mut padding_bottom : Int
  mut alignment : AlignmentHorizontal
  mut vertical_alignment : AlignmentVertical
  mut width_mode : WidthMode
  mut height_mode : HeightMode
  mut horizontal_lines : HorizontalLines
  custom_horizontal_lines : Array[(Int, HorizontalLine)]
  alignment_rules : Array[(Int, Int, Int, AlignmentHorizontal)]
  vertical_alignment_rules : Array[(Int, Int, Int, AlignmentVertical)]
  padding_rules : Array[(Int, Int, Int, Int, Int, Int, Int)]
}

///|
pub fn SpannedConfig::default() -> SpannedConfig {
  {
    borders: Borders::ascii(),
    padding_left: 1,
    padding_right: 1,
    padding_top: 0,
    padding_bottom: 0,
    alignment: AlignmentHorizontal::center(),
    vertical_alignment: AlignmentVertical::top(),
    width_mode: WidthMode::none(),
    height_mode: HeightMode::none(),
    horizontal_lines: HorizontalLines::all(),
    custom_horizontal_lines: [],
    alignment_rules: [],
    vertical_alignment_rules: [],
    padding_rules: [],
  }
}

///|
pub fn SpannedConfig::set_borders(
  self : SpannedConfig,
  borders : Borders,
) -> Unit {
  self.borders = borders
}

///|
pub fn SpannedConfig::borders(self : SpannedConfig) -> Borders {
  self.borders
}

///|
pub fn SpannedConfig::set_padding(
  self : SpannedConfig,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_left = left
  self.padding_right = right
  self.padding_top = top
  self.padding_bottom = bottom
}

///|
pub fn SpannedConfig::padding_left(self : SpannedConfig) -> Int {
  self.padding_left
}

///|
pub fn SpannedConfig::padding_right(self : SpannedConfig) -> Int {
  self.padding_right
}

///|
pub fn SpannedConfig::padding_top(self : SpannedConfig) -> Int {
  self.padding_top
}

///|
pub fn SpannedConfig::padding_bottom(self : SpannedConfig) -> Int {
  self.padding_bottom
}

///|
pub fn SpannedConfig::set_alignment(
  self : SpannedConfig,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment = alignment
}

///|
pub fn SpannedConfig::alignment(self : SpannedConfig) -> AlignmentHorizontal {
  self.alignment
}

///|
pub fn SpannedConfig::set_vertical_alignment(
  self : SpannedConfig,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment = alignment
}

///|
pub fn SpannedConfig::vertical_alignment(
  self : SpannedConfig,
) -> AlignmentVertical {
  self.vertical_alignment
}

///|
pub fn SpannedConfig::set_width_mode(
  self : SpannedConfig,
  mode : WidthMode,
) -> Unit {
  self.width_mode = mode
}

///|
pub fn SpannedConfig::width_mode(self : SpannedConfig) -> WidthMode {
  self.width_mode
}

///|
pub fn SpannedConfig::set_height_mode(
  self : SpannedConfig,
  mode : HeightMode,
) -> Unit {
  self.height_mode = mode
}

///|
pub fn SpannedConfig::height_mode(self : SpannedConfig) -> HeightMode {
  self.height_mode
}

///|
pub fn SpannedConfig::set_horizontal_lines(
  self : SpannedConfig,
  mode : HorizontalLines,
) -> Unit {
  self.horizontal_lines = mode
}

///|
pub fn SpannedConfig::horizontal_lines(self : SpannedConfig) -> HorizontalLines {
  self.horizontal_lines
}

///|
pub fn SpannedConfig::set_custom_horizontal_lines(
  self : SpannedConfig,
  lines : Array[(Int, HorizontalLine)],
) -> Unit {
  self.custom_horizontal_lines.clear()
  lines.each(line => self.custom_horizontal_lines.push(line))
}

///|
pub fn SpannedConfig::custom_horizontal_line(
  self : SpannedConfig,
  row : Int,
) -> HorizontalLine? {
  let mut index = self.custom_horizontal_lines.length() - 1
  while index >= 0 {
    let line = self.custom_horizontal_lines[index]
    if line.0 == row {
      return Some(line.1)
    }
    index = index - 1
  }
  None
}

///|
fn scope_matches(
  kind : Int,
  start : Int,
  end : Int,
  row : Int,
  column : Int,
) -> Bool {
  if kind == 0 {
    row >= start && row < end
  } else if kind == 1 {
    column >= start && column < end
  } else if kind == 3 {
    row == start && column == end
  } else {
    true
  }
}

///|
pub fn SpannedConfig::set_alignment_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((0, start, end, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((1, start, end, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_all(
  self : SpannedConfig,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((2, 0, 0, alignment))
}

///|
pub fn SpannedConfig::set_alignment_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  alignment : AlignmentHorizontal,
) -> Unit {
  self.alignment_rules.push((3, row, column, alignment))
}

///|
pub fn SpannedConfig::alignment_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> AlignmentHorizontal {
  let mut value = self.alignment
  self.alignment_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((0, start, end, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((1, start, end, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_all(
  self : SpannedConfig,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((2, 0, 0, alignment))
}

///|
pub fn SpannedConfig::set_vertical_alignment_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  alignment : AlignmentVertical,
) -> Unit {
  self.vertical_alignment_rules.push((3, row, column, alignment))
}

///|
pub fn SpannedConfig::vertical_alignment_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> AlignmentVertical {
  let mut value = self.vertical_alignment
  self.vertical_alignment_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      value = rule.3
    }
  })
  value
}

///|
pub fn SpannedConfig::set_padding_for_rows(
  self : SpannedConfig,
  start : Int,
  end : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((0, start, end, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_columns(
  self : SpannedConfig,
  start : Int,
  end : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((1, start, end, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_all(
  self : SpannedConfig,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((2, 0, 0, left, right, top, bottom))
}

///|
pub fn SpannedConfig::set_padding_for_cell(
  self : SpannedConfig,
  row : Int,
  column : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Unit {
  self.padding_rules.push((3, row, column, left, right, top, bottom))
}

///|
pub fn SpannedConfig::padding_at(
  self : SpannedConfig,
  row : Int,
  column : Int,
) -> (Int, Int, Int, Int) {
  let mut left = self.padding_left
  let mut right = self.padding_right
  let mut top = self.padding_top
  let mut bottom = self.padding_bottom
  self.padding_rules.each(rule => {
    if scope_matches(rule.0, rule.1, rule.2, row, column) {
      left = rule.3
      right = rule.4
      top = rule.5
      bottom = rule.6
    }
  })
  (left, right, top, bottom)
}
