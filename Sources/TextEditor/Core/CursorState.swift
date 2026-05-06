//
//  CursorState.swift
//  TextEditor
//
//  Created by Aryan Rogye on 12/7/25.
//

import Foundation

@MainActor
final class CursorState: ObservableObject {
    @Published var position: Position?
    @Published var isOnNewLine = false
    @Published private var cursorRange: NSRange?

    var nsRange: NSRange? {
        cursorRange
    }

    func update(from buffer: BufferView) {
        let position = buffer.cursorPosition()
        self.position = position
        cursorRange = buffer.getCursorPosition()
        isOnNewLine = buffer.isOnNewLine(position)
    }
}
