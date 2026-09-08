///|
/// Appends one record. Use `Builder::push_record` instead.
#deprecated("Use Builder::push_record instead")
pub fn Builder::extend_(self : Builder, row : Array[String]) -> Unit {
  self.push_record(row)
}
