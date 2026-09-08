use tabled::{Table, settings::{Height, Width, Alignment, Padding, Margin, Modify, Span, Style, Color, Settings}};
use tabled::settings::object::{Rows, Segment};
use tabled::settings::measurement::{Max, Min, Percent};
use tabled::settings::peaker::{PriorityMax, PriorityMin};
use tabled::grid::{config::{ColoredConfig, Entity}, dimension::CompleteDimension, records::vec_records::{Text, VecRecords}};
use tabled::settings::{TableOption, CellOption};

struct MeasuredCells(bool);
impl TableOption<VecRecords<Text<String>>, ColoredConfig, CompleteDimension> for MeasuredCells {
    fn change(self, records: &mut VecRecords<Text<String>>, config: &mut ColoredConfig, _: &mut CompleteDimension) {
        if self.0 { CellOption::change(Height::increase(Max), records, config, Entity::Global); }
        else { CellOption::change(Height::limit(Min), records, config, Entity::Global); }
    }
}

fn main() {
    let mut table = Table::from_iter([["a\nb\nc\n", "long value"], ["d\ne", "x\ny\nz"], ["", "q"]]);
    let mode = std::env::args().nth(1).unwrap();
    match mode.as_str() {
        "list" => { table.with(Height::list([2, 0, 3])); },
        "long-list" => { table.with(Height::list([2, 0, 3, 99])); },
        "short-list" => { table.with(Height::list([2, 0, 3])).with(Height::list([1])); },
        "increase" => { table.with(Height::increase(20)); },
        "limit" => { table.with(Height::limit(7)); },
        "zero" => { table.with(Height::limit(0)); },
        "min-limit" => { table.with(Height::limit(6).priority(PriorityMin::right())); },
        "max-limit" => { table.with(Height::limit(7).priority(PriorityMax::left())); },
        "min-increase" => { table.with(Height::increase(18).priority(PriorityMin::right())); },
        "max-increase" => { table.with(Height::increase(18).priority(PriorityMax::left())); },
        "record-increase" => { table.modify(Segment::all(), Height::increase(5)); },
        "record-limit" => { table.modify(Segment::all(), Height::limit(1)); },
        "record-zero" => { table.modify(Segment::all(), Height::limit(0)); },
        "max" => { table.with(MeasuredCells(true)); },
        "min" => { table.with(MeasuredCells(false)); },
        "percent-increase" => { table.with(Height::increase(Percent(200))); },
        "percent-limit" => { table.with(Height::limit(Percent(50))); },
        "percent-margin" => { table.with(Margin::new(1, 1, 2, 3)).with(Height::increase(Percent(200))); },
        "mixed-padding" => { table.modify((0, 0), Padding::new(1, 1, 2, 0)).modify((0, 1), Padding::new(1, 1, 0, 3)).with(Height::limit(8)); },
        "padding-list" => { table.with(Padding::new(1, 1, 2, 3)).with(Height::list([3, 0, 6])); },
        "row-span" => { table.modify((0, 0), Span::row(2)).modify((1, 0), "hidden\nlong\ntext\na\nb\nc").with(Height::limit(8)); },
        "column-span" => { table.modify((0, 0), Span::column(2)).modify((0, 1), "hidden\nlong\ntext\na\nb\nc").with(Height::increase(16)); },
        "crlf" => { table.modify((0, 0), "a\r\nb\r\n").modify((0, 0), Height::limit(2)); },
        "ansi" => { table.modify((0, 0), "\u{1b}[31ma\nb\nc\u{1b}[39m").modify((0, 0), Height::limit(2)); },
        "color" => { table.with(Height::list([2, 0, 3])).with(Color::FG_RED); },
        "settings" => { table.with(Settings::new(Height::list([5, 0, 3]), Alignment::bottom())); },
        "array" => { table.with(vec![Height::list([2, 0, 3])]); },
        "cell-align" => { table.with(Height::list([2, 0, 3])).modify((0, 0), Alignment::bottom()); },
        "increase-after-list" => { table.with(Height::list([50, 50, 50])).with(Height::increase(15)); },
        "limit-after-list" => { table.with(Height::list([50, 50, 50])).with(Height::limit(8)); },
        "increase-noop-list" => { table.with(Height::list([50, 50, 50])).with(Height::increase(1)); },
        "limit-noop-list" => { table.with(Height::list([50, 50, 50])).with(Height::limit(100)); },
        "width-cache" => { table.with(Width::list([8, 12])).with(Height::limit(7)); },
        "width-after-height" => { table.with(Height::increase(20)).with(Width::wrap(18)); },
        "nested" => { table.with((Modify::new(Rows::first()).with(Height::increase(8)), Height::limit(12))); },
        "markdown" => { table.with(Style::markdown()).with(Height::limit(3)); },
        "empty-style" => { table.with(Style::empty()).with(Height::limit(0)); },
        _ => panic!("unknown height scenario"),
    }
    println!("{:?}", table.to_string());
    println!("{:?}", table.get_dimension().get_widths());
    println!("{:?}", table.get_dimension().get_heights());
    println!("{}", table.total_width());
    println!("{}", table.total_height());
    for row in table.get_records().iter() {
        println!("{:?}", row.iter().map(|cell| cell.as_ref()).collect::<Vec<_>>());
    }
}
