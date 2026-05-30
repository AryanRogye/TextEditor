//
//  LineNumberView.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//

#if os(iOS)

import UIKit

final class LineNumberView: UIView {
    weak var textView: UITextView?
    var fontSize: CGFloat = 16
    var drawnLineNumbers = Set<Int>()

    override func draw(_ rect: CGRect) {
        guard let textView else { return }

        let layoutManager = textView.layoutManager
        let textStorage = textView.textStorage

        let fullRange = NSRange(location: 0, length: textStorage.length)
        drawnLineNumbers.removeAll()

        layoutManager.enumerateLineFragments(
            forGlyphRange: fullRange
        ) { _, usedRect, _, glyphRange, _ in

            let charRange = layoutManager.characterRange(
                forGlyphRange: glyphRange,
                actualGlyphRange: nil
            )

            let lineNumber = textStorage.string[..<textStorage.string.index(
                textStorage.string.startIndex,
                offsetBy: charRange.location
            )]
                .filter { $0 == "\n" }
                .count + 1

            if self.drawnLineNumbers.contains(lineNumber) {
            } else {
                self.drawnLineNumbers.insert(lineNumber)

                let font = UIFont.systemFont(ofSize: self.fontSize, weight: .regular)

                let y = usedRect.minY
                + textView.textContainerInset.top
                + ((usedRect.height - font.lineHeight) / 2)


                "\(lineNumber)".draw(
                    at: CGPoint(x: 15, y: y),
                    withAttributes: [
                        .font: font,
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                )
            }
        }
    }
}

#endif
