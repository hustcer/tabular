///|
/// Select the next column or row to resize. Returning None stops resizing.
///
/// ```mbt check
/// test {
///   let priority = Priority::none()
///   let values = [5, 0, 2]
///   assert_eq(Peaker::peak(priority, [0, 0, 0], values), Some(0))
///   assert_eq(Peaker::peak(priority, [0, 0, 0], values), Some(2))
///   assert_eq(Peaker::peak(priority, [0, 0, 0], values), Some(0))
/// }
/// ```
pub(open) trait Peaker {
  fn peak(Self, Array[Int], Array[Int]) -> Int?
}

///|
/// Factories for the upstream dimension-resizing priorities.
pub enum Priority {}

///|
pub struct PriorityNone {
  priv mut index : Int
} derive(Eq, Debug)

///|
pub fn PriorityNone::new() -> PriorityNone {
  { index: 0, }
}

///|
pub fn PriorityNone::default() -> PriorityNone {
  PriorityNone::new()
}

///|
pub impl Peaker for PriorityNone with fn peak(self, _minimums, widths) {
  if widths.is_empty() {
    return None
  }
  let mut index = self.index % widths.length()
  for _ in 0..<widths.length() {
    if widths[index] != 0 {
      self.index = (index + 1) % widths.length()
      return Some(index)
    }
    index = (index + 1) % widths.length()
  }
  None
}

///|
pub struct PriorityLeft {} derive(Eq, Debug)

///|
pub fn PriorityLeft::new() -> PriorityLeft {
  PriorityLeft::{ }
}

///|
pub fn PriorityLeft::default() -> PriorityLeft {
  PriorityLeft::new()
}

///|
pub impl Peaker for PriorityLeft with fn peak(_self, minimums, widths) {
  for index in 0..<widths.length() {
    if widths[index] > minimums.get(index).unwrap_or(0) {
      return Some(index)
    }
  }
  None
}

///|
pub struct PriorityRight {
  priv mut index : Int?
} derive(Eq, Debug)

///|
pub fn PriorityRight::new() -> PriorityRight {
  { index: None, }
}

///|
pub fn PriorityRight::default() -> PriorityRight {
  PriorityRight::new()
}

///|
pub impl Peaker for PriorityRight with fn peak(self, minimums, widths) {
  if widths.is_empty() {
    return None
  }
  if self.index is None {
    self.index = Some(widths.length() - 1)
  }
  let start = Int::min(self.index.unwrap_or(0), widths.length() - 1)
  for index = start; index >= 0; index = index - 1 {
    if widths[index] > minimums.get(index).unwrap_or(0) {
      return Some(index)
    }
  }
  None
}

///|
pub struct PriorityMin {
  priv right : Bool
} derive(Eq, Debug)

///|
pub fn PriorityMin::new(priorities_right : Bool) -> PriorityMin {
  { right: priorities_right, }
}

///|
pub fn PriorityMin::default() -> PriorityMin {
  PriorityMin::left()
}

///|
pub fn PriorityMin::left() -> PriorityMin {
  PriorityMin::new(false)
}

///|
pub fn PriorityMin::right() -> PriorityMin {
  PriorityMin::new(true)
}

///|
pub struct PriorityMax {
  priv right : Bool
} derive(Eq, Debug)

///|
pub fn PriorityMax::new(priorities_right : Bool) -> PriorityMax {
  { right: priorities_right, }
}

///|
pub fn PriorityMax::default() -> PriorityMax {
  PriorityMax::left()
}

///|
pub fn PriorityMax::left() -> PriorityMax {
  PriorityMax::new(false)
}

///|
pub fn PriorityMax::right() -> PriorityMax {
  PriorityMax::new(true)
}

///|
fn peak_extreme(
  minimums : Array[Int],
  widths : Array[Int],
  right : Bool,
  maximum : Bool,
) -> Int? {
  let mut chosen : Int? = None
  for offset in 0..<widths.length() {
    let index = if right { offset } else { widths.length() - offset - 1 }
    if !minimums.is_empty() && widths[index] <= minimums.get(index).unwrap_or(0) {
      continue
    }
    match chosen {
      None => chosen = Some(index)
      Some(current) =>
        // Rust's min_by_key keeps the first equal minimum; max_by_key keeps
        // the last equal maximum. Preserve this difference in side priority.
        if (maximum && widths[index] >= widths[current]) ||
          (!maximum && widths[index] < widths[current]) {
          chosen = Some(index)
        }
    }
  }
  chosen.filter(index => widths[index] != 0)
}

///|
pub impl Peaker for PriorityMin with fn peak(self, minimums, widths) {
  peak_extreme(minimums, widths, self.right, false)
}

///|
pub impl Peaker for PriorityMax with fn peak(self, minimums, widths) {
  peak_extreme(minimums, widths, self.right, true)
}

///|
pub fn Priority::none() -> PriorityNone {
  PriorityNone::new()
}

///|
pub fn Priority::left() -> PriorityLeft {
  PriorityLeft::new()
}

///|
pub fn Priority::right() -> PriorityRight {
  PriorityRight::new()
}

///|
pub fn Priority::min(right : Bool) -> PriorityMin {
  PriorityMin::new(right)
}

///|
pub fn Priority::max(right : Bool) -> PriorityMax {
  PriorityMax::new(right)
}
