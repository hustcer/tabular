///|
// Port of unicode-width 0.2.2's non-CJK string-width state machine.
// Copyright 2012-2025 The Rust Project Developers. See THIRD_PARTY_NOTICES.md.
const UW_DEFAULT : Int = 0

///|
const UW_LINE_FEED : Int = 1

///|
const UW_EMOJI_MODIFIER : Int = 2

///|
const UW_REGIONAL_INDICATOR : Int = 3

///|
const UW_SEVERAL_REGIONAL : Int = 4

///|
const UW_EMOJI : Int = 5

///|
const UW_ZWJ_EMOJI : Int = 0x1006

///|
const UW_VS16_ZWJ_EMOJI : Int = 0x9006

///|
const UW_KEYCAP_ZWJ : Int = 0x1007

///|
const UW_VS16_KEYCAP_ZWJ : Int = 0x9007

///|
const UW_REGIONAL_ZWJ : Int = 9

///|
const UW_EVEN_REGIONAL_ZWJ : Int = 10

///|
const UW_ODD_REGIONAL_ZWJ : Int = 11

///|
const UW_TAG_END : Int = 16

///|
const UW_TAG_D1 : Int = 17

///|
const UW_TAG_D2 : Int = 18

///|
const UW_TAG_D3 : Int = 19

///|
const UW_TAG_A1 : Int = 25

///|
const UW_TAG_A2 : Int = 26

///|
const UW_TAG_A3 : Int = 27

///|
const UW_TAG_A4 : Int = 28

///|
const UW_TAG_A5 : Int = 29

///|
const UW_TAG_A6 : Int = 30

///|
const UW_KIRAT_E : Int = 32

///|
const UW_KIRAT_AI : Int = 33

///|
const UW_VS123 : Int = 0x0200

///|
const UW_VS15 : Int = 0x4000

///|
const UW_VS16 : Int = 0x8000

///|
const UW_ALEF : Int = 0x30ff

///|
const UW_ZWJ_LAMED : Int = 0x3c00

///|
const UW_ZWJ_BUGINESE_YA : Int = 0x3c01

///|
const UW_BUGINESE_I_ZWJ_YA : Int = 0x3c02

///|
const UW_TIFINAGH : Int = 0x3803

///|
const UW_ZWJ_TIFINAGH : Int = 0x3c03

///|
const UW_TIFINAGH_JOINER : Int = 0x3c04

///|
const UW_LISU_TONE : Int = 0x3c05

///|
const UW_ZWJ_OLD_TURKIC_I : Int = 0x3c06

///|
const UW_KHMER_COENG : Int = 0x3c07

///|
fn unicode_metadata(ch : Char) -> Int {
  let cp = ch.to_int()
  for lo = 0, hi = unicode_width_ranges.length(); lo < hi; {
    let mid = lo + (hi - lo) / 2
    let (start, end_, value) = unicode_width_ranges[mid]
    if cp < start {
      continue lo, mid
    }
    if cp > end_ {
      continue mid + 1, hi
    }
    return value
  }
  1
}

///|
/// Return the width of one Unicode scalar. Control characters have width zero.
/// Ambiguous-width characters are narrow, as in tabled's default width policy.
pub fn get_char_width(ch : Char) -> Int {
  let cp = ch.to_int()
  if cp < 0x20 || (cp >= 0x7f && cp < 0xa0) {
    0
  } else {
    unicode_metadata(ch) & 3
  }
}

///|
fn unicode_set_presentation(info : Int, selector : Int) -> Int {
  if (info & 0x2000) == 0x2000 ||
    (selector == UW_VS16 && (info & 0x9000) == 0x1000) {
    info | selector
  } else {
    selector
  }
}

///|
fn unicode_ligature_transparent(cp : Int) -> Bool {
  match cp {
    0x034f
    | 0x17b4..=0x17b5
    | 0x180b..=0x180d
    | 0x180f
    | 0x200d
    | 0xfe00..=0xfe0f
    | 0xe0100..=0xe01ef => true
    _ => false
  }
}

///|
fn unicode_width_step(ch : Char, next_info : Int) -> (Int, Int) {
  let cp = ch.to_int()
  let metadata = unicode_metadata(ch)
  let mut next = next_info
  if (next & UW_VS16) != 0 {
    if (metadata & (1 << 18)) != 0 {
      let width = if (next & 0xb000) == 0x9000 { 0 } else { 2 }
      return (width, UW_EMOJI)
    } else {
      next = if (next & 0x2000) == 0x2000 {
        next & UW_VS16.lnot()
      } else {
        UW_DEFAULT
      }
    }
  }
  if cp <= 0xa0 {
    return match cp {
      10 => (1, UW_LINE_FEED)
      13 if next == UW_LINE_FEED => (0, UW_DEFAULT)
      _ => (1, UW_DEFAULT)
    }
  }
  if next != UW_DEFAULT {
    match cp {
      0xfe0f => return (0, unicode_set_presentation(next, UW_VS16))
      0xfe01 => return (0, unicode_set_presentation(next, UW_VS123))
      0xfe0e => return (0, unicode_set_presentation(next, UW_VS15))
      _ => ()
    }
    if (next & UW_VS15) != 0 {
      if (metadata & (1 << 19)) != 0 {
        return (1, UW_DEFAULT)
      }
      next = next & UW_VS15.lnot()
    } else if (next & UW_VS123) != 0 {
      if cp is (0x2018 | 0x2019 | 0x201c | 0x201d) {
        return (2, UW_DEFAULT)
      }
      next = next & UW_VS123.lnot()
    }
    if (next & 0x0800) != 0 {
      if cp == 0x200d {
        return (0, next | 0x0400)
      }
      if unicode_ligature_transparent(cp) {
        return (0, next)
      }
    }
    match (next, cp) {
      // Arabic Lam-Alef and Hebrew Alef-ZWJ-Lamed.
      (UW_ALEF, 0x0644 | 0x06b5..=0x06b8 | 0x076a | 0x08a6 | 0x08c7) =>
        return (0, UW_DEFAULT)
      (UW_ALEF, _) if (metadata & (1 << 21)) != 0 => return (0, UW_ALEF)
      (UW_ZWJ_LAMED, 0x05d0) => return (0, UW_DEFAULT)
      // Khmer, Buginese, Tifinagh, Lisu and Old Turkic ligatures.
      (UW_KHMER_COENG, 0x17d2) => return (-1, UW_DEFAULT)
      (UW_ZWJ_BUGINESE_YA, 0x1a17) => return (0, UW_BUGINESE_I_ZWJ_YA)
      (UW_BUGINESE_I_ZWJ_YA, 0x1a15) => return (0, UW_DEFAULT)
      (UW_TIFINAGH | UW_ZWJ_TIFINAGH, 0x2d7f) => return (1, UW_TIFINAGH_JOINER)
      (UW_ZWJ_TIFINAGH, 0x2d31..=0x2d65 | 0x2d6f) => return (0, UW_DEFAULT)
      (UW_TIFINAGH_JOINER, 0x2d31..=0x2d65 | 0x2d6f) => return (-1, UW_DEFAULT)
      (UW_LISU_TONE, 0xa4f8..=0xa4fb) => return (0, UW_DEFAULT)
      (UW_ZWJ_OLD_TURKIC_I, 0x10c32) => return (0, UW_DEFAULT)
      // Emoji modifiers, regional indicators and ZWJ presentation sequences.
      (UW_EMOJI_MODIFIER, _) if (metadata & (1 << 20)) != 0 =>
        return (0, UW_EMOJI)
      (UW_REGIONAL_INDICATOR | UW_SEVERAL_REGIONAL, 0x1f1e6..=0x1f1ff) =>
        return (1, UW_SEVERAL_REGIONAL)
      (
        UW_EMOJI
        | UW_SEVERAL_REGIONAL
        | UW_EVEN_REGIONAL_ZWJ
        | UW_ODD_REGIONAL_ZWJ
        | UW_EMOJI_MODIFIER,
        0x200d,
      ) => return (0, UW_ZWJ_EMOJI)
      (UW_ZWJ_EMOJI, 0x20e3) => return (0, UW_KEYCAP_ZWJ)
      (UW_VS16_ZWJ_EMOJI, _) if (metadata & (1 << 18)) != 0 =>
        return (0, UW_EMOJI)
      (UW_VS16_KEYCAP_ZWJ, 0x0030..=0x0039 | 0x0023 | 0x002a) =>
        return (0, UW_EMOJI)
      (UW_ZWJ_EMOJI, 0x1f1e6..=0x1f1ff) => return (1, UW_REGIONAL_ZWJ)
      (UW_REGIONAL_ZWJ | UW_ODD_REGIONAL_ZWJ, 0x1f1e6..=0x1f1ff) =>
        return (-1, UW_EVEN_REGIONAL_ZWJ)
      (UW_EVEN_REGIONAL_ZWJ, 0x1f1e6..=0x1f1ff) =>
        return (3, UW_ODD_REGIONAL_ZWJ)
      (UW_ZWJ_EMOJI, 0x1f3fb..=0x1f3ff) => return (0, UW_EMOJI_MODIFIER)
      // Emoji tag sequences.
      (UW_ZWJ_EMOJI, 0xe007f) => return (0, UW_TAG_END)
      (UW_TAG_END, 0xe0061..=0xe007a) => return (0, UW_TAG_A1)
      (UW_TAG_A1, 0xe0061..=0xe007a) => return (0, UW_TAG_A2)
      (UW_TAG_A2, 0xe0061..=0xe007a) => return (0, UW_TAG_A3)
      (UW_TAG_A3, 0xe0061..=0xe007a) => return (0, UW_TAG_A4)
      (UW_TAG_A4, 0xe0061..=0xe007a) => return (0, UW_TAG_A5)
      (UW_TAG_A5, 0xe0061..=0xe007a) => return (0, UW_TAG_A6)
      (
        UW_TAG_END
        | UW_TAG_A1
        | UW_TAG_A2
        | UW_TAG_A3
        | UW_TAG_A4,
        0xe0030..=0xe0039,
      ) => return (0, UW_TAG_D1)
      (UW_TAG_D1, 0xe0030..=0xe0039) => return (0, UW_TAG_D2)
      (UW_TAG_D2, 0xe0030..=0xe0039) => return (0, UW_TAG_D3)
      (UW_TAG_A3 | UW_TAG_A4 | UW_TAG_A5 | UW_TAG_A6 | UW_TAG_D3, 0x1f3f4) =>
        return (0, UW_EMOJI)
      (UW_ZWJ_EMOJI, _) if ((metadata >> 2) & 0xffff) == UW_EMOJI =>
        return (0, UW_EMOJI)
      // Kirat Rai vowel combinations.
      (UW_KIRAT_E, 0x16d63 | 0x16d69) => return (0, UW_DEFAULT)
      (UW_KIRAT_E, 0x16d67) => return (0, UW_KIRAT_AI)
      (UW_KIRAT_E, 0x16d68) => return (1, UW_KIRAT_E)
      (UW_KIRAT_AI, 0x16d63) => return (0, UW_DEFAULT)
      _ => ()
    }
  }
  (metadata & 3, (metadata >> 2) & 0xffff)
}

///|
/// Measure Unicode text using Unicode 17.0.0 width and presentation rules.
/// This measures the string itself; use `get_line_width` to exclude ANSI codes.
///
/// ```mbt check
/// test {
///   assert_eq(get_string_width("👩‍🔬"), 2)
///   assert_eq(get_char_width('🏳'), 1)
///   assert_eq(get_string_width("🏳️"), 2)
/// }
/// ```
pub fn get_string_width(text : String) -> Int {
  let mut width = 0
  let mut state = UW_DEFAULT
  for ch in text.rev_iter() {
    let (add, next) = unicode_width_step(ch, state)
    width += add
    state = next
  }
  width
}
