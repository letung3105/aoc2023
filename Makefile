all: buildrs buildhs buildc buildzig

target/day01rs: day01/main.rs
	rustc -o $@ $?

.PHONY: setup
setup:
	mkdir -p target
