package ofarben

@(private = "file")
_stack: [dynamic]Style

parser_init :: proc(allocator := context.allocator) {
	_stack = make([dynamic]Style, allocator)
}

parser_destroy :: proc() {
	delete(_stack)
}

parse :: proc(tokens: []Token, allocator := context.allocator) -> ([]Span, Maybe(Parse_Error))
