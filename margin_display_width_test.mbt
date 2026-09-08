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
      .with_(
        @tabular.Margin::new(left=0, right=0, top=1, bottom=1).fill(
          left='x',
          right='x',
          top='x',
          bottom='x',
        ),
      )
    assert_eq(table.to_string(), expected)
  }
}
