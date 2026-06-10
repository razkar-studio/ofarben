package ofarben

@(private)
Ansi256 :: struct {
	ansi: u8,
}

@(private)
Rgb :: struct {
	r, g, b: u8,
}

@(private)
Named_Color :: enum {
	Black,
	Red,
	Green,
	Yellow,
	Blue,
	Magenta,
	Cyan,
	White,
	Bright_Black,
	Bright_Red,
	Bright_Green,
	Bright_Yellow,
	Bright_Blue,
	Bright_Magenta,
	Bright_Cyan,
	Bright_White,
}

@(private)
Color :: union {
	Named_Color,
	Ansi256,
	Rgb,
}
