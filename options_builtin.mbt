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
pub impl TableOption for Duplicate with fn change(self, table) {
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

///|
pub extend Align with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend Align with TableOption::{change, hint_change}

///|
pub extend VAlign with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend VAlign with TableOption::{change, hint_change}

///|
pub extend Padding with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend Padding with TableOption::{change, hint_change}

///|
pub extend Format with CellOption::{
  change as change_cell,
  hint_change as hint_change_cell,
}

///|
pub extend Format with TableOption::{change, hint_change}

///|
pub extend Style with TableOption::{change, hint_change}

///|
pub extend Rotate with TableOption::{change, hint_change}

///|
pub extend Reverse with TableOption::{change, hint_change}

///|
pub extend Concat with TableOption::{change, hint_change}

///|
pub extend Duplicate with TableOption::{change, hint_change}

///|
pub extend Highlight with TableOption::{change, hint_change}

///|
pub extend Merge with TableOption::{change, hint_change}

///|
pub extend Shadow with TableOption::{change, hint_change}

///|
pub extend PanelConfig with TableOption::{change, hint_change}

///|
pub extend Split with TableOption::{change, hint_change}
