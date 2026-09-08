///|
pub enum WidthMode {
  None
  Wrap(Int, String)
  Truncate(Int, String)
}

///|
pub enum HeightMode {
  None
  Increase(Int)
  Limit(Int)
}

///|
pub fn WidthMode::none() -> WidthMode {
  None
}

///|
pub fn WidthMode::wrap(width : Int) -> WidthMode {
  Wrap(width, "�")
}

///|
pub fn WidthMode::wrap_with(width : Int, placeholder : String) -> WidthMode {
  Wrap(width, placeholder)
}

///|
pub fn WidthMode::truncate(width : Int, suffix : String) -> WidthMode {
  Truncate(width, suffix)
}

///|
pub fn HeightMode::none() -> HeightMode {
  None
}

///|
pub fn HeightMode::increase(size : Int) -> HeightMode {
  Increase(size)
}

///|
pub fn HeightMode::limit(size : Int) -> HeightMode {
  Limit(size)
}

///|
pub fn split_lines(content : String) -> Array[String] {
  let lines = content.split("\n").map(StringView::to_owned).collect()
  if lines.is_empty() {
    [""]
  } else {
    lines
  }
}

///|
fn char_display_width(ch : Char) -> Int {
  get_char_width(ch)
}

///|
fn string_display_width(line : String) -> Int {
  let mut width = 0
  for token in ansi_tokens(line) {
    if token.kind is Text {
      width += get_string_width(token.text)
    }
  }
  width
}

///|
fn take_prefix_by_width(line : String, width : Int) -> String {
  cut_str(line, width)
}

///|
fn wrap_lines(
  content : String,
  width : Int,
  placeholder : String,
) -> Array[String] {
  if width <= 0 {
    return [""]
  }
  if get_text_width(content) <= width {
    return get_lines(content)
  }
  get_lines(wrap_text(content, width, placeholder~))
}

///|
pub fn apply_width(content : String, mode : WidthMode) -> Array[String] {
  let lines = get_lines(content)
  match mode {
    None => lines
    Wrap(width, placeholder) => wrap_lines(content, width, placeholder)
    Truncate(width, suffix) => {
      let result = []
      let suffix_width = string_display_width(suffix)
      lines.each(line => {
        if width <= 0 {
          result.push("")
        } else if string_display_width(line) <= width {
          result.push(line)
        } else if suffix_width >= width {
          result.push(take_prefix_by_width(suffix, width))
        } else {
          let keep = width - suffix_width
          result.push(take_prefix_by_width(line, keep) + suffix)
        }
      })
      if result.is_empty() {
        [""]
      } else {
        result
      }
    }
  }
}

///|
pub fn apply_height(lines : Array[String], mode : HeightMode) -> Array[String] {
  match mode {
    None => lines
    Increase(size) => {
      let result = lines.copy()
      while result.length() < size {
        result.push("")
      }
      result
    }
    Limit(size) =>
      if size <= 0 {
        []
      } else if lines.length() <= size {
        lines
      } else {
        lines[:size].to_owned()
      }
  }
}

///|
pub fn processed_lines(
  content : String,
  width_mode : WidthMode,
  height_mode : HeightMode,
) -> Array[String] {
  apply_height(apply_width(content, width_mode), height_mode)
}
