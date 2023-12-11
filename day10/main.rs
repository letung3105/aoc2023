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

#[derive(Debug)]
struct Shape {
    positions: HashSet<(usize, usize)>,
    vertices: Vec<(usize, usize)>,
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
    map_size: usize,
) -> Option<(usize, usize)> {
    match facing {
        Facing::North if position.1 > 0 => Some((position.0, position.1 - 1)),
        Facing::South if position.1 < map_size - 1 => Some((position.0, position.1 + 1)),
        Facing::East if position.0 < map_size - 1 => Some((position.0 + 1, position.1)),
        Facing::West if position.0 > 0 => Some((position.0 - 1, position.1)),
        _ => None,
    }
}

fn is_corner(c: char) -> bool {
    c == 'S' || c == 'F' || c == '7' || c == 'J' || c == 'L'
}

fn find_loop(start_pos: (usize, usize), map: &[Vec<char>]) -> Option<Shape> {
    let map_size = map.len();
    for start_facing in [Facing::North, Facing::South, Facing::East, Facing::West] {
        let mut positions = HashSet::new();
        let mut vertices = Vec::new();
        let mut pos = start_pos;
        let mut facing = start_facing;
        let mut looped = false;
        loop {
            positions.insert(pos);
            if is_corner(map[pos.1][pos.0]) {
                vertices.push(pos);
            }
            if let Some(p) = change_position(pos, facing, map_size) {
                pos = p;
                looped = map[pos.1][pos.0] == 'S';
            } else {
                break;
            };
            if let Some(f) = change_facing(facing, map[pos.1][pos.0]) {
                facing = f;
            } else {
                break;
            };
        }
        if looped {
            return Some(Shape {
                positions,
                vertices,
            });
        }
    }
    None
}

fn part02a(shape: &Shape, map_size: usize) -> usize {
    let n_vertices = shape.vertices.len();
    let vertical_segments: Vec<_> = (0..n_vertices)
        .map(|i| (shape.vertices[i], shape.vertices[(i + 1) % n_vertices]))
        .filter(|(start, stop)| start.0 == stop.0)
        .map(|(start, stop)| Segment { start, stop })
        .collect();
    let mut points = 0;
    for y in 0..map_size {
        for x in 0..map_size {
            let pos = (x, y);
            if shape.positions.contains(&pos) {
                continue;
            }
            // Cast a ray from every point westward and count the number of intersections
            // with vertical segments on the loop. If the number of intersections is odd,
            // the point is inside the loop, otherwise, it is outside the loop.
            let ray = Segment {
                start: (0, pos.1),
                stop: pos,
            };
            let intersections = vertical_segments
                .iter()
                .filter(|s| intersects(s, &ray))
                .count();
            if intersections % 2 == 1 {
                points += 1;
            }
        }
    }
    points
}

fn part02b(shape: &Shape) -> usize {
    let n_positions = shape.positions.len();
    let n_vertices = shape.vertices.len();
    let mut s1 = 0;
    let mut s2 = 0;
    // Apply shoelace formula to calculate the area of a polygon.
    for i in 0..n_vertices {
        let j = (i + 1) % n_vertices;
        let curr = shape.vertices[i];
        let next = shape.vertices[j];
        s1 += curr.0 * next.1;
        s2 += curr.1 * next.0;
    }
    // Apply Pick's theorem to find the number of integer coordinates
    // inside the polygon.
    let area = (s1.max(s2) - s1.min(s2)) / 2;
    area + 1 - n_positions / 2
}

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");
    let mut reader = BufReader::new(file);

    let mut map = Vec::new();
    let mut start_pos = (0, 0);

    let mut line = String::new();
    while reader.read_line(&mut line).expect("can't read line") > 0 {
        let mut row = Vec::new();
        for (i, c) in line.trim().chars().enumerate() {
            row.push(c);
            if c == 'S' {
                start_pos.0 = i;
                start_pos.1 = map.len();
            }
        }
        map.push(row);
        line.clear();
    }

    let map_size = map.len();
    let shape = find_loop(start_pos, &map).expect("no loop found");

    let res01 = shape.positions.len() / 2;
    let res02a = part02a(&shape, map_size);
    let res02b = part02b(&shape);

    println!("{}", res01);
    println!("{}", res02a);
    println!("{}", res02b);
}
