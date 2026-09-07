///|
test "table defaults use left alignment and preserve multiline blocks" {
  let table = @tabular.Table::from_rows([["12345"], ["ab\nc"]])
  assert_eq(
    table.to_string(),
    "+-------+\n| 12345 |\n+-------+\n| ab    |\n| c     |\n+-------+",
  )
  table.with_(@tabular.Alignment::right()) |> ignore
  assert_eq(
    table.to_string(),
    "+-------+\n| 12345 |\n+-------+\n|    ab |\n|    c  |\n+-------+",
  )
  table.with_(@tabular.AlignmentStrategy::PerLine) |> ignore
  assert_eq(
    table.to_string(),
    "+-------+\n| 12345 |\n+-------+\n|    ab |\n|     c |\n+-------+",
  )
  table.with_(@tabular.AlignmentStrategy::PerCell) |> ignore
  assert_eq(
    table.to_string(),
    "+-------+\n| 12345 |\n+-------+\n|    ab |\n|    c  |\n+-------+",
  )
}

///|
test "trim axes accumulate and reset without changing records or dimensions" {
  let table = @tabular.Table::from_rows([["\n  x \n\n", "other"]])
  let original = table.to_string()
  let records = table.rows.map(row => row.copy())
  table.with_(
    (@tabular.TrimStrategy::Vertical, @tabular.TrimStrategy::Horizontal),
  )
  |> ignore
  assert_eq(
    table.config.get_formatting(0, 0),
    @papergrid.Formatting::new(true, true, false),
  )
  assert_eq(table.rows, records)
  let trimmed = table.to_string()
  assert_eq(
    @papergrid.split_lines(trimmed).length(),
    @papergrid.split_lines(original).length(),
  )
  assert_eq(
    @papergrid.split_lines(trimmed)[0],
    @papergrid.split_lines(original)[0],
  )
  assert_true(trimmed != original)
  table.with_(@tabular.TrimStrategy::None) |> ignore
  assert_eq(table.to_string(), original)
}

///|
test "format strategies preserve independent fields and selected scopes" {
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table
  .with_(@tabular.AlignmentStrategy::PerLine)
  .modify(@tabular.Cols::first(), @tabular.TrimStrategy::Horizontal)
  .modify(@tabular.Rows::one(1), @tabular.TrimStrategy::Vertical)
  .modify(@tabular.Cell::new(1, 0), @tabular.TrimStrategy::None)
  |> ignore
  assert_eq(
    table.config.get_formatting(0, 0),
    @papergrid.Formatting::new(true, false, true),
  )
  assert_eq(
    table.config.get_formatting(0, 1),
    @papergrid.Formatting::new(false, false, true),
  )
  assert_eq(
    table.config.get_formatting(1, 0),
    @papergrid.Formatting::new(false, false, true),
  )
  assert_eq(
    table.config.get_formatting(1, 1),
    @papergrid.Formatting::new(false, true, true),
  )
  table.with_(@tabular.TrimStrategy::Both) |> ignore
  assert_eq(
    table.config.get_formatting(1, 0),
    @papergrid.Formatting::new(true, true, true),
  )
}

///|
test "uncolored justification clears previous fill color" {
  let table = @tabular.Table::from_rows([["wide"], ["x"]])
  table.with_(@tabular.Justification::colored('.', @tabular.Color::bg_red()))
  |> ignore
  assert_eq(
    table.to_string(),
    "+------+\n| wide |\n+------+\n| x\u001b[41m...\u001b[49m |\n+------+",
  )
  table.with_(@tabular.Justification::new('#')) |> ignore
  assert_eq(
    table.to_string(),
    "+------+\n| wide |\n+------+\n| x### |\n+------+",
  )
  table.with_(@tabular.Justification::default()) |> ignore
  assert_eq(
    table.to_string(),
    "+------+\n| wide |\n+------+\n| x    |\n+------+",
  )
}

///|
test "charset cleaning respects selection tab size and control boundaries" {
  let table = @tabular.Table::from_rows([["\u0000a\tb\r\n界\u007f", "x\ty"]])
  let original = table.rows.map(row => row.copy())
  table.with_(@tabular.Charset::default()) |> ignore
  assert_eq(table.rows, original)
  table.modify(
    @tabular.Cols::first(),
    @tabular.Charset::new().tab_size(2).clean(),
  )
  |> ignore
  assert_eq(table.rows, [["a  b\n界\u007f", "x\ty"]])
  table.with_(@tabular.Charset::new().tab_size(0)) |> ignore
  assert_eq(table.rows, [["a  b\n界\u007f", "xy"]])
  assert_eq(@tabular.Charset::charset_clean("a\tb\r\n\u001bc"), "a    b\nc")
}

///|
test "formatting scopes follow extracted and removed records" {
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"], ["e", "f"]])
  table
  .modify(@tabular.Rows::one(1), @tabular.TrimStrategy::Vertical)
  .modify(@tabular.Cols::one(1), @tabular.AlignmentStrategy::PerLine)
  .modify(@tabular.Cell::new(1, 1), @tabular.Color::fg_red())
  .modify(@tabular.Rows::one(2), @tabular.Justification::new('#'))
  .extract_cols(@tabular.Cols::one(1))
  .remove_rows(@tabular.Rows::first())
  |> ignore
  assert_eq(table.rows, [["d"], ["f"]])
  assert_eq(
    table.config.get_formatting(0, 0),
    @papergrid.Formatting::new(false, true, true),
  )
  assert_eq(
    table.config.get_color(0, 0),
    Some(@tabular.Color::fg_red().to_ansi_buf()),
  )
  assert_eq(table.config.get_color(1, 0), None)
  assert_eq(table.config.get_justification(1, 0), '#')
}

///|
test "rendering option layout hints match each upstream trait" {
  let global = Some(@tabular.Entity::Global)
  assert_eq(
    @tabular.TableOption::hint_change(@tabular.TrimStrategy::Both),
    None,
  )
  assert_eq(
    @tabular.CellOption::hint_change(@tabular.TrimStrategy::Both),
    global,
  )
  assert_eq(
    @tabular.TableOption::hint_change(@tabular.AlignmentStrategy::PerCell),
    None,
  )
  assert_eq(
    @tabular.CellOption::hint_change(@tabular.AlignmentStrategy::PerCell),
    global,
  )
  assert_eq(@tabular.TableOption::hint_change(@tabular.Charset::new()), global)
  assert_eq(@tabular.CellOption::hint_change(@tabular.Charset::new()), global)
  assert_eq(
    @tabular.CellOption::hint_change(@tabular.Justification::default()),
    None,
  )
  assert_eq(@tabular.CellOption::hint_change(@tabular.Color::default()), None)
}
