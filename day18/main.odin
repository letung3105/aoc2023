package main

import "core:bufio"
import "core:container/priority_queue"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

Position :: struct {
	row: int,
	col: int,
}

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

Instruction :: struct {
	dir: Direction,
	len: int,
}

position_get_distance_between :: proc(p1: Position, p2: Position) -> int {
	return math.abs(p1.row - p2.row) + math.abs(p1.col - p2.col)
}

instruction_parse1 :: proc(line: []string) -> Instruction {
	inst_dir: Direction
	switch line[0] {
	case "U":
		inst_dir = .Up
	case "D":
		inst_dir = .Down
	case "L":
		inst_dir = .Left
	case "R":
		inst_dir = .Right
	}

	inst_len: int
	if x, ok := strconv.parse_int(line[1]); ok {
		inst_len = x
	} else {
		panic("unable to parse int")
	}

	return Instruction{inst_dir, inst_len}
}

instruction_parse2 :: proc(line: []string) -> Instruction {
	inst_dir: Direction
	switch line[2][7] {
	case '0':
		inst_dir = .Right
	case '1':
		inst_dir = .Down
	case '2':
		inst_dir = .Left
	case '3':
		inst_dir = .Up
	}

	inst_len: int
	if x, ok := strconv.parse_int(line[2][2:7], 16); ok {
		inst_len = x
	} else {
		panic("unable to parse int")
	}

	return Instruction{inst_dir, inst_len}
}

vertices_from_instructions :: proc(instructions: []Instruction) -> ([]Position, int) {
	positions_on_edge := 0
	vertices: [dynamic]Position
	append(&vertices, Position{0, 0})
	for inst in instructions {
		vertex := vertices[len(vertices) - 1]
		switch inst.dir {
		case .Up:
			vertex.row -= inst.len
		case .Down:
			vertex.row += inst.len
		case .Left:
			vertex.col -= inst.len
		case .Right:
			vertex.col += inst.len
		}
		positions_on_edge += inst.len
		if vertex != vertices[len(vertices) - 1] do append(&vertices, vertex)
	}
	return vertices[:], positions_on_edge
}

get_area :: proc(vertices: []Position) -> int {
	s1 := 0
	s2 := 0
	for i in 0 ..< len(vertices) {
		j := (i + 1) % len(vertices)
		curr := vertices[i]
		next := vertices[j]
		s1 += curr.row * next.col
		s2 += curr.col * next.row
	}
	return math.abs(s1 - s2) / 2
}

main :: proc() {
	file, file_error := os.open(os.args[1])
	if file_error != 0 do panic("unable to open file")
	defer os.close(file)

	instructions1 := make([dynamic]Instruction)
	defer delete(instructions1)

	instructions2 := make([dynamic]Instruction)
	defer delete(instructions2)

	file_stream := os.stream_from_handle(file)
	buffer: [1024]u8
	scanner: bufio.Scanner
	scanner.split = bufio.scan_lines
	bufio.scanner_init_with_buffer(&scanner, file_stream, buffer[:])

	for bufio.scanner_scan(&scanner) {
		line := bufio.scanner_text(&scanner)
		trimmed_line := strings.trim_space(line)

		instruction_idx := 0
		instruction_raw: [3]string
		for str in strings.split_iterator(&trimmed_line, " ") {
			instruction_raw[instruction_idx] = str
			instruction_idx += 1
		}
		append(&instructions1, instruction_parse1(instruction_raw[:]))
		append(&instructions2, instruction_parse2(instruction_raw[:]))
	}

	parts := [2][]Instruction{instructions1[:], instructions2[:]}
	for instructions in parts {
		vertices, positions_on_edge := vertices_from_instructions(instructions[:])
		defer delete(vertices)
		area := get_area(vertices[:])
		positions_inner := area + 1 - positions_on_edge / 2
		positions_total := positions_inner + positions_on_edge
		fmt.println(positions_total)
	}
}
