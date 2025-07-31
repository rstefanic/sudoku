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

	fmt.println(board)
}
