package ofarben

import "core:strconv"
import "core:strings"

import "base:runtime"

@(private = "file")
_stack: [dynamic]Tag

@(init)
_ofarben_init :: proc "contextless" () {
	context = runtime.default_context()
	_stack = make([dynamic]Tag)
}

@(fini)
_ofarben_fini :: proc "contextless" () {
	context = runtime.default_context()
	delete(_stack)
}

parse :: proc(
	tokens: []Token,
	bleed := false,
	allocator := context.allocator,
) -> (
	string,
	Maybe(Parse_Error),
) {
	sb := strings.builder_make(allocator)
	for token in tokens {
		switch type in token {
		case Token_Text:
			encode(_stack[:], &sb)
			strings.write_string(&sb, type.text)
		case Token_Tag:
			tags, err := parse_tags(type.raw, allocator)
			if err != nil do return strings.to_string(sb), err
			append(&_stack, ..tags[:])
			delete(tags)
		case Token_Close:
			if type.raw == "" {
				strings.write_string(&sb, "\x1b[0m")
				clear(&_stack)
			} else {
				// TODO: implement ResetOne
				clear(&_stack)
			}
		}
	}
	if !bleed do strings.write_string(&sb, "\x1b[0m")
	return strings.to_string(sb), nil
}

parse_tags :: proc(
	raw: string,
	allocator := context.allocator,
) -> (
	[dynamic]Tag,
	Maybe(Parse_Error),
) {
	tags := make([dynamic]Tag, allocator)
	parts := strings.fields(raw, allocator)
	defer delete(parts)
	for part in parts {
		switch part {
		case "bold":
			append(&tags, Tag_Emphasis{.Bold})
		case "dim":
			append(&tags, Tag_Emphasis{.Dim})
		case "italic":
			append(&tags, Tag_Emphasis{.Italic})
		case "underline":
			append(&tags, Tag_Emphasis{.Underline})
		case "double_underline":
			append(&tags, Tag_Emphasis{.Double_Underline})
		case "strikethrough":
			append(&tags, Tag_Emphasis{.Strikethrough})
		case "blink":
			append(&tags, Tag_Emphasis{.Blink})
		case "overline":
			append(&tags, Tag_Emphasis{.Overline})
		case "invisible":
			append(&tags, Tag_Emphasis{.Invisible})
		case "reverse":
			append(&tags, Tag_Emphasis{.Reverse})
		case "rapid_blink":
			append(&tags, Tag_Emphasis{.Rapid_Blink})
		case:
			ground := Ground.Background if strings.starts_with(part, "bg:") else Ground.Foreground
			new_part :=
				part[3:] if strings.starts_with(part, "bg:") || strings.starts_with(part, "fg:") else part
			if strings.starts_with(new_part, "rgb(") {
				new_part = new_part[4:]
				if !strings.ends_with(new_part, ")") {
					return tags, Parse_Error{kind = .Unclosed_Parentheses}
				}
				new_part = new_part[:len(new_part) - 1]
				raw_nums := strings.split(new_part, ",", allocator)
				defer delete(raw_nums)
				if len(raw_nums) != 3 {
					return tags, Parse_Error{kind = .Invalid_Argument_Count}
				}
				nums: [3]u8
				for n, i in raw_nums {
					trimmed := strings.trim_space(n)
					value, ok := strconv.parse_uint(trimmed)
					if !ok || value > 255 {
						return tags, Parse_Error{kind = .Invalid_Argument}
					}
					nums[i] = auto_cast value
				}
				append(&tags, Tag_Color{color = Rgb{nums[0], nums[1], nums[2]}, ground = ground})
			} else if strings.starts_with(new_part, "ansi(") {
				new_part = new_part[5:]
				if !strings.ends_with(new_part, ")") {
					return tags, Parse_Error{kind = .Unclosed_Parentheses}
				}
				new_part = new_part[:len(new_part) - 1]
				value, ok := strconv.parse_uint(strings.trim_space(new_part))
				if !ok || value > 255 {
					return tags, Parse_Error{kind = .Invalid_Argument}
				}
				append(&tags, Tag_Color{color = Ansi256{auto_cast value}, ground = ground})
			} else {
				color: Maybe(Named_Color)
				switch new_part {
				case "black":
					color = Named_Color.Black
				case "bright-black":
					color = Named_Color.Bright_Black
				case "red":
					color = Named_Color.Red
				case "bright-red":
					color = Named_Color.Bright_Red
				case "green":
					color = Named_Color.Green
				case "bright-green":
					color = Named_Color.Bright_Green
				case "yellow":
					color = Named_Color.Yellow
				case "bright-yellow":
					color = Named_Color.Bright_Yellow
				case "blue":
					color = Named_Color.Blue
				case "bright-blue":
					color = Named_Color.Bright_Blue
				case "magenta":
					color = Named_Color.Magenta
				case "bright-magenta":
					color = Named_Color.Bright_Magenta
				case "cyan":
					color = Named_Color.Cyan
				case "bright-cyan":
					color = Named_Color.Bright_Cyan
				case "white":
					color = Named_Color.White
				case "bright-white":
					color = Named_Color.Bright_White
				case:
					return tags, Parse_Error{kind = .Unknown_Tag}
				}
				if c, ok := color.?; ok {
					append(&tags, Tag_Color{color = c, ground = ground})
				}
			}
		}
	}
	return tags, nil
}
