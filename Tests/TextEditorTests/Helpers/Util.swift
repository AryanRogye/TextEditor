//
//  Util.swift
//  TextEditor
//
//  Created by Aryan Rogye on 12/9/25.
//

import AppKit
@testable import TextEditor

struct Util {
    static func makeKeyEvent(_ char: String) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: char,
            charactersIgnoringModifiers: char,
            isARepeat: false,
            keyCode: 0
        )!
    }

    @MainActor
    static func makeTextViewBuffer(
        text: String,
        cursorOffset: Int
    ) -> (NSTextViewBufferAdapter, NSTextView) {
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
        textView.string = text
        textView.setSelectedRange(NSRange(location: cursorOffset, length: 0))

        let buffer = NSTextViewBufferAdapter()
        buffer.setTextView(textView)
        return (buffer, textView)
    }

    static func offset(in lines: [String], line: Int, column: Int) -> Int {
        var offset = 0

        for i in 0..<min(line, lines.count) {
            offset += lines[i].count + 1
        }

        guard line < lines.count else { return offset }
        return offset + min(column, lines[line].count)
    }
}
