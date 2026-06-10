package ofarben

main :: proc() {
	cprintfln("[rgb(255,100,0)]rgb color")
	cprintfln("[bold ansi(200)]ansi256 color", reset = false)
	cprintfln("[/ansi(200)]i'm bold[/bold] [red]named color", reset = false)
	cprintfln("should be red")
}
