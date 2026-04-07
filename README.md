# Sigil

A minimalist markdown reader for macOS.

Built because every markdown viewer out there is either Electron-bloated, abandoned, collecting data, or hiding behind a subscription. Sigil just opens `.md` files and makes them look good.

Swift, native rendering, nothing phones home.

## Download

1. Go to [Releases](https://github.com/jcdentonintheflesh/sigil/releases/latest) and download **Sigil.zip**
2. Double-click the zip to unzip it
3. Drag **Sigil.app** into your **Applications** folder
4. Try opening Sigil. macOS will block it because it's not from the App Store.
5. Open **System Settings > Privacy & Security**, scroll down, you'll see "Sigil was blocked" with an **Open Anyway** button. Click it and enter your password. This only happens once.
6. To make Sigil your default app for `.md` files: right-click any `.md` file, click **Get Info**, under "Open with" pick **Sigil**, then click **Change All**

## Features

- 6 themes: Neon, Obsidian, Nord, Parchment, Paper, Terminal
- Inline editing with syntax tinting
- Adjustable font size and line spacing
- Renders code blocks, lists, links, headings, blockquotes, checkboxes

## Build from source

Requires macOS 13+ and Xcode Command Line Tools.

```
git clone https://github.com/jcdentonintheflesh/sigil.git
cd sigil
./build.sh
open Sigil.app test.md
```
