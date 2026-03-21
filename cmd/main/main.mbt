///|
fn main {
  let data : Array[Array[String]] = [
    ["Name", "Language", "Stars", "License"],
    ["Deno", "Rust/TS", "101k", "MIT"],
    ["Bun", "Zig/C++", "76k", "MIT"],
    ["Node.js", "C++/JS", "110k", "MIT"],
    ["MoonBit", "Rust", "1.2k", "Apache-2.0"],
  ]
  let styles : Array[(String, @tabular.Style)] = [
    ("ascii", @tabular.Style::ascii()),
    ("modern", @tabular.Style::modern()),
    ("rounded", @tabular.Style::rounded()),
    ("extended", @tabular.Style::extended()),
    ("dots", @tabular.Style::dots()),
    ("empty", @tabular.Style::empty()),
    ("blank", @tabular.Style::blank()),
    ("re_structured_text", @tabular.Style::re_structured_text()),
    ("ascii_rounded", @tabular.Style::ascii_rounded()),
    ("markdown", @tabular.Style::markdown()),
    ("psql", @tabular.Style::psql()),
  ]
  for i, entry in styles {
    let (name, style) = entry
    let table = @tabular.Table::from_rows(data)
    table.apply(style) |> ignore
    if i > 0 {
      println("")
    }
    println(
      "────────── Style: \{name} ──────────\n",
    )
    println(table.to_string())
  }
}
