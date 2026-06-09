package errors

Parse_Error :: struct {
	kind: Error_Kind,
	pos:  int,
	src:  string,
}

Error_Kind :: enum {
	Unclosed_Tag,
	Unknown_Tag,
}
