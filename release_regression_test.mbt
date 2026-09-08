///|
test "table wrapping ignores and preserves excess width cache entries" {
  let table = @tabular.Table::from_rows([["abcdef"]])
    .with_(@tabular.Width::list([8, 99]))
    .with_(@tabular.Width::wrap(6))
  assert_eq(table.rows, [["ab\ncd\nef"]])
  assert_eq(table.total_width(), 6)
  assert_eq(table.dimension_snapshot().get_widths(), Some([4, 99]))
  assert_eq(table.to_string(), "+----+\n| ab |\n| cd |\n| ef |\n+----+")
}

///|
test "table truncation selects real columns with excess width cache entries" {
  let table = @tabular.Table::from_rows([["abcdef", "ghijkl"]])
    .with_(@tabular.Width::list([8, 8, 99]))
    .with_(@tabular.Width::truncate(15).priority(@tabular.Priority::last()))
  assert_eq(table.rows, [["abcdef", "gh"]])
  assert_eq(table.total_width(), 15)
  assert_eq(table.dimension_snapshot().get_widths(), Some([8, 4, 99]))
  assert_eq(
    table.to_string(),
    "+--------+----+\n| abcdef | gh |\n+--------+----+",
  )
}

///|
test "table width growth never counts or adjusts inactive columns" {
  for tail in [0, 99] {
    let table = @tabular.Table::from_rows([["abcdef"]])
      .with_(@tabular.Width::list([8, tail]))
      .with_(@tabular.Width::increase(14).priority(@tabular.Priority::last()))
    assert_eq(table.total_width(), 14)
    assert_eq(table.dimension_snapshot().get_widths(), Some([12, tail]))
    assert_eq(table.rows, [["abcdef"]])
  }
  let table = @tabular.Table::from_rows([["abcdef"]])
    .with_(@tabular.Width::list([8, 8]))
    .with_(@tabular.Width::increase(14))
  assert_eq(table.dimension_snapshot().get_widths(), Some([12, 8]))
  table.with_(@tabular.Width::wrap(14)) |> ignore
  table.with_(@tabular.Width::truncate(14)) |> ignore
  assert_eq(table.dimension_snapshot().get_widths(), Some([12, 8]))
  assert_eq(table.rows, [["abcdef"]])
}

///|
test "dimension queries include legacy wrapping and height without caching reads" {
  let table = @tabular.Table::from_rows([["abcdef"]])
    .set_width(@tabular.Width::wrap(2))
    .set_height(@tabular.Height::increase(5))
  assert_eq(
    table.to_string(),
    "+----+\n| ab |\n| cd |\n| ef |\n|    |\n|    |\n+----+",
  )
  assert_eq((table.total_width(), table.total_height()), (6, 7))
  assert_true(table.dimension_snapshot().is_empty())
  assert_eq(table.rows, [["abcdef"]])
  table.dimension_cache().estimate(table)
  assert_eq(table.dimension_snapshot().get_widths(), Some([4]))
  assert_eq(table.dimension_snapshot().get_heights(), Some([5]))
  table.with_(@tabular.Width::increase(10)) |> ignore
  assert_eq(table.total_width(), 10)
  assert_eq(
    table.to_string(),
    "+--------+\n| ab     |\n| cd     |\n| ef     |\n|        |\n|        |\n+--------+",
  )
}

///|
test "dimension queries include scoped legacy modes and explicit cache overrides" {
  let table = @tabular.Table::from_rows([["abcdef"], ["ghijkl"]])
    .modify_cols(
      @tabular.Cols::first(),
      @tabular.Setting::width(@tabular.Width::truncate(2)),
    )
    .modify_rows(
      @tabular.Rows::first(),
      @tabular.Setting::height(@tabular.Height::increase(4)),
    )
    .modify_cell(
      @tabular.Cell::new(1, 0),
      @tabular.Setting::height(@tabular.Height::limit(0)),
    )
  assert_eq(
    table.to_string(),
    "+----+\n| ab |\n|    |\n|    |\n|    |\n+----+\n+----+",
  )
  assert_eq((table.total_width(), table.total_height()), (6, 7))
  assert_true(table.dimension_snapshot().is_empty())
  table.with_(@tabular.Width::list([8, 99])) |> ignore
  table.with_(@tabular.Height::list([1, 2, 99])) |> ignore
  assert_eq((table.total_width(), table.total_height()), (10, 6))
  assert_eq(
    table.to_string(),
    "+--------+\n| ab     |\n+--------+\n|        |\n|        |\n+--------+",
  )
  assert_eq(table.dimension_snapshot().get_widths(), Some([8, 99]))
  assert_eq(table.dimension_snapshot().get_heights(), Some([1, 2, 99]))
}
