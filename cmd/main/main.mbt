///|
fn main {
  let table = @tabular.Table::from_rows([
    ["language", "year"],
    ["MoonBit", "2022"],
    ["Rust", "2010"],
  ])
  table.apply(@tabular.Style::modern()) |> ignore
  println(table.to_string())
}
