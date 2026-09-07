///|
// The original snapshot scenarios use centered, per-line presentation.
// Make those choices explicit now that defaults match tabled (left/per-cell).
fn centered_table(rows : Array[Array[String]]) -> @tabular.Table {
  @tabular.Table::from_rows(rows).with_(
    (@tabular.Alignment::center(), @tabular.AlignmentStrategy::PerLine),
  )
}
