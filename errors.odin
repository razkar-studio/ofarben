package ofarben

Parse_Error :: struct {
	kind: Error_Kind,
	pos:  int,
	src:  string,
}

Error_Kind :: enum {
	Unclosed_Tag,
	Unknown_Tag,
	Unclosed_Parentheses,
	Invalid_Argument_Count,
	Invalid_Argument,
}
