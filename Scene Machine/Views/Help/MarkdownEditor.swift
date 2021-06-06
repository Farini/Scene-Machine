//
//  MarkdownEditor.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/5/21.
//

import SwiftUI
import HighlightedTextEditor

struct MarkdownEditor: View {
    
    @State private var text: String = ""
    
    var body: some View {
        VStack {
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
        }
    }
}

struct MarkdownEditor_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditor()
    }
}
