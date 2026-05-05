//
//  SyntaxHighlightLanguage.swift
//  TextEditor
//
//  Created by OpenAI on 5/5/26.
//

import Foundation

public enum SyntaxHighlightLanguage: Equatable, Sendable {
    case none
    case swift
    case javascript
    case typescript
    case json
    case markdown
    case python
}

extension SyntaxHighlightLanguage {
    var keywords: Set<String> {
        switch self {
        case .swift:
            return [
                "actor", "any", "as", "associatedtype", "async", "await", "break", "case",
                "catch", "class", "continue", "defer", "deinit", "do", "else", "enum",
                "extension", "fallthrough", "false", "fileprivate", "for", "func", "guard",
                "if", "import", "in", "init", "inout", "internal", "is", "let", "nil",
                "nonisolated", "open", "operator", "private", "protocol", "public",
                "repeat", "rethrows", "return", "self", "Self", "static", "struct",
                "subscript", "super", "switch", "throws", "true", "try", "typealias",
                "var", "where", "while"
            ]
        case .javascript, .typescript:
            let keywords: Set<String> = [
                "async", "await", "break", "case", "catch", "class", "const", "continue",
                "debugger", "default", "delete", "do", "else", "export", "extends",
                "false", "finally", "for", "from", "function", "if", "import", "in",
                "instanceof", "let", "new", "null", "of", "return", "static", "super",
                "switch", "this", "throw", "true", "try", "typeof", "undefined", "var",
                "void", "while", "with", "yield"
            ]
            guard self == .typescript else { return keywords }
            return keywords.union([
                "any", "boolean", "declare", "enum", "implements", "interface", "keyof",
                "namespace", "never", "number", "private", "protected", "public",
                "readonly", "string", "type", "unknown"
            ])
        case .json:
            return ["true", "false", "null"]
        case .python:
            return [
                "and", "as", "assert", "async", "await", "break", "class", "continue",
                "def", "del", "elif", "else", "except", "False", "finally", "for",
                "from", "global", "if", "import", "in", "is", "lambda", "None",
                "nonlocal", "not", "or", "pass", "raise", "return", "True", "try",
                "while", "with", "yield"
            ]
        case .markdown, .none:
            return []
        }
    }

    var supportsSlashComments: Bool {
        switch self {
        case .swift, .javascript, .typescript:
            return true
        case .none, .json, .markdown, .python:
            return false
        }
    }

    var supportsHashComments: Bool {
        self == .python
    }
}
