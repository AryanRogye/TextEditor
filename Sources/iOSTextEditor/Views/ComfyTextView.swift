//
//  ComfyTextView.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//

#if os(iOS)

import UIKit
import SwiftUI

final class ComfyTextView: UITextView {
    
    private let placeholderLabel = UILabel()
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    override var text: String! {
        didSet {
            updatePlaceholder()
        }
    }

    let placeholderColor: Color
    
    init(placeholderColor: Color) {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        self.placeholderColor = placeholderColor

        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        super.init(frame: .zero, textContainer: textContainer)

        textContainerInset = .zero

        font = UIFont(name: "SF Mono", size: 10)
        isEditable = true
        isSelectable = true
        setupPlaceholder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updatePlaceholderSize(_ size: CGFloat) {
        placeholderLabel.font = placeholderLabel.font.withSize(size)
    }
    
    private func setupPlaceholder() {
        placeholderLabel.textColor = UIColor(placeholderColor)
        placeholderLabel.font = font
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: textContainerInset.left + 5
            ),
            placeholderLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: textContainerInset.top
            )
        ])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    @objc private func textChanged() {
        updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

#endif
