package example

import "core:fmt"
//# Showcase of oFarben's features and idioms.
//# Run with: odin run example

//! Import as frb shorthand
import frb ".." //< replace with path to oFarben

/*
	oFarben uses a simple markup syntax for terminal styling.
	Tags are written as `[tag]` and reset with `[/]`.

	To escape a tag within an oFarben call, write `[[` and `]]`
	respectively.

	Partial resets are supported: `[/tag]` removes a specific style,
	keeping everything else active. For example, `[bold red]text[/red]`
	leaves bold active after removing red.

	Styles can bleed across calls by setting `reset = false`.
	This is useful for multi-line output that shares the same style.
	The next `[/]` or a call with `reset = true` (the default) ends the bleed.

	Color detection is automatic, oFarben respects `NO_COLOR`,
	`CLICOLOR_FORCE`, and `COLORTERM`, and degrades colors based on
	terminal support (Truecolor -> ANSI256 -> 16 colors -> nothing).

	You can try!

	    NO_COLOR=1 odin run example # no colors
		COLORTERM=0 TERM=0 odin run example # named colors only
		odin run example # full color
*/

main :: proc() {
	//? oFarben supports named colors like so.
	//? Prefix with `bg:` for background, `fg:` is optional for foreground
	frb.cprintfln(
		"[red]red[/] [green]green[/] [blue]blue[/] [yellow]yellow[/] [magenta]magenta[/] [cyan]cyan[/]",
	)
	frb.cprintfln(
		"[bright-red]bright-red[/] [bright-green]bright-green[/] [bright-blue]bright-blue[/]",
	)

	frb.cprintfln("[bg:red white]bg:red[/] [bg:green black]bg:green[/] [bg:blue white]bg:blue[/]")
	frb.cprintfln(
		"[bold]bold[/] [dim]dim[/] [italic]italic[/] [underline]underline[/] [strikethrough]strikethrough[/]",
	)

	//? It also supports RGB, ANSI256, and Hex (with shorthands!)
	frb.cprintfln(
		"[rgb(255,100,0)]rgb(255,100,0)[/] [ansi(200)]ansi(200)[/] [#ff00aa]#ff00aa[/] [#f0a]#f0a[/]",
	)

	//? You can also chain tags:
	frb.cprintfln(
		"[bold underline red]bold underline red[/] [italic bg:blue white]italic on blue[/]",
	)

	//? Partially reset instead of full reset:
	frb.cprintfln("[bold red]bold red[/red] still bold[/]")

	//? Set `reset` to `false` so the color bleeds into across calls
	frb.cprintfln("[bold green]this bleeds...", reset = false)
	frb.cprintfln("...into this line[/]")
}
