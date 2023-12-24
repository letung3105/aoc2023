all: buildrs buildhs buildc buildzig

target/day01rs: day01/main.rs
	rustc -o $@ $?

target/day02rs: day02/main.rs
	rustc -o $@ $?

target/day03rs: day03/main.rs
	rustc -o $@ $?

target/day04nim: day04/main.nim
	nim c -o:$@ $?

target/day05nim: day05/main.nim
	nim c -o:$@ $?

target/day06nim: day06/main.nim
	nim c -o:$@ $?

target/day07nim: day07/main.nim
	nim c -o:$@ $?

target/day08nim: day08/main.nim
	nim c -o:$@ $?

target/day09nim: day09/main.nim
	nim c -o:$@ $?

target/day09rs: day09/main.rs
	rustc -o $@ $?

target/day10rs: day10/main.rs
	rustc -o $@ $?

target/day11rs: day11/main.rs
	rustc -o $@ $?

target/day12rs: day12/main.rs
	rustc -o $@ $?

target/day13rs: day13/main.rs
	rustc -o $@ $?

target/day14rs: day14/main.rs
	rustc -o $@ $?

target/day15odin: day15/main.odin
	odin build $? -file -out:$@

target/day16odin: day16/main.odin
	odin build $? -file -out:$@

target/day17odin: day17/main.odin
	odin build $? -file -out:$@

target/day18odin: day18/main.odin
	odin build $? -file -out:$@

target/day19odin: day19/main.odin
	odin build $? -file -out:$@

.PHONY: setup
setup:
	mkdir -p target
