///|
test "settings combine table and object options" {
  let config = @tabular.Settings::default()
    .with_(@tabular.Style::psql())
    .with_(@tabular.Alignment::left())
    .modify(@tabular.Rows::first(), @tabular.Alignment::right())
  let table = upstream_matrix(1, 1).with_(config)
  assert_eq(table.to_string(), " N | column 0 \n---+----------\n 0 | 0-0      ")
  let other = upstream_matrix(1, 1).with_(config)
  assert_eq(other.to_string(), table.to_string())
}

///|
test "modify runs all options on each entity before advancing" {
  let seen : Array[String] = []
  let first = @tabular.Format::positioned((text, row, col) => {
    seen.push("first:\{row}:\{col}")
    text + "!"
  })
  let second = @tabular.Format::positioned((text, row, col) => {
    seen.push("second:\{row}:\{col}")
    text + "?"
  })
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table.with_(
    @tabular.Modify::new(@tabular.Rows::all()).with_(first).with_(second),
  )
  |> ignore
  assert_eq(table.rows, [["a!?", "b!?"], ["c!?", "d!?"]])
  assert_eq(seen, [
    "first:0:0", "first:0:1", "second:0:0", "second:0:1", "first:1:0", "first:1:1",
    "second:1:0", "second:1:1",
  ])
}

///|
test "settings support both table and cell traits" {
  let option = @tabular.Settings::new(
    @tabular.Format::value("x"),
    @tabular.Format::surround("[", "]"),
  )
  let table = @tabular.Table::from_rows([["a", "b"]])
  table.modify(@tabular.Cell::new(0, 0), option) |> ignore
  assert_eq(table.rows, [["[x]", "b"]])
  table.with_(option) |> ignore
  assert_eq(table.rows, [["[x]", "[x]"]])
}

///|
test "settings empty and extension leave existing branches reusable" {
  let root = @tabular.Settings::empty()
  let first = root.with_(@tabular.Rotate::Left)
  let second = root.with_(@tabular.Rotate::Right)
  assert_eq(@tabular.Table::from_rows([["a", "b"]]).with_(root).rows, [
    ["a", "b"],
  ])
  assert_eq(@tabular.Table::from_rows([["a", "b"]]).with_(first).rows, [
    ["b"],
    ["a"],
  ])
  assert_eq(@tabular.Table::from_rows([["a", "b"]]).with_(second).rows, [
    ["a"],
    ["b"],
  ])
}

///|
test "table and cell options accept tuples and arrays" {
  let table = @tabular.Table::from_rows([["a", "b"]])
  table.with_((@tabular.Rotate::Left, @tabular.Rotate::Right)) |> ignore
  assert_eq(table.rows, [["a", "b"]])
  table.modify(
    @tabular.Rows::first(),
    ("x", @tabular.Format::surround("[", "]")),
  )
  |> ignore
  assert_eq(table.rows, [["[x]", "[x]"]])
  table.with_([@tabular.Rotate::Left, @tabular.Rotate::Left]) |> ignore
  assert_eq(table.rows, [["[x]", "[x]"]])
  table.modify(@tabular.Cols::first(), ["1", "2"]) |> ignore
  assert_eq(table.rows, [["2", "[x]"]])
}

///|
test "global options override earlier cell configuration" {
  let table = @tabular.Table::from_rows([["head", "x"], ["a", "long"]])
  table.modify(@tabular.Cell::new(1, 0), @tabular.Alignment::right()) |> ignore
  table.with_(@tabular.Alignment::left()) |> ignore
  assert_eq(
    table.to_string(),
    "+------+------+\n| head | x    |\n+------+------+\n| a    | long |\n+------+------+",
  )
}

///|
priv struct RecordEntity {
  calls : Array[@tabular.Entity]
}

///|
impl @tabular.CellOption for RecordEntity with fn change(self, _table, entity) {
  self.calls.push(entity)
}

///|
test "custom cell options receive original object scopes" {
  let calls = []
  let recorder = RecordEntity::{ calls, }
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table
  .modify(@tabular.Segment::all(), recorder)
  .modify(@tabular.Rows::all(), recorder)
  .modify(@tabular.Cols::first(), recorder)
  .modify(@tabular.Cell::new(1, 1), recorder)
  |> ignore
  assert_eq(calls, [
    @tabular.Entity::Global,
    @tabular.Entity::Row(0),
    @tabular.Entity::Row(1),
    @tabular.Entity::Col(0),
    @tabular.Entity::Cell(1, 1),
  ])
}

///|
priv struct AppendRow {
  text : String
}

///|
impl @tabular.TableOption for AppendRow with fn change(self, table) {
  table.rows.push([self.text])
}

///|
test "custom table options participate in settings" {
  let config = @tabular.Settings::new(AppendRow::{ text: "a", }, AppendRow::{
    text: "b",
  })
  assert_eq(@tabular.Table::from_rows([]).with_(config).rows, [["a"], ["b"]])
}

///|
priv struct HintOption {
  hint : @tabular.Entity?
}

///|
impl @tabular.TableOption for HintOption with fn change(_self, _table) {
  ()
}

///|
impl @tabular.TableOption for HintOption with fn hint_change(self) {
  self.hint
}

///|
test "settings and tuples combine layout hints like upstream" {
  let none = HintOption::{ hint: None, }
  let row = HintOption::{ hint: Some(@tabular.Entity::Row(1)), }
  let col = HintOption::{ hint: Some(@tabular.Entity::Col(2)), }
  let cell = HintOption::{ hint: Some(@tabular.Entity::Cell(1, 2)), }
  assert_eq(@tabular.TableOption::hint_change((none, none)), None)
  assert_eq(@tabular.TableOption::hint_change((row, cell, none)), row.hint)
  assert_eq(@tabular.TableOption::hint_change((none, cell, col)), col.hint)
  assert_eq(
    @tabular.TableOption::hint_change(@tabular.Settings::new(row, col)),
    Some(@tabular.Entity::Global),
  )
  assert_eq(@tabular.TableOption::hint_change((cell, cell)), cell.hint)
  assert_eq(
    @tabular.TableOption::hint_change(
      @tabular.Modify::new(@tabular.Rows::all()).with_(
        @tabular.Alignment::left(),
      ),
    ),
    Some(@tabular.Entity::Global),
  )
  assert_eq(@tabular.TableOption::hint_change(@tabular.Alignment::left()), None)
  assert_eq(
    @tabular.CellOption::hint_change(@tabular.Alignment::left()),
    Some(@tabular.Entity::Global),
  )
  assert_eq(
    @tabular.TableOption::hint_change([none, none]),
    Some(@tabular.Entity::Global),
  )
  assert_eq(
    @tabular.TableOption::hint_change(@tabular.Settings::empty()),
    Some(@tabular.Entity::Global),
  )
}

///|
test "alignment converts between horizontal and vertical settings" {
  assert_true(
    @tabular.Alignment::from_horizontal(@tabular.Align::left()).as_horizontal()
    is Some(@tabular.Align::Left),
  )
  assert_true(
    @tabular.Alignment::from_vertical(@tabular.VAlign::bottom()).as_vertical()
    is Some(@tabular.VAlign::Bottom),
  )
  assert_true(@tabular.Alignment::top().as_horizontal() is None)
  assert_true(@tabular.Alignment::right().as_vertical() is None)
}

///|
test "table shape and empty queries include ragged rows" {
  assert_eq(@tabular.Table::from_rows([]).shape(), (0, 0))
  assert_true(@tabular.Table::from_rows([[]]).is_empty())
  let table = @tabular.Table::from_rows([["a"], ["b", "c"]])
  assert_eq(table.shape(), (2, 2))
  assert_eq(table.count_rows(), 2)
  assert_eq(table.count_cols(), 2)
  assert_false(table.is_empty())
}

///|
test "entity iteration is bounded and row-major" {
  assert_eq(@tabular.Entity::Global.iter(2, 2).to_array(), [
    (0, 0),
    (0, 1),
    (1, 0),
    (1, 1),
  ])
  assert_eq(@tabular.Entity::Col(1).iter(3, 2).to_array(), [
    (0, 1),
    (1, 1),
    (2, 1),
  ])
  assert_eq(@tabular.Entity::Col(1).iter(3, 2).to_array(), [
    (0, 1),
    (1, 1),
    (2, 1),
  ])
  assert_eq(@tabular.Entity::Row(-1).iter(3, 2).to_array(), [])
  assert_eq(@tabular.Entity::Cell(3, 0).iter(3, 2).to_array(), [])
  assert_eq(
    @tabular.Entity::Global.iter(2147483647, 2147483647).take(3).to_array(),
    [(0, 0), (0, 1), (0, 2)],
  )
}
