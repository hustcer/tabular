///|
test "style exposes borders" {
  let style = Style::modern()
  inspect(style.borders().top_left, content="Some('┌')")
}
