// Existing settings participate in the common option traits.

///|
pub impl CellOption for Align with fn change(self, table, entity) {
  CellOption::change(Setting::align(self), table, entity)
}

///|
pub impl TableOption for Align with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for Align with fn hint_change(_self) {
  None
}

///|
pub impl CellOption for VAlign with fn change(self, table, entity) {
  CellOption::change(Setting::valign(self), table, entity)
}

///|
pub impl TableOption for VAlign with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for VAlign with fn hint_change(_self) {
  None
}

///|
pub impl CellOption for Padding with fn change(self, table, entity) {
  CellOption::change(Setting::padding(self), table, entity)
}

///|
pub impl TableOption for Padding with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl CellOption for Format with fn change(self, table, entity) {
  CellOption::change(Setting::format(self), table, entity)
}

///|
pub impl TableOption for Format with fn change(self, table) {
  CellOption::change(self, table, Entity::Global)
}

///|
pub impl TableOption for Style with fn change(self, table) {
  table.option_depth += 1
  table.apply(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Rotate with fn change(self, table) {
  table.option_depth += 1
  table.rotate(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Reverse with fn change(self, table) {
  table.option_depth += 1
  table.reverse(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Concat with fn change(self, table) {
  table.option_depth += 1
  table.concat(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Dup with fn change(self, table) {
  table.option_depth += 1
  table.duplicate(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Highlight with fn change(self, table) {
  table.option_depth += 1
  table.highlight(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Merge with fn change(self, table) {
  table.option_depth += 1
  table.merge(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Shadow with fn change(self, table) {
  table.option_depth += 1
  table.shadow(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for PanelConfig with fn change(self, table) {
  table.option_depth += 1
  table.panel(self) |> ignore
  table.option_depth -= 1
}

///|
pub impl TableOption for Split with fn change(self, table) {
  table.option_depth += 1
  table.split(self) |> ignore
  table.option_depth -= 1
}
