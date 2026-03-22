///|
pub struct Style {
  borders : @papergrid.Borders
  horizontal_lines : @papergrid.HorizontalLines
  custom_horizontal_lines : Array[(Int, @papergrid.HorizontalLine)]
}

///|
pub enum Align {
  Left
  Right
  Center
}

///|
pub enum VAlign {
  Top
  Bottom
  Center
}

///|
pub enum Width {
  Wrap(Int, String)
  Truncate(Int, String)
}

///|
pub enum Height {
  Increase(Int)
  Limit(Int)
}

///|
pub enum Format {
  Surround(String, String, Bool)
  Value(String, Bool)
  Content((String) -> String, Bool)
  Positioned((String, Int, Int) -> String, Bool)
}

///|
pub struct Rows {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude : Rows?
  predicate : ((Entity) -> Bool)?
}

///|
pub struct Cols {
  start : Int
  end_ : Int
  skip_n : Int
  step_n : Int
  exclude : Cols?
  predicate : ((Entity) -> Bool)?
}

///|
pub struct Cell {
  row : Int
  col : Int
}

///|
pub struct ByColName {
  name : String
}

///|
pub enum Entity {
  Row(Int)
  Col(Int)
}

///|
pub enum SegmentKind {
  All
  Range(Int, Int, Int, Int)
  RowsOnly(Rows)
  ColsOnly(Cols)
  CellOnly(Cell)
  Cross(Rows, Cols)
  InverseRows(Rows)
  InverseCols(Cols)
  InverseCell(Cell)
  Union2(Segment, Segment)
  Diff2(Segment, Segment)
}

///|
pub struct Segment {
  kind : SegmentKind
  skip_n : Int
  step_n : Int
}

///|
pub enum Setting {
  Align(Align)
  VAlign(VAlign)
  Pad(Padding)
  W(Width)
  H(Height)
  Fmt(Format)
  SpanCol(Int)
  SpanRow(Int)
}

///|
pub struct Padding {
  left : Int
  right : Int
  top : Int
  bottom : Int
}

///|
pub struct HorizontalLine {
  line : @papergrid.HorizontalLine
}

///|
pub enum Span {}

///|
pub enum Panel {}
