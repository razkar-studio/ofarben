Changelog
=================================================

All notable changes will be documented here

0.1.3: 2026-06-13
-----------------

### Changed
- Color support is now detected per stream: the `ce*` stderr procs use
  stderr's own TTY detection instead of stdout's. String-returning and
  writer-based procs still use stdout's detection.

### Fixed
- Bug where `ceprintln` prints two newlines instead of one (stderr twin
  of the `cprintln` fix in 0.1.2)

0.1.2: 2026-06-12
-----------------

### Fixed
- Bug where `cprintln` prints two newlines instead of one

0.1.1: 2026-06-12
-----------------

### Added
- Example program under `example/`

### Changed
- Escape notation from `\x1b` to `\e` throughout
- Removed package-level `main` procedure

### Fixed
- Trailing ANSI reset codes no longer appear in non-TTY output

0.1.0: 2026-06-10
-----------------

Initial release
