package ofarben

import "base:runtime"
import "core:os"
import "core:strings"
import "core:sys/posix"

import sys_windows "core:sys/windows"

@(private)
_color_support: Color_Support

@(init)
_detect_color_support_init :: proc "contextless" () {
	context = runtime.default_context()
	_color_support = detect_color_support()
}

@(private)
Color_Support :: enum {
	None,
	Ansi16,
	Ansi256,
	Truecolor,
}

@(private)
detect_color_support :: proc(allocator := context.allocator) -> Color_Support {
	_, no_color_found := os.lookup_env_alloc("NO_COLOR", allocator)
	if no_color_found do return .None

	_, force_found := os.lookup_env_alloc("CLICOLOR_FORCE", allocator)
	if !force_found do _, force_found = os.lookup_env_alloc("FORCE_COLOR", allocator)

	is_tty: bool
	when ODIN_OS == .Windows {
		is_tty =
			sys_windows.GetFileType(sys_windows.HANDLE(os.stdout)) == sys_windows.FILE_TYPE_CHAR
	} else {
		is_tty = auto_cast posix.isatty(posix.STDOUT_FILENO)
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
