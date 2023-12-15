package main

import "core:bufio"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"

HashMapEntry :: struct {
	key:   []u8,
	value: int,
}

hash_map_entry_key_equal :: proc "contextless" (entry: ^HashMapEntry, key: []u8) -> bool {
	if len(key) != len(entry.key) do return false
	for i in 0 ..< len(entry.key) {
		if entry.key[i] != key[i] do return false
	}
	return true
}

HashMap :: struct {
	boxes: [256][dynamic]HashMapEntry,
}

hashmap_hash :: proc "contextless" (key: []u8) -> (hash: int) {
	for b in key {
		hash += int(b)
		hash *= 17
		hash %= 256
	}
	return
}

hashmap_deinit :: proc(hashmap: ^HashMap) {
	for &box in hashmap.boxes do delete(box)
}

hashmap_insert :: proc(hashmap: ^HashMap, key: []u8, value: int) {
	chain := &hashmap.boxes[hashmap_hash(key)]
	for &entry in chain {
		if hash_map_entry_key_equal(&entry, key) {
			entry.value = value
			return
		}
	}
	append(chain, HashMapEntry{key, value})
}

hashmap_remove :: proc(hashmap: ^HashMap, key: []u8) {
	chain := &hashmap.boxes[hashmap_hash(key)]
	for &entry, idx in chain {
		if hash_map_entry_key_equal(&entry, key) {
			ordered_remove(chain, idx)
			return
		}
	}
}

main :: proc() {
	input, ok := os.read_entire_file(os.args[1])
	if !ok do return
	defer delete(input)

	part01 := 0
	part02 := 0

	hashmap: HashMap
	defer hashmap_deinit(&hashmap)

	it := string(input)
	for inst in strings.split_by_byte_iterator(&it, ',') {
		inst_len := len(inst)
		part01 += hashmap_hash(transmute([]u8)inst)
		if inst[inst_len - 1] == '-' {
			hashmap_remove(&hashmap, transmute([]u8)inst[:inst_len - 1])
		} else {
			insertion := strings.split(inst, "=")
			defer delete(insertion)
			if focal, ok := strconv.parse_int(insertion[1]); ok {
				label := transmute([]u8)insertion[0]
				hashmap_insert(&hashmap, label, focal)
			}
		}
	}

	for box, i in hashmap.boxes {
		for &entry, j in box {
			part02 += (i + 1) * (j + 1) * entry.value
		}
	}

	fmt.println(part01)
	fmt.println(part02)
}
