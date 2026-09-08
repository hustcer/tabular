///|
// The data helpers below preserve tabled/tests/settings/render_settings.rs.
// Matrix::iter supplies the header row and centers the table horizontally.
fn upstream_multiline_data1() -> @tabular.Table {
  let table = upstream_matrix(3, 3)
  table.rows[2][0] = "asd\n21213123\n\n   asdasd\n\n"
  table.rows[3][2] = "https://\nwww\n.\nredhat\n.com\n/en"
  table
}

///|
fn upstream_multiline_data2() -> @tabular.Table {
  let table = upstream_matrix(3, 3)
  table.rows[2][0] = "\n\n\nasd\n21213123   asdasd\n\n\n"
  table.rows[3][2] = "https://\nwww\n.\nredhat\n.com\n/en"
  table
}

///|
fn upstream_tab_data1() -> @tabular.Table {
  let table = upstream_matrix(3, 3)
  table.rows[2][0] = "123\t123\tasdasd"
  table.rows[3][2] = "htt\tps://\nwww\n.\nred\that\n.c\tom\n/en"
  table
}

///|
fn upstream_tab_data2() -> @tabular.Table {
  let table = upstream_tab_data1()
  table.rows[1][0] = "\tH\t\tello\tWorld"
  table
}

///|
fn upstream_colored_data() -> @tabular.Table {
  let table = upstream_multiline_data1()
  table.rows[2][0] = @tabular.Color::fg_red().colorize(table.rows[2][0])
  table.rows[3][2] = @tabular.Color::bg_blue().colorize(table.rows[3][2])
  table
}
