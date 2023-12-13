use std::{
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

#[derive(Debug, Default)]
struct Pattern {
    vertical: Vec<usize>,
    horizontal: Vec<usize>,
}

fn is_mirrored(pattern_1d: &[usize]) -> Option<usize> {
    (1..pattern_1d.len()).find(|&i| {
        pattern_1d[..i]
            .iter()
            .rev()
            .zip(pattern_1d[i..].iter())
            .all(|(x, y)| x == y)
    })
}

fn is_mirrored_smudged(pattern_1d: &[usize]) -> Option<usize> {
    let pattern_len = pattern_1d.len();
    (1..pattern_len).find(|&i| {
        let mut count_zeros = 0;
        let mut count_power_of_twos = 0;
        for xor in pattern_1d[..i]
            .iter()
            .rev()
            .zip(pattern_1d[i..].iter())
            .map(|(x, y)| x ^ y)
        {
            if xor == 0 {
                count_zeros += 1;
            } else if xor.is_power_of_two() {
                count_power_of_twos += 1;
            }
        }
        count_power_of_twos == 1 && count_zeros + count_power_of_twos == i.min(pattern_len - i)
    })
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");

    let mut patterns = vec![Pattern::default()];
    let mut reader = BufReader::new(file);
    let mut line = String::new();
    while reader.read_line(&mut line).unwrap() > 0 {
        let trimmed_line = line.trim();
        if trimmed_line.is_empty() {
            patterns.push(Pattern::default());
            continue;
        }
        let patterns_len = patterns.len();
        let pattern = &mut patterns[patterns_len - 1];
        let mut row_id = 0;
        for (i, c) in trimmed_line.chars().enumerate() {
            let flag = if c == '#' { 1 } else { 0 };
            if i >= pattern.vertical.len() {
                pattern.vertical.push(flag);
            } else {
                pattern.vertical[i] <<= 1;
                pattern.vertical[i] |= flag;
            }
            row_id <<= 1;
            row_id |= flag;
        }
        pattern.horizontal.push(row_id);
        line.clear();
    }

    let mut vertical1 = 0;
    let mut horizontal1 = 0;

    let mut vertical2 = 0;
    let mut horizontal2 = 0;

    for pattern in patterns {
        if let Some(x) = is_mirrored(&pattern.vertical) {
            vertical1 += x;
        }
        if let Some(x) = is_mirrored(&pattern.horizontal) {
            horizontal1 += x;
        }
        if let Some(x) = is_mirrored_smudged(&pattern.vertical) {
            vertical2 += x;
        }
        if let Some(x) = is_mirrored_smudged(&pattern.horizontal) {
            horizontal2 += x;
        }
    }

    let part01 = vertical1 + 100 * horizontal1;
    let part02 = vertical2 + 100 * horizontal2;
    println!("{}", part01);
    println!("{}", part02);
}
