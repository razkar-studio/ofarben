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


merge_styles :: proc(base, override: Style) -> (result: Style) {
	result.fg = override.fg if override.fg != nil else base.fg
	result.bg = override.bg if override.bg != nil else base.bg
	result.bold = base.bold || override.bold
	result.dim = base.dim || override.dim
	result.italic = base.italic || override.italic
	result.underline = base.underline || override.underline
	result.double_underline = base.double_underline || override.double_underline
	result.strikethrough = base.strikethrough || override.strikethrough
	result.blink = base.blink || override.blink
	result.overline = base.overline || override.overline
	result.invisible = base.invisible || override.invisible
	result.reverse = base.reverse || override.reverse
	result.rapid_blink = base.rapid_blink || override.rapid_blink
	return
}
