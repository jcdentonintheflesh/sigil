# Sigil

A native macOS markdown reader. No Electron, no web views, no dependencies.

Opens `.md` files in a clean, themed window. That's it.

## Features

- Native AppKit text rendering
- 6 built-in themes (Neon, Obsidian, Nord, Parchment, Paper, Terminal)
- Inline editing with syntax tinting
- Adjustable font size and line spacing
- Dark/light themes
- Zero network access, zero telemetry

## Build

Requires macOS 13+ and Xcode Command Line Tools.

```
./build.sh
```

The built `Sigil.app` will be in the project root.

## Install

1. Copy `Sigil.app` to `/Applications/`
2. First launch: right-click → **Open** (macOS blocks unsigned apps on first run)
3. To set as default for `.md` files: right-click any `.md` → Get Info → Open with → Sigil → Change All

## Why

Every markdown viewer is either Electron-bloated, abandoned, or wants your data. Sigil is ~500 lines of Swift, reads files, renders them, and does nothing else.
