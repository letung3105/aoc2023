package main

import "core:bufio"
import "core:container/priority_queue"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

Op :: enum {
	GT,
	LT,
	None,
}

op_from_byte :: proc(b: u8) -> (op: Op) {
	switch b {
	case '>':
		op = .GT
	case '<':
		op = .LT
	case:
		panic("unknown op")
	}
	return
}

Rule :: struct {
	rating_type:    u8,
	op:             Op,
	value:          int,
	workflow_label: string,
}

rule_from_string :: proc(data: string) -> (rule: Rule) {
	rule_parts := strings.split(data, ":")
	if len(rule_parts) == 1 {
		rule.op = .None
		rule.workflow_label = strings.clone(rule_parts[0])
	} else {
		rule_description := rule_parts[0]
		rule.rating_type = rule_description[0]
		rule.op = op_from_byte(rule_description[1])
		if value, ok := strconv.parse_int(rule_description[2:]); ok {
			rule.value = value
		} else {
			panic("unable to parse rule value")
		}
		rule.workflow_label = strings.clone(rule_parts[1])
	}
	return
}

rule_deinit :: proc(rule: ^Rule) {
	delete(rule.workflow_label)
}

Workflow :: struct {
	rules: []Rule,
}

workflow_from_string :: proc(data: string) -> (string, Workflow) {
	rules_begin_idx := strings.index_rune(data, '{')
	label := strings.clone(data[0:rules_begin_idx])
	rule_strings := strings.split(data[rules_begin_idx + 1:len(data) - 1], ",")
	defer delete(rule_strings)

	rules: [dynamic]Rule
	for r in rule_strings {
		rule := rule_from_string(r)
		append(&rules, rule)
	}
	return label, Workflow{rules[:]}
}

workflow_deinit :: proc(workflow: ^Workflow) {
	for &rule in workflow.rules do rule_deinit(&rule)
	delete(workflow.rules)
}

Rating :: struct {
	x: int,
	m: int,
	a: int,
	s: int,
}

rating_get_value_for_type :: proc(rating: Rating, t: u8) -> (value: int) {
	switch t {
	case 'x':
		value = rating.x
	case 'm':
		value = rating.m
	case 'a':
		value = rating.a
	case 's':
		value = rating.s
	case:
		panic("unknown rating type")
	}
	return
}

rating_set_value_for_type :: proc(rating: ^Rating, t: u8, value: int) {
	switch t {
	case 'x':
		rating.x = value
	case 'm':
		rating.m = value
	case 'a':
		rating.a = value
	case 's':
		rating.s = value
	case:
		panic("unknown rating type")
	}
}

rating_from_string :: proc(data: string) -> (rating: Rating) {
	types := strings.split(data[1:len(data) - 1], ",")
	defer delete(types)

	for t in types {
		rating_raw := strings.split(t, "=")
		defer delete(rating_raw)

		ok: bool
		switch rating_raw[0] {
		case "x":
			rating.x, ok = strconv.parse_int(rating_raw[1])
		case "m":
			rating.m, ok = strconv.parse_int(rating_raw[1])
		case "a":
			rating.a, ok = strconv.parse_int(rating_raw[1])
		case "s":
			rating.s, ok = strconv.parse_int(rating_raw[1])
		case:
			panic("unknown rating type")
		}
		if !ok do panic("unable to parse rating value")
	}
	return
}

main :: proc() {
	file, file_error := os.open(os.args[1])
	if file_error != 0 do panic("unable to open file")
	defer os.close(file)

	file_stream := os.stream_from_handle(file)
	buffer: [1024]u8
	scanner: bufio.Scanner
	scanner.split = bufio.scan_lines
	bufio.scanner_init_with_buffer(&scanner, file_stream, buffer[:])

	workflows := make(map[string]Workflow)
	defer {
		for label, &workflow in workflows {
			delete(label)
			workflow_deinit(&workflow)
		}
		delete(workflows)
	}

	for bufio.scanner_scan(&scanner) {
		line := bufio.scanner_text(&scanner)
		trimmed_line := strings.trim_space(line)
		if len(trimmed_line) == 0 do break
		label, workflow := workflow_from_string(trimmed_line)
		workflows[label] = workflow
	}

	ratings := make([dynamic]Rating)
	defer delete(ratings)

	for bufio.scanner_scan(&scanner) {
		line := bufio.scanner_text(&scanner)
		trimmed_line := strings.trim_space(line)
		if len(trimmed_line) == 0 do break
		append(&ratings, rating_from_string(trimmed_line))
	}

	sum := 0
	for rating in ratings {
		label := "in"
		for label != "A" && label != "R" {
			rules_loop: for rule in workflows[label].rules {
				switch rule.op {
				case .GT:
					if rating_get_value_for_type(rating, rule.rating_type) > rule.value {
						label = rule.workflow_label
						break rules_loop
					}
				case .LT:
					if rating_get_value_for_type(rating, rule.rating_type) < rule.value {
						label = rule.workflow_label
						break rules_loop
					}
				case .None:
					label = rule.workflow_label
					break rules_loop
				}
			}
		}
		if label == "A" {
			sum += rating.x + rating.m + rating.a + rating.s
		}
	}

	fmt.println(sum)
}
