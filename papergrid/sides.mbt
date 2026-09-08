///|
/// A character repeated to occupy an inner or outer indent.
pub(all) struct Indent {
  fill : Char
  size : Int
} derive(Eq, Compare, Debug, Hash)

///|
pub fn Indent::new(size : Int, fill : Char) -> Indent {
  { size: Int::max(0, size), fill, }
}

///|
pub fn Indent::spaced(size : Int) -> Indent {
  Indent::new(size, ' ')
}

///|
pub fn Indent::zero() -> Indent {
  Indent::spaced(0)
}

///|
pub fn Indent::default() -> Indent {
  Indent::zero()
}

///|
pub impl Default for Indent with fn default() {
  Indent::zero()
}

///|
pub fn Indent::is_empty(self : Indent) -> Bool {
  self.size == 0
}

///|
/// Values associated with the left, right, top, and bottom of a box.
pub(all) struct Sides[T] {
  left : T
  right : T
  top : T
  bottom : T
} derive(Eq, Compare, Debug, Hash)

///|
pub fn[T] Sides::new(left~ : T, right~ : T, top~ : T, bottom~ : T) -> Sides[T] {
  { left, right, top, bottom, }
}

///|
pub fn[T] Sides::filled(value : T) -> Sides[T] {
  Sides::new(left=value, right=value, top=value, bottom=value)
}

///|
pub fn[T : Default] Sides::default() -> Sides[T] {
  Sides::new(
    left=T::default(),
    right=T::default(),
    top=T::default(),
    bottom=T::default(),
  )
}

///|
pub impl[T : Default] Default for Sides[T] with fn default() {
  Sides::default()
}

///|
pub fn[T, U] Sides::map(self : Sides[T], f : (T) -> U) -> Sides[U] {
  Sides::new(
    left=f(self.left),
    right=f(self.right),
    top=f(self.top),
    bottom=f(self.bottom),
  )
}

///|
pub fn[T, U] Sides::fold(self : Sides[T], init : U, f : (U, T) -> U) -> U {
  f(f(f(f(init, self.left), self.right), self.top), self.bottom)
}

///|
pub fn[T] Sides::is_empty(self : Sides[T?]) -> Bool {
  self.left is None &&
  self.right is None &&
  self.top is None &&
  self.bottom is None
}

///|
/// An offset from the start or end of an axis.
pub(all) enum Offset {
  Start(Int)
  End(Int)
} derive(Eq, Compare, Debug, Hash)

///|
pub fn Offset::from_int(value : Int) -> Offset {
  if value > 0 {
    Start(value)
  } else {
    End(if value == -2147483648 { 2147483647 } else { -value })
  }
}

///|
fn Offset::signed(self : Offset) -> Int {
  match self {
    Start(value) => Int::max(0, value)
    End(value) => -Int::max(0, value)
  }
}
