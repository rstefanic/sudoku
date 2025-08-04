package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"

main :: proc() {
	// Read command line arguments
	args := os.args[1:]
	if len(args) < 1 {
		fmt.println("Input file required.")
		os.exit(1)
	}

	// Read the file into memory
	filepath := args[0]
	data, ok := os.read_entire_file(filepath, context.allocator) 
	if !ok {
		fmt.println("Could not read file")
		os.exit(1)
	}
	defer delete(data, context.allocator)

	// Parse the file into a board
	board: [9][9]int
	idx := 0
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		row: [9]int
		for c, i in line {
			if i > 8 {
				fmt.printf("Too many numbers in row %d\n", idx + 1)
				os.exit(1)
			}

			s := utf8.runes_to_string([]rune{c})
			n, ok := strconv.parse_int(s)
			if !ok {
				fmt.printf("Error converting %c to a number\n", c)
				os.exit(1)
			}
			row[i] = n
		}

		board[idx] = row
		idx += 1
	}

	fmt.println(verify(board))
}

verify :: proc(board: [9][9]int) -> bool {
	// Rows
	for row, i in board {
		if !verify_group(board[i]) {
			return false
		}
	}

	// Columns
	for i in 0..=8 {
		col: [9]int

		for j in 0..=8 {
			col[j] = board[j][i]
		}

		if !verify_group(col) {
			return false
		}
	}

	// Houses
	houses: [9][9]int
	house_window := struct {
		idx: int,
		start: int,
		end: int,
	} {
		idx = 0,
		start = 0,
		end = 2,
	}
	cell_window := struct {
		idx: int,
		start: int,
		end: int,
	} {
		idx = 0,
		start = 0,
		end = 2,
	}

	for i in 0..=8 {
		if i > 0 && i % 3 == 0 {
			// Advance house window
			house_window.start = house_window.end + 1
			house_window.end += 3
			house_window.idx = house_window.start

			// Reset cell window
			cell_window.idx = 0
			cell_window.start = 0
			cell_window.end = 2
		}

		for j in 0..=8 {
			n := board[i][j]

			// Switch to next house every 3 values
			if j > 0 && j % 3 == 0 {
				if house_window.idx + 1 > house_window.end {
					house_window.idx = house_window.start
				} else {
					house_window.idx += 1
				}
			}

			houses[house_window.idx][cell_window.idx] = n

			// Increment the target house cell
			if cell_window.idx + 1 > cell_window.end {
				cell_window.idx = cell_window.start
			} else {
				cell_window.idx += 1
			}
		}

		// Reset the house window and advance the cell window
		house_window.idx = house_window.start
		cell_window.start = cell_window.end + 1
		cell_window.end += 3
		cell_window.idx = cell_window.start
	}

	for house in houses {
		if !verify_group(house) {
			return false
		}
	}

	return true
}

verify_group:: proc(group: [9]int) -> bool {
	used := make(map[int]bool)
	defer delete(used)

	for n in group {
		used[n] = true
	}

	for i in 1..=9 {
		_, ok := used[i]
		if !ok {
			return false
		}
	}

	return true
}
