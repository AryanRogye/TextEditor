//
//  ColorConfig.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/6/26.
//

import SwiftUI

public struct ColorConfig {
    /// Color of the editor background
    public var editorBackground: Color
    
    /// Color of the text
    public var editorForegroundStyle: Color
    
    /// Color of the border
    public var borderColor: Color

    public init(
        editorBackground: Color = .white,
        editorForegroundStyle: Color = .black,
        borderColor: Color = Color.gray.opacity(0.3)
    ) {
        self.editorBackground = editorBackground
        self.editorForegroundStyle = editorForegroundStyle
        self.borderColor = borderColor
    }
}
