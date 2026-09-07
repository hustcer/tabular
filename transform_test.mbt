///|
// Upstream: tabled/tests/settings/rotate_test.rs::test_rotate
test "upstream rotate test_rotate" {
  let table = () => upstream_int_table([[123, 456, 789], [234, 567, 891]])
  let original = table().to_string()
  assert_eq(
    table()
    .rotate(@tabular.Rotate::Left)
    .rotate(@tabular.Rotate::Left)
    .rotate(@tabular.Rotate::Left)
    .rotate(@tabular.Rotate::Left)
    .to_string(),
    original,
  )
  assert_eq(
    table()
    .rotate(@tabular.Rotate::Right)
    .rotate(@tabular.Rotate::Right)
    .rotate(@tabular.Rotate::Right)
    .rotate(@tabular.Rotate::Right)
    .to_string(),
    original,
  )
  for
    pair in [
      (@tabular.Rotate::Right, @tabular.Rotate::Left),
      (@tabular.Rotate::Left, @tabular.Rotate::Right),
      (@tabular.Rotate::Bottom, @tabular.Rotate::Top),
      (@tabular.Rotate::Bottom, @tabular.Rotate::Bottom),
      (@tabular.Rotate::Top, @tabular.Rotate::Top),
    ] {
    let (first, second) = pair
    assert_eq(table().rotate(first).rotate(second).to_string(), original)
  }
}

///|
// Upstream: tabled/src/settings/reverse/mod.rs::tests::test_reverse_rows
test "upstream reverse test_reverse_rows" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["3", "4", "5"],
    ["6", "7", "8"],
  ])
  table.reverse(@tabular.Reverse::rows(0)) |> ignore
  assert_eq(table.rows, [["6", "7", "8"], ["3", "4", "5"], ["0", "1", "2"]])
}

///|
// Upstream: tabled/src/settings/reverse/mod.rs::tests::test_reverse_columns
test "upstream reverse test_reverse_columns" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["3", "4", "5"],
    ["6", "7", "8"],
  ])
  table.reverse(@tabular.Reverse::columns(0)) |> ignore
  assert_eq(table.rows, [["2", "1", "0"], ["5", "4", "3"], ["8", "7", "6"]])
}

///|
test "rotate rectangular and degenerate tables" {
  for
    rotation in [
      @tabular.Rotate::Left,
      @tabular.Rotate::Right,
      @tabular.Rotate::Top,
      @tabular.Rotate::Bottom,
    ] {
    assert_eq(@tabular.Table::from_rows([]).rotate(rotation).to_string(), "")
    assert_eq(@tabular.Table::from_rows([[]]).rotate(rotation).to_string(), "")
    assert_eq(@tabular.Table::from_rows([["界"]]).rotate(rotation).rows, [
      ["界"],
    ])
  }
  for row_count in 1..<=5 {
    for col_count in 1..<=5 {
      let rows = Array::makei(row_count, row => {
        Array::makei(col_count, col => "\{row}:\{col}")
      })
      let table = @tabular.Table::from_rows(rows)
      table.rotate(@tabular.Rotate::Left).rotate(@tabular.Rotate::Right)
      |> ignore
      assert_eq(table.rows, rows)
      for _ in 0..<4 {
        table.rotate(@tabular.Rotate::Right) |> ignore
      }
      assert_eq(table.rows, rows)
    }
  }
}

///|
test "reverse invalid ranges do not change records" {
  let make_table = () => @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  let original = make_table().to_string()
  for
    reverse in [
      @tabular.Reverse::rows(-1),
      @tabular.Reverse::rows(2),
      @tabular.Reverse::columns(3),
      @tabular.Reverse::columns(0).limit(@tabular.Offset::Start(0)),
      @tabular.Reverse::rows(1).limit(@tabular.Offset::Start(2)),
      @tabular.Reverse::columns(0).limit(@tabular.Offset::End(3)),
      @tabular.Reverse::rows(0).limit(@tabular.Offset::Start(-1)),
      @tabular.Reverse::columns(0).limit(@tabular.Offset::End(-1)),
      @tabular.Reverse::rows(1).limit(@tabular.Offset::Start(2147483647)),
    ] {
    assert_eq(make_table().reverse(reverse).to_string(), original)
  }
}

///|
test "concat empty tables and ragged records" {
  let lhs = @tabular.Table::from_rows([])
  let rhs = @tabular.Table::from_rows([["a", "b"], ["c"]])
  lhs.concat(@tabular.Concat::horizontal(rhs)) |> ignore
  assert_eq(lhs.rows, [["a", "b"], ["c", ""]])
  assert_eq(rhs.rows, [["a", "b"], ["c"]])
  lhs.concat(@tabular.Concat::vertical(@tabular.Table::from_rows([]))) |> ignore
  assert_eq(lhs.rows, [["a", "b"], ["c", ""]])
}

///|
test "concat default cell follows upstream asymmetric expansion" {
  let horizontal = @tabular.Table::from_rows([["a"], ["b"]])
  horizontal.concat(
    @tabular.Concat::horizontal(@tabular.Table::from_rows([["c"]])).default_cell(
      "?",
    ),
  )
  |> ignore
  assert_eq(horizontal.rows, [["a", "c"], ["b", ""]])
  let vertical = @tabular.Table::from_rows([["a", "b"]])
  vertical.concat(
    @tabular.Concat::vertical(@tabular.Table::from_rows([["c"]])).default_cell(
      "?",
    ),
  )
  |> ignore
  assert_eq(vertical.rows, [["a", "b"], ["c", ""]])
}

///|
test "concat with self snapshots both sides" {
  let table = @tabular.Table::from_rows([["a"], ["b"]])
  table.concat(@tabular.Concat::horizontal(table)) |> ignore
  assert_eq(table.rows, [["a", "a"], ["b", "b"]])
  table.rows[0][0] = "changed"
  assert_eq(table.rows[0][1], "a")
}

///|
test "duplicate overlapping source is collected before mutation" {
  let table = @tabular.Table::from_rows([["a", "b", "c", "d"]])
  table.duplicate(
    @tabular.Dup::new(@tabular.Cols::new(1, 4), @tabular.Cols::new(0, 3)),
  )
  |> ignore
  // Each column is a separate destination entity and restarts at "a".
  assert_eq(table.rows, [["a", "a", "a", "a"]])
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table.duplicate(
    @tabular.Dup::new(@tabular.Segment::all(), @tabular.Cols::all()),
  )
  |> ignore
  assert_eq(table.rows, [["a", "c"], ["b", "d"]])
}

///|
test "duplicate cycles separately for rows and columns" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Dup::new(@tabular.Cols::new(1, 3), @tabular.Rows::one(0)),
  )
  |> ignore
  assert_eq(table.rows, [["a", "a", "a"], ["d", "b", "b"]])
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Dup::new(@tabular.Rows::all(), @tabular.Cols::one(0)),
  )
  |> ignore
  assert_eq(table.rows, [["a", "d", "a"], ["a", "d", "a"]])
}

///|
test "duplicate rectangular segment restarts per cell" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Dup::new(@tabular.Segment::new(0, 2, 1, 3), @tabular.Rows::one(0)),
  )
  |> ignore
  assert_eq(table.rows, [["a", "a", "a"], ["d", "a", "a"]])
}

///|
priv struct CustomSelection {
  groups : Array[Array[(Int, Int)]]
}

///|
impl @tabular.Object for CustomSelection with fn cells(self, _table) {
  self.groups
}

///|
test "duplicate accepts custom objects and validates cell bounds" {
  let table = @tabular.Table::from_rows([["a", "b"], ["c"]])
  table.duplicate(
    @tabular.Dup::new(
      CustomSelection::{ groups: [[(-1, 0), (1, 1), (2, 0), (0, 0)]], },
      CustomSelection::{ groups: [[(0, 2), (0, 1), (1, 0)]], },
    ),
  )
  |> ignore
  assert_eq(table.rows, [["c", "b"], ["c", "b"]])
}
