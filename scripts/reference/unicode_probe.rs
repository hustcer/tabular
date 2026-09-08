use std::io::{self, BufRead};

#[allow(dead_code)]
mod tables;

fn main() {
    match std::env::args().nth(1).as_deref() {
        Some("ranges") => {
            let mut start = 0;
            let mut previous = None;
            for cp in 0..=0x110000 {
                let value = char::from_u32(cp).map(tables::tabular_metadata);
                if value != previous {
                    if let Some(value) = previous {
                        if value != 1 {
                            println!("{start} {} {value}", cp - 1);
                        }
                    }
                    start = cp;
                    previous = value;
                }
            }
        }
        Some("widths") => {
            for line in io::stdin().lock().lines() {
                let line = line.unwrap();
                let bytes: Vec<u8> = line.as_bytes().chunks_exact(2).map(|pair| {
                    u8::from_str_radix(std::str::from_utf8(pair).unwrap(), 16).unwrap()
                }).collect();
                let text = String::from_utf8(bytes).unwrap();
                println!("{}", tables::str_width(&text));
            }
        }
        Some("scalar-digests") => {
            let mut chars = 14695981039346656037u64;
            let mut strings = chars;
            for ch in (0..=0x10ffff).filter_map(char::from_u32) {
                chars = (chars ^ tables::single_char_width(ch).unwrap_or(0) as u64)
                    .wrapping_mul(1099511628211);
                strings = (strings ^ tables::str_width(&ch.to_string()) as u64)
                    .wrapping_mul(1099511628211);
            }
            println!("{chars}\n{strings}");
        }
        _ => panic!("expected ranges, widths, or scalar-digests"),
    }
}
