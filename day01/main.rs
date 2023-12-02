use std::{
    fs::File,
    io::{BufRead, BufReader},
    str::Chars,
};

fn main() {
    let path = std::env::args().skip(1).next().expect("missing input path");
    let file = File::open(path).expect("unable to read file");
    let reader = BufReader::new(file);
    let lines = reader
        .lines()
        .map(|l| l.expect("unable to read line"))
        .collect::<Vec<_>>();

    let sum = part01(&lines);
    println!("{sum}");

    let sum = part02(&lines);
    println!("{sum}");
}

fn part01(lines: &[String]) -> u32 {
    lines
        .iter()
        .flat_map(|line| {
            let digits: Vec<_> = line.chars().filter_map(|c| c.to_digit(10)).collect();
            let fst = digits.first();
            let snd = digits.last();
            fst.and_then(|fst| snd.map(|snd| fst * 10 + snd))
        })
        .sum()
}

fn part02(lines: &[String]) -> u32 {
    lines
        .iter()
        .flat_map(|line| {
            let digits: Vec<_> = (0..line.len())
                .flat_map(|i| find_number(&line[i..]))
                .collect();
            let fst = digits.first();
            let snd = digits.last();
            fst.and_then(|fst| snd.map(|snd| fst * 10 + snd))
        })
        .sum()
}

fn is_next_match(chars: &mut Chars, pattern: &str) -> bool {
    for c in pattern.chars() {
        if chars.next() != Some(c) {
            return false;
        }
    }
    true
}

fn find_number(input: &str) -> Option<u32> {
    let mut chars = input.chars();
    match chars.next() {
        Some('e') if is_next_match(&mut chars, "ight") => Some(8),
        Some('f') => match chars.next() {
            Some('o') if is_next_match(&mut chars, "ur") => Some(4),
            Some('i') if is_next_match(&mut chars, "ve") => Some(5),
            _ => None,
        },
        Some('n') if is_next_match(&mut chars, "ine") => Some(9),
        Some('o') if is_next_match(&mut chars, "ne") => Some(1),
        Some('s') => match chars.next() {
            Some('i') => match chars.next() {
                Some('x') => Some(6),
                _ => None,
            },
            Some('e') if is_next_match(&mut chars, "ven") => Some(7),
            _ => None,
        },
        Some('t') => match chars.next() {
            Some('w') => match chars.next() {
                Some('o') => Some(2),
                _ => None,
            },
            Some('h') if is_next_match(&mut chars, "ree") => Some(3),
            _ => None,
        },
        Some(c) => c.to_digit(10),
        _ => None,
    }
}
