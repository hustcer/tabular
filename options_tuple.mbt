// Tuple combinators mirror tabled's implementations for arities 2 through 10.

///|
pub impl[T0 : TableOption, T1 : TableOption] TableOption for (T0, T1) with fn change(
  self,
  table,
) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
}

///|
pub impl[T0 : TableOption, T1 : TableOption] TableOption for (T0, T1) with fn hint_change(
  self,
) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
  ])
}

///|
pub impl[T0 : CellOption, T1 : CellOption] CellOption for (T0, T1) with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
}

///|
pub impl[T0 : CellOption, T1 : CellOption] CellOption for (T0, T1) with fn hint_change(
  self,
) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
  ])
}

///|
pub impl[T0 : TableOption, T1 : TableOption, T2 : TableOption] TableOption for (
  T0,
  T1,
  T2,
) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
}

///|
pub impl[T0 : TableOption, T1 : TableOption, T2 : TableOption] TableOption for (
  T0,
  T1,
  T2,
) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
  ])
}

///|
pub impl[T0 : CellOption, T1 : CellOption, T2 : CellOption] CellOption for (
  T0,
  T1,
  T2,
) with fn change(self, table, entity) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
}

///|
pub impl[T0 : CellOption, T1 : CellOption, T2 : CellOption] CellOption for (
  T0,
  T1,
  T2,
) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
  ])
}

///|
pub impl[T0 : TableOption, T1 : TableOption, T2 : TableOption, T3 : TableOption] TableOption for (
  T0,
  T1,
  T2,
  T3,
) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
}

///|
pub impl[T0 : TableOption, T1 : TableOption, T2 : TableOption, T3 : TableOption] TableOption for (
  T0,
  T1,
  T2,
  T3,
) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
  ])
}

///|
pub impl[T0 : CellOption, T1 : CellOption, T2 : CellOption, T3 : CellOption] CellOption for (
  T0,
  T1,
  T2,
  T3,
) with fn change(self, table, entity) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
}

///|
pub impl[T0 : CellOption, T1 : CellOption, T2 : CellOption, T3 : CellOption] CellOption for (
  T0,
  T1,
  T2,
  T3,
) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
] TableOption for (T0, T1, T2, T3, T4) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
] TableOption for (T0, T1, T2, T3, T4) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
] CellOption for (T0, T1, T2, T3, T4) with fn change(self, table, entity) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
] CellOption for (T0, T1, T2, T3, T4) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
  TableOption::change(self.5, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
    TableOption::hint_change(self.5),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5) with fn change(self, table, entity) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
  CellOption::change(self.5, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
    CellOption::hint_change(self.5),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
  TableOption::change(self.5, table)
  TableOption::change(self.6, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
    TableOption::hint_change(self.5),
    TableOption::hint_change(self.6),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6) with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
  CellOption::change(self.5, table, entity)
  CellOption::change(self.6, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
    CellOption::hint_change(self.5),
    CellOption::hint_change(self.6),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7) with fn change(self, table) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
  TableOption::change(self.5, table)
  TableOption::change(self.6, table)
  TableOption::change(self.7, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
    TableOption::hint_change(self.5),
    TableOption::hint_change(self.6),
    TableOption::hint_change(self.7),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7) with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
  CellOption::change(self.5, table, entity)
  CellOption::change(self.6, table, entity)
  CellOption::change(self.7, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
    CellOption::hint_change(self.5),
    CellOption::hint_change(self.6),
    CellOption::hint_change(self.7),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
  T8 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8) with fn change(
  self,
  table,
) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
  TableOption::change(self.5, table)
  TableOption::change(self.6, table)
  TableOption::change(self.7, table)
  TableOption::change(self.8, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
  T8 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8) with fn hint_change(self) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
    TableOption::hint_change(self.5),
    TableOption::hint_change(self.6),
    TableOption::hint_change(self.7),
    TableOption::hint_change(self.8),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
  T8 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8) with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
  CellOption::change(self.5, table, entity)
  CellOption::change(self.6, table, entity)
  CellOption::change(self.7, table, entity)
  CellOption::change(self.8, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
  T8 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8) with fn hint_change(self) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
    CellOption::hint_change(self.5),
    CellOption::hint_change(self.6),
    CellOption::hint_change(self.7),
    CellOption::hint_change(self.8),
  ])
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
  T8 : TableOption,
  T9 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) with fn change(
  self,
  table,
) {
  TableOption::change(self.0, table)
  TableOption::change(self.1, table)
  TableOption::change(self.2, table)
  TableOption::change(self.3, table)
  TableOption::change(self.4, table)
  TableOption::change(self.5, table)
  TableOption::change(self.6, table)
  TableOption::change(self.7, table)
  TableOption::change(self.8, table)
  TableOption::change(self.9, table)
}

///|
pub impl[
  T0 : TableOption,
  T1 : TableOption,
  T2 : TableOption,
  T3 : TableOption,
  T4 : TableOption,
  T5 : TableOption,
  T6 : TableOption,
  T7 : TableOption,
  T8 : TableOption,
  T9 : TableOption,
] TableOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) with fn hint_change(
  self,
) {
  combine_hints([
    TableOption::hint_change(self.0),
    TableOption::hint_change(self.1),
    TableOption::hint_change(self.2),
    TableOption::hint_change(self.3),
    TableOption::hint_change(self.4),
    TableOption::hint_change(self.5),
    TableOption::hint_change(self.6),
    TableOption::hint_change(self.7),
    TableOption::hint_change(self.8),
    TableOption::hint_change(self.9),
  ])
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
  T8 : CellOption,
  T9 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) with fn change(
  self,
  table,
  entity,
) {
  CellOption::change(self.0, table, entity)
  CellOption::change(self.1, table, entity)
  CellOption::change(self.2, table, entity)
  CellOption::change(self.3, table, entity)
  CellOption::change(self.4, table, entity)
  CellOption::change(self.5, table, entity)
  CellOption::change(self.6, table, entity)
  CellOption::change(self.7, table, entity)
  CellOption::change(self.8, table, entity)
  CellOption::change(self.9, table, entity)
}

///|
pub impl[
  T0 : CellOption,
  T1 : CellOption,
  T2 : CellOption,
  T3 : CellOption,
  T4 : CellOption,
  T5 : CellOption,
  T6 : CellOption,
  T7 : CellOption,
  T8 : CellOption,
  T9 : CellOption,
] CellOption for (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) with fn hint_change(
  self,
) {
  combine_hints([
    CellOption::hint_change(self.0),
    CellOption::hint_change(self.1),
    CellOption::hint_change(self.2),
    CellOption::hint_change(self.3),
    CellOption::hint_change(self.4),
    CellOption::hint_change(self.5),
    CellOption::hint_change(self.6),
    CellOption::hint_change(self.7),
    CellOption::hint_change(self.8),
    CellOption::hint_change(self.9),
  ])
}
