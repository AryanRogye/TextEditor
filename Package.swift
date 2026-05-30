// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextEditor",
    platforms: [
        .macOS(.v14),
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "TextEditor",
            targets: ["TextEditor"]
        ),
        .library(
            name: "iOSTextEditor",
            targets: ["iOSTextEditor"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/AryanRogye/LocalShortcuts.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "TextEditor",
            dependencies: [
                .product(name: "LocalShortcuts", package: "LocalShortcuts"),
            ]
        ),
        .target(
            name: "iOSTextEditor"
            /// no deps
        ),
        .testTarget(
            name: "TextEditorTests",
            dependencies: [
                "TextEditor"
            ]
        ),
    ],
    swiftLanguageModes: [
        .v6
    ],
)
