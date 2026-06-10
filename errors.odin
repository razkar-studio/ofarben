package ofarben

import "core:fmt"
import "core:strconv"
import "core:strings"

// what the fuck am I doing
// it's working though
// beautifully

@(private)
Parse_Error :: struct {
	kind:      Error_Kind,
	pos:       int,
	src:       string,
	raw:       string,
	value_pos: int,
	// Invalid_Argument_Count //
	expected:  int,
	got:       int,
	// Invalid_Argument //
	value:     string,
	type_name: string,
}

@(private)
Error_Kind :: enum {
	Unclosed_Tag,
	Unknown_Tag,
	Unclosed_Parentheses,
	Invalid_Argument_Count,
	Invalid_Argument,
}

@(private)
format_error :: proc(error: Parse_Error) -> (result: string) {
	pos := error.value_pos if error.value_pos > 0 else error.pos
	src := error.src

	line := 1
	col := 1
	for i := 0; i < pos; i += 1 {
		if src[i] == '\n' {
			line += 1
			col = 1
		} else {
			col += 1
		}
	}

	line_start := pos
	for line_start > 0 && src[line_start - 1] != '\n' {
		line_start -= 1
	}
	line_end := pos
	for line_end < len(src) && src[line_end] != '\n' {
		line_end += 1
	}
	line_text := src[line_start:line_end]

	caret_len := len(error.value) if error.value_pos > 0 else len(error.raw)
	carets := strings.repeat("~", max(0, caret_len - 1))
	defer delete(carets)

	kind_str: string
	switch error.kind {
	case .Unknown_Tag:
		kind_str = "Unknown tag"
	case .Unclosed_Tag:
		kind_str = "Unclosed tag"
	case .Unclosed_Parentheses:
		kind_str = "Unclosed parentheses"
	case .Invalid_Argument:
		kind_str = "Invalid argument"
	case .Invalid_Argument_Count:
		kind_str = "Invalid argument count"
	}

	if error.kind == .Unclosed_Tag {
		result = ctprintf(
			"[bold dim]input(%d:%d)[/] [red]Error:[/] %v\n\t[dim]%s[/]\n\t[green]%s^%s[/]",
			line,
			col,
			kind_str,
			untag(line_text),
			strings.repeat(" ", col - 1),
			carets,
		)
	} else if error.kind == .Invalid_Argument_Count {
		result = ctprintf(
			"[bold dim]input(%d:%d)[/] [red]Error:[/] %v: expected %d, got %d\n\t[dim]%s[/]\n\t[green]%s^%s[/]",
			line,
			col,
			kind_str,
			error.expected,
			error.got,
			untag(line_text),
			strings.repeat(" ", col - 1),
			carets,
		)
	} else if error.kind == .Invalid_Argument {
		value_str: string
		if _, ok := strconv.parse_uint(error.value); ok {
			value_str = fmt.tprintf("%s", error.value)
		} else {
			value_str = fmt.tprintf("'%s'", error.value)
		}
		result = ctprintf(
			"[bold dim]input(%d:%d)[/] [red]Error:[/] %v: expected %s, got %v\n\t[dim]%s[/]\n\t[green]%s^%s[/]",
			line,
			col,
			kind_str,
			error.type_name,
			value_str,
			untag(line_text),
			strings.repeat(" ", col - 1),
			carets,
		)
	} else {
		result = ctprintf(
			"[bold dim]input(%d:%d)[/] [red]Error:[/] %v: %s\n\t[dim]%s[/]\n\t[bold green]%s^%s[/]",
			line,
			col,
			kind_str,
			error.raw,
			untag(line_text),
			strings.repeat(" ", col - 1),
			carets,
		)
	}
	return
}
