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

@(private)
parse :: proc(
	src: string,
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
			tags, err := parse_tags(type.raw, type.pos, src, allocator)
			if err != nil do return strings.to_string(sb), err
			append(&_stack, ..tags[:])
			delete(tags)
		case Token_Close:
			if type.raw == "" {
				strings.write_string(&sb, "\x1b[0m")
				clear(&_stack)
			} else {
				tags, _ := parse_tags(type.raw, type.pos, src, allocator)
				for reset_tag in tags {
					for i := len(_stack) - 1; i >= 0; i -= 1 {
						if _stack[i] == reset_tag {
							ordered_remove(&_stack, i)
							break
						}
					}
				}
				delete(tags)
				strings.write_string(&sb, "\x1b[0m")
				encode(_stack[:], &sb)
			}
		}
	}
	if !bleed {strings.write_string(&sb, "\x1b[0m"); clear(&_stack)}
	return strings.to_string(sb), nil
}

@(private = "file")
parse_tags :: proc(
	raw: string,
	pos: int,
	src: string,
	allocator := context.allocator,
) -> (
	[dynamic]Tag,
	Maybe(Parse_Error),
) {
	tags := make([dynamic]Tag, allocator)
	parts := split_tag_parts(raw, allocator)
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
					return tags, Parse_Error {
						kind = .Unclosed_Parentheses,
						pos = pos,
						src = src,
						raw = raw,
						value_pos = int(uintptr(raw_data(new_part)) - uintptr(raw_data(src))) - 1,
					}
				}
				new_part = new_part[:len(new_part) - 1]
				raw_nums := strings.split(new_part, ",", allocator)
				defer delete(raw_nums)
				if len(raw_nums) != 3 {
					return tags, Parse_Error {
						kind = .Invalid_Argument_Count,
						pos = pos,
						src = src,
						raw = raw,
						value = new_part,
						value_pos = int(uintptr(raw_data(new_part)) - uintptr(raw_data(src))),
						expected = 3,
						got = len(raw_nums),
					}
				}
				nums: [3]u8
				for n, i in raw_nums {
					trimmed := strings.trim_space(n)
					value, ok := strconv.parse_uint(trimmed)
					if !ok || value > 255 {
						return tags, Parse_Error {
							kind = .Invalid_Argument,
							pos = pos,
							src = src,
							raw = raw,
							value_pos = int(uintptr(raw_data(trimmed)) - uintptr(raw_data(src))),
							value = trimmed,
							type_name = "u8",
						}
					}
					nums[i] = auto_cast value
				}
				append(&tags, Tag_Color{color = Rgb{nums[0], nums[1], nums[2]}, ground = ground})
			} else if strings.starts_with(new_part, "ansi(") {
				new_part = new_part[5:]
				if !strings.ends_with(new_part, ")") {
					return tags, Parse_Error {
						kind = .Unclosed_Parentheses,
						pos = pos,
						src = src,
						raw = raw,
						value_pos = int(uintptr(raw_data(new_part)) - uintptr(raw_data(src))) - 1,
					}
				}
				new_part = new_part[:len(new_part) - 1]
				raw_nums := strings.split(new_part, ",", allocator)
				defer delete(raw_nums)
				if len(raw_nums) != 1 {
					return tags, Parse_Error {
						kind = .Invalid_Argument_Count,
						pos = pos,
						src = src,
						raw = raw,
						value = new_part,
						value_pos = int(uintptr(raw_data(new_part)) - uintptr(raw_data(src))),
						expected = 1,
						got = len(raw_nums),
					}
				}
				trimmed := strings.trim_space(new_part)
				value, ok := strconv.parse_uint(trimmed)
				if !ok || value > 255 {
					return tags, Parse_Error {
						kind = .Invalid_Argument,
						pos = pos,
						src = src,
						raw = raw,
						value_pos = int(uintptr(raw_data(trimmed)) - uintptr(raw_data(src))),
						value = strings.trim_space(new_part),
						type_name = "u8",
					}
				}
				append(&tags, Tag_Color{color = Ansi256{auto_cast value}, ground = ground})
			} else if strings.starts_with(new_part, "#") {
				hex := new_part[1:]
				r, g, b: u8
				switch len(hex) {
				case 3:
					rv := strconv.parse_uint(hex[0:1], 16) or_else 999
					gv := strconv.parse_uint(hex[1:2], 16) or_else 999
					bv := strconv.parse_uint(hex[2:3], 16) or_else 999
					if rv > 15 || gv > 15 || bv > 15 {
						return tags, Parse_Error {
							kind = .Invalid_Argument,
							pos = pos,
							src = src,
							raw = raw,
							value_pos = int(uintptr(raw_data(hex)) - uintptr(raw_data(src))),
							value = hex,
							type_name = "hex digit",
						}
					}
					r = auto_cast (rv * 17)
					g = auto_cast (gv * 17)
					b = auto_cast (bv * 17)
				case 6:
					rv := strconv.parse_uint(hex[0:2], 16) or_else 999
					gv := strconv.parse_uint(hex[2:4], 16) or_else 999
					bv := strconv.parse_uint(hex[4:6], 16) or_else 999
					if rv > 255 || gv > 255 || bv > 255 {
						return tags, Parse_Error {
							kind = .Invalid_Argument,
							pos = pos,
							src = src,
							raw = raw,
							value_pos = int(uintptr(raw_data(hex)) - uintptr(raw_data(src))),
							value = hex,
							type_name = "hex digit",
						}
					}
					r = auto_cast rv
					g = auto_cast gv
					b = auto_cast bv
				case:
					return tags, Parse_Error {
						kind = .Invalid_Argument_Count,
						pos = pos,
						src = src,
						raw = raw,
						value = hex,
						value_pos = int(uintptr(raw_data(hex)) - uintptr(raw_data(src))),
						expected = 3,
						got = len(hex),
					}
				}
				append(&tags, Tag_Color{color = Rgb{r, g, b}, ground = ground})
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
					return tags, Parse_Error {
						kind = .Unknown_Tag,
						pos = pos,
						src = src,
						raw = raw,
						value = new_part,
						value_pos = int(uintptr(raw_data(new_part)) - uintptr(raw_data(src))),
					}
				}
				if c, ok := color.?; ok {
					append(&tags, Tag_Color{color = c, ground = ground})
				}
			}
		}
	}
	return tags, nil
}

@(private = "file")
split_tag_parts :: proc(raw: string, allocator := context.allocator) -> []string {
	parts := make([dynamic]string, allocator)
	depth := 0
	start := 0
	for i := 0; i < len(raw); i += 1 {
		switch raw[i] {
		case '(':
			depth += 1
		case ')':
			depth -= 1
		case ' ', '\t':
			if depth == 0 && i > start {
				append(&parts, raw[start:i])
				start = i + 1
			} else if depth == 0 {
				start = i + 1
			}
		}
	}
	if start < len(raw) {
		append(&parts, raw[start:])
	}
	return parts[:]
}
