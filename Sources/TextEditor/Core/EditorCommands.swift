//
//  EditorCommands.swift
//  TextEditor
//
//  Created by Aryan Rogye on 12/24/25.
//

#if os(macOS)

@MainActor
public protocol EditorCommands: AnyObject {
    func toggleWrap()
    func toggleBold()
    func increaseFontOrZoomIn()
    func decreaseFontOrZoomOut()
}
#endif
