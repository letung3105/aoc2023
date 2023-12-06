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

.PHONY: setup
setup:
	mkdir -p target
