// An Odin rewrite of the Rust farben terminal coloring library.
//
// ofarben provides a simple markup syntax for terminal colors and styles:
//
// 	ofarben.cprintfln("[bold red]Error:[/] something went wrong.")
//
// Tags are written as `[tag]` and reset with `[/]` or `[/tag]` for partial resets.
// Colors are automatically degraded based on terminal support, and disabled
// when `NO_COLOR` is set or output is not a TTY.
//
// See the Tag Reference in the README for a full list of supported tags.
package ofarben

import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"

@(private = "file")
pipeline :: proc(formatted: string, bleed := false, allocator := context.allocator) -> string {
	l := lexer_new(formatted)
	tokens, tok_maybe_err := tokenize(&l)
	err, ok := tok_maybe_err.?
	if ok {fmt.eprintln(format_error(err)); os.exit(1)}
	result, parse_maybe_err := parse(formatted, tokens, bleed, allocator)
	err, ok = parse_maybe_err.?
	if ok {fmt.eprintln(format_error(err)); os.exit(1)}
	return result
}

@(private = "file")
write_to :: proc(w: io.Writer, result: string, flush: bool) {
	io.write_string(w, result)
}

// Escapes markup brackets in `s` so they display literally through the pipeline.
//
// `[red]` becomes `[[red]]`, which prints as `[red]`.
//
// Inputs:
// - `s`: The string to escape
// - `allocator`: Allocator for the returned string
untag :: proc(s: string, allocator := context.allocator) -> (result: string) {
	s1, _ := strings.replace(s, "[", "[[", -1, allocator)
	s2, _ := strings.replace(s1, "]", "]]", -1, allocator)
	delete(s1)
	result = s2
	return
}

// Strips all ofarben markup tags from `src`, returning plain text.
//
// `[red]hello[/]` becomes `hello`. Escaped brackets `[[` and `]]`
// are preserved as `[` and `]`.
//
// Inputs:
// - `src`: The markup string to strip
// - `allocator`: Allocator for the returned string
unmarkup :: proc(src: string, allocator := context.allocator) -> string {
	sb := strings.builder_make(allocator)
	i := 0
	for i < len(src) {
		if src[i] == '[' {
			if i + 1 < len(src) && src[i + 1] == '[' {
				strings.write_byte(&sb, '[')
				i += 2
				continue
			}
			for i < len(src) && src[i] != ']' {
				i += 1
			}
			i += 1
		} else if src[i] == ']' && i + 1 < len(src) && src[i + 1] == ']' {
			strings.write_byte(&sb, ']')
			i += 2
		} else {
			strings.write_byte(&sb, src[i])
			i += 1
		}
	}
	return strings.to_string(sb)
}

// Strips all ANSI escape sequences from `src`, returning plain text.
//
// Inputs:
// - `src`: The string to strip ANSI codes from
// - `allocator`: Allocator for the returned string
unansi :: proc(src: string, allocator := context.allocator) -> string {
	sb := strings.builder_make(allocator)
	i := 0
	for i < len(src) {
		if src[i] == 0x1b && i + 1 < len(src) && src[i + 1] == '[' {
			i += 2
			for i < len(src) &&
			    !(src[i] >= 'A' && src[i] <= 'Z') &&
			    !(src[i] >= 'a' && src[i] <= 'z') {
				i += 1
			}
			i += 1
		} else {
			strings.write_byte(&sb, src[i])
			i += 1
		}
	}
	return strings.to_string(sb)
}

// Formats and renders markup, returning a temp-allocated styled string.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
csprintf :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintf(markup, ..args), !reset)
}

// Formats and renders markup, returning a temp-allocated styled string with a newline.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
csprintfln :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintfln(markup, ..args), !reset)
}

// Formats args and renders markup, returning a temp-allocated styled string.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
csprint :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprint(..args, sep = sep), !reset)
}

// Formats args and renders markup, returning a temp-allocated styled string with a newline.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
csprintln :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprintln(..args, sep = sep), !reset)
}

// Formats and renders markup, writing the result to stdout.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush stdout after writing
// - `reset`: Whether to reset all styles after rendering
cprintf :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.printf(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

// Formats and renders markup, writing the result to stdout with a newline.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush stdout after writing
// - `reset`: Whether to reset all styles after rendering
cprintfln :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.printfln(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

// Formats args and renders markup, writing the result to stdout.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush stdout after writing
// - `reset`: Whether to reset all styles after rendering
cprint :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.print(pipeline(fmt.tprint(..args, sep = sep), !reset), flush = flush)
}

// Formats args and renders markup, writing the result to stdout with a newline.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush stdout after writing
// - `reset`: Whether to reset all styles after rendering
cprintln :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.println(pipeline(fmt.tprintln(..args, sep = sep), !reset), flush = flush)
}

// Formats and renders markup, writing the result to stderr.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush stderr after writing
// - `reset`: Whether to reset all styles after rendering
ceprintf :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.eprintf(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

// Formats and renders markup, writing the result to stderr with a newline.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush stderr after writing
// - `reset`: Whether to reset all styles after rendering
ceprintfln :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.eprintfln(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

// Formats args and renders markup, writing the result to stderr.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush stderr after writing
// - `reset`: Whether to reset all styles after rendering
ceprint :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.eprint(pipeline(fmt.tprint(..args, sep = sep), !reset), flush = flush)
}

// Formats args and renders markup, writing the result to stderr with a newline.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush stderr after writing
// - `reset`: Whether to reset all styles after rendering
ceprintln :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.eprintln(pipeline(fmt.tprintln(..args, sep = sep), !reset), flush = flush)
}

// Formats args and renders markup, returning a heap-allocated styled string.
//
// The caller is responsible for deleting the returned string.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
// - `allocator`: Allocator for the returned string
caprint :: proc(args: ..any, sep := " ", reset := true, allocator := context.allocator) -> string {
	return pipeline(
		fmt.aprint(..args, sep = sep, allocator = allocator),
		bleed = !reset,
		allocator = allocator,
	)
}

// Formats args and renders markup, returning a heap-allocated styled string with a newline.
//
// The caller is responsible for deleting the returned string.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
// - `allocator`: Allocator for the returned string
caprintln :: proc(
	args: ..any,
	sep := " ",
	reset := true,
	allocator := context.allocator,
) -> string {
	return pipeline(
		fmt.aprintln(..args, sep = sep, allocator = allocator),
		bleed = !reset,
		allocator = allocator,
	)
}

// Formats and renders markup, returning a heap-allocated styled string.
//
// The caller is responsible for deleting the returned string.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
// - `allocator`: Allocator for the returned string
caprintf :: proc(
	markup: string,
	args: ..any,
	reset := true,
	allocator := context.allocator,
) -> string {
	return pipeline(
		fmt.aprintf(markup, ..args, allocator = allocator),
		bleed = !reset,
		allocator = allocator,
	)
}

// Formats and renders markup, returning a heap-allocated styled string with a newline.
//
// The caller is responsible for deleting the returned string.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
// - `allocator`: Allocator for the returned string
caprintfln :: proc(
	markup: string,
	args: ..any,
	reset := true,
	allocator := context.allocator,
) -> string {
	return pipeline(
		fmt.aprintfln(markup, ..args, allocator = allocator),
		bleed = !reset,
		allocator = allocator,
	)
}

// Formats args and renders markup into `buf`, returning the styled string.
//
// Inputs:
// - `buf`: The byte buffer to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
cbprint :: proc(buf: []byte, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.bprint(buf, ..args, sep = sep), !reset)
}

// Formats args and renders markup into `buf`, returning the styled string with a newline.
//
// Inputs:
// - `buf`: The byte buffer to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
cbprintln :: proc(buf: []byte, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.bprintln(buf, ..args, sep = sep), !reset)
}

// Formats and renders markup into `buf`, returning the styled string.
//
// Inputs:
// - `buf`: The byte buffer to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
cbprintf :: proc(buf: []byte, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.bprintf(buf, markup, ..args), !reset)
}

// Formats and renders markup into `buf`, returning the styled string with a newline.
//
// Inputs:
// - `buf`: The byte buffer to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
cbprintfln :: proc(buf: []byte, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.bprintfln(buf, markup, ..args), !reset)
}

// Formats args and renders markup into `buf`, returning the styled string.
//
// Inputs:
// - `buf`: The `strings.Builder` to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
csbprint :: proc(buf: ^strings.Builder, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.sbprint(buf, ..args, sep = sep), !reset)
}

// Formats args and renders markup into `buf`, returning the styled string with a newline.
//
// Inputs:
// - `buf`: The `strings.Builder` to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
csbprintln :: proc(buf: ^strings.Builder, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.sbprintln(buf, ..args, sep = sep), !reset)
}

// Formats and renders markup into `buf`, returning the styled string.
//
// Inputs:
// - `buf`: The `strings.Builder` to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
csbprintf :: proc(buf: ^strings.Builder, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.sbprintf(buf, markup, ..args), !reset)
}

// Formats and renders markup into `buf`, returning the styled string with a newline.
//
// Inputs:
// - `buf`: The `strings.Builder` to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
csbprintfln :: proc(buf: ^strings.Builder, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.sbprintfln(buf, markup, ..args), !reset)
}

// Formats args and renders markup, writing the result to `w`.
//
// Inputs:
// - `w`: The `io.Writer` to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush the writer after writing
// - `reset`: Whether to reset all styles after rendering
cwprint :: proc(w: io.Writer, args: ..any, sep := " ", flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprint(..args, sep = sep), !reset))
}

// Formats args and renders markup, writing the result to `w` with a newline.
//
// Inputs:
// - `w`: The `io.Writer` to write into
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `flush`: Whether to flush the writer after writing
// - `reset`: Whether to reset all styles after rendering
cwprintln :: proc(w: io.Writer, args: ..any, sep := " ", flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintln(..args, sep = sep), !reset))
}

// Formats and renders markup, writing the result to `w`.
//
// Inputs:
// - `w`: The `io.Writer` to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush the writer after writing
// - `reset`: Whether to reset all styles after rendering
cwprintf :: proc(w: io.Writer, markup: string, args: ..any, flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintf(markup, ..args), !reset))
}

// Formats and renders markup, writing the result to `w` with a newline.
//
// Inputs:
// - `w`: The `io.Writer` to write into
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `flush`: Whether to flush the writer after writing
// - `reset`: Whether to reset all styles after rendering
cwprintfln :: proc(w: io.Writer, markup: string, args: ..any, flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintfln(markup, ..args), !reset))
}

// Formats args and renders markup, returning a temp-allocated styled string.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
ctprint :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprint(..args, sep = sep), !reset)
}

// Formats args and renders markup, returning a temp-allocated styled string with a newline.
//
// Inputs:
// - `args`: Arguments to format
// - `sep`: Separator between arguments
// - `reset`: Whether to reset all styles after rendering
ctprintln :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprintln(..args, sep = sep), !reset)
}

// Formats and renders markup, returning a temp-allocated styled string.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
ctprintf :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintf(markup, ..args), !reset)
}

// Formats and renders markup, returning a temp-allocated styled string with a newline.
//
// Inputs:
// - `markup`: A format string with ofarben markup tags
// - `args`: Arguments to format into the markup string
// - `reset`: Whether to reset all styles after rendering
ctprintfln :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintfln(markup, ..args), !reset)
}
