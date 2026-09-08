// Appended to a temporary copy of unicode-width's tables.rs by the importer.
// The original source is never changed.
pub fn tabular_metadata(c: char) -> u32 {
    let (width, info) = lookup_width(c);
    u32::from(width)
        | (u32::from(info.0) << 2)
        | ((starts_emoji_presentation_seq(c) as u32) << 18)
        | ((starts_non_ideographic_text_presentation_seq(c) as u32) << 19)
        | ((is_emoji_modifier_base(c) as u32) << 20)
        | ((is_transparent_zero_width(c) as u32) << 21)
}
