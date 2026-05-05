//
//  SyntaxHighlighter.swift
//  TextEditor
//
//  Created by OpenAI on 5/5/26.
//

import AppKit

@MainActor
final class SyntaxHighlighter {
    weak var textView: NSTextView?

    var language: SyntaxHighlightLanguage = .none {
        didSet {
            guard oldValue != language else { return }
            scheduleHighlight()
        }
    }

    var baseTextColor: NSColor = .labelColor {
        didSet {
            scheduleHighlight()
        }
    }

    private var pendingWorkItem: DispatchWorkItem?

    init(textView: NSTextView? = nil) {
        self.textView = textView
    }

    func scheduleHighlight() {
        pendingWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.applyHighlighting()
            }
        }
        pendingWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: item)
    }

    func applyHighlighting() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil

        guard let textView, let storage = textView.textStorage else { return }

        let fullRange = NSRange(location: 0, length: storage.length)
        guard fullRange.length > 0 else { return }

        storage.beginEditing()
        storage.addAttribute(.foregroundColor, value: baseTextColor, range: fullRange)

        switch language {
        case .none:
            break
        case .markdown:
            applyMarkdownHighlighting(to: storage, fullRange: fullRange)
        default:
            applyCodeHighlighting(to: storage, fullRange: fullRange)
        }

        storage.endEditing()
        textView.setNeedsDisplay(textView.visibleRect)
    }

    private func applyCodeHighlighting(to storage: NSTextStorage, fullRange: NSRange) {
        let text = storage.string as NSString

        applyKeywords(to: storage, fullRange: fullRange)
        apply(pattern: #"(?<![\w.])-?\b\d+(?:\.\d+)?\b"#, color: .systemOrange, to: storage, range: fullRange)

        apply(
            pattern: #""(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'"#,
            color: .systemGreen,
            to: storage,
            range: fullRange
        )

        if language == .swift {
            apply(pattern: "#\"(?:\\\\.|[^\"\\\\])*\"#", color: .systemGreen, to: storage, range: fullRange)
        }

        if language.supportsSlashComments {
            apply(pattern: #"//[^\n\r]*"#, color: .systemGray, to: storage, range: fullRange)
            apply(
                pattern: #"/\*.*?\*/"#,
                color: .systemGray,
                to: storage,
                range: fullRange,
                options: [.dotMatchesLineSeparators]
            )
        }

        if language.supportsHashComments {
            apply(pattern: #"#[^\n\r]*"#, color: .systemGray, to: storage, range: fullRange)
        }

        if language == .json {
            apply(pattern: #""(?:\\.|[^"\\])*"\s*:"#,
                  color: .systemBlue,
                  to: storage,
                  range: NSRange(location: 0, length: text.length))
        }
    }

    private func applyMarkdownHighlighting(to storage: NSTextStorage, fullRange: NSRange) {
        apply(pattern: #"(?m)^#{1,6}\s+.*$"#, color: .systemBlue, to: storage, range: fullRange)
        apply(pattern: #"`[^`\n]+`"#, color: .systemPurple, to: storage, range: fullRange)
        apply(
            pattern: #"(?s)```.*?```"#,
            color: .systemGreen,
            to: storage,
            range: fullRange,
            options: [.dotMatchesLineSeparators]
        )
        apply(pattern: #"(?m)^\s*[-*+]\s+"#, color: .systemOrange, to: storage, range: fullRange)
        apply(pattern: #"\[[^\]]+\]\([^)]+\)"#, color: .systemTeal, to: storage, range: fullRange)
    }

    private func applyKeywords(to storage: NSTextStorage, fullRange: NSRange) {
        guard !language.keywords.isEmpty else { return }
        let escaped = language.keywords
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .sorted { $0.count > $1.count }
            .joined(separator: "|")

        apply(pattern: #"(?<![A-Za-z0-9_])("# + escaped + #")(?![A-Za-z0-9_])"#,
              color: .systemPurple,
              to: storage,
              range: fullRange)
    }

    private func apply(
        pattern: String,
        color: NSColor,
        to storage: NSTextStorage,
        range: NSRange,
        options: NSRegularExpression.Options = []
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
        regex.enumerateMatches(in: storage.string, options: [], range: range) { match, _, _ in
            guard let match, match.range.location != NSNotFound, match.range.length > 0 else { return }
            storage.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }
}
