use tabled::{Table, settings::{Padding, PaddingColor, Margin, MarginColor, Alignment, Width, Height, Color, Span, Style, Settings}};
use tabled::settings::object::{Rows, Columns, Segment};
use tabled::grid::config::{Sides, Offset};

fn main() {
    let mut table = Table::from_iter([["a\nb", "long value"], ["d", "x\ny\nz"], ["", "q"]]);
    match std::env::args().nth(1).unwrap().as_str() {
        "horizontal" => { table.with(Padding::expand(true)); },
        "vertical" => { table.with(Padding::expand(false)); },
        "both" => { table.with(PaddingColor::filled(Color::BG_BLUE)).with(Padding::expand(true)).with(Padding::expand(false)); },
        "right" => { table.with(Alignment::right()).with(Padding::expand(true)); },
        "center" => { table.with(Alignment::center()).with(Padding::expand(true)); },
        "bottom" => { table.with(Alignment::bottom()).with(Padding::expand(false)); },
        "center-vertical" => { table.with(Alignment::center_vertical()).with(Padding::expand(false)); },
        "custom-fills" => { table.with(Padding::new(2, 1, 2, 1).fill('>', '<', '^', 'v')).with(Padding::expand(true)).with(Padding::expand(false)); },
        "padding-bottom" => { table.with(Padding::new(1, 1, 1, 2).fill('>', '<', '^', 'v')).with(Alignment::bottom()); },
        "padding-center" => { table.with(Padding::new(1, 1, 1, 2).fill('>', '<', '^', 'v')).with(Alignment::center_vertical()); },
        "row-over-column" => { table.modify(Columns::first(), Padding::new(2, 1, 2, 1).fill('>', '<', '^', 'v')).modify(Rows::first(), Padding::new(1, 2, 1, 2).fill('a', 'b', 'c', 'd')); },
        "column-over-row" => { table.modify(Rows::first(), Padding::new(2, 1, 2, 1).fill('>', '<', '^', 'v')).modify(Columns::first(), Padding::new(1, 2, 1, 2).fill('a', 'b', 'c', 'd')); },
        "reset-fill" => { table.modify((0, 0), Padding::new(2, 1, 2, 1).fill('>', '<', '^', 'v')).with(Padding::new(1, 1, 1, 1)); },
        "color-scopes" => { table.with(Padding::new(1, 1, 1, 1)).modify(Columns::first(), PaddingColor::filled(Color::BG_RED)).modify(Rows::first(), PaddingColor::filled(Color::BG_BLUE)); },
        "clear-color" => { table.with(Padding::new(1, 1, 1, 1)).with(PaddingColor::filled(Color::BG_RED)).modify((0, 0), PaddingColor::empty()); },
        "zero-color" => { table.with(Padding::zero()).with(PaddingColor::filled(Color::BG_RED)); },
        "cell-expand" => { table.modify((0, 0), Padding::expand(true)).modify((1, 0), Padding::expand(false)); },
        "row-span" => { table.modify((0, 0), Span::row(2)).with(PaddingColor::filled(Color::BG_BLUE)).with(Padding::expand(true)).with(Padding::expand(false)); },
        "column-span" => { table.modify((0, 0), Span::column(2)).with(Padding::expand(true)).with(Padding::expand(false)); },
        "span-colors" => { table.modify((0, 0), Span::row(2)).with(Padding::new(1, 1, 1, 1).fill('>', '<', '^', 'v')).with(PaddingColor::filled(Color::BG_BLUE)); },
        "width-cache" => { table.with(Width::list([15, 18])).with(Padding::expand(true)); },
        "height-cache" => { table.with(Height::list([12, 12, 12])).with(Padding::expand(false)); },
        "color-cache" => { table.with(Width::list([15, 18])).with(PaddingColor::filled(Color::BG_RED)); },
        "margin-cache" => { table.with(Height::list([12, 12, 12])).with(MarginColor::filled(Color::BG_RED)); },
        "margin-empty" => { table.with(Margin::new(1, 2, 1, 2)).with(MarginColor::filled(Color::BG_RED)).with(MarginColor::empty()); },
        "offset-start" => { table.with(Margin::new(1, 2, 1, 2).fill('>', '<', '^', 'v')).with(MarginColor::filled(Color::BG_RED)); table.get_config_mut().set_margin_offset(Sides::new(Offset::Start(2), Offset::Start(3), Offset::Start(2), Offset::Start(4))); },
        "offset-end" => { table.with(Margin::new(1, 2, 1, 2).fill('>', '<', '^', 'v')).with(MarginColor::filled(Color::BG_RED)); table.get_config_mut().set_margin_offset(Sides::new(Offset::End(2), Offset::End(3), Offset::End(2), Offset::End(4))); },
        "offset-large" => { table.with(Margin::new(1, 2, 1, 2).fill('>', '<', '^', 'v')).with(MarginColor::filled(Color::BG_RED)); table.get_config_mut().set_margin_offset(Sides::new(Offset::Start(100), Offset::End(100), Offset::Start(100), Offset::End(100))); },
        "empty-style" => { table.with(Style::empty()).with(PaddingColor::filled(Color::BG_RED)).with(Padding::expand(true)); },
        "settings" => { table.with(Settings::new(Padding::expand(true), Padding::expand(false))); },
        "ansi" => { table.modify((0, 0), Color::FG_RED.colorize("a\nb")).with(Padding::expand(true)).with(Padding::expand(false)); },
        "global-entity" => { table.modify(Segment::all(), Padding::expand(false)); },
        _ => panic!("unknown indent scenario"),
    }
    println!("{:?}", table.to_string());
    println!("{:?}", table.get_dimension().get_widths());
    println!("{:?}", table.get_dimension().get_heights());
    println!("{}", table.total_width());
    println!("{}", table.total_height());
    for row in table.get_records().iter() {
        println!("{:?}", row.iter().map(|cell| cell.as_ref()).collect::<Vec<_>>());
    }
    let pads: Vec<_> = (0..3).flat_map(|row| (0..2).map(move |col| (row, col))).map(|pos| {
        let pad = table.get_config().get_padding(pos.into());
        [pad.left.size, pad.right.size, pad.top.size, pad.bottom.size]
    }).collect();
    println!("{:?}", pads);
}
