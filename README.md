# ofarben

The official Odin rewrite of the Rust [Farben](https://github.com/razkar-studio/farben) terminal coloring library.

## Installation

### Using Odyn (recommended)

Install Odyn, the reproducible vendoring tool, [here](https://razkar.codeberg.page/odyn/docs/install).

Add it to your project:

```sh
odyn get razkar/ofarben --platform codeberg
```

Import in your code:

```odin
import "deps:ofarben"
```

### Manual

Clone the repository and add it to your project:

```sh
git clone https://codeberg.org/<you>/ofarben
```

Then import it in your Odin code:

```odin
import "path/to/ofarben"
```

## Quick Start

```odin
import "ofarben"

main :: proc() {
    ofarben.cprintfln("[bold red]Error:[/] something went wrong.")
    ofarben.cprintfln("[green]Success:[/] operation completed.")
    ofarben.cprintfln("[bg:blue white]Highlighted text[/]")
}
```

Colors are automatically disabled when `NO_COLOR` is set or the output is not a TTY.

## Tag Reference

### Colors

| Tag | Description |
|-----|-------------|
| `[red]` | Named foreground color |
| `[bg:red]` | Named background color |
| `[fg:red]` | Explicit foreground (same as `[red]`) |
| `[rgb(255,0,0)]` | RGB foreground color |
| `[bg:rgb(255,0,0)]` | RGB background color |
| `[ansi(196)]` | ANSI 256 foreground color |
| `[bg:ansi(196)]` | ANSI 256 background color |
| `[#ff0000]` | Hex foreground color |
| `[bg:#ff0000]` | Hex background color |
| `[#f00]` | Shorthand hex foreground |

Available named colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, and their `bright-` variants (e.g. `bright-red`).

### Emphasis

| Tag | Description |
|-----|-------------|
| `[bold]` | Bold |
| `[dim]` | Dim |
| `[italic]` | Italic |
| `[underline]` | Underline |
| `[double_underline]` | Double underline |
| `[strikethrough]` | Strikethrough |
| `[blink]` | Blink |
| `[rapid_blink]` | Rapid blink |
| `[overline]` | Overline |
| `[invisible]` | Invisible |
| `[reverse]` | Reverse |

### Resets

| Tag | Description |
|-----|-------------|
| `[/]` | Reset all styles |
| `[/red]` | Reset specific color |
| `[/bold]` | Reset specific emphasis |

### Escaping

| Sequence | Output |
|----------|--------|
| `[[` | Literal `[` |
| `]]` | Literal `]` |

### Combining

Multiple tags can be combined in one bracket:

```
[bold red bg:blue]text[/]
```

## Public API

All procedures accept a `reset` parameter (default `true`) that controls whether styles are reset after the call. Set `reset = false` to bleed styles into the next call.

<details>
<summary>Click to expand</summary>

### Stdout
| Procedure | Description |
|-----------|-------------|
| `cprintf(markup, args, flush, reset)` | Print without newline |
| `cprintfln(markup, args, flush, reset)` | Print with newline |
| `cprint(args, sep, flush, reset)` | Print args without newline |
| `cprintln(args, sep, flush, reset)` | Print args with newline |

### Stderr
| Procedure | Description |
|-----------|-------------|
| `ceprintf(markup, args, flush, reset)` | Print to stderr without newline |
| `ceprintfln(markup, args, flush, reset)` | Print to stderr with newline |
| `ceprint(args, sep, flush, reset)` | Print args to stderr without newline |
| `ceprintln(args, sep, flush, reset)` | Print args to stderr with newline |

### Temp-allocated (returns string)
| Procedure | Description |
|-----------|-------------|
| `ctprintf(markup, args, reset)` | Styled string without newline |
| `ctprintfln(markup, args, reset)` | Styled string with newline |
| `ctprint(args, sep, reset)` | Styled args without newline |
| `ctprintln(args, sep, reset)` | Styled args with newline |

### Heap-allocated (returns string, caller owns)
| Procedure | Description |
|-----------|-------------|
| `caprintf(markup, args, reset, allocator)` | Styled string without newline |
| `caprintfln(markup, args, reset, allocator)` | Styled string with newline |
| `caprint(args, sep, reset, allocator)` | Styled args without newline |
| `caprintln(args, sep, reset, allocator)` | Styled args with newline |

### Byte buffer
| Procedure | Description |
|-----------|-------------|
| `cbprintf(buf, markup, args, reset)` | Write styled string to byte buffer |
| `cbprintfln(buf, markup, args, reset)` | Write styled string to byte buffer with newline |
| `cbprint(buf, args, sep, reset)` | Write styled args to byte buffer |
| `cbprintln(buf, args, sep, reset)` | Write styled args to byte buffer with newline |

### strings.Builder
| Procedure | Description |
|-----------|-------------|
| `csbprintf(buf, markup, args, reset)` | Write styled string to Builder |
| `csbprintfln(buf, markup, args, reset)` | Write styled string to Builder with newline |
| `csbprint(buf, args, sep, reset)` | Write styled args to Builder |
| `csbprintln(buf, args, sep, reset)` | Write styled args to Builder with newline |

### Writer
| Procedure | Description |
|-----------|-------------|
| `cwprintf(w, markup, args, flush, reset)` | Write styled string to `io.Writer` |
| `cwprintfln(w, markup, args, flush, reset)` | Write styled string to `io.Writer` with newline |
| `cwprint(w, args, sep, flush, reset)` | Write styled args to `io.Writer` |
| `cwprintln(w, args, sep, flush, reset)` | Write styled args to `io.Writer` with newline |

### Format (returns string)
| Procedure | Description |
|-----------|-------------|
| `csprintf(markup, args, reset)` | Same as `ctprintf` |
| `csprintfln(markup, args, reset)` | Same as `ctprintfln` |
| `csprint(args, sep, reset)` | Same as `ctprint` |
| `csprintln(args, sep, reset)` | Same as `ctprintln` |

### Utilities
| Procedure | Description |
|-----------|-------------|
| `unmarkup(src, allocator)` | Strip all markup tags, return plain text |
| `unansi(src, allocator)` | Strip ANSI escape codes |
| `untag(src, allocator)` | Escape markup for safe display through the pipeline |

</details>

## License

This project is licensed under the [zlib](https://zlib.https://zlib.net/zlib_license.html) license.

Cheers, RazkarStudio.

Copyright © 2026 RazkarStudio. All rights reserved.
