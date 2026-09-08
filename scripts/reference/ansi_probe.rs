use ansi_str::AnsiStr;
use std::io::Read;

fn main() {
    let mut text = String::new();
    std::io::stdin().read_to_string(&mut text).unwrap();
    match std::env::args().nth(1).as_deref() {
        Some("width") => println!("{}", papergrid::util::string::get_line_width(&text)),
        Some("trim") => println!("{:?}", text.ansi_trim()),
        Some("strip") => println!("{:?}", text.ansi_strip()),
        Some("cut") => {
            let width = std::env::args().nth(2).unwrap().parse().unwrap();
            println!("{:?}", tabled::settings::width::Truncate::truncate(&text, width));
        }
        Some("wrap") => {
            let width = std::env::args().nth(2).unwrap().parse().unwrap();
            println!("{:?}", tabled::settings::width::Wrap::wrap(&text, width, false));
        }
        Some("split") => {
            for line in text.ansi_split("\n") {
                println!("{:?}", line);
            }
        }
        Some("parse") => match papergrid::ansi::ANSIBuf::try_from(text.as_str()) {
            Ok(color) => println!("ok\n{:?}\n{:?}", color.get_prefix(), color.get_suffix()),
            Err(()) => println!("err"),
        },
        Some("tokens") => {
            for token in ansitok::parse_ansi(&text) {
                println!("{:?} {:?}", token.kind(), &text[token.start()..token.end()]);
            }
        }
        _ => panic!("expected width, trim, strip, split, parse, tokens, cut, or wrap"),
    }
}
