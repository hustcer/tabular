///|
/// An option that leaves records and configuration unchanged.
pub struct EmptySettings {}

///|
pub fn EmptySettings::default() -> EmptySettings {
  EmptySettings::{ }
}

///|
pub impl TableOption for EmptySettings with fn change(_self, _table) {
  ()
}

///|
pub impl CellOption for EmptySettings with fn change(_self, _table, _entity) {
  ()
}

///|
/// Compose options while preserving their application order.
pub struct Settings[A, B] {
  priv first : A
  priv second : B
}

///|
pub fn Settings::default() -> Settings[EmptySettings, EmptySettings] {
  { first: EmptySettings::default(), second: EmptySettings::default(), }
}

///|
pub fn Settings::empty() -> Settings[EmptySettings, EmptySettings] {
  Settings::default()
}

///|
pub fn[A, B] Settings::new(first : A, second : B) -> Settings[A, B] {
  { first, second, }
}

///|
pub fn[A, B, C] Settings::with_(
  self : Settings[A, B],
  option : C,
) -> Settings[Settings[A, B], C] {
  Settings::new(self, option)
}

///|
/// Append a modification of a selected object to this configuration chain.
pub fn[A, B, O, M] Settings::modify(
  self : Settings[A, B],
  object : O,
  option : M,
) -> Settings[Settings[A, B], ModifyList[O, M]] {
  self.with_(Modify::list(object, option))
}

///|
pub impl[A : TableOption, B : TableOption] TableOption for Settings[A, B] with fn change(
  self,
  table,
) {
  TableOption::change(self.first, table)
  TableOption::change(self.second, table)
}

///|
pub impl[A : CellOption, B : CellOption] CellOption for Settings[A, B] with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.first, table, entity)
  CellOption::change(self.second, table, entity)
}

///|
pub impl[A : TableOption, B : TableOption] TableOption for Settings[A, B] with fn hint_change(
  self,
) {
  combine_hints([
    TableOption::hint_change(self.first),
    TableOption::hint_change(self.second),
  ])
}

///|
pub impl[A : CellOption, B : CellOption] CellOption for Settings[A, B] with fn hint_change(
  self,
) {
  combine_hints([
    CellOption::hint_change(self.first),
    CellOption::hint_change(self.second),
  ])
}
