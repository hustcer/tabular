///|
/// Select an object for deferred cell configuration.
pub struct Modify[O] {
  priv object : O
}

///|
pub fn[O] Modify::new(object : O) -> Modify[O] {
  { object, }
}

///|
pub fn[O, M] Modify::with_(self : Modify[O], option : M) -> CellSettings[O, M] {
  { object: self.object, options: option, }
}

///|
/// Options are applied entity by entity, in the order they were appended.
pub struct CellSettings[O, M] {
  priv object : O
  priv options : M
}

///|
pub fn[O, A, B] CellSettings::with_(
  self : CellSettings[O, A],
  option : B,
) -> CellSettings[O, Settings[A, B]] {
  { object: self.object, options: Settings::new(self.options, option), }
}

///|
pub impl[O : Object, M : CellOption] TableOption for CellSettings[O, M] with fn change(
  self,
  table,
) {
  for entity in Object::entities(self.object, table) {
    CellOption::change(self.options, table, entity)
  }
}

///|
pub impl[O : Object, M : CellOption] TableOption for CellSettings[O, M] with fn hint_change(
  self,
) {
  CellOption::hint_change(self.options)
}
