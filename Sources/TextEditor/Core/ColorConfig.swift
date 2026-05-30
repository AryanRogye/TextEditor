//
//  ColorConfig.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/6/26.
//

#if os(macOS)

import SwiftUI

public struct ColorConfig {
    /// Color of the editor background
    public var editorBackground: Color
    
    /// Color of the text
    public var editorForegroundStyle: Color

    /// Color of the border
    public var borderColor: Color


    var syntaxKeyword               : Color
    var syntaxString                : Color
    var syntaxNumber                : Color
    var syntaxComment               : Color
    var syntaxJsonKey               : Color

    public init(
        editorBackground: Color = .white,
        editorForegroundStyle: Color = .black,
        borderColor: Color = Color.gray.opacity(0.3),
        syntaxKeyword : Color,
        syntaxString  : Color,
        syntaxNumber  : Color,
        syntaxComment : Color,
        syntaxJsonKey : Color

    ) {
        self.editorBackground = editorBackground
        self.editorForegroundStyle = editorForegroundStyle
        self.borderColor = borderColor
        self.syntaxKeyword = syntaxKeyword
        self.syntaxString = syntaxString
        self.syntaxNumber = syntaxNumber
        self.syntaxComment = syntaxComment
        self.syntaxJsonKey = syntaxJsonKey
    }
}
#endif
