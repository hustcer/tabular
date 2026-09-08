///|
// Keep the four upstream names in the fixture adapter. Vertical flips use Reverse.
fn upstream_rotation(
  table : @tabular.Table,
  direction : String,
) -> @tabular.Table {
  match direction {
    "Left" => table.rotate(@tabular.Rotate::Left)
    "Right" => table.rotate(@tabular.Rotate::Right)
    "Top" | "Bottom" => table.reverse(@tabular.Reverse::rows(0))
    _ => abort("unknown upstream rotation")
  }
}

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
      ("Right", "Left"),
      ("Left", "Right"),
      ("Bottom", "Top"),
      ("Bottom", "Bottom"),
      ("Top", "Top"),
    ] {
    let (first, second) = pair
    assert_eq(
      upstream_rotation(upstream_rotation(table(), first), second).to_string(),
      original,
    )
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
  table.reverse(@tabular.Reverse::cols(0)) |> ignore
  assert_eq(table.rows, [["2", "1", "0"], ["5", "4", "3"], ["8", "7", "6"]])
}

///|
test "rotate rectangular and degenerate tables" {
  for rotation in ["Left", "Right", "Top", "Bottom"] {
    assert_eq(
      upstream_rotation(@tabular.Table::from_rows([]), rotation).to_string(),
      "",
    )
    assert_eq(
      upstream_rotation(@tabular.Table::from_rows([[]]), rotation).to_string(),
      "",
    )
    assert_eq(
      upstream_rotation(@tabular.Table::from_rows([["界"]]), rotation).rows,
      [["界"]],
    )
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
      @tabular.Reverse::cols(3),
      @tabular.Reverse::cols(0).take(0),
      @tabular.Reverse::rows(1).take(2),
      @tabular.Reverse::cols(0).exclude_last(3),
      @tabular.Reverse::rows(0).take(-1),
      @tabular.Reverse::cols(0).exclude_last(-1),
      @tabular.Reverse::rows(1).take(2147483647),
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
    @tabular.Duplicate::new(
      source=@tabular.Cols::new(0, 3),
      destination=@tabular.Cols::new(1, 4),
    ),
  )
  |> ignore
  // Each column is a separate destination entity and restarts at "a".
  assert_eq(table.rows, [["a", "a", "a", "a"]])
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table.duplicate(
    @tabular.Duplicate::new(
      source=@tabular.Cols::all(),
      destination=@tabular.Segment::all(),
    ),
  )
  |> ignore
  assert_eq(table.rows, [["a", "c"], ["b", "d"]])
}

///|
test "duplicate cycles separately for rows and columns" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Duplicate::new(
      source=@tabular.Rows::one(0),
      destination=@tabular.Cols::new(1, 3),
    ),
  )
  |> ignore
  assert_eq(table.rows, [["a", "a", "a"], ["d", "b", "b"]])
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Duplicate::new(
      source=@tabular.Cols::one(0),
      destination=@tabular.Rows::all(),
    ),
  )
  |> ignore
  assert_eq(table.rows, [["a", "d", "a"], ["a", "d", "a"]])
}

///|
test "duplicate rectangular segment restarts per cell" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.duplicate(
    @tabular.Duplicate::new(
      source=@tabular.Rows::one(0),
      destination=@tabular.Segment::new(0, 2, 1, 3),
    ),
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
    @tabular.Duplicate::new(
      source=CustomSelection::{ groups: [[(0, 2), (0, 1), (1, 0)]], },
      destination=CustomSelection::{
        groups: [[(-1, 0), (1, 1), (2, 0), (0, 0)]],
      },
    ),
  )
  |> ignore
  assert_eq(table.rows, [["c", "b"], ["c", "b"]])
}
