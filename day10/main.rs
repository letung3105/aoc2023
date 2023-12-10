use std::{
    collections::HashSet,
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

#[derive(Debug, Copy, Clone)]
enum Facing {
    North,
    South,
    East,
    West,
}

#[derive(Debug)]
struct Segment {
    start: (usize, usize),
    stop: (usize, usize),
}

fn intersects(vertical: &Segment, horizontal: &Segment) -> bool {
    let intersect_x = vertical.start.0 >= horizontal.start.0.min(horizontal.stop.0)
        && vertical.start.0 < horizontal.start.0.max(horizontal.stop.0);
    let intersect_y = horizontal.start.1 >= vertical.start.1.min(vertical.stop.1)
        && horizontal.start.1 < vertical.start.1.max(vertical.stop.1);
    intersect_x && intersect_y
}

fn change_facing(facing: Facing, current: char) -> Option<Facing> {
    match facing {
        Facing::North if current == '|' => Some(Facing::North),
        Facing::North if current == '7' => Some(Facing::West),
        Facing::North if current == 'F' => Some(Facing::East),
        Facing::South if current == '|' => Some(Facing::South),
        Facing::South if current == 'J' => Some(Facing::West),
        Facing::South if current == 'L' => Some(Facing::East),
        Facing::East if current == '-' => Some(Facing::East),
        Facing::East if current == 'J' => Some(Facing::North),
        Facing::East if current == '7' => Some(Facing::South),
        Facing::West if current == '-' => Some(Facing::West),
        Facing::West if current == 'L' => Some(Facing::North),
        Facing::West if current == 'F' => Some(Facing::South),
        _ => None,
    }
}

fn change_position(
    position: (usize, usize),
    facing: Facing,
    width: usize,
    height: usize,
) -> Option<(usize, usize)> {
    match facing {
        Facing::North if position.1 > 0 => Some((position.0, position.1 - 1)),
        Facing::South if position.1 < height - 1 => Some((position.0, position.1 + 1)),
        Facing::East if position.0 < width - 1 => Some((position.0 + 1, position.1)),
        Facing::West if position.0 > 0 => Some((position.0 - 1, position.1)),
        _ => None,
    }
}

fn is_corner(c: char) -> bool {
    c == 'S' || c == 'F' || c == '7' || c == 'J' || c == 'L'
}

fn find_loop(
    start_pos: (usize, usize),
    map: &[Vec<char>],
) -> Option<(HashSet<(usize, usize)>, Vec<Segment>)> {
    let height = map.len();
    let width = map[height - 1].len();
    for start_facing in [Facing::North, Facing::South, Facing::East, Facing::West] {
        let mut pos = start_pos;
        let mut pos_corner = pos;
        let mut facing = start_facing;
        let mut pos_on_loop = HashSet::new();
        let mut vertical_segments = Vec::new();
        let mut looped = false;
        loop {
            pos_on_loop.insert(pos);
            if let Some(p) = change_position(pos, facing, width, height) {
                pos = p;
                looped = map[pos.1][pos.0] == 'S';
            } else {
                break;
            };
            if is_corner(map[pos.1][pos.0]) {
                if pos_corner.0 == pos.0 {
                    vertical_segments.push(Segment {
                        start: pos_corner,
                        stop: pos,
                    });
                }
                pos_corner = pos;
            }
            if let Some(f) = change_facing(facing, map[pos.1][pos.0]) {
                facing = f;
            } else {
                break;
            };
        }
        if looped {
            return Some((pos_on_loop, vertical_segments));
        }
    }
    None
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");
    let mut reader = BufReader::new(file);

    let mut map = Vec::new();
    let mut start_pos = (0, 0);

    let mut line = String::new();
    while reader.read_line(&mut line).expect("can't read line") > 0 {
        let row: Vec<_> = line.chars().collect();
        for (i, c) in row.iter().enumerate() {
            if *c == 'S' {
                start_pos.0 = i;
                start_pos.1 = map.len();
            }
        }
        map.push(row);
        line.clear();
    }

    let (pos_on_loop, vertical_segments) = find_loop(start_pos, &map).expect("no loop found");
    let res01 = pos_on_loop.len() / 2;
    let mut res02 = 0;

    for (y, row) in map.iter().enumerate() {
        for x in 0..row.len() {
            let pos = (x, y);
            if pos_on_loop.contains(&pos) {
                continue;
            }
            let ray = Segment {
                start: (0, pos.1),
                stop: pos,
            };
            let intersections = vertical_segments
                .iter()
                .filter(|s| intersects(s, &ray))
                .count();
            if intersections % 2 == 1 {
                res02 += 1;
            }
        }
    }

    println!("{}", res01);
    println!("{}", res02);
}
