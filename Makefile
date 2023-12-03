all: buildrs buildhs buildc buildzig

target/day01rs: day01/main.rs
	rustc -o $@ $?

target/day02rs: day02/main.rs
	rustc -o $@ $?

target/day03rs: day03/main.rs
	rustc -o $@ $?

.PHONY: setup
setup:
	mkdir -p target
