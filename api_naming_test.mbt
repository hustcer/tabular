///|
test "resize priorities use explicit first and last tie breaks" {
  let sizes = [4, 1, 1, 4]
  for
    case in [(@tabular.TieBreak::First, 1, 0), (@tabular.TieBreak::Last, 2, 3)] {
    let (tie_break, min_index, max_index) = case
    assert_eq(
      @tabular.ResizeSelector::select(
        @tabular.Priority::min(tie_break~),
        [],
        sizes,
      ),
      Some(min_index),
    )
    assert_eq(
      @tabular.ResizeSelector::select(
        @tabular.Priority::max(tie_break~),
        [],
        sizes,
      ),
      Some(max_index),
    )
  }
  // Preserve the distinct upstream defaults while naming them explicitly.
  assert_eq(
    @tabular.ResizeSelector::select(@tabular.PriorityMin::default(), [], sizes),
    Some(2),
  )
  assert_eq(
    @tabular.ResizeSelector::select(@tabular.PriorityMax::default(), [], sizes),
    Some(0),
  )
}
