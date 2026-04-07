#!/bin/bash
set -e

rm -rf Sigil.app SigilBin

swiftc \
  -target arm64-apple-macosx13.0 \
  -sdk "$(xcrun --show-sdk-path)" \
  -framework SwiftUI \
  -framework AppKit \
  -framework UniformTypeIdentifiers \
  -parse-as-library \
  -O \
  -o SigilBin \
  Sigil/SigilApp.swift \
  Sigil/MarkdownDocument.swift \
  Sigil/SigilTheme.swift \
  Sigil/MarkdownRenderer.swift \
  Sigil/MarkdownView.swift

mkdir -p Sigil.app/Contents/MacOS Sigil.app/Contents/Resources
mv SigilBin Sigil.app/Contents/MacOS/Sigil
cp Sigil/Info.plist Sigil.app/Contents/Info.plist
cp Sigil/Sigil.icns Sigil.app/Contents/Resources/Sigil.icns
echo 'APPL????' > Sigil.app/Contents/PkgInfo

# Ad-hoc sign so macOS doesn't flag it as "damaged"
codesign -s - --force --deep Sigil.app

echo "Built Sigil.app"
