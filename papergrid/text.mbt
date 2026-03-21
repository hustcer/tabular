///|
pub enum WidthMode {
  None
  Wrap(Int)
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
  Wrap(width)
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
  let lines = content.split("\n").map(StringView::to_string).collect()
  if lines.is_empty() {
    [""]
  } else {
    lines
  }
}

///|
fn chunk_line(line : String, width : Int) -> Array[String] {
  if width <= 0 {
    return [""]
  }
  if line.length() <= width {
    return [line]
  }

  let parts = []
  for start = 0; start < line.length(); start = start + width {
    let end_index = if start + width < line.length() {
      start + width
    } else {
      line.length()
    }
    parts.push(line.unsafe_substring(start~, end=end_index))
  }
  parts
}

///|
pub fn apply_width(content : String, mode : WidthMode) -> Array[String] {
  let lines = split_lines(content)
  match mode {
    None => lines
    Wrap(width) => {
      let result = []
      lines.each(line => chunk_line(line, width).each(part => result.push(part)))
      if result.is_empty() {
        [""]
      } else {
        result
      }
    }
    Truncate(width, suffix) => {
      let result = []
      lines.each(line => {
        if width <= 0 {
          result.push("")
        } else if line.length() <= width {
          result.push(line)
        } else if suffix.length() >= width {
          result.push(suffix.unsafe_substring(start=0, end=width))
        } else {
          let keep = width - suffix.length()
          result.push(line.unsafe_substring(start=0, end=keep) + suffix)
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
        lines[:size].to_array()
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
