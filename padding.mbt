// Padding expansion follows tabled; see THIRD_PARTY_NOTICES.md.

///|
pub using @papergrid {type Indent, type Sides}

///|
/// Choose the fill character independently for each side of a cell.
///
/// ```mbt check
/// test {
///   let table = Table::from_rows([["x"]]).with_(
///     Padding::new(1, 1, 1, 1).fill('>', '<', '^', 'v'),
///   )
///   assert_eq(table.to_string(), "+---+\n|^^^|\n|>x<|\n|vvv|\n+---+")
/// }
/// ```
pub fn Padding::fill(
  self : Padding,
  left : Char,
  right : Char,
  top : Char,
  bottom : Char,
) -> Padding {
  { ..self, fills: Sides::new(left, right, top, bottom), }
}

///|
pub fn Padding::to_sides(self : Padding) -> Sides[Indent] {
  Sides::new(
    Indent::new(self.left, self.fills.left),
    Indent::new(self.right, self.fills.right),
    Indent::new(self.top, self.fills.top),
    Indent::new(self.bottom, self.fills.bottom),
  )
}

///|
pub fn Padding::from_sides(sides : Sides[Indent]) -> Padding {
  Padding::new(
    sides.left.size,
    sides.right.size,
    sides.top.size,
    sides.bottom.size,
  ).fill(sides.left.fill, sides.right.fill, sides.top.fill, sides.bottom.fill)
}

///|
pub fn Margin::to_sides(self : Margin) -> Sides[Indent] {
  Sides::new(
    Indent::new(self.left, self.fill_left),
    Indent::new(self.right, self.fill_right),
    Indent::new(self.top, self.fill_top),
    Indent::new(self.bottom, self.fill_bottom),
  )
}

///|
pub fn Margin::from_sides(sides : Sides[Indent]) -> Margin {
  Margin::new(
    sides.left.size,
    sides.right.size,
    sides.top.size,
    sides.bottom.size,
  ).fill(sides.left.fill, sides.right.fill, sides.top.fill, sides.bottom.fill)
}

///|
pub(all) enum PaddingExpand {
  Horizontal
  Vertical
} derive(Eq, Compare, Debug)

///|
pub fn Padding::expand(horizontal : Bool) -> PaddingExpand {
  if horizontal {
    Horizontal
  } else {
    Vertical
  }
}

///|
pub impl CellOption for PaddingExpand with fn change(self, table, entity) {
  let records = @papergrid.IterRecords::new(table.rows)
  let dimensions = match self {
    Horizontal => @papergrid.IterGridDimension::width(records, table.config)
    Vertical => @papergrid.IterGridDimension::height(records, table.config)
  }
  for position in entity.iter(table.count_rows(), table.count_columns()) {
    let (row, col) = position
    let text = records.get_cell(row, col)
    let (size, total) = match self {
      Horizontal => (@papergrid.get_text_dimension(text).1, dimensions[col])
      Vertical => (@papergrid.count_lines(text), dimensions[row])
    }
    if size >= total {
      continue
    }
    let space = total - size
    let pad = table.config.get_padding(row, col)
    let pad = match self {
      Horizontal => {
        let (left, right) = match table.config.align_at(row, col) {
          Left => (0, space)
          Right => (space, 0)
          Center => (space / 2, space - space / 2)
        }
        {
          ..pad,
          left: { ..pad.left, size: left, },
          right: { ..pad.right, size: right, },
        }
      }
      Vertical => {
        let (top, bottom) = match table.config.valign_at(row, col) {
          Top => (0, space)
          Bottom => (space, 0)
          Center => (space / 2, space - space / 2)
        }
        {
          ..pad,
          top: { ..pad.top, size: top, },
          bottom: { ..pad.bottom, size: bottom, },
        }
      }
    }
    table.config.set_padding_sides(Entity::Cell(row, col), pad)
  }
}

///|
pub impl TableOption for PaddingExpand with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}
