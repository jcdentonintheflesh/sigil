# Sigil

A minimalist markdown reader for macOS.

Built because every markdown viewer out there is either Electron-bloated, abandoned, collecting data, or hiding behind a subscription. Sigil just opens `.md` files and makes them look good.

Swift, native rendering, nothing phones home.

## Features

- 6 themes: Neon, Obsidian, Nord, Parchment, Paper, Terminal
- Inline editing with syntax tinting
- Adjustable font size and line spacing
- Renders code blocks, lists, links, headings, blockquotes, checkboxes

## Build

Requires macOS 13+ and Xcode Command Line Tools.

```
./build.sh
```

## Install

1. Copy `Sigil.app` to `/Applications/`
2. First launch: right-click the app, then click **Open** (macOS flags unsigned apps on first run, this only happens once)
3. Set as default: right-click any `.md` file, Get Info, Open with, select Sigil, Change All
