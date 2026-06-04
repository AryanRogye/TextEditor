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
    let fontSize: CGFloat
    let backgroundColor: Color
    @Binding var isTextViewFocused: Bool
    @Binding var isKeyboardDismissed: Bool
    @Binding var isShowingLineNumbers: Bool
    var onReady: (EditorCommands) -> Void

    public init(
        text: Binding<String>,
        placeholderText: String? = nil,
        fontSize: CGFloat = 30,
        backgroundColor: Color = .clear,
        isTextViewFocused: Binding<Bool>,
        isKeyboardDismissed: Binding<Bool>,
        isShowingLineNumbers: Binding<Bool>,
        onReady: @escaping (EditorCommands) -> Void
    ) {
        self._text = text
        self.placeholderText = placeholderText
        self.backgroundColor = backgroundColor
        self.fontSize = fontSize
        self._isKeyboardDismissed = isKeyboardDismissed
        self._isTextViewFocused = isTextViewFocused
        self._isShowingLineNumbers = isShowingLineNumbers
        self.onReady = onReady
    }

    public func makeUIViewController(context: Context) -> TextViewController {
        let v = TextViewController(
            backgroundColor: backgroundColor,
            fontSize: fontSize,
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
