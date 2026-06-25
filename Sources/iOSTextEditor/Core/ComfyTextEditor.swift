//
//  ComfyTextEditor.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/29/26.
//

#if os(iOS)

import SwiftUI
import UIKit

// MARK: - ComfyTextEditorContainer
public struct ComfyTextEditor: UIViewControllerRepresentable {

    @Binding var text: String
    let placeholderText: String?
    let font: UIFont
    let backgroundColor: Color
    let foregroundColor: Color
    let placeholderColor: Color
    let allowHorizontalScrolling: Bool
    let showVerticalScrollIndicator: Bool
    let showHorizontalScrollIndicator: Bool
    @Binding var isTextViewFocused: Bool
    @Binding var isKeyboardDismissed: Bool
    @Binding var isShowingLineNumbers: Bool
    var onReady: (EditorCommands) -> Void

    public init(
        text: Binding<String>,
        placeholderText: String? = nil,
        font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        foregroundColor: Color = .black,
        backgroundColor: Color = .clear,
        placeholderColor: Color = .black.opacity(0.5),
        isTextViewFocused: Binding<Bool>,
        isKeyboardDismissed: Binding<Bool>,
        isShowingLineNumbers: Binding<Bool>,
        allowHorizontalScrolling: Bool = true,
        showVerticalScrollIndicator: Bool = true,
        showHorizontalScrollIndicator: Bool = true,
        onReady: @escaping (EditorCommands) -> Void
    ) {
        self._text = text
        self.placeholderText = placeholderText
        self.backgroundColor = backgroundColor
        self.placeholderColor = placeholderColor
        self.font = font
        self.foregroundColor = foregroundColor
        self._isKeyboardDismissed = isKeyboardDismissed
        self._isTextViewFocused = isTextViewFocused
        self._isShowingLineNumbers = isShowingLineNumbers
        self.onReady = onReady
        self.allowHorizontalScrolling = allowHorizontalScrolling
        self.showVerticalScrollIndicator = showVerticalScrollIndicator
        self.showHorizontalScrollIndicator = showHorizontalScrollIndicator
    }

    public func makeUIViewController(context: Context) -> TextViewController {
        let v = TextViewController(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            placeholderColor: placeholderColor,
            font: font,
            allowHorizontalScrolling: allowHorizontalScrolling,
            showVerticalScrollIndicator: showVerticalScrollIndicator,
            showHorizontalScrollIndicator: showHorizontalScrollIndicator,
            isTextViewFocused: { focused in
                isTextViewFocused = focused
            },
            isKeyboardDismissed: { dismissed in
                isKeyboardDismissed = dismissed
            },
            onTextChange: { text in
                self.text = text
            }
        )
        if let placeholderText {
            v.textView.placeholder = placeholderText
        }
        onReady(v)
        return v
    }

    public func updateUIViewController(_ uiViewController: TextViewController, context: Context) {
        if uiViewController.textView.text != text {
            uiViewController.textView.text = text
        }
        uiViewController.setLineNumbersVisible(isShowingLineNumbers)
    }
}

#endif
