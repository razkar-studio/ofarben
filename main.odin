// Copyright (c) 2026 RazkarStudio
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from
// the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software in
//    a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

package ofarben

main :: proc() {
	cprintfln("[rgb(255,100,0)]rgb color")
	cprintfln("[bold ansi(200)]ansi256 color", reset = false)
	cprintfln("[/ansi(200)]i'm bold[/bold] [red]named color", reset = false)
	cprintfln("should be red]")
	cprintln(untag("[red]"))
	// cprintfln("[rgb(hey,whats,good)]test") // Invalid_Argument - 'hey'
	// cprintfln("[rgb(300,0,0)]test") // Invalid_Argument - overflow
	// cprintfln("[rgb(1,2,3,4)]test") // Invalid_Argument_Count - 4 not 3
	// cprintfln("[rgb(1,2]test") // Unclosed_Parentheses
	// cprintfln("[ansi(300)]test") // Invalid_Argument - overflow
	// cprintfln("[ansi(1,2)]test") // Invalid_Argument_Count - 2 not 1
	// cprintfln("[ansi(hey]test") // Unclosed_Parentheses
	// cprintfln("[#gg0000]test") // Invalid_Argument - bad hex
	// cprintfln("[#ffff]test") // Invalid_Argument_Count - 5 digits
	// cprintfln("[bold blorf red]test") // Unknown_Tag
	// cprintfln("[bold red") // Unclosed_Tag
}
