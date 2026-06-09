package ofarben

import "core:fmt"
import "core:strings"

cprintln :: proc(markup: string, args: ..any) {
	formatted := fmt.tprintf(markup, ..args)
	l := lexer_new(formatted)
	tokens, _ := tokenize(&l)
	result, _ := parse(tokens)
	fmt.println(result)
}
