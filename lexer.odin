package ofarben

Lexer :: struct {
	src:    string,
	cursor: int,
}

Token_Text :: struct {
	text: string,
}
Token_Tag :: struct {
	raw: string,
	pos: int,
}
Token_Close :: struct {
	raw: string,
	pos: int,
}

Token :: union {
	Token_Text,
	Token_Tag,
	Token_Close,
}

lexer_new :: proc(src: string) -> Lexer {
	return Lexer{src = src}
}

@(private = "file")
peek :: proc(lexer: Lexer) -> u8 {
	if lexer.cursor + 1 >= len(lexer.src) do return 0
	return lexer.src[lexer.cursor + 1]
}

@(private = "file")
advance :: proc(lexer: ^Lexer, count := 1) {
	if lexer.cursor < len(lexer.src) do lexer.cursor += count
}

@(private = "file")
current :: proc(lexer: Lexer) -> u8 {
	return lexer.src[lexer.cursor]
}

tokenize :: proc(lexer: ^Lexer, allocator := context.allocator) -> ([]Token, Maybe(Parse_Error)) {
	tokens := make([dynamic]Token, allocator)
	for lexer.cursor < len(lexer.src) {
		ch := current(lexer^)
		if ch == '[' {
			if peek(lexer^) == '[' {
				append(&tokens, Token_Text{"["})
				advance(lexer, 2)
			} else {
				tag_start := lexer.cursor
				advance(lexer)
				start := lexer.cursor
				for lexer.cursor < len(lexer.src) && current(lexer^) != ']' {
					advance(lexer)
				}
				if lexer.cursor >= len(lexer.src) {
					return tokens[:], Parse_Error {
						kind = .Unclosed_Tag,
						pos = tag_start,
						src = lexer.src,
					}
				}
				if tag_content := lexer.src[start:lexer.cursor]; len(tag_content) == 0 {
					append(&tokens, Token_Text{""})
				} else if tag_content[0] == '/' {
					append(&tokens, Token_Close{tag_content[1:], start})
				} else {
					append(&tokens, Token_Tag{tag_content, start})
				}
				advance(lexer)
			}
		} else if ch == ']' && peek(lexer^) == ']' {
			append(&tokens, Token_Text{"]"})
			advance(lexer, 2)
		} else {
			start := lexer.cursor
			for lexer.cursor < len(lexer.src) && current(lexer^) != '[' {
				advance(lexer)
			}
			append(&tokens, Token_Text{lexer.src[start:lexer.cursor]})
		}
	}
	return tokens[:], nil
}
