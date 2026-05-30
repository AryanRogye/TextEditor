//
//  ComfyTextView.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//

#if os(iOS)

import UIKit

final class ComfyTextView: UITextView {
    init() {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()


        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        super.init(frame: .zero, textContainer: textContainer)

        textContainerInset = .zero

        font = UIFont(name: "SF Mono", size: 10)
        isEditable = true
        isSelectable = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
