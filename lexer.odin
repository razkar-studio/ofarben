// Copyright (c) 2026 RazkarStudio
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from
// the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software in
//    a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

package ofarben

@(private)
Lexer :: struct {
	src:    string,
	cursor: int,
}

@(private)
Token_Text :: struct {
	text: string,
}
@(private)
Token_Tag :: struct {
	raw: string,
	pos: int,
}
@(private)
Token_Close :: struct {
	raw: string,
	pos: int,
}

@(private)
Token :: union {
	Token_Text,
	Token_Tag,
	Token_Close,
}

@(private)
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

@(private)
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
		} else if ch == ']' {
			append(&tokens, Token_Text{"]"})
			advance(lexer, 1)
		} else {
			start := lexer.cursor
			for lexer.cursor < len(lexer.src) && current(lexer^) != '[' && current(lexer^) != ']' {
				advance(lexer)
			}
			append(&tokens, Token_Text{lexer.src[start:lexer.cursor]})
		}
	}
	return tokens[:], nil
}
