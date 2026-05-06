//
//  ComfyTextView.swift
//  ComfyEditor
//
//  Created by Aryan Rogye on 12/2/25.
//

import AppKit
import LocalShortcuts
import SwiftUI

final class ComfyTextView: NSTextView {

    override var insertionPointColor: NSColor? {
        get { .controlAccentColor }
        set { /* ignore external changes */  }
    }

    var vimEngine: VimEngine
    var cursorState: CursorState
    private(set) var isNoWrap = true

    lazy var vimCursorView: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor(Color.accentColor.opacity(0.5)).cgColor
        v.isHidden = true  // Hide until first update
        return v
    }()

    public func setupCursorView() {
        self.addSubview(vimCursorView)
    }

    public func goToRange(_ range: NSRange) {
        self.scrollRangeToVisible(range)
        self.setSelectedRange(range)
    }

    public func updateHighlightedRanges(range: NSRange, filterText: String) {
        guard let storage = self.textStorage else { return }

        let matchLen = (filterText as NSString).length
        let matchRange = NSRange(location: range.location, length: matchLen)

        storage.beginEditing()

        if matchRange.location >= 0,
           matchRange.location + matchRange.length <= storage.length {
            storage.addAttribute(
                .backgroundColor,
                value: NSColor.selectedTextBackgroundColor.withAlphaComponent(0.4),
                range: matchRange
            )
        }

        storage.endEditing()
    }

    public func resetHighlightedRanges() {
        guard let storage = self.textStorage else { return }
        let full = NSRange(location: 0, length: storage.length)
        storage.removeAttribute(.backgroundColor, range: full)
    }

    public func setNoWrap(_ value: Bool) {
        guard isNoWrap != value else { return }
        isNoWrap = value

        if value {
            configureNoWrap()
        } else {
            configureWrap(contentSize: enclosingScrollView?.contentSize ?? bounds.size)
        }
    }

    public func configureWrap(contentSize: NSSize) {
        guard !isNoWrap, let textContainer else { return }

        let wrappingWidth = max(0, contentSize.width)
        minSize = NSSize(width: 0, height: contentSize.height)
        maxSize = NSSize(
            width: CoreFoundation.CGFloat.greatestFiniteMagnitude,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )
        isVerticallyResizable = true
        isHorizontallyResizable = false
        autoresizingMask = [.width]
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textContainer.lineFragmentPadding = 0
        textContainer.containerSize = NSSize(
            width: wrappingWidth,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )
        if abs(frame.width - wrappingWidth) > 0.5 {
            setFrameSize(NSSize(width: wrappingWidth, height: max(frame.height, contentSize.height)))
        }
        invalidateTextLayout()
    }

    private func configureNoWrap() {
        guard let textContainer else { return }

        isVerticallyResizable = true
        isHorizontallyResizable = true
        autoresizingMask = [.height]
        maxSize = NSSize(
            width: CoreFoundation.CGFloat.greatestFiniteMagnitude,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        textContainer.lineFragmentPadding = 0
        textContainer.containerSize = NSSize(
            width: CoreFoundation.CGFloat.greatestFiniteMagnitude,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )
        invalidateTextLayout()
    }

    private func invalidateTextLayout() {
        guard let textContainer else { return }

        layoutManager?.invalidateLayout(forCharacterRange: NSRange(location: 0, length: string.utf16.count), actualCharacterRange: nil)
        layoutManager?.ensureLayout(for: textContainer)
        needsLayout = true
        needsDisplay = true
    }

    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
        // If the blink cycle is off, don't draw anything
        guard flag else { return }

        /// if User is not using vim mode then draw regular
        if !vimEngine.isInVimMode {
            super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
            return
        }
        handleVimInsertionPoint(rect, color)
    }

    override func keyDown(with event: NSEvent) {
        if vimEngine.isInVimMode {
            if vimEngine.handleVimEvent(event) {
                /// if vimEvent is ok to type then we can type
                super.keyDown(with: event)
            }
            return
        }
        super.keyDown(with: event)
    }

    init(vimEngine: VimEngine, cursorState: CursorState) {

        self.vimEngine = vimEngine
        self.cursorState = cursorState

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()

        let textContainer = NSTextContainer()

        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        textContainer.containerSize = NSSize(
            width: CoreFoundation.CGFloat.greatestFiniteMagnitude,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        super.init(frame: .zero, textContainer: textContainer)
        self.vimEngine.buffer.setTextView(self)

        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay

        isVerticallyResizable = true
        isHorizontallyResizable = true
        autoresizingMask = [.height]
        textContainerInset = .zero

        maxSize = NSSize(
            width: CoreFoundation.CGFloat.greatestFiniteMagnitude,
            height: CoreFoundation.CGFloat.greatestFiniteMagnitude
        )

        font = NSFont(name: "SF Mono", size: 10)
        isEditable = true
        isSelectable = true
        isRichText = true
        allowsDocumentBackgroundColorChange = true
        usesFontPanel = true
        usesRuler = true
        
        // Disable NSTextView's own background drawing to prevent white tearing
        // Background will be drawn via layer instead
        drawsBackground = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
