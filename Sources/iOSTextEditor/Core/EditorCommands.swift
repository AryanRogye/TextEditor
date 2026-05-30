//
//  EditorCommands.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//

#if os(iOS)

@MainActor
public protocol EditorCommands: AnyObject {
    func focusTextView()
    func dismissKeyboardKeepingFocus()
    func showKeyboardKeepingFocus()
    func magnifyOut()
    func magnifyIn()
}

#endif
