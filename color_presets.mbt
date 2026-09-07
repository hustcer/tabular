///|
pub fn Color::fg_black() -> Color {
  Color::new_static("\u001b[30m", "\u001b[39m")
}

///|
pub fn Color::fg_red() -> Color {
  Color::new_static("\u001b[31m", "\u001b[39m")
}

///|
pub fn Color::fg_green() -> Color {
  Color::new_static("\u001b[32m", "\u001b[39m")
}

///|
pub fn Color::fg_yellow() -> Color {
  Color::new_static("\u001b[33m", "\u001b[39m")
}

///|
pub fn Color::fg_blue() -> Color {
  Color::new_static("\u001b[34m", "\u001b[39m")
}

///|
pub fn Color::fg_magenta() -> Color {
  Color::new_static("\u001b[35m", "\u001b[39m")
}

///|
pub fn Color::fg_cyan() -> Color {
  Color::new_static("\u001b[36m", "\u001b[39m")
}

///|
pub fn Color::fg_white() -> Color {
  Color::new_static("\u001b[37m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_black() -> Color {
  Color::new_static("\u001b[90m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_red() -> Color {
  Color::new_static("\u001b[91m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_green() -> Color {
  Color::new_static("\u001b[92m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_yellow() -> Color {
  Color::new_static("\u001b[93m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_blue() -> Color {
  Color::new_static("\u001b[94m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_magenta() -> Color {
  Color::new_static("\u001b[95m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_cyan() -> Color {
  Color::new_static("\u001b[96m", "\u001b[39m")
}

///|
pub fn Color::fg_bright_white() -> Color {
  Color::new_static("\u001b[97m", "\u001b[39m")
}

///|
pub fn Color::bg_black() -> Color {
  Color::new_static("\u001b[40m", "\u001b[49m")
}

///|
pub fn Color::bg_red() -> Color {
  Color::new_static("\u001b[41m", "\u001b[49m")
}

///|
pub fn Color::bg_green() -> Color {
  Color::new_static("\u001b[42m", "\u001b[49m")
}

///|
pub fn Color::bg_yellow() -> Color {
  Color::new_static("\u001b[43m", "\u001b[49m")
}

///|
pub fn Color::bg_blue() -> Color {
  Color::new_static("\u001b[44m", "\u001b[49m")
}

///|
pub fn Color::bg_magenta() -> Color {
  Color::new_static("\u001b[45m", "\u001b[49m")
}

///|
pub fn Color::bg_cyan() -> Color {
  Color::new_static("\u001b[46m", "\u001b[49m")
}

///|
pub fn Color::bg_white() -> Color {
  Color::new_static("\u001b[47m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_black() -> Color {
  Color::new_static("\u001b[100m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_red() -> Color {
  Color::new_static("\u001b[101m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_green() -> Color {
  Color::new_static("\u001b[102m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_yellow() -> Color {
  Color::new_static("\u001b[103m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_blue() -> Color {
  Color::new_static("\u001b[104m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_magenta() -> Color {
  Color::new_static("\u001b[105m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_cyan() -> Color {
  Color::new_static("\u001b[106m", "\u001b[49m")
}

///|
pub fn Color::bg_bright_white() -> Color {
  Color::new_static("\u001b[107m", "\u001b[49m")
}

///|
pub fn Color::blink() -> Color {
  Color::new_static("\u001b[5m", "\u001b[25m")
}

///|
pub fn Color::bold() -> Color {
  Color::new_static("\u001b[1m", "\u001b[22m")
}

///|
pub fn Color::dimmed() -> Color {
  Color::new_static("\u001b[2m", "\u001b[22m")
}

///|
pub fn Color::hidden() -> Color {
  Color::new_static("\u001b[8m", "\u001b[28m")
}

///|
pub fn Color::invert() -> Color {
  Color::new_static("\u001b[7m", "\u001b[27m")
}

///|
pub fn Color::italic() -> Color {
  Color::new_static("\u001b[3m", "\u001b[23m")
}

///|
pub fn Color::reset() -> Color {
  Color::new_static("\u001b[0m", "\u001b[0m")
}

///|
pub fn Color::strikethrough() -> Color {
  Color::new_static("\u001b[9m", "\u001b[29m")
}

///|
pub fn Color::underline() -> Color {
  Color::new_static("\u001b[4m", "\u001b[24m")
}
