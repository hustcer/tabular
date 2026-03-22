///|
fn main {
  let data : Array[Array[String]] = [
    ["Name", "Language", "Stars", "License"],
    ["Deno", "Rust/TS", "101k", "MIT"],
    ["Bun", "Zig/C++", "76k", "MIT"],
    ["Node.js", "C++/JS", "110k", "MIT"],
    ["MoonBit", "Rust", "1.2k", "Apache-2.0"],
  ]

  // 1. Style presets
  println("== Style Presets ==\n")
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
    println("--- Style: \{name} ---\n")
    println(table.to_string())
  }

  // 2. Builder usage
  println("\n== Builder ==\n")
  let builder = @tabular.Builder::default()
  builder.push_record(["Language", "Type", "Year"])
  builder.push_record(["Rust", "Compiled", "2010"])
  builder.push_record(["MoonBit", "Compiled", "2022"])
  builder.push_record(["Python", "Interpreted", "1991"])
  let table = builder.build()
  table.apply(@tabular.Style::rounded()) |> ignore
  println(table.to_string())

  // 3. Align and padding
  println("\n== Align & Padding ==\n")
  let table = @tabular.Table::from_rows(data)
  table.apply(@tabular.Style::modern()) |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table.modify_cols(
    @tabular.Cols::last(),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::padding(@tabular.Padding::new(2, 2, 0, 0)),
  )
  |> ignore
  println(table.to_string())

  // 4. Format
  println("\n== Format ==\n")
  let table = @tabular.Table::from_rows([
    ["name", "value"],
    ["pi", "3.14"],
    ["e", "2.72"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::format(@tabular.Format::content(fn(v) { v.to_upper() })),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::all().skip(1),
    @tabular.Setting::format(@tabular.Format::surround("[", "]")),
  )
  |> ignore
  println(table.to_string())

  // 5. Panel
  println("\n== Panel ==\n")
  let table = @tabular.Table::from_rows(data)
  table.apply(@tabular.Style::modern()) |> ignore
  table.panel(@tabular.Panel::header("JavaScript Runtime Comparison")) |> ignore
  println(table.to_string())

  // 6. Shadow
  println("\n== Shadow ==\n")
  let table = @tabular.Table::from_rows([["A", "B"], ["1", "2"], ["3", "4"]])
  table.apply(@tabular.Style::rounded()) |> ignore
  let shadow = @tabular.Shadow::new(1)
  table.shadow(shadow) |> ignore
  println(table.to_string())

  // 7. Extract
  println("\n== Extract ==\n")
  let table = @tabular.Table::from_rows(data)
  table.apply(@tabular.Style::modern()) |> ignore
  table.extract_cols(@tabular.Cols::new(0, 2)) |> ignore
  println(table.to_string())

  // 8. Merge
  println("\n== Merge ==\n")
  let table = @tabular.Table::from_rows([
    ["name", "type", "type"],
    ["Rust", "compiled", "compiled"],
    ["Python", "interpreted", "dynamic"],
  ])
  table.apply(@tabular.Style::modern()) |> ignore
  table.merge(@tabular.Merge::horizontal()) |> ignore
  println(table.to_string())

  // 9. Split
  println("\n== Split ==\n")
  let table = @tabular.Table::from_rows([
    ["A", "B", "C", "D"],
    ["1", "2", "3", "4"],
    ["5", "6", "7", "8"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::col(2)) |> ignore
  println(table.to_string())
}
