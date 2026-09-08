use tabled::{Table, settings::{Alignment, Padding, Span, Panel, Style, object::Columns, themes::BorderCorrection}};

fn base<const N: usize>(rows: Vec<[&str; N]>) -> Table {
    let mut table = Table::from_iter(rows);
    table.with(Alignment::center()).with(Padding::new(1, 1, 0, 0));
    table
}

fn main() {
    let mut t = base(vec![["first line", "", "e.g."], ["0", "1", "2"], ["0", "1", "2"], ["full last line", "", ""]]);
    t.modify((0, 0), Span::column(2)).modify((3, 0), Span::column(3));
    println!("{:?}", t.to_string());
    let mut t = base(vec![["0-0xxxxxxx", "0-1", "0-2"], ["1-0", "1-1", "1-2"], ["2-0", "2-1", "2-2"]]);
    t.modify((0, 0), Span::column(2)).modify((1, 1), Span::column(2));
    println!("{:?}", t.to_string());
    let mut t = base(vec![["0-0", "0-1"], ["1-0", "1-1"], ["2-0", "2-1"]]);
    t.modify(Columns::one(0), Span::column(2));
    println!("{:?}", t.to_string());
    let mut t = base(vec![["first row", ""], ["0", "1"], ["a longer second row", ""]]);
    t.modify((0, 0), Span::column(2)).modify((2, 0), Span::column(2));
    println!("{:?}", t.to_string());
    for col in [0, 1] {
        let mut t = base(vec![["N", "col 0", "col 1", "col 2"], ["0", "0-0", "0-1", "0-2"], ["1", "1-0", "1-1", "1-2"], ["2", "2-0", "2-1", "2-2"]]);
        t.with(Style::psql()).with(Alignment::left()).modify(Columns::one(col), Span::column(2));
        println!("{:?}", t.to_string());
    }
    for mode in 0..3 {
        let mut rows = vec![["0", "1", "2"], ["1", "2", "3"]];
        if mode > 0 { rows.push(["4", "5", "6"]); }
        let mut t = base(rows);
        t.with(Panel::header("Tabled Releases"));
        if mode != 1 { t.modify((1, 0), Span::column(2)); }
        if mode != 0 { t.modify((2, 0), Span::column(2)); }
        t.with(BorderCorrection::span());
        println!("{:?}", t.to_string());
    }
    let mut t = base(vec![["0-0", "0-1"], ["1-0", "1-1"], ["2-0", "2-1"]]);
    t.modify((0, 0), (Span::row(2), Padding::new(0, 0, 4, 4)));
    println!("{:?}", t.to_string());
}
