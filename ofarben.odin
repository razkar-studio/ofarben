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
	result, parse_maybe_err := parse(formatted, tokens, bleed)
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

csprintf :: proc(markup: string, args: ..any) -> string {
	return pipeline(fmt.tprintf(markup, ..args))
}

csprintfln :: proc(markup: string, args: ..any) -> string {
	return pipeline(fmt.tprintfln(markup, ..args))
}

csprint :: proc(args: ..any, sep := " ") -> string {
	return pipeline(fmt.tprint(..args, sep = sep))
}

csprintln :: proc(args: ..any, sep := " ") -> string {
	return pipeline(fmt.tprintln(..args, sep = sep))
}

// --- stdout ---

cprintf :: proc(markup: string, args: ..any, flush := true) {
	fmt.printf(pipeline(fmt.tprintf(markup, ..args)), flush = flush)
}

cprintfln :: proc(markup: string, args: ..any, flush := true) {
	fmt.printfln(pipeline(fmt.tprintf(markup, ..args)), flush = flush)
}

cprint :: proc(args: ..any, sep := " ", flush := true) {
	fmt.print(pipeline(fmt.tprint(..args, sep = sep)), flush = flush)
}

cprintln :: proc(args: ..any, sep := " ", flush := true) {
	fmt.println(pipeline(fmt.tprintln(..args, sep = sep)), flush = flush)
}

// --- stderr ---

ceprintf :: proc(markup: string, args: ..any, flush := true) {
	fmt.eprintf(pipeline(fmt.tprintf(markup, ..args)), flush = flush)
}

ceprintfln :: proc(markup: string, args: ..any, flush := true) {
	fmt.eprintfln(pipeline(fmt.tprintf(markup, ..args)), flush = flush)
}

ceprint :: proc(args: ..any, sep := " ", flush := true) {
	fmt.eprint(pipeline(fmt.tprint(..args, sep = sep)), flush = flush)
}

ceprintln :: proc(args: ..any, sep := " ", flush := true) {
	fmt.eprintln(pipeline(fmt.tprintln(..args, sep = sep)), flush = flush)
}

// --- heap allocated ---

caprint :: proc(args: ..any, sep := " ", allocator := context.allocator) -> string {
	return pipeline(fmt.aprint(..args, sep = sep, allocator = allocator), allocator = allocator)
}

caprintln :: proc(args: ..any, sep := " ", allocator := context.allocator) -> string {
	return pipeline(fmt.aprintln(..args, sep = sep, allocator = allocator), allocator = allocator)
}

caprintf :: proc(markup: string, args: ..any, allocator := context.allocator) -> string {
	return pipeline(fmt.aprintf(markup, ..args, allocator = allocator), allocator = allocator)
}

caprintfln :: proc(markup: string, args: ..any, allocator := context.allocator) -> string {
	return pipeline(fmt.aprintfln(markup, ..args, allocator = allocator), allocator = allocator)
}

// --- byte buffer ---

cbprint :: proc(buf: []byte, args: ..any, sep := " ") -> string {
	return pipeline(fmt.bprint(buf, ..args, sep = sep))
}

cbprintln :: proc(buf: []byte, args: ..any, sep := " ") -> string {
	return pipeline(fmt.bprintln(buf, ..args, sep = sep))
}

cbprintf :: proc(buf: []byte, markup: string, args: ..any) -> string {
	return pipeline(fmt.bprintf(buf, markup, ..args))
}

cbprintfln :: proc(buf: []byte, markup: string, args: ..any) -> string {
	return pipeline(fmt.bprintfln(buf, markup, ..args))
}

// --- strings.Builder ---

csbprint :: proc(buf: ^strings.Builder, args: ..any, sep := " ") -> string {
	return pipeline(fmt.sbprint(buf, ..args, sep = sep))
}

csbprintln :: proc(buf: ^strings.Builder, args: ..any, sep := " ") -> string {
	return pipeline(fmt.sbprintln(buf, ..args, sep = sep))
}

csbprintf :: proc(buf: ^strings.Builder, markup: string, args: ..any) -> string {
	return pipeline(fmt.sbprintf(buf, markup, ..args))
}

csbprintfln :: proc(buf: ^strings.Builder, markup: string, args: ..any) -> string {
	return pipeline(fmt.sbprintfln(buf, markup, ..args))
}

// --- writer ---

cwprint :: proc(w: io.Writer, args: ..any, sep := " ", flush := true) {
	io.write_string(w, pipeline(fmt.tprint(..args, sep = sep)))
}

cwprintln :: proc(w: io.Writer, args: ..any, sep := " ", flush := true) {
	io.write_string(w, pipeline(fmt.tprintln(..args, sep = sep)))
}

cwprintf :: proc(w: io.Writer, markup: string, args: ..any, flush := true) {
	io.write_string(w, pipeline(fmt.tprintf(markup, ..args)))
}

cwprintfln :: proc(w: io.Writer, markup: string, args: ..any, flush := true) {
	io.write_string(w, pipeline(fmt.tprintfln(markup, ..args)))
}

// --- temp-allocated ---

ctprint :: proc(args: ..any, sep := " ") -> string {
	return pipeline(fmt.tprint(..args, sep = sep))
}

ctprintln :: proc(args: ..any, sep := " ") -> string {
	return pipeline(fmt.tprintln(..args, sep = sep))
}

ctprintf :: proc(markup: string, args: ..any) -> string {
	return pipeline(fmt.tprintf(markup, ..args))
}

ctprintfln :: proc(markup: string, args: ..any) -> string {
	return pipeline(fmt.tprintfln(markup, ..args))
}
