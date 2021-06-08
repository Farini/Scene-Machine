//
//  MarkdownEditor.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/5/21.
//

import SwiftUI
import HighlightedTextEditor

fileprivate let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])
fileprivate let metalFloat = try! NSRegularExpression(pattern: "float", options: [])

struct MarkdownEditor: View {
    
    @State private var text: String = ""
    
    // Changing Highlight rules
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: betweenUnderscores, formattingRules: [
            TextFormattingRule(fontTraits: [.italic, .monoSpace]),
            TextFormattingRule(key: .foregroundColor, value: NSColor.red),
            TextFormattingRule(key: .underlineStyle) { content, range in
                if content.count > 10 { return NSUnderlineStyle.double.rawValue }
                else { return NSUnderlineStyle.single.rawValue }
            }
        ]),
        HighlightRule(pattern: metalFloat, formattingRules: [
            TextFormattingRule(fontTraits: [.monoSpace]),
            TextFormattingRule(key: .foregroundColor, value: NSColor.red)
        ])]
    
    
    var body: some View {
        VSplitView {
            HighlightedTextEditor(text: $text, highlightRules: .markdown)
                // optional modifiers
                // .onSelectionChange{ range in print("Range: \(range)") }
                
                .onCommit { print("commited") }
                .onEditingChanged { print("editing changed") }
                // .onTextChange { print("latest text value", $0) }
                //                .onSelectionChange { print("NSRange of current selection", $0)}
                
                
                .introspect { editor in
                    // access underlying UITextView or NSTextView
                    // editor.textView.backgroundColor = .green
                }
            HighlightedTextEditor(text: $text, highlightRules: rules)
        }
    }
}

struct MarkdownEditor_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditor()
    }
}
