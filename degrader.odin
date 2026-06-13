package ofarben

@(private = "file")
NAMED_COLOR_RGB := [Named_Color][3]u8 {
	.Black          = {0, 0, 0},
	.Red            = {170, 0, 0},
	.Green          = {0, 170, 0},
	.Yellow         = {170, 85, 0},
	.Blue           = {0, 0, 170},
	.Magenta        = {170, 0, 170},
	.Cyan           = {0, 170, 170},
	.White          = {170, 170, 170},
	.Bright_Black   = {85, 85, 85},
	.Bright_Red     = {255, 85, 85},
	.Bright_Green   = {85, 255, 85},
	.Bright_Yellow  = {255, 255, 85},
	.Bright_Blue    = {85, 85, 255},
	.Bright_Magenta = {255, 85, 255},
	.Bright_Cyan    = {85, 255, 255},
	.Bright_White   = {255, 255, 255},
}

@(private)
degrade_to_ansi16 :: proc(r, g, b: u8) -> Named_Color {
	best := Named_Color.Black
	best_dist := max(int)
	for color in Named_Color {
		rgb := NAMED_COLOR_RGB[color]
		dr := int(r) - int(rgb[0])
		dg := int(g) - int(rgb[1])
		db := int(b) - int(rgb[2])
		dist := dr * dr + dg * dg + db * db
		if dist < best_dist {
			best_dist = dist
			best = color
		}
	}
	return best
}

@(private = "file")
CUBE_LEVELS := [6]u8{0, 95, 135, 175, 215, 255}

@(private = "file")
nearest_cube_level :: proc(v: u8) -> u8 {
	best := u8(0)
	best_dist := max(int)
	for level, i in CUBE_LEVELS {
		dist := abs(int(v) - int(level))
		if dist < best_dist {
			best_dist = dist
			best = u8(i)
		}
	}
	return best
}

@(private)
degrade_to_ansi256 :: proc(r, g, b: u8) -> u8 {
	ri := nearest_cube_level(r)
	gi := nearest_cube_level(g)
	bi := nearest_cube_level(b)
	return 16 + ri * 36 + gi * 6 + bi
}

@(private)
ansi256_to_rgb :: proc(index: u8) -> (r, g, b: u8) {
	if index < 16 {
		rgb := NAMED_COLOR_RGB[Named_Color(index)]
		return rgb[0], rgb[1], rgb[2]
	} else if index >= 232 {
		v := 8 + u8(index - 232) * 10
		return v, v, v
	} else {
		i := index - 16
		r = CUBE_LEVELS[i / 36]
		g = CUBE_LEVELS[(i % 36) / 6]
		b = CUBE_LEVELS[i % 6]
		return
	}
}

@(private)
degrade_color :: proc(color: Color, support: Color_Support) -> Color {
	switch support {
	case .None:
		return color
	case .Truecolor:
		return color
	case .Ansi256:
		switch c in color {
		case Rgb:
			return Ansi256{degrade_to_ansi256(c.r, c.g, c.b)}
		case Named_Color, Ansi256:
			return color
		}
	case .Ansi16:
		switch c in color {
		case Rgb:
			return degrade_to_ansi16(c.r, c.g, c.b)
		case Ansi256:
			r, g, b := ansi256_to_rgb(c.ansi)
			return degrade_to_ansi16(r, g, b)
		case Named_Color:
			return color
		}
	}
	return color
}
