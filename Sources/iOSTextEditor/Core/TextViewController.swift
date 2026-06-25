//
//  TextViewController.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//
#if os(iOS)

import UIKit
import SwiftUI

public class TextViewController: UIViewController, UITextViewDelegate, EditorCommands {

    let scrollView = ComfyScrollView()
    let textView : ComfyTextView

    let lineNumberView = LineNumberView()
    let lineNumberSeperatorView = UIView()

    private var editorFont: UIFont
    let foregroundColor: Color
    let backgroundColor: Color
    let placeholderColor: Color
    let isTextViewFocused: (Bool) -> Void
    let isKeyboardDismissed: (Bool) -> Void
    let onTextChange: (String) -> Void

    let lineNumberWidth: CGFloat = 44
    let lineNumberSeperatorWidth: CGFloat = 1

    /// storing this so that we can modify this
    var lineNumberWidthConstraint: NSLayoutConstraint
    var textViewWidthConstraint: NSLayoutConstraint

    /// font size computed
    private var fontSize: CGFloat {
        textView.font?.pointSize ?? editorFont.pointSize
    }
    
    let allowHorizontalScrolling: Bool
    let showVerticalScrollIndicator: Bool
    let showHorizontalScrollIndicator: Bool

    init(
        foregroundColor: Color,
        backgroundColor: Color,
        placeholderColor: Color,
        font: UIFont,
        allowHorizontalScrolling: Bool,
        showVerticalScrollIndicator: Bool,
        showHorizontalScrollIndicator: Bool,
        isTextViewFocused: @escaping (Bool) -> Void,
        isKeyboardDismissed: @escaping (Bool) -> Void,
        onTextChange: @escaping (String) -> Void
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.placeholderColor = placeholderColor
        self.isTextViewFocused = isTextViewFocused
        self.isKeyboardDismissed = isKeyboardDismissed
        self.onTextChange = onTextChange
        self.editorFont = font
        self.allowHorizontalScrolling = allowHorizontalScrolling
        self.showVerticalScrollIndicator = showVerticalScrollIndicator
        self.showHorizontalScrollIndicator = showHorizontalScrollIndicator
        self.textView = ComfyTextView(placeholderColor: placeholderColor)

        /// setup the width
        lineNumberWidthConstraint = lineNumberView.widthAnchor.constraint(equalToConstant: lineNumberWidth)
        textViewWidthConstraint = textView.widthAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.widthAnchor,
            /// the left side should be combination of the lineNumberView + the seperator width
            constant: -(lineNumberWidth + lineNumberSeperatorWidth)
        )
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let root = UIView()
        root.backgroundColor = .clear
        self.view = root

        lineNumberSeperatorView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        lineNumberView.translatesAutoresizingMaskIntoConstraints = false

        /// lineNumberView background should be clear
        lineNumberView.backgroundColor = .clear
        /// seperator background
        lineNumberSeperatorView.backgroundColor = .black
        
        view.backgroundColor = UIColor(backgroundColor)
        scrollView.backgroundColor = UIColor(backgroundColor)
        

        lineNumberView.textView = textView

        scrollView.addSubview(lineNumberView)
        scrollView.addSubview(lineNumberSeperatorView)
        scrollView.addSubview(textView)
        
        scrollView.showsVerticalScrollIndicator = showVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = showHorizontalScrollIndicator
        
        scrollView.contentInset.bottom = 640
        scrollView.alwaysBounceVertical = true

        root.addSubview(scrollView)

        textView.backgroundColor = UIColor(backgroundColor)
        textView.textColor = UIColor(foregroundColor)
        textView.font = editorFont
        textView.text = "Hello How Are You"
        textView.delegate = self
        textView.updatePlaceholderSize(editorFont.pointSize)
        /// this forces us to use the scrollviews scrolling
        textView.isScrollEnabled = false

        var constraints: [NSLayoutConstraint] = [
            /// ScrollView Constraints
            /// background view (expand all the way)
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: root.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            
            /// LineNumberView Constrains
            /// lineNumberView should go all the way to the left
            lineNumberView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            /// top bottom should stretch all the way
            lineNumberView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            lineNumberView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            /// set lineNumberView
            lineNumberWidthConstraint,
            
            /// LineNumberSeperatorView Constraints
            lineNumberSeperatorView.leadingAnchor.constraint(equalTo: lineNumberView.trailingAnchor),
            lineNumberSeperatorView.widthAnchor.constraint(equalToConstant: lineNumberSeperatorWidth),
            
            /// top bottom should stretch all the way
            lineNumberSeperatorView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            lineNumberSeperatorView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor),
            
            
            /// TextView Constraints
            /// leading should go up to the lineNumberView
            textView.leadingAnchor.constraint(equalTo: lineNumberSeperatorView.trailingAnchor),
            /// end all the way down
            textView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            textViewWidthConstraint,
            textView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ]
        if !allowHorizontalScrolling {
            constraints.append(
                scrollView.contentLayoutGuide.widthAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.widthAnchor
                )
            )
        }
        
        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - Delegate Functions
extension TextViewController {
    public func textViewDidChange(_ textView: UITextView) {
        lineNumberView.setNeedsDisplay()
        onTextChange(textView.text)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        /// indicate that the textview is now in focus
        isTextViewFocused(true)
        /// when we start focusing our keyboard is active
        isKeyboardDismissed(false)

        /// show keyboard again
        showKeyboardKeepingFocus()

        toggleLineNumberOn()
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        /// indicate that the textview is not in focused
        isTextViewFocused(false)
        /// when dismissed keyboard is gone too
        isKeyboardDismissed(true)
    }
}

// MARK:  - EditorCommands
extension TextViewController {

    /// Function makes the textview focused
    public func focusTextView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.textView.becomeFirstResponder()
        }
    }


    public func dismissKeyboardKeepingFocus() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.textView.inputView = UIView()
            self.textView.reloadInputViews()
            self.isKeyboardDismissed(true)
            toggleLineNumberOn()
        }
    }

    public func showKeyboardKeepingFocus() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.textView.inputView = nil
            self.textView.reloadInputViews()
            self.isKeyboardDismissed(false)
            toggleLineNumberOn()
        }
    }


    public func magnifyIn() {
        setEditorFontSize(fontSize + 2)
    }

    public func magnifyOut() {
        setEditorFontSize(fontSize - 2)
    }
}

// MARK: - Helpers
extension TextViewController {
    private func setEditorFontSize(_ size: CGFloat) {
        let clamped = min(max(size, 12), 60)
        
        let newFont = textView.font?.withSize(clamped)
        ?? UIFont.monospacedSystemFont(ofSize: clamped, weight: .regular)
        
        textView.font = newFont
        editorFont = newFont
        
        lineNumberView.fontSize = clamped * 0.55
        lineNumberView.setNeedsDisplay()
        
        textView.invalidateIntrinsicContentSize()
        textView.updatePlaceholderSize(clamped)
        view.layoutIfNeeded()
    }

    private func toggleLineNumberOn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            magnifyIn()
            magnifyOut()
        }
    }

    public func setLineNumbersVisible(_ visible: Bool) {
        if visible {
            lineNumberView.isHidden = false
            lineNumberSeperatorView.isHidden = false
        }

        lineNumberWidthConstraint.constant = visible ? lineNumberWidth : 0

        textViewWidthConstraint.constant = visible
        ? -(lineNumberWidth + lineNumberSeperatorWidth)
        : 0

        UIView.animate(withDuration: 0.25) {
            self.lineNumberView.alpha = visible ? 1 : 0
            self.lineNumberSeperatorView.alpha = visible ? 1 : 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !visible {
                self.lineNumberView.isHidden = true
                self.lineNumberSeperatorView.isHidden = true
            }
        }

        if visible {
            lineNumberView.setNeedsDisplay()
        }
    }
}

#endif
