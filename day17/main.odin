package main

import "core:bufio"
import "core:container/priority_queue"
import "core:fmt"
import "core:os"
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

State :: struct {
	pos: Position,
	dir: Direction,
	cnt: int,
}

OrderedState :: struct {
	state:     State,
	heat_loss: int,
}

direction_get_next_valid :: proc(dir: Direction) -> (next: [3]Direction) {
	switch dir {
	case .Up:
		next = [3]Direction{.Up, .Left, .Right}
	case .Down:
		next = [3]Direction{.Down, .Right, .Left}
	case .Left:
		next = [3]Direction{.Left, .Down, .Up}
	case .Right:
		next = [3]Direction{.Right, .Up, .Down}
	}
	return next
}

state_move_in_direction :: proc(state: State, dir: Direction) -> State {
	new := state
	new.dir = dir
	if state.dir == dir {
		new.cnt += 1
	} else {
		new.cnt = 1
	}
	switch dir {
	case .Up:
		new.pos.row -= 1
	case .Down:
		new.pos.row += 1
	case .Left:
		new.pos.col -= 1
	case .Right:
		new.pos.col += 1
	}
	return new
}

orrdered_state_less_than :: proc(s1: OrderedState, s2: OrderedState) -> bool {
	return s1.heat_loss < s2.heat_loss
}

find_min_heat_loss :: proc(
	heat_losses: [][]int,
	can_skip_proc: proc(prev_state: State, curr_state: State) -> bool,
	width: int,
	height: int,
) -> int {
	visited := make(map[State]^struct {})
	defer delete(visited)

	min_heat_losses := make([][]int, height)
	defer {
		for row in min_heat_losses do delete(row)
		delete(min_heat_losses)
	}
	for &row, row_id in min_heat_losses {
		row = make([]int, width)
		for &x in row do x = max(int)
	}

	ordered_states_buf: [dynamic]OrderedState
	ordered_states: priority_queue.Priority_Queue(OrderedState)
	priority_queue.init_from_dynamic_array(
		&ordered_states,
		ordered_states_buf,
		orrdered_state_less_than,
		priority_queue.default_swap_proc(OrderedState),
	)
	defer priority_queue.destroy(&ordered_states)

	min_heat_losses[0][0] = 0
	priority_queue.push(&ordered_states, OrderedState{State{Position{0, 0}, .Right, 0}, 0})

	for priority_queue.len(ordered_states) > 0 {
		ordered_state := priority_queue.pop(&ordered_states)
		if _, seen := visited[ordered_state.state]; seen do continue
		visited[ordered_state.state] = nil

		for dir in direction_get_next_valid(ordered_state.state.dir) {
			next_state := state_move_in_direction(ordered_state.state, dir)
			if next_state.pos.col < 0 || next_state.pos.col >= width do continue
			if next_state.pos.row < 0 || next_state.pos.row >= height do continue
			if can_skip_proc(ordered_state.state, next_state) do continue

			new_heat_loss :=
				ordered_state.heat_loss + heat_losses[next_state.pos.row][next_state.pos.col]

			old_min_heat_loss := &min_heat_losses[next_state.pos.row][next_state.pos.col]
			old_min_heat_loss^ = min(old_min_heat_loss^, new_heat_loss)
			priority_queue.push(&ordered_states, OrderedState{next_state, new_heat_loss})
		}
	}

	return min_heat_losses[height - 1][width - 1]
}

main :: proc() {
	file, file_error := os.open(os.args[1])
	if file_error != 0 do panic("unable to open file")
	defer os.close(file)

	reader: bufio.Reader
	buffer: [1024]u8
	file_stream := os.stream_from_handle(file)
	bufio.reader_init_with_buf(&reader, file_stream, buffer[:])

	heat_losses := make([dynamic][]int)
	defer {
		for row in heat_losses do delete(row)
		delete(heat_losses)
	}

	for {
		line, err := bufio.reader_read_string(&reader, '\n')
		if err != nil do break
		defer delete(line)

		trimmed_line := strings.trim_space(line)
		row := make([]int, len(trimmed_line))
		for c, col in trimmed_line do row[col] = int(c - '0')
		append(&heat_losses, row)
	}

	height := len(heat_losses)
	width := 0
	for row in heat_losses do width = max(width, len(row))

	p1 := proc(prev_state: State, curr_state: State) -> bool {
		return curr_state.cnt > 3
	}

	p2 := proc(prev_state: State, curr_state: State) -> bool {
		if curr_state.cnt > 10 do return true
		if curr_state.cnt == 1 && prev_state.cnt > 0 && prev_state.cnt < 4 do return true
		return false
	}

	r1 := find_min_heat_loss(heat_losses[:], p1, width, height)
	r2 := find_min_heat_loss(heat_losses[:], p2, width, height)
	fmt.println(r1)
	fmt.println(r2)
}
