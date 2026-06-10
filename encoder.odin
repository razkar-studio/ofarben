package ofarben

import "core:fmt"
import "core:strings"

@(private)
encode :: proc(tags: []Tag, sb: ^strings.Builder) {
	for tag in tags {
		switch t in tag {
		case Tag_Emphasis:
			if _color_support == .None do continue
			switch t.emphasis {
			case .Bold:
				strings.write_string(sb, "\x1b[1m")
			case .Dim:
				strings.write_string(sb, "\x1b[2m")
			case .Italic:
				strings.write_string(sb, "\x1b[3m")
			case .Underline:
				strings.write_string(sb, "\x1b[4m")
			case .Blink:
				strings.write_string(sb, "\x1b[5m")
			case .Rapid_Blink:
				strings.write_string(sb, "\x1b[6m")
			case .Reverse:
				strings.write_string(sb, "\x1b[7m")
			case .Invisible:
				strings.write_string(sb, "\x1b[8m")
			case .Strikethrough:
				strings.write_string(sb, "\x1b[9m")
			case .Double_Underline:
				strings.write_string(sb, "\x1b[21m")
			case .Overline:
				strings.write_string(sb, "\x1b[53m")
			}
		case Tag_Color:
			if _color_support == .None do continue
			degraded := degrade_color(t.color)
			switch c in degraded {
			case Named_Color:
				fg_code: int
				switch c {
				case .Black:
					fg_code = 30
				case .Red:
					fg_code = 31
				case .Green:
					fg_code = 32
				case .Yellow:
					fg_code = 33
				case .Blue:
					fg_code = 34
				case .Magenta:
					fg_code = 35
				case .Cyan:
					fg_code = 36
				case .White:
					fg_code = 37
				case .Bright_Black:
					fg_code = 90
				case .Bright_Red:
					fg_code = 91
				case .Bright_Green:
					fg_code = 92
				case .Bright_Yellow:
					fg_code = 93
				case .Bright_Blue:
					fg_code = 94
				case .Bright_Magenta:
					fg_code = 95
				case .Bright_Cyan:
					fg_code = 96
				case .Bright_White:
					fg_code = 97
				}
				code := fg_code + 10 if t.ground == .Background else fg_code
				strings.write_string(sb, fmt.tprintf("\x1b[%dm", code))
			case Ansi256:
				switch t.ground {
				case .Foreground:
					strings.write_string(sb, fmt.tprintf("\x1b[38;5;%dm", c.ansi))
				case .Background:
					strings.write_string(sb, fmt.tprintf("\x1b[48;5;%dm", c.ansi))
				}
			case Rgb:
				switch t.ground {
				case .Foreground:
					strings.write_string(sb, fmt.tprintf("\x1b[38;2;%d;%d;%dm", c.r, c.g, c.b))
				case .Background:
					strings.write_string(sb, fmt.tprintf("\x1b[48;2;%d;%d;%dm", c.r, c.g, c.b))
				}
			}
		}
	}
}
