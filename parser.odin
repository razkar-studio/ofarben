package ofarben

import "core:strconv"
import "core:strings"

@(private = "file")
_stack: [dynamic]Style

parser_init :: proc(allocator := context.allocator) {
	_stack = make([dynamic]Style, allocator)
}

parser_destroy :: proc() {
	delete(_stack)
}

parse :: proc(tokens: []Token, allocator := context.allocator) -> ([]Span, Maybe(Parse_Error)) {
	spans := make([dynamic]Span, allocator)
	for token in tokens {
		switch type in token {
		case Token_Text:
			append(
				&spans,
				Span {
					text = type.text,
					style = _stack[len(_stack) - 1] if len(_stack) > 0 else Style{},
				},
			)
		case Token_Tag:
		case Token_Close:
		}
	}
	return spans[:], nil
}

parse_style :: proc(raw: string, allocator := context.allocator) -> (Style, Maybe(Parse_Error)) {
	style: Style
	parts := strings.fields(raw, allocator)
	defer delete(parts)
	for part in parts {
		switch part {
		case "bold":
			style.bold = true
		case "dim":
			style.dim = true
		case "italic":
			style.italic = true
		case "underline":
			style.underline = true
		case "double_underline":
			style.double_underline = true
		case "strikethrough":
			style.strikethrough = true
		case "blink":
			style.blink = true
		case "overline":
			style.overline = true
		case "invisible":
			style.invisible = true
		case "reverse":
			style.reverse = true
		case "rapid_blink":
			style.rapid_blink = true
		case:
			ground := Ground.Background if strings.starts_with(part, "bg:") else Ground.Foreground
			new_part :=
				part[3:] if strings.starts_with(part, "bg:") || strings.starts_with(part, "fg:") else part
			if strings.starts_with(new_part, "rgb(") {
				new_part = new_part[4:]
				if !strings.ends_with(new_part, ")") {
					// FIXME: pos, src
					return style, Parse_Error{kind = .Unclosed_Parentheses}
				}
				new_part = new_part[:len(new_part) - 1]
				raw_nums := strings.split(new_part, ",", allocator)
				defer delete(raw_nums)
				if len(raw_nums) != 3 {
					// FIXME: pos, src
					// TODO: invalid argument count requires expected and actual
					// 		 but enums can't do that?
					return style, Parse_Error{kind = .Invalid_Argument_Count}
				}
				nums := make([dynamic]u8)
				defer delete(nums)
				for &n in raw_nums {
					n = strings.trim_space(n)
					value, ok := strconv.parse_uint(n)
					if !ok || value > 255 {
						// FIXME: pos, src
						return style, Parse_Error{kind = .Invalid_Argument}
					}
					append(&nums, cast(u8)value)
				}
				r, g, b := nums[0], nums[1], nums[2]
				switch ground {
				case .Background:
					style.bg = Rgb{r, g, b}
				case .Foreground:
					style.fg = Rgb{r, g, b}
				}
			} else if strings.starts_with(new_part, "ansi(") {
				new_part = new_part[5:]
				if !strings.ends_with(new_part, ")") {
					// FIXME: pos, src
					return style, Parse_Error{kind = .Unclosed_Parentheses}
				}
				new_part = new_part[:len(new_part) - 1]
				raw_nums := strings.split(new_part, ",", allocator)
				defer delete(raw_nums)
				if len(raw_nums) != 1 {
					// FIXME: pos, src
					// TODO: invalid argument count requires expected and actual
					// 		 but enums can't do that?
					return style, Parse_Error{kind = .Invalid_Argument_Count}
				}
				value, ok := strconv.parse_uint(raw_nums[0])
				if !ok || value > 255 {
					// FIXME: pos, src
					return style, Parse_Error{kind = .Invalid_Argument}
				}
				ansi := cast(u8)value
				switch ground {
				case .Background:
					style.bg = Ansi256{ansi}
				case .Foreground:
					style.fg = Ansi256{ansi}
				}
			} else {
				switch new_part {
				case "black":
					set_color(&style, ground, .Black)
				case "bright-black":
					set_color(&style, ground, .Bright_Black)
				case "red":
					set_color(&style, ground, .Red)
				case "bright-red":
					set_color(&style, ground, .Bright_Red)
				case "green":
					set_color(&style, ground, .Green)
				case "bright-green":
					set_color(&style, ground, .Bright_Green)
				case "yellow":
					set_color(&style, ground, .Yellow)
				case "bright-yellow":
					set_color(&style, ground, .Bright_Yellow)
				case "blue":
					set_color(&style, ground, .Blue)
				case "bright-blue":
					set_color(&style, ground, .Bright_Blue)
				case "magenta":
					set_color(&style, ground, .Magenta)
				case "bright-magenta":
					set_color(&style, ground, .Bright_Magenta)
				case "cyan":
					set_color(&style, ground, .Cyan)
				case "bright-cyan":
					set_color(&style, ground, .Bright_Cyan)
				case "white":
					set_color(&style, ground, .White)
				case "bright-white":
					set_color(&style, ground, .Bright_White)
				case:
					// FIXME: pos, src
					return style, Parse_Error{kind = .Unknown_Tag}
				}
			}
		}
	}
	return style, nil
}

set_color :: proc(style: ^Style, ground: Ground, color: Color) {
	switch ground {
	case .Background:
		style.bg = color
	case .Foreground:
		style.fg = color
	}
}
