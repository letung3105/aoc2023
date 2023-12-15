use std::{
    collections::HashMap,
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

fn rotate_right<T>(matrix: &[Vec<T>]) -> Vec<Vec<T>>
where
    T: Clone,
{
    let rows = matrix.len();
    let cols = matrix[0].len();
    let mut result = Vec::new();
    for x in 0..cols {
        let mut row = Vec::new();
        for y in (0..rows).rev() {
            row.push(matrix[y][x].clone());
        }
        result.push(row);
    }
    result
}

fn tilt(platform: &[Vec<u8>]) -> Vec<Vec<u8>> {
    let rows = platform.len();
    let cols = platform[0].len();
    let mut platform = platform.to_vec();
    let mut heights = vec![rows; cols];
    for y in 0..rows {
        for x in 0..cols {
            match platform[y][x] {
                b'O' => {
                    platform[y][x] = b'.';
                    platform[rows - heights[x]][x] = b'O';
                    heights[x] -= 1;
                }
                b'#' => {
                    heights[x] = rows - y - 1;
                }
                _ => {}
            }
        }
    }
    platform
}

fn calculate_load(platform: &[Vec<u8>]) -> usize {
    let rows = platform.len();
    let mut load = 0;
    for (y, row) in platform.iter().enumerate() {
        for &c in row {
            if c == b'O' {
                load += rows - y;
            }
        }
    }
    load
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");

    let mut platform = Vec::new();
    let mut reader = BufReader::new(file);
    let mut line = String::new();
    while reader.read_line(&mut line).unwrap() > 0 {
        let trimmed_line = line.trim();
        let row: Vec<_> = trimmed_line.bytes().collect();
        platform.push(row);
        line.clear();
    }

    let part01 = calculate_load(&tilt(&platform));
    println!("{}", part01);

    let mut states = HashMap::new();
    let mut loads = Vec::new();
    let mut count = 0;
    let mut cycle_start = 0;
    let mut cycle_end = 0;
    loop {
        if let Some(cycle_prev) = states.get(&platform) {
            cycle_start = *cycle_prev;
            cycle_end = count;
            break;
        }
        states.insert(platform.clone(), count);
        for _ in 0..4 {
            platform = tilt(&platform);
            platform = rotate_right(&platform);
        }
        loads.push(calculate_load(&platform));
        count += 1;
    }

    let cycle_len = cycle_end - cycle_start;
    let cycle_index = (1000000000 - cycle_start) % cycle_len;
    println!("{}", loads[cycle_start + cycle_index - 1]);
}
