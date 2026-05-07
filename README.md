# TextEditor

This editor started inside **ComfyEditor** as a built‑in component. As I built more apps, I needed the same editor elsewhere, so I extracted it into a Swift package. That let me keep one generalized editor that I can reuse across all my projects instead of copy‑pasting the code.

In short: **ComfyEditor ➜ Swift Package ➜ General‑purpose editor for all projects.**

The main reason this package exists is simple: I want a native SwiftUI/AppKit text editor with **Vim motions built in**. There are plenty of text editor wrappers, but I use this one in my own apps because Vim support is part of the editor instead of something each app has to bolt on separately.

## What It Does

- Provides a reusable macOS text editor packaged as `TextEditor`.
- Supports Vim mode and tested Vim movement behavior out of the box.
- Exposes editor commands through `onReady`, so host apps can wire buttons, menus, and keyboard shortcuts.
- Exposes highlight commands through `onHighlight`, so host apps can jump between highlighted ranges.
- Supports configurable initial zoom and initial wrapping mode.
- Supports configurable colors, border radius, editability, syntax highlighting, and bold/font bindings.
- Supports chunked text rendering and highlight navigation for larger/editor-like workflows.

## Package Requirements

- Swift tools version: `6.1`
- Platform: macOS 14+
- Product: `TextEditor`
- Target: `TextEditor`
- Dependency: [`LocalShortcuts`](https://github.com/AryanRogye/LocalShortcuts), tracked from the `main` branch.

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
    @State private var isBold = false
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
                isBold: $isBold,
                magnification: $magnification,
                noWrap: true,
                showScrollbar: .constant(true),
                isInVimMode: .constant(true),
                onReady: { commands in
                    editorCommands = commands
                },
                onSave: {
                    print("save requested")
                }
            )
        }
    }
}
```

## Public Controls

`ComfyTextEditor` supports:

- `text`: editable text binding for normal single-buffer usage.
- `chunks`: chunked text binding for larger read/edit workflows.
- `useChunks`: selects chunked rendering in the full initializer.
- `highlightIndexRows`: maps highlight row indices to source text for highlight navigation.
- `currentIndex`: tracks the current highlighted row.
- `filterText`: text used when applying highlight ranges.
- `font`: current editor font size binding.
- `isBold`: tracks whether the current cursor location is bold.
- `magnification`: controls the starting zoom level and stays in sync with editor zoom changes.
- `noWrap`: controls whether the editor starts with line wrapping disabled.
- `allowEdit`: controls whether the text view is editable.
- `isInVimMode`: enables Vim-style command handling.
- `showScrollbar`: controls vertical scrollbar visibility.
- `syntaxHighlighting`: enables lightweight syntax highlighting for supported languages.
- `editorBackground`: controls the editor background color.
- `editorForegroundStyle`: controls the text color.
- `borderColor`: controls the editor border color.
- `borderRadius`: controls the editor corner radius.
- `onReady`: returns `EditorCommands` for host-app controls.
- `onHighlight`: returns `HighlightCommands` for host-app highlight navigation.
- `onSave`: fires when Vim save is requested.
- `onSearchRequested`: fires when Vim search is requested.
- `onHighlightUpdated`: reports progress while chunked highlights are applied.

`EditorCommands` currently exposes:

- `toggleWrap()`
- `toggleBold()`
- `increaseFontOrZoomIn()`
- `decreaseFontOrZoomOut()`

`HighlightCommands` currently exposes:

- `gotoHighlight(_ index: Int)`
- `gotoHighlight(_ range: NSRange)`
- `resetHighlightedRanges()`

`SyntaxHighlightLanguage` currently supports:

- `.none`
- `.swift`
- `.javascript`
- `.typescript`
- `.json`
- `.markdown`
- `.python`

## Chunked Usage

```swift
import SwiftUI
import TextEditor

struct ChunkedEditorView: View {
    @State private var chunks = ["func example() {\n", "    print(\"hello\")\n", "}\n"]
    @State private var showScrollbar = true
    @State private var currentIndex: Int?
    @State private var highlightRows: [Int: String] = [1: "print(\"hello\")"]
    @State private var filterText = "hello"
    @State private var highlightCommands: HighlightCommands?

    var body: some View {
        ComfyTextEditor(
            chunks: $chunks,
            highlightIndexRows: $highlightRows,
            filterText: $filterText,
            currentIndex: $currentIndex,
            showScrollbar: $showScrollbar,
            syntaxHighlighting: .swift,
            onHighlight: { commands in
                highlightCommands = commands
            }
        )
    }
}
```

## Tests

The package includes tests for the Vim engine and movement behavior. Run them with:

```sh
swift test
```
