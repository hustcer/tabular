///|
/// Set all four padding sizes and fill characters for the selected entity.
pub fn SpannedConfig::set_padding_sides(
  self : SpannedConfig,
  entity : Entity,
  padding : Sides[Indent],
) -> Unit {
  let scope = entity_scope(entity)
  self.padding_rules.push(
    (
      scope,
      padding.left.size,
      padding.right.size,
      padding.top.size,
      padding.bottom.size,
    ),
  )
  self.padding_fills.push((scope, padding.map(indent => indent.fill)))
}

///|
pub fn SpannedConfig::get_padding(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Sides[Indent] {
  let (left, right, top, bottom) = self.padding_at(row, col)
  let fills = self.padding_fill_at(row, col)
  Sides::new(
    left=Indent::new(left, fills.left),
    right=Indent::new(right, fills.right),
    top=Indent::new(top, fills.top),
    bottom=Indent::new(bottom, fills.bottom),
  )
}

///|
fn SpannedConfig::padding_fill_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Sides[Char] {
  let mut fills = Sides::filled(' ')
  for rule in self.padding_fills {
    if scope_matches(rule.0, row, col) {
      fills = rule.1
    }
  }
  fills
}

///|
pub fn SpannedConfig::set_padding_color(
  self : SpannedConfig,
  entity : Entity,
  colors : Sides[ANSIBuf?],
) -> Unit {
  self.padding_colors.push((entity_scope(entity), colors))
}

///|
pub fn SpannedConfig::get_padding_color(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Sides[ANSIBuf?] {
  let mut colors : Sides[ANSIBuf?] = Sides::filled(None)
  for rule in self.padding_colors {
    if scope_matches(rule.0, row, col) {
      colors = rule.1
    }
  }
  colors
}

///|
pub fn SpannedConfig::set_margin_color(
  self : SpannedConfig,
  colors : Sides[ANSIBuf?],
) -> Unit {
  self.margin_colors = colors
}

///|
pub fn SpannedConfig::get_margin_color(self : SpannedConfig) -> Sides[ANSIBuf?] {
  self.margin_colors
}

///|
pub fn SpannedConfig::set_margin_sides(
  self : SpannedConfig,
  margin : Sides[Indent],
) -> Unit {
  self.set_margin(
    margin.top.size,
    margin.bottom.size,
    margin.left.size,
    margin.right.size,
    margin.top.fill,
    margin.bottom.fill,
    margin.left.fill,
    margin.right.fill,
  )
}

///|
pub fn SpannedConfig::get_margin(self : SpannedConfig) -> Sides[Indent] {
  Sides::new(
    left=Indent::new(self.margin_left, self.margin_fill_left),
    right=Indent::new(self.margin_right, self.margin_fill_right),
    top=Indent::new(self.margin_top, self.margin_fill_top),
    bottom=Indent::new(self.margin_bottom, self.margin_fill_bottom),
  )
}

///|
pub fn SpannedConfig::set_margin_offsets(
  self : SpannedConfig,
  offsets : Sides[Offset],
) -> Unit {
  self.set_margin_offset(
    offsets.top.signed(),
    offsets.bottom.signed(),
    offsets.left.signed(),
    offsets.right.signed(),
  )
  self.margin_offsets = offsets
}

///|
pub fn SpannedConfig::get_margin_offsets(self : SpannedConfig) -> Sides[Offset] {
  self.margin_offsets
}

///|
fn[T] remap_side_rules(
  rules : Array[(Scope, T)],
  row_map : Array[Int],
  col_map : Array[Int],
) -> Unit {
  let mapped = []
  for rule in rules {
    match rule.0 {
      RowRange(start, end_) =>
        mapped_runs(row_map, start, end_).each(run => {
          mapped.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end_) =>
        mapped_runs(col_map, start, end_).each(run => {
          mapped.push((ColRange(run.0, run.1), rule.1))
        })
      All => mapped.push(rule)
      Cell(row, col) => {
        let row = map_index(row_map, row)
        let col = map_index(col_map, col)
        if row >= 0 && col >= 0 {
          mapped.push((Cell(row, col), rule.1))
        }
      }
    }
  }
  rules.clear()
  mapped.each(rule => rules.push(rule))
}
