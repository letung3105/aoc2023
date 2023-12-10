use std::{
    env,
    fs::File,
    io::{prelude::*, BufReader},
};

fn main() {
    let filename = env::args().skip(1).next().expect("no filename");
    let file = File::open(filename).expect("can't open file");
    let mut reader = BufReader::new(file);

    let mut res01 = 0;
    let mut res02 = 0;
    let mut line = String::new();
    while reader.read_line(&mut line).expect("can't read line") > 0 {
        let mut expanded: Vec<Vec<_>> = Vec::new();
        expanded.push(
            line.split_whitespace()
                .map(|x| x.parse::<i32>().expect("can't parse number"))
                .collect(),
        );

        // Expand history.
        while expanded[expanded.len() - 1].iter().any(|x| *x != 0) {
            let history = &expanded[expanded.len() - 1];
            let mut diff = Vec::new();
            for i in 0..history.len() - 1 {
                diff.push(history[i + 1] - history[i]);
            }
            expanded.push(diff);
        }

        // Calculate result.
        let mut extrapolated_forward = 0;
        let mut extrapolated_backward = 0;
        for diff in expanded.iter().rev() {
            extrapolated_forward = extrapolated_forward + diff[diff.len() - 1];
            extrapolated_backward = diff[0] - extrapolated_backward;
        }

        res01 += extrapolated_forward;
        res02 += extrapolated_backward;
        line.clear();
    }

    println!("{res01}");
    println!("{res02}");
}
