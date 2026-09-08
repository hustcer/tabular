///|
/// Select the next column or row to resize. Returning None stops resizing.
/// Arguments after the selector are minimum sizes and current sizes, in index order.
/// An empty minimum-size array means no explicit lower bounds were supplied.
///
/// ```mbt check
/// test {
///   let priority = Priority::round_robin()
///   let values = [5, 0, 2]
///   assert_eq(ResizeSelector::select(priority, [0, 0, 0], values), Some(0))
///   assert_eq(ResizeSelector::select(priority, [0, 0, 0], values), Some(2))
///   assert_eq(ResizeSelector::select(priority, [0, 0, 0], values), Some(0))
/// }
/// ```
pub(open) trait ResizeSelector {
  fn select(Self, Array[Int], Array[Int]) -> Int?
}

///|
/// Factories for the upstream dimension-resizing priorities.
pub enum Priority {}

///|
/// Choose the lowest or highest index when eligible sizes are equal.
/// This applies to both columns (left/right) and rows (top/bottom).
pub(all) enum TieBreak {
  First
  Last
} derive(Eq, Debug)

///|
/// Round-robin selection skips zero-sized entries, retaining its next index.
pub struct PriorityRoundRobin {
  priv mut index : Int
} derive(Eq, Debug)

///|
pub fn PriorityRoundRobin::new() -> PriorityRoundRobin {
  { index: 0, }
}

///|
pub fn PriorityRoundRobin::default() -> PriorityRoundRobin {
  PriorityRoundRobin::new()
}

///|
pub impl ResizeSelector for PriorityRoundRobin with fn select(
  self,
  _minimums,
  sizes,
) {
  if sizes.is_empty() {
    return None
  }
  let mut index = self.index % sizes.length()
  for _ in 0..<sizes.length() {
    if sizes[index] != 0 {
      self.index = (index + 1) % sizes.length()
      return Some(index)
    }
    index = (index + 1) % sizes.length()
  }
  None
}

///|
/// Select the lowest eligible index (leftmost column or topmost row).
pub struct PriorityFirst {} derive(Eq, Debug)

///|
pub fn PriorityFirst::new() -> PriorityFirst {
  PriorityFirst::{ }
}

///|
pub fn PriorityFirst::default() -> PriorityFirst {
  PriorityFirst::new()
}

///|
pub impl ResizeSelector for PriorityFirst with fn select(_self, minimums, sizes) {
  for index in 0..<sizes.length() {
    if sizes[index] > minimums.get(index).unwrap_or(0) {
      return Some(index)
    }
  }
  None
}

///|
/// Select from the highest eligible index (rightmost column or bottommost row).
pub struct PriorityLast {
  priv mut index : Int?
} derive(Eq, Debug)

///|
pub fn PriorityLast::new() -> PriorityLast {
  { index: None, }
}

///|
pub fn PriorityLast::default() -> PriorityLast {
  PriorityLast::new()
}

///|
pub impl ResizeSelector for PriorityLast with fn select(self, minimums, sizes) {
  if sizes.is_empty() {
    return None
  }
  if self.index is None {
    self.index = Some(sizes.length() - 1)
  }
  let start = Int::min(self.index.unwrap_or(0), sizes.length() - 1)
  for index = start; index >= 0; index = index - 1 {
    if sizes[index] > minimums.get(index).unwrap_or(0) {
      return Some(index)
    }
  }
  None
}

///|
/// Select a minimum size; equal values use the explicitly chosen tie break.
pub struct PriorityMin {
  priv tie_break : TieBreak
} derive(Eq, Debug)

///|
pub fn PriorityMin::new(tie_break~ : TieBreak) -> PriorityMin {
  { tie_break, }
}

///|
/// Preserve the upstream default: equal minimum sizes prefer the last index.
pub fn PriorityMin::default() -> PriorityMin {
  PriorityMin::prefer_last()
}

///|
pub fn PriorityMin::prefer_last() -> PriorityMin {
  PriorityMin::new(tie_break=Last)
}

///|
pub fn PriorityMin::prefer_first() -> PriorityMin {
  PriorityMin::new(tie_break=First)
}

///|
/// Select a maximum size; equal values use the explicitly chosen tie break.
pub struct PriorityMax {
  priv tie_break : TieBreak
} derive(Eq, Debug)

///|
pub fn PriorityMax::new(tie_break~ : TieBreak) -> PriorityMax {
  { tie_break, }
}

///|
/// Preserve the upstream default: equal maximum sizes prefer the first index.
pub fn PriorityMax::default() -> PriorityMax {
  PriorityMax::prefer_first()
}

///|
pub fn PriorityMax::prefer_first() -> PriorityMax {
  PriorityMax::new(tie_break=First)
}

///|
pub fn PriorityMax::prefer_last() -> PriorityMax {
  PriorityMax::new(tie_break=Last)
}

///|
fn select_extreme(
  minimums : Array[Int],
  sizes : Array[Int],
  tie_break : TieBreak,
  maximum : Bool,
) -> Int? {
  let mut chosen : Int? = None
  for index in 0..<sizes.length() {
    if !minimums.is_empty() && sizes[index] <= minimums.get(index).unwrap_or(0) {
      continue
    }
    match chosen {
      None => chosen = Some(index)
      Some(current) =>
        if (maximum && sizes[index] > sizes[current]) ||
          (!maximum && sizes[index] < sizes[current]) ||
          (sizes[index] == sizes[current] && tie_break == Last) {
          chosen = Some(index)
        }
    }
  }
  chosen.filter(index => sizes[index] != 0)
}

///|
pub impl ResizeSelector for PriorityMin with fn select(self, minimums, sizes) {
  select_extreme(minimums, sizes, self.tie_break, false)
}

///|
pub impl ResizeSelector for PriorityMax with fn select(self, minimums, sizes) {
  select_extreme(minimums, sizes, self.tie_break, true)
}

///|
pub fn Priority::round_robin() -> PriorityRoundRobin {
  PriorityRoundRobin::new()
}

///|
pub fn Priority::first() -> PriorityFirst {
  PriorityFirst::new()
}

///|
pub fn Priority::last() -> PriorityLast {
  PriorityLast::new()
}

///|
pub fn Priority::min(tie_break~ : TieBreak) -> PriorityMin {
  PriorityMin::new(tie_break~)
}

///|
pub fn Priority::max(tie_break~ : TieBreak) -> PriorityMax {
  PriorityMax::new(tie_break~)
}
