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

// --- --- //

untag :: proc(s: string, allocator := context.allocator) -> string {
	s1, _ := strings.replace(s, "[", "[[", -1, allocator)
	return s1
}

// --- format ---

csprintf :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintf(markup, ..args), !reset)
}

csprintfln :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintfln(markup, ..args), !reset)
}

csprint :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprint(..args, sep = sep), !reset)
}

csprintln :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprintln(..args, sep = sep), !reset)
}

// --- stdout ---

cprintf :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.printf(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

cprintfln :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.printfln(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

cprint :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.print(pipeline(fmt.tprint(..args, sep = sep), !reset), flush = flush)
}

cprintln :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.println(pipeline(fmt.tprintln(..args, sep = sep), !reset), flush = flush)
}

// --- stderr ---

ceprintf :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.eprintf(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

ceprintfln :: proc(markup: string, args: ..any, flush := true, reset := true) {
	fmt.eprintfln(pipeline(fmt.tprintf(markup, ..args), !reset), flush = flush)
}

ceprint :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.eprint(pipeline(fmt.tprint(..args, sep = sep), !reset), flush = flush)
}

ceprintln :: proc(args: ..any, sep := " ", flush := true, reset := true) {
	fmt.eprintln(pipeline(fmt.tprintln(..args, sep = sep), !reset), flush = flush)
}

// --- heap allocated ---

caprint :: proc(args: ..any, sep := " ", reset := true, allocator := context.allocator) -> string {
	return pipeline(
		fmt.aprint(..args, sep = sep, allocator = allocator),
		bleed = !reset,
		allocator = allocator,
	)
}

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

// --- byte buffer ---

cbprint :: proc(buf: []byte, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.bprint(buf, ..args, sep = sep), !reset)
}

cbprintln :: proc(buf: []byte, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.bprintln(buf, ..args, sep = sep), !reset)
}

cbprintf :: proc(buf: []byte, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.bprintf(buf, markup, ..args), !reset)
}

cbprintfln :: proc(buf: []byte, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.bprintfln(buf, markup, ..args), !reset)
}

// --- strings.Builder ---

csbprint :: proc(buf: ^strings.Builder, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.sbprint(buf, ..args, sep = sep), !reset)
}

csbprintln :: proc(buf: ^strings.Builder, args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.sbprintln(buf, ..args, sep = sep), !reset)
}

csbprintf :: proc(buf: ^strings.Builder, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.sbprintf(buf, markup, ..args), !reset)
}

csbprintfln :: proc(buf: ^strings.Builder, markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.sbprintfln(buf, markup, ..args), !reset)
}

// --- writer ---

cwprint :: proc(w: io.Writer, args: ..any, sep := " ", flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprint(..args, sep = sep), !reset))
}

cwprintln :: proc(w: io.Writer, args: ..any, sep := " ", flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintln(..args, sep = sep), !reset))
}

cwprintf :: proc(w: io.Writer, markup: string, args: ..any, flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintf(markup, ..args), !reset))
}

cwprintfln :: proc(w: io.Writer, markup: string, args: ..any, flush := true, reset := true) {
	io.write_string(w, pipeline(fmt.tprintfln(markup, ..args), !reset))
}

// --- temp-allocated ---

ctprint :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprint(..args, sep = sep), !reset)
}

ctprintln :: proc(args: ..any, sep := " ", reset := true) -> string {
	return pipeline(fmt.tprintln(..args, sep = sep), !reset)
}

ctprintf :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintf(markup, ..args), !reset)
}

ctprintfln :: proc(markup: string, args: ..any, reset := true) -> string {
	return pipeline(fmt.tprintfln(markup, ..args), !reset)
}
