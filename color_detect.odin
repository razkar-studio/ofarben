package ofarben

import "base:runtime"
import "core:os"
import "core:strings"
import "core:sys/posix"

import sys_windows "core:sys/windows"

@(private)
_color_support: Color_Support

@(private)
_color_support_stderr: Color_Support

@(init)
_detect_color_support_init :: proc "contextless" () {
	context = runtime.default_context()
	_color_support = detect_color_support(.Stdout)
	_color_support_stderr = detect_color_support(.Stderr)
}

@(private)
Output_Stream :: enum {
	Stdout,
	Stderr,
}

@(private)
Color_Support :: enum {
	None,
	Ansi16,
	Ansi256,
	Truecolor,
}

@(private)
detect_color_support :: proc(
	stream := Output_Stream.Stdout,
	allocator := context.allocator,
) -> Color_Support {
	_, no_color_found := os.lookup_env_alloc("NO_COLOR", allocator)
	if no_color_found do return .None

	_, force_found := os.lookup_env_alloc("CLICOLOR_FORCE", allocator)
	if !force_found do _, force_found = os.lookup_env_alloc("FORCE_COLOR", allocator)

	is_tty: bool
	when ODIN_OS == .Windows {
		handle := os.stdout if stream == .Stdout else os.stderr
		is_tty = sys_windows.GetFileType(sys_windows.HANDLE(handle)) == sys_windows.FILE_TYPE_CHAR
	} else {
		fd: posix.FD = posix.STDOUT_FILENO if stream == .Stdout else posix.STDERR_FILENO
		is_tty = auto_cast posix.isatty(fd)
	}
	if !force_found && !is_tty do return .None

	colorterm, colorterm_found := os.lookup_env_alloc("COLORTERM", allocator)
	defer if colorterm_found do delete(colorterm)
	if colorterm_found {
		if colorterm == "truecolor" || colorterm == "24bit" do return .Truecolor
	}

	term, term_found := os.lookup_env_alloc("TERM", allocator)
	defer if term_found do delete(term)
	if term_found {
		if term == "dumb" do return .None
		if strings.contains(term, "256color") do return .Ansi256
	}

	return .Ansi16
}
