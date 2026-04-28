# TextEditor

This editor started inside **ComfyEditor** as a built‑in component. As I built more apps, I needed the same editor elsewhere, so I extracted it into a Swift package. That let me keep one generalized editor that I can reuse across all my projects instead of copy‑pasting the code.

In short: **ComfyEditor ➜ Swift Package ➜ General‑purpose editor for all projects.**

The main reason this package exists is simple: I want a native SwiftUI/AppKit text editor with **Vim motions built in**. There are plenty of text editor wrappers, but I use this one in my own apps because Vim support is part of the editor instead of something each app has to bolt on separately.

## What It Does

- Provides a reusable macOS text editor packaged as `TextEditor`.
- Supports Vim mode and tested Vim movement behavior out of the box.
- Exposes editor commands through `onReady`, so host apps can wire buttons, menus, and keyboard shortcuts.
- Supports configurable initial zoom and initial wrapping mode.
- Supports chunked text rendering and highlight navigation for larger/editor-like workflows.

## Vim Support

Vim support is intentionally practical, not complete. I am adding the motions and behaviors I actually need as I build apps with this package. The existing Vim behavior is covered by tests, and new Vim features should be added with focused tests when possible.

Current focus:

- Normal-mode movement primitives.
- Cursor and insertion-point handling.
- Basic editing commands where useful.
- Save/search hooks needed by host apps.

Not every Vim feature is implemented. That is expected for now.

## Basic Usage

```swift
import SwiftUI
import TextEditor

struct EditorView: View {
    @State private var text = ""
    @State private var magnification: CGFloat = 1
    @State private var editorCommands: EditorCommands?

    var body: some View {
        VStack {
            HStack {
                Button("Toggle Wrap") {
                    editorCommands?.toggleWrap()
                }

                Button("Zoom In") {
                    editorCommands?.increaseFontOrZoomIn()
                }

                Button("Zoom Out") {
                    editorCommands?.decreaseFontOrZoomOut()
                }
            }

            ComfyTextEditor(
                text: $text,
                magnification: $magnification,
                noWrap: true,
                showScrollbar: .constant(true),
                isInVimMode: .constant(true),
                onReady: { commands in
                    editorCommands = commands
                }
            )
        }
    }
}
```

## Public Controls

`ComfyTextEditor` supports:

- `magnification`: controls the starting zoom level and stays in sync with editor zoom changes.
- `noWrap`: controls whether the editor starts with line wrapping disabled.
- `isInVimMode`: enables Vim-style command handling.
- `showScrollbar`: controls vertical scrollbar visibility.
- `onReady`: returns `EditorCommands` for host-app controls.

`EditorCommands` currently exposes:

- `toggleWrap()`
- `toggleBold()`
- `increaseFontOrZoomIn()`
- `decreaseFontOrZoomOut()`

## Tests

The package includes tests for the Vim engine and movement behavior. Run them with:

```sh
swift test
```
