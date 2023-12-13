use std::{
    collections::HashMap,
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

#[derive(Debug, Hash, Eq, PartialEq)]
struct Args {
    springs: Vec<char>,
    sizes: Vec<usize>,
    run_length: usize,
}

impl Args {
    fn new(springs: &[char], sizes: &[usize], run_length: usize) -> Self {
        Self {
            springs: springs.to_vec(),
            sizes: sizes.to_vec(),
            run_length,
        }
    }
}

fn count(
    memo: &mut HashMap<Args, usize>,
    springs: &[char],
    sizes: &[usize],
    run_length: usize,
) -> usize {
    if springs.is_empty() {
        return if sizes.is_empty() || (sizes.len() == 1 && sizes[0] == run_length) {
            1
        } else {
            0
        };
    }
    if sizes.is_empty() {
        return if springs.iter().all(|&c| c != '#') {
            1
        } else {
            0
        };
    }
    if run_length > sizes[0] {
        return 0;
    }

    let args = Args::new(springs, sizes, run_length);
    if let Some(&arrangements) = memo.get(&args) {
        return arrangements;
    }

    let mut arrangements = 0;
    if springs[0] == '.' || springs[0] == '?' {
        if run_length == 0 {
            arrangements += count(memo, &springs[1..], sizes, 0);
        }
        if run_length == sizes[0] {
            arrangements += count(memo, &springs[1..], &sizes[1..], 0);
        }
    }
    if springs[0] == '#' || springs[0] == '?' {
        arrangements += count(memo, &springs[1..], sizes, run_length + 1);
    }
    memo.insert(args, arrangements);
    arrangements
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");

    let mut part01 = 0;
    let mut part02 = 0;
    let mut memo = HashMap::new();

    let mut reader = BufReader::new(file);
    let mut line = String::new();
    while reader.read_line(&mut line).unwrap() > 0 {
        let mut line_iter = line.trim().split(' ');
        let springs: Vec<_> = line_iter.next().unwrap().chars().collect();
        let sizes: Vec<_> = line_iter
            .next()
            .unwrap()
            .split(',')
            .map(|s| s.parse::<usize>().unwrap())
            .collect();

        let mut unfolded_springs = springs.clone();
        let mut unfolded_sizes = sizes.clone();
        for _ in 0..4 {
            unfolded_springs.push('?');
            unfolded_springs.extend(springs.iter());
            unfolded_sizes.extend(sizes.iter());
        }

        part01 += count(&mut memo, &springs, &sizes, 0);
        part02 += count(&mut memo, &unfolded_springs, &unfolded_sizes, 0);
        line.clear();
    }

    println!("{}", part01);
    println!("{}", part02);
}
