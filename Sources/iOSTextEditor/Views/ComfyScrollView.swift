//
//  ComfyScrollView.swift
//  TextEditor
//
//  Created by Aryan Rogye on 5/30/26.
//

#if os(iOS)

import UIKit

final class ComfyScrollView: UIScrollView, UIScrollViewDelegate {

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        minimumZoomScale = 1.0
        maximumZoomScale = 4.0
        zoomScale = 1.0


        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the background color for the scroll view (shown in over-scroll areas)
    func setScrollBackground(_ color: UIColor) {
        backgroundColor = color
        layer.backgroundColor = color.cgColor
    }
}

#endif
