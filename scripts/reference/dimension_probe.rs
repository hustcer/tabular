use std::io::Read;
use tabled::{Table, settings::{Style, Padding, Span, Margin, Width, Height}};
use tabled::settings::measurement::{Measurement, Max, Min, Percent};
use tabled::settings::peaker::{Peaker, PriorityNone, PriorityLeft, PriorityRight, PriorityMin, PriorityMax};

fn numbers(text: &str) -> Vec<usize> {
    if text.is_empty() { Vec::new() } else { text.split(',').map(|s| s.parse().unwrap()).collect() }
}

fn main() {
    let args: Vec<_> = std::env::args().collect();
    if args[1] == "priority" {
        let mut priority: Box<dyn Peaker> = match args[2].as_str() {
            "none" => Box::new(PriorityNone::new()),
            "left" => Box::new(PriorityLeft::new()),
            "right" => Box::new(PriorityRight::new()),
            "min-left" => Box::new(PriorityMin::left()),
            "min-right" => Box::new(PriorityMin::right()),
            "max-left" => Box::new(PriorityMax::left()),
            "max-right" => Box::new(PriorityMax::right()),
            _ => panic!("unknown priority"),
        };
        let mins = numbers(&args[3]);
        let mut values = numbers(&args[4]);
        for _ in 0..30 {
            let index = priority.peak(&mins, &values);
            println!("{}", index.map(|i| i as i32).unwrap_or(-1));
            if let Some(index) = index {
                if values[index] > mins.get(index).copied().unwrap_or(0) { values[index] -= 1; }
            }
        }
        return;
    }
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input).unwrap();
    let rows: Vec<Vec<String>> = if input.is_empty() { vec![] } else {
        input.trim_end_matches('\n').split('\n').map(|row| row.split(',').map(|cell| {
            let bytes = cell.as_bytes().chunks_exact(2).map(|pair| {
                u8::from_str_radix(std::str::from_utf8(pair).unwrap(), 16).unwrap()
            }).collect::<Vec<_>>();
            String::from_utf8(bytes).unwrap()
        }).collect()).collect()
    };
    let mut table = Table::from_iter(rows);
    match args[2].as_str() {
        "ascii" => (),
        "empty" => { table.with(Style::empty()); },
        "psql" => { table.with(Style::psql()); },
        "padding" => { table.with(Padding::new(2, 3, 1, 2)); },
        "margin" => { table.with(Margin::new(4, 5, 2, 3)); },
        "column-span" => { table.modify((0, 0), Span::column(2)); },
        "row-span" => { table.modify((0, 0), Span::row(2)); },
        "mixed-padding" => {
            table.modify((0, 0), Padding::new(0, 0, 3, 0));
            table.modify((0, 1), Padding::new(2, 2, 0, 3));
        },
        _ => panic!("unknown measurement configuration"),
    }
    let records = table.get_records();
    let config = table.get_config();
    println!("{}", <Max as Measurement<Width>>::measure(&Max, records, config));
    println!("{}", <Min as Measurement<Width>>::measure(&Min, records, config));
    println!("{}", <Max as Measurement<Height>>::measure(&Max, records, config));
    println!("{}", <Min as Measurement<Height>>::measure(&Min, records, config));
    println!("{}", <Percent as Measurement<Width>>::measure(&Percent(37), records, config));
    println!("{}", <Percent as Measurement<Height>>::measure(&Percent(150), records, config));
}
