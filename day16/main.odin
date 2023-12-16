package main

import "core:bufio"
import "core:container/queue"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"

Facing :: enum {
	Up,
	Down,
	Left,
	Right,
}

Position :: struct {
	row: int,
	col: int,
}

LightBeam :: struct {
	position: Position,
	facing:   Facing,
}

position_change :: proc(position: Position, facing: Facing) -> Position {
	switch facing {
	case .Up:
		return Position{position.row - 1, position.col}
	case .Down:
		return Position{position.row + 1, position.col}
	case .Left:
		return Position{position.row, position.col - 1}
	case .Right:
		return Position{position.row, position.col + 1}
	}
	return position
}

position_is_valid :: proc(position: Position, width: int, height: int) -> bool {
	return position.row >= 0 && position.row < height && position.col >= 0 && position.col < width
}

queue_next_light_beam :: proc(
	running_beams: ^queue.Queue(LightBeam),
	position: Position,
	facings: []Facing,
	width: int,
	height: int,
) {
	for facing in facings {
		pos := position_change(position, facing)
		if position_is_valid(pos, width, height) {
			queue.push_back(running_beams, LightBeam{pos, facing})
		}
	}
}

count_energized_cells :: proc(schema: []string, start: LightBeam) -> int {
	height := len(schema)
	width := len(schema[0])

	states := make(map[LightBeam]struct {})
	defer delete(states)

	visited := make(map[Position]struct {})
	defer delete(visited)

	running_beams: queue.Queue(LightBeam)
	defer queue.destroy(&running_beams)

	queue.init(&running_beams)
	queue.push_back(&running_beams, start)

	energized_cells := 0
	for queue.len(running_beams) > 0 {
		beam := queue.pop_front(&running_beams)
		if _, ok := states[beam]; ok {
			continue
		}

		states[beam] = {}
		if _, ok := visited[beam.position]; !ok {
			energized_cells += 1
			visited[beam.position] = {}
		}

		item := schema[beam.position.row][beam.position.col]
		if item == '-' && (beam.facing == .Up || beam.facing == .Down) {
			facings := [?]Facing{Facing.Left, Facing.Right}
			queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
		} else if item == '|' && (beam.facing == .Left || beam.facing == .Right) {
			facings := [?]Facing{Facing.Up, Facing.Down}
			queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
		} else if item == '/' {
			switch beam.facing {
			case .Up:
				facings := [?]Facing{Facing.Right}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Down:
				facings := [?]Facing{Facing.Left}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Left:
				facings := [?]Facing{Facing.Down}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Right:
				facings := [?]Facing{Facing.Up}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			}
		} else if item == '\\' {
			switch beam.facing {
			case .Up:
				facings := [?]Facing{Facing.Left}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Down:
				facings := [?]Facing{Facing.Right}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Left:
				facings := [?]Facing{Facing.Up}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			case .Right:
				facings := [?]Facing{Facing.Down}
				queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
			}
		} else {
			facings := [?]Facing{beam.facing}
			queue_next_light_beam(&running_beams, beam.position, facings[:], width, height)
		}
	}
	return energized_cells
}

main :: proc() {
	file, file_error := os.open(os.args[1])
	if file_error != 0 {
		fmt.printf("unable to open file (code %d)\n", file_error)
		return
	}
	defer os.close(file)

	schema: [dynamic]string
	defer {
		for line in schema do delete(line)
		delete(schema)
	}

	reader: bufio.Reader
	buffer: [1024]u8
	file_stream := os.stream_from_handle(file)
	bufio.reader_init_with_buf(&reader, file_stream, buffer[:])

	for {
		line, err := bufio.reader_read_string(&reader, '\n')
		if err != nil do break
		defer delete(line)
		append(&schema, strings.clone(strings.trim_space(line)))
	}

	part01 := count_energized_cells(schema[:], LightBeam{Position{0, 0}, Facing.Right})
	part02 := 0

	height := len(schema)
	width := len(schema[0])
	for row in 0 ..< height {
		part02 = max(
			part02,
			count_energized_cells(schema[:], LightBeam{Position{row, 0}, Facing.Right}),
		)
		part02 = max(
			part02,
			count_energized_cells(schema[:], LightBeam{Position{row, width - 1}, Facing.Left}),
		)
	}
	for col in 0 ..< width {
		part02 = max(
			part02,
			count_energized_cells(schema[:], LightBeam{Position{0, col}, Facing.Down}),
		)
		part02 = max(
			part02,
			count_energized_cells(schema[:], LightBeam{Position{height - 1, col}, Facing.Up}),
		)
	}

	fmt.println(part01)
	fmt.println(part02)
}
