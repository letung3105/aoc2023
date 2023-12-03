use std::{
    collections::HashMap,
    fs::File,
    io::{BufRead, BufReader},
};

fn main() {
    let path = std::env::args().skip(1).next().expect("missing input path");
    let file = File::open(path).expect("unable to read file");
    let reader = BufReader::new(file);

    let mut schema = Vec::new();
    for line in reader.lines() {
        let row: Vec<_> = line.expect("unable to read line").chars().collect();
        schema.push(row);
    }

    let mut sum = 0;
    let mut gears = HashMap::new();

    for (y, row) in schema.iter().enumerate() {
        let mut current_number = 0;
        let mut is_adjacent = false;
        let mut gear = None;

        for (x, c) in row.iter().enumerate() {
            if let Some(d) = c.to_digit(10) {
                current_number = current_number * 10 + d;
                is_adjacent |= is_adjacent_symbol(&schema, (x, y));
                gear = gear.or_else(|| nearby_gear(&schema, (x, y)));
            } else {
                if is_adjacent {
                    sum += current_number;
                    if let Some(gear) = gear {
                        gears
                            .entry(gear)
                            .or_insert_with(Vec::new)
                            .push(current_number);
                    }
                    is_adjacent = false;
                    gear = None;
                }
                current_number = 0;
            }
        }

        if is_adjacent {
            sum += current_number;
            if let Some(gear) = gear {
                gears
                    .entry(gear)
                    .or_insert_with(Vec::new)
                    .push(current_number);
            }
        }
    }
    println!("{}", sum);

    let mut sum = 0;
    for (_, numbers) in gears {
        if numbers.len() == 2 {
            sum += numbers.iter().product::<u32>();
        }
    }
    println!("{}", sum);
}

fn is_adjacent_symbol(schema: &[Vec<char>], position: (usize, usize)) -> bool {
    for y in [position.1.saturating_sub(1), position.1, position.1 + 1] {
        for x in [position.0.saturating_sub(1), position.0, position.0 + 1] {
            if x == position.0 && y == position.1 {
                continue;
            }
            if let Some(row) = schema.get(y) {
                if let Some(c) = row.get(x) {
                    if !c.is_digit(10) && *c != '.' {
                        return true;
                    }
                }
            }
        }
    }
    false
}

fn nearby_gear(schema: &[Vec<char>], position: (usize, usize)) -> Option<(usize, usize)> {
    for y in [position.1.saturating_sub(1), position.1, position.1 + 1] {
        for x in [position.0.saturating_sub(1), position.0, position.0 + 1] {
            if x == position.0 && y == position.1 {
                continue;
            }
            if let Some(row) = schema.get(y) {
                if let Some(c) = row.get(x) {
                    if *c == '*' {
                        return Some((x, y));
                    }
                }
            }
        }
    }
    None
}
