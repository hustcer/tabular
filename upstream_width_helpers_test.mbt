///|
fn upstream_width_strings(
  values : Array[String],
  header : String,
) -> @tabular.Table {
  @tabular.Table::from_rows([[header]] + values.map(value => [value]))
}

///|
fn upstream_width_arrays(values : Array[Array[String]]) -> @tabular.Table {
  let count = if values.is_empty() { 0 } else { values[0].length() }
  @tabular.Table::from_rows(
    [Array::makei(count, col => col.to_string())] + values,
  )
}

///|
fn upstream_assert_width(text : String, width : Int) -> Unit raise {
  for line in @papergrid.get_lines(text) {
    assert_eq(@papergrid.get_line_width(line), width)
  }
}

///|
// The field order and renamed Tabled headers match the upstream D record.
fn upstream_width_versions(colored : Bool) -> @tabular.Table {
  let rows = [
    ["version", "published_date", "is_active", "major_feature"],
    ["0.2.1", "2021-06-23", "true", "#[header(inline)] attribute"],
    ["0.2.0", "2021-06-19", "false", "API changes"],
    ["0.1.4", "2021-06-07", "false", "display_with attribute"],
  ]
  if colored {
    let red = @tabular.Color::fg_red()
    rows[1][0] = red.colorize(rows[1][0])
    rows[2][0] = red.colorize(rows[2][0])
    rows[3][0] = @tabular.Color::fg_white().colorize(rows[3][0])
    rows[1][1] = (red | @tabular.Color::bg_rgb(8, 10, 30)).colorize(rows[1][1])
    rows[2][1] = (@tabular.Color::fg_green() |
    @tabular.Color::bg_rgb(8, 100, 30)).colorize(rows[2][1])
    rows[3][1] = (red | @tabular.Color::bg_rgb(8, 10, 30)).colorize(rows[3][1])
    rows[1][3] = (@tabular.Color::fg_blue() | @tabular.Color::bg_green()).colorize(
      rows[1][3],
    )
    rows[2][3] = @tabular.Color::fg_yellow().colorize(rows[2][3])
    rows[3][3] = (red | @tabular.Color::bg_black()).colorize(rows[3][3])
  }
  @tabular.Table::from_rows(rows)
  .set_align(@tabular.Align::center())
  .apply(@tabular.Style::markdown())
}

///|
fn upstream_width_links(color_first : Bool, color_all : Bool) -> Array[String] {
  fn link(url : String, text : String) -> String {
    "\u001b]8;;" + url + "\u001b\\" + text + "\u001b]8;;\u001b\\"
  }
  let debian = "https://www.debian.org/"
  let wikipedia = "https://www.wikipedia.org/"
  let red = @tabular.Color::fg_red()
  let first = if color_first { red.colorize("Debian") } else { "Debian" }
  let other = if color_all { red.colorize("Debian") } else { "Debian" }
  let last = if color_all { red.colorize("Wiki") } else { "Debian" }
  [
    link(debian, first),
    link(debian, other) + " :link",
    "asd " +
    link(debian, other) +
    " 2 links in a string " +
    link(wikipedia, last),
  ]
}
