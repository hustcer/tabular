use tabled::{Table, settings::{Width, Alignment, Padding, Modify, Span, Color, Settings, object::Segment}};
use tabled::settings::measurement::{Max, Min, Percent};
use tabled::settings::peaker::{PriorityMax, PriorityMin};
use tabled::grid::{config::{ColoredConfig, Entity}, dimension::CompleteDimension, records::vec_records::{Text, VecRecords}};
use tabled::settings::{TableOption, CellOption};

struct MeasuredCells(bool);
impl TableOption<VecRecords<Text<String>>, ColoredConfig, CompleteDimension> for MeasuredCells {
    fn change(self, records: &mut VecRecords<Text<String>>, config: &mut ColoredConfig, _: &mut CompleteDimension) {
        if self.0 { CellOption::change(Width::increase(Max), records, config, Entity::Global); }
        else { CellOption::change(Width::truncate(Min), records, config, Entity::Global); }
    }
}

fn main() {
    let mut table = Table::from_iter([["abc", "xy"], ["de", "z"]]);
    let mode = std::env::args().nth(1).unwrap();
    match mode.as_str() {
        "list" => { table.with(Width::list([8, 5])); },
        "long-list" => { table.with(Width::list([8, 5, 99])); },
        "short-list" => { table.with(Width::list([8, 5])).with(Width::list([1])); },
        "align" => { table.with(Width::list([8, 5])).with(Alignment::right()); },
        "cell-align" => { table.with(Width::list([8, 5])).modify((0, 0), Alignment::right()); },
        "settings" => { table.with(Settings::new(Width::list([8, 5]), Alignment::right())); },
        "array" => { table.with(vec![Width::list([8, 5])]); },
        "nested" => {
            table.with(Width::list([5, 4]));
            table.with((Modify::new((0, 0)).with("a very long string"), Width::truncate(12)));
        },
        "record-wrap" => { table.modify(Segment::all(), Width::wrap(2)); },
        "record-increase" => { table.modify(Segment::all(), Width::increase(5).fill_with('.')); },
        "max" => { table.with(MeasuredCells(true)); },
        "min" => { table.with(MeasuredCells(false)); },
        "percent" => { table.with(Width::wrap(Percent(75))); },
        "percent-increase" => { table.with(Width::increase(Percent(200))); },
        "minimum-priority" => { table.with(Width::increase(20).priority(PriorityMin::right())); },
        "maximum-priority" => { table.with(Width::increase(20).priority(PriorityMax::left())); },
        "justify-max" => { table.with(tabled::settings::width::Justify::max()); },
        "justify-min" => { table.with(tabled::settings::width::Justify::min()); },
        "mixed-padding" => { table.modify((0, 0), Padding::new(1, 1, 2, 0)).modify((0, 1), Padding::new(1, 1, 0, 3)).with(Width::increase(14)); },
        "row-span" => { table.modify((0, 0), Span::row(2)).modify((1, 0), "a very long hidden value").with(Width::increase(14)); },
        "crlf" => { table.modify((0, 0), "a\r\nb\r\n").with(Width::increase(12)); },
        "heights" => { table.get_dimension_mut().set_heights(vec![3, 2]); },
        "height-row-hint" => { table.get_dimension_mut().set_heights(vec![3, 2]); table.with(Width::wrap(100)); },
        "height-no-hint" => { table.get_dimension_mut().set_heights(vec![3, 2]); table.with(Width::truncate(100)); },
        "color" => { table.with(Width::list([8, 5])).with(Color::FG_RED); },
        _ => panic!("unknown case"),
    }
    // Render first: observing a table must not materialize its public cache.
    println!("{:?}", table.to_string());
    let dims = table.get_dimension();
    println!("{:?}", dims.get_widths());
    println!("{:?}", dims.get_heights());
    println!("{}", table.total_width());
    println!("{}", table.total_height());
    for row in table.get_records().iter() {
        println!("{:?}", row.iter().map(|cell| cell.as_ref()).collect::<Vec<_>>());
    }
}
