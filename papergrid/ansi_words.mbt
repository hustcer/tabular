///|
// Ported from tabled and ansi-str. See THIRD_PARTY_NOTICES.md.
priv struct StyledBlock {
  text : Array[Char]
  prefix : String
  suffix : String
}

///|
fn styled_blocks(text : String) -> Array[StyledBlock] {
  let blocks = []
  let state = SgrState::new()
  let mut pending = ""
  for token in ansi_tokens(text) {
    match token.kind {
      Sgr => state.update(token.text)
      Text => {
        blocks.push({
          text: (pending + token.text).to_array(),
          prefix: if state.has_any() {
            state.prefix()
          } else {
            ""
          },
          suffix: if state.has_any() {
            state.suffix()
          } else {
            ""
          },
        })
        pending = ""
      }
      _ => pending += token.text
    }
  }
  blocks
}

///|
/// Apply the style of the final ANSI text block to an appended suffix.
pub fn colorize_suffix(text : String, suffix : String) -> String {
  match styled_blocks(text).last() {
    Some(block) => block.prefix + suffix + block.suffix
    None => suffix
  }
}

///|
priv struct WordBlocks {
  blocks : Array[StyledBlock]
  mut index : Int
  mut position : Int
}

///|
fn WordBlocks::take(
  self : WordBlocks,
  out : StringBuilder,
  count : Int,
  skip : Bool,
) -> Unit {
  let mut remaining = count
  while remaining > 0 && self.index < self.blocks.length() {
    let block = self.blocks[self.index]
    let available = block.text.length() - self.position
    let amount = Int::min(remaining, available)
    let started = self.position > 0
    if !started && (!skip || remaining < available) {
      out.write_string(block.prefix)
    }
    if !skip {
      out.write_string(
        String::from_array(block.text[self.position:self.position + amount]),
      )
    }
    remaining -= amount
    self.position += amount
    if self.position == block.text.length() {
      if started || !skip {
        out.write_string(block.suffix)
      }
      self.index += 1
      self.position = 0
    }
  }
}

///|
fn WordBlocks::break_line(
  self : WordBlocks,
  out : StringBuilder,
  prefix : String,
  suffix : String,
) -> Unit {
  let block = if self.position > 0 { self.blocks.get(self.index) } else { None }
  if block is Some(block) {
    out.write_string(block.suffix)
  }
  out.write_string(suffix + "\n" + prefix)
  if block is Some(block) {
    out.write_string(block.prefix)
  }
}

///|
fn wrap_words(
  text : String,
  width : Int,
  prefix : String,
  suffix : String,
  placeholder? : String = "�",
) -> String {
  guard width > 0 && !text.is_empty() else { return "" }
  let plain = strip_ansi(text)
  if plain.length() == text.length() && prefix.is_empty() && suffix.is_empty() {
    return wrap_words_plain(text, width, placeholder)
  }
  let cursor = { blocks: styled_blocks(text), index: 0, position: 0, }
  let out = StringBuilder()
  out.write_string(prefix)
  let mut used = 0
  for index, word in plain.split(" ").to_array() {
    if index > 0 {
      if used >= width {
        cursor.break_line(out, prefix, suffix)
        used = 0
      }
      cursor.take(out, 1, false)
      used += 1
    }
    let size = get_string_width(word.to_owned())
    let chars = word.to_owned().to_array()
    if size == 0 {
      if !chars.is_empty() {
        cursor.take(out, chars.length(), true)
      }
      continue
    }
    if used + size <= width {
      cursor.take(out, chars.length(), false)
      used += size
      continue
    }
    if size <= width {
      cursor.break_line(out, prefix, suffix)
      cursor.take(out, chars.length(), false)
      used = size
      continue
    }
    for ch in chars {
      let size = Int::max(1, get_char_width(ch))
      if used + size <= width {
        cursor.take(out, 1, false)
        used += size
      } else if size <= width {
        cursor.break_line(out, prefix, suffix)
        cursor.take(out, 1, false)
        used = size
      } else {
        if used == width {
          cursor.break_line(out, prefix, suffix)
          used = 0
        }
        for _ in used..<width {
          out.write_string(cut_str(placeholder, 1))
        }
        used = width
        cursor.take(out, 1, true)
      }
    }
  }
  out.write_string(suffix)
  out.to_string()
}

///|
fn wrap_words_plain(text : String, width : Int, replacement : String) -> String {
  let out = StringBuilder()
  let mut used = 0
  for index, word in text.split(" ").to_array() {
    if index > 0 {
      if used >= width {
        out.write_char('\n')
        used = 0
      }
      out.write_char(' ')
      used += 1
    }
    let size = get_string_width(word.to_owned())
    if used + size <= width {
      out.write_string(word.to_owned())
      used += size
      continue
    }
    if size <= width {
      out.write_char('\n')
      out.write_string(word.to_owned())
      used = size
      continue
    }
    for ch in word {
      let size = Int::max(1, get_char_width(ch))
      if used + size > width {
        if size > width {
          if used == width {
            out.write_char('\n')
            used = 0
          }
          for _ in used..<width {
            out.write_string(cut_str(replacement, 1))
          }
          used = width
          continue
        }
        out.write_char('\n')
        used = 0
      }
      out.write_char(ch)
      used += size
    }
  }
  out.to_string()
}
