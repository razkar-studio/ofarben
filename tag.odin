package ofarben

Tag :: union {
	Tag_Color,
	Tag_Emphasis,
}

Tag_Color :: struct {
	color:  Color,
	ground: Ground,
}

Tag_Emphasis :: struct {
	emphasis: Emphasis,
}

Emphasis :: enum {
	Bold,
	Dim,
	Italic,
	Underline,
	Double_Underline,
	Strikethrough,
	Blink,
	Rapid_Blink,
	Overline,
	Invisible,
	Reverse,
}
