use std::{
    fs::File,
    io::{BufRead, BufReader},
};

fn main() {
    let path = std::env::args().skip(1).next().expect("missing input path");
    let file = File::open(path).expect("unable to read file");
    let reader = BufReader::new(file);

    let lines = reader
        .lines()
        .map(|l| l.expect("unable to read line"))
        .collect::<Vec<_>>();

    let result = part01(&lines);
    println!("{}", result);

    let result = part02(&lines);
    println!("{}", result);
}

fn part01(lines: &[String]) -> u32 {
    let mut sum = 0;
    for line in lines {
        let mut game_input = line.split(": ");
        let game_id: u32 = game_input
            .next()
            .and_then(|game_id| game_id.split(' ').skip(1).next())
            .expect("missing game id")
            .parse()
            .expect("invalid game id");

        let mut is_valid = true;
        'game_loop: for set in game_input.next().expect("missing game sets").split("; ") {
            for entry in set.split(", ") {
                let mut splitted = entry.split(' ');
                let count = splitted
                    .next()
                    .and_then(|count| count.parse::<u32>().ok())
                    .expect("missing count");

                let color = splitted.next().expect("missing color");
                if color == "red" && count > 12 {
                    is_valid = false;
                    break 'game_loop;
                }
                if color == "green" && count > 13 {
                    is_valid = false;
                    break 'game_loop;
                }
                if color == "blue" && count > 14 {
                    is_valid = false;
                    break 'game_loop;
                }
            }
        }

        if is_valid {
            sum += game_id;
        }
    }
    sum
}

fn part02(lines: &[String]) -> u32 {
    let mut sum = 0;
    for line in lines {
        let mut maxes = [0, 0, 0];
        for set in line
            .split(": ")
            .skip(1)
            .next()
            .expect("missing game sets")
            .split("; ")
        {
            for entry in set.split(", ") {
                let mut splitted = entry.split(' ');
                let count = splitted
                    .next()
                    .and_then(|count| count.parse::<u32>().ok())
                    .expect("missing count");

                let color = splitted.next().expect("missing color");
                if color == "red" {
                    maxes[0] = maxes[0].max(count);
                }
                if color == "green" {
                    maxes[1] = maxes[1].max(count);
                }
                if color == "blue" {
                    maxes[2] = maxes[2].max(count);
                }
            }
        }
        sum += maxes.iter().product::<u32>();
    }
    sum
}
