///|
// Rust reference: Style::empty(), Margin::new(0, 0, 1, 1).fill('x', 'x', 'x', 'x').
test "borderless margins use terminal width for CJK and ANSI content" {
  for
    pair in [
      ("中", "xxxx\n 中 \nxxxx"),
      ("\u001b[31mx\u001b[39m", "xxx\n \u001b[31mx\u001b[39m \nxxx"),
    ] {
    let (input, expected) = pair
    let table = @tabular.Table::from_rows([[input]])
      .apply(@tabular.Style::empty())
      .with_(@tabular.Margin::new(0, 0, 1, 1).fill('x', 'x', 'x', 'x'))
    assert_eq(table.to_string(), expected)
  }
}
