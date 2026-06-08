package ofarben

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

Ansi256 :: struct {
	value: u8,
}

Rgb :: struct {
	r, g, b: u8,
}

Color :: union {
	Named_Color,
	Rgb,
	Ansi256,
}

Style :: struct {
	fg:               Maybe(Color),
	bg:               Maybe(Color),
	bold:             bool,
	dim:              bool,
	italic:           bool,
	underline:        bool,
	double_underline: bool,
	strikethrough:    bool,
	blink:            bool,
	overline:         bool,
	invisible:        bool,
	reverse:          bool,
	rapid_blink:      bool,
}
