package ofarben

@(private)
Tag :: union {
	Tag_Color,
	Tag_Emphasis,
}

@(private)
Tag_Color :: struct {
	color:  Color,
	ground: Ground,
}

@(private)
Tag_Emphasis :: struct {
	emphasis: Emphasis,
}

@(private)
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
