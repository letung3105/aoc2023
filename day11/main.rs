use std::{
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

fn manhattan_distance(p1: (usize, usize), p2: (usize, usize)) -> usize {
    let x_min = p1.0.min(p2.0);
    let x_max = p1.0.max(p2.0);
    let y_min = p1.1.min(p2.1);
    let y_max = p1.1.max(p2.1);
    (x_max - x_min) + (y_max - y_min)
}

fn count_empty_spaces(
    empty_row_flags: &[bool],
    empty_col_flags: &[bool],
    p1: (usize, usize),
    p2: (usize, usize),
) -> (usize, usize) {
    let x_min = p1.0.min(p2.0);
    let x_max = p1.0.max(p2.0);
    let y_min = p1.1.min(p2.1);
    let y_max = p1.1.max(p2.1);
    let empty_rows = (y_min + 1..y_max)
        .filter(|&row| empty_row_flags[row])
        .count();
    let empty_cols = (x_min + 1..x_max)
        .filter(|&col| empty_col_flags[col])
        .count();
    (empty_rows, empty_cols)
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");
    let mut reader = BufReader::new(file);

    let mut galaxies = Vec::new();
    let mut empty_row_flags = Vec::new();
    let mut empty_col_flags = Vec::new();

    let mut line = String::new();
    while let Ok(n) = reader.read_line(&mut line) {
        if n == 0 {
            break;
        }
        let mut is_row_empty = true;
        for (i, c) in line.trim().chars().enumerate() {
            let is_galaxy = c == '#';
            if is_galaxy {
                galaxies.push((i, empty_row_flags.len()));
            }
            is_row_empty &= !is_galaxy;
            if i >= empty_col_flags.len() {
                empty_col_flags.push(!is_galaxy);
            } else {
                empty_col_flags[i] &= !is_galaxy;
            }
        }
        empty_row_flags.push(is_row_empty);
        line.clear();
    }

    let mut sum01 = 0;
    let mut sum02 = 0;
    for i in 0..galaxies.len() - 1 {
        for j in i + 1..galaxies.len() {
            let distance = manhattan_distance(galaxies[i], galaxies[j]);
            let (empty_rows, empty_cols) =
                count_empty_spaces(&empty_row_flags, &empty_col_flags, galaxies[i], galaxies[j]);
            let empty_spaces = empty_rows + empty_cols;
            sum01 += distance + empty_spaces;
            sum02 += distance + empty_spaces * 999999;
        }
    }

    println!("{}", sum01);
    println!("{}", sum02);
}
