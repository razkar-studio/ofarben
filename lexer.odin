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
}
Token_Close :: struct {
	raw: string,
}

Token :: union {
	Token_Text,
	Token_Tag,
	Token_Close,
}
