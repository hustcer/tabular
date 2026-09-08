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
pub fn[O, M] Modify::list(object : O, option : M) -> ModifyList[O, M] {
  { object, options: option, }
}

///|
pub fn[O, M] Modify::with_(self : Modify[O], option : M) -> ModifyList[O, M] {
  Modify::list(self.object, option)
}

///|
/// Options are applied entity by entity, in the order they were appended.
pub struct ModifyList[O, M] {
  priv object : O
  priv options : M
}

///|
pub fn[O, A, B] ModifyList::with_(
  self : ModifyList[O, A],
  option : B,
) -> ModifyList[O, Settings[A, B]] {
  { object: self.object, options: Settings::new(self.options, option), }
}

///|
pub impl[O : Object, M : CellOption] TableOption for ModifyList[O, M] with fn change(
  self,
  table,
) {
  for entity in Object::entities(self.object, table) {
    CellOption::change(self.options, table, entity)
  }
}

///|
pub impl[O : Object, M : CellOption] TableOption for ModifyList[O, M] with fn hint_change(
  self,
) {
  CellOption::hint_change(self.options)
}
