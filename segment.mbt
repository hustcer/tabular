///|
pub fn Align::left() -> Align {
  Left
}

///|
pub fn Align::right() -> Align {
  Right
}

///|
pub fn Align::center() -> Align {
  Center
}

///|
pub fn VAlign::top() -> VAlign {
  Top
}

///|
pub fn VAlign::bottom() -> VAlign {
  Bottom
}

///|
pub fn VAlign::center() -> VAlign {
  Center
}

///|
pub fn Width::wrap(width : Int) -> Width {
  Wrap(width, ".")
}

///|
pub fn Width::wrap_with(width : Int, placeholder : String) -> Width {
  Wrap(width, placeholder)
}

///|
pub fn Width::truncate(width : Int, suffix? : String = "") -> Width {
  Truncate(width, suffix)
}

///|
pub fn Height::increase(size : Int) -> Height {
  Increase(size)
}

///|
pub fn Height::limit(size : Int) -> Height {
  Limit(size)
}

///|
pub fn Format::surround(prefix : String, suffix : String) -> Format {
  Surround(prefix, suffix, false)
}

///|
pub fn Format::value(text : String) -> Format {
  Value(text, false)
}

///|
pub fn Format::content(transform : (String) -> String) -> Format {
  Content(transform, false)
}

///|
pub fn Format::positioned(transform : (String, Int, Int) -> String) -> Format {
  Positioned(transform, false)
}

///|
pub fn Format::multiline(self : Format) -> Format {
  match self {
    Surround(prefix, suffix, _) => Surround(prefix, suffix, true)
    Value(text, _) => Value(text, true)
    Content(transform, _) => Content(transform, true)
    Positioned(transform, _) => Positioned(transform, true)
  }
}

///|
pub fn Rows::new(start : Int, end_ : Int) -> Rows {
  { start, end_, skip_n: 0, step_n: 1, exclude: None, predicate: None }
}

///|
pub fn Rows::first() -> Rows {
  Rows::new(0, 1)
}

///|
pub fn Rows::one(index : Int) -> Rows {
  Rows::new(index, index + 1)
}

///|
pub fn Rows::first_offset(offset : Int) -> Rows {
  Rows::one(offset)
}

///|
pub fn Rows::last() -> Rows {
  Rows::new(-2, 0)
}

///|
pub fn Rows::last_offset(offset : Int) -> Rows {
  Rows::new(-2 - offset, 0)
}

///|
pub fn Rows::all() -> Rows {
  Rows::new(0, -1)
}

///|
pub fn Rows::intersect(self : Rows, cols : Cols) -> Segment {
  { kind: Cross(self, cols), skip_n: 0, step_n: 1 }
}

///|
pub fn Rows::and_(self : Rows, other : Rows) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Rows::and_cols(self : Rows, cols : Cols) -> Segment {
  self.as_segment().and_(cols.as_segment())
}

///|
pub fn Rows::and_cell(self : Rows, cell : Cell) -> Segment {
  self.as_segment().and_(cell.as_segment())
}

///|
pub fn Rows::as_segment(self : Rows) -> Segment {
  { kind: RowsOnly(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Rows::inverse(self : Rows) -> Segment {
  { kind: InverseRows(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Rows::not(self : Rows, other : Rows) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude: Some(other),
    predicate: self.predicate,
  }
}

///|
pub fn Rows::not_cols(self : Rows, cols : Cols) -> Segment {
  self.as_segment().not(cols.as_segment())
}

///|
pub fn Rows::not_cell(self : Rows, cell : Cell) -> Segment {
  self.as_segment().not(cell.as_segment())
}

///|
pub fn Rows::skip(self : Rows, count : Int) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: count,
    step_n: self.step_n,
    exclude: self.exclude,
    predicate: self.predicate,
  }
}

///|
pub fn Rows::step_by(self : Rows, step : Int) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: if step <= 0 {
      1
    } else {
      step
    },
    exclude: self.exclude,
    predicate: self.predicate,
  }
}

///|
pub fn Rows::filter(self : Rows, predicate : (Entity) -> Bool) -> Rows {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude: self.exclude,
    predicate: Some(predicate),
  }
}

///|
pub fn Cols::new(start : Int, end_ : Int) -> Cols {
  { start, end_, skip_n: 0, step_n: 1, exclude: None, predicate: None }
}

///|
pub fn Cols::first() -> Cols {
  Cols::new(0, 1)
}

///|
pub fn Cols::one(index : Int) -> Cols {
  Cols::new(index, index + 1)
}

///|
pub fn Cols::first_offset(offset : Int) -> Cols {
  Cols::one(offset)
}

///|
pub fn Cols::last() -> Cols {
  Cols::new(-2, 0)
}

///|
pub fn Cols::last_offset(offset : Int) -> Cols {
  Cols::new(-2 - offset, 0)
}

///|
pub fn Cols::all() -> Cols {
  Cols::new(0, -1)
}

///|
pub fn Cols::intersect(self : Cols, rows : Rows) -> Segment {
  { kind: Cross(rows, self), skip_n: 0, step_n: 1 }
}

///|
pub fn Cols::and_(self : Cols, other : Cols) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Cols::and_rows(self : Cols, rows : Rows) -> Segment {
  self.as_segment().and_(rows.as_segment())
}

///|
pub fn Cols::and_cell(self : Cols, cell : Cell) -> Segment {
  self.as_segment().and_(cell.as_segment())
}

///|
pub fn Cols::as_segment(self : Cols) -> Segment {
  { kind: ColsOnly(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Cols::inverse(self : Cols) -> Segment {
  { kind: InverseCols(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Cols::not(self : Cols, other : Cols) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude: Some(other),
    predicate: self.predicate,
  }
}

///|
pub fn Cols::not_rows(self : Cols, rows : Rows) -> Segment {
  self.as_segment().not(rows.as_segment())
}

///|
pub fn Cols::not_cell(self : Cols, cell : Cell) -> Segment {
  self.as_segment().not(cell.as_segment())
}

///|
pub fn Cols::skip(self : Cols, count : Int) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: count,
    step_n: self.step_n,
    exclude: self.exclude,
    predicate: self.predicate,
  }
}

///|
pub fn Cols::step_by(self : Cols, step : Int) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: if step <= 0 {
      1
    } else {
      step
    },
    exclude: self.exclude,
    predicate: self.predicate,
  }
}

///|
pub fn Cols::filter(self : Cols, predicate : (Entity) -> Bool) -> Cols {
  {
    start: self.start,
    end_: self.end_,
    skip_n: self.skip_n,
    step_n: self.step_n,
    exclude: self.exclude,
    predicate: Some(predicate),
  }
}

///|
pub fn Segment::all() -> Segment {
  { kind: All, skip_n: 0, step_n: 1 }
}

///|
pub fn Cell::new(row : Int, col : Int) -> Cell {
  { row, col }
}

///|
pub fn ByColName::new(name : String) -> ByColName {
  { name, }
}

///|
pub fn Cell::as_segment(self : Cell) -> Segment {
  { kind: CellOnly(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Cell::and_(self : Cell, other : Cell) -> Segment {
  self.as_segment().and_(other.as_segment())
}

///|
pub fn Cell::not(self : Cell, other : Cell) -> Segment {
  self.as_segment().not(other.as_segment())
}

///|
pub fn Cell::inverse(self : Cell) -> Segment {
  { kind: InverseCell(self), skip_n: 0, step_n: 1 }
}

///|
pub fn Segment::new(
  row_start : Int,
  row_end : Int,
  col_start : Int,
  col_end : Int,
) -> Segment {
  { kind: Range(row_start, row_end, col_start, col_end), skip_n: 0, step_n: 1 }
}

///|
pub fn Segment::and_(self : Segment, other : Segment) -> Segment {
  { kind: Union2(self, other), skip_n: 0, step_n: 1 }
}

///|
pub fn Segment::and_rows(self : Segment, rows : Rows) -> Segment {
  self.and_(rows.as_segment())
}

///|
pub fn Segment::and_cols(self : Segment, cols : Cols) -> Segment {
  self.and_(cols.as_segment())
}

///|
pub fn Segment::and_cell(self : Segment, cell : Cell) -> Segment {
  self.and_(cell.as_segment())
}

///|
pub fn Segment::not_(self : Segment, other : Segment) -> Segment {
  { kind: Diff2(self, other), skip_n: 0, step_n: 1 }
}

///|
pub fn Segment::not(self : Segment, other : Segment) -> Segment {
  self.not_(other)
}

///|
pub fn Segment::not_cell(self : Segment, cell : Cell) -> Segment {
  self.not(cell.as_segment())
}

///|
pub fn Segment::skip(self : Segment, count : Int) -> Segment {
  { ..self, skip_n: count }
}

///|
pub fn Segment::step_by(self : Segment, step : Int) -> Segment {
  { ..self, step_n: if step <= 0 { 1 } else { step } }
}

///|
pub fn Setting::align(align : Align) -> Setting {
  Align(align)
}

///|
pub fn Setting::valign(align : VAlign) -> Setting {
  VAlign(align)
}

///|
pub fn Setting::padding(padding : Padding) -> Setting {
  Pad(padding)
}

///|
pub fn Setting::format(format : Format) -> Setting {
  Fmt(format)
}

///|
pub fn Setting::width(width : Width) -> Setting {
  W(width)
}

///|
pub fn Setting::height(height : Height) -> Setting {
  H(height)
}

///|
pub fn Span::col(size : Int) -> Setting {
  SpanCol(size)
}

///|
pub fn Span::row(size : Int) -> Setting {
  SpanRow(size)
}

///|
pub fn Padding::new(
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Padding {
  { left, right, top, bottom }
}
