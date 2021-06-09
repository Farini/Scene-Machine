//
//  MarkdownEditor.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/5/21.
//

import SwiftUI
import HighlightedTextEditor

struct MarkdownEditor: View {
    
    @State private var text: String = "# Title"
    @State private var saveURL:URL?
    @State private var fileName:String = ""
    @State private var popHelper:Bool = false
    
    private let rules: [HighlightRule] = [
        
        HighlightRule(pattern: headingRegex, formattingRules: [
            TextFormattingRule(key: .font) { content, range in
                if content.contains("###") {
                    return NSFont.systemFont(ofSize: 14)
                } else if content.contains("##") {
                    return NSFont.systemFont(ofSize: 16)
                } else {
                    return NSFont.systemFont(ofSize: 18)
                }
            }
        ]),
        
        HighlightRule(pattern: inlineCodeRegex, formattingRule: TextFormattingRule(key: .font, value: NSFont.monospacedSystemFont(ofSize: 11, weight: .thin))),
        
        HighlightRule(pattern: codeBlockRegex, formattingRule: TextFormattingRule(key: .font, value: NSFont.monospacedSystemFont(ofSize: 11, weight: .thin))),
        HighlightRule(
            pattern: linkOrImageRegex,
            formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
        ),
        HighlightRule(
            pattern: linkOrImageTagRegex,
            formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
        ),
        HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(fontTraits: .bold)),
        HighlightRule(
            pattern: asteriskEmphasisRegex,
            formattingRule: TextFormattingRule(fontTraits: .italic)
        ),
        HighlightRule(
            pattern: underscoreEmphasisRegex,
            formattingRule: TextFormattingRule(fontTraits: .italic)
        ),
        HighlightRule(
            pattern: boldEmphasisAsteriskRegex,
            formattingRule: TextFormattingRule(fontTraits: .bold)
        ),
        HighlightRule(
            pattern: blockquoteRegex,
            formattingRules: [TextFormattingRule(key: .backgroundColor, value: NSColor.windowBackgroundColor),
                              TextFormattingRule(key: .font, value: NSFont.systemFont(ofSize: 13, weight: .semibold)),
                              TextFormattingRule(fontTraits: .italic),
                              TextFormattingRule(key: .foregroundColor, value: NSColor.controlAccentColor)]
        ),
        HighlightRule(
            pattern: horizontalRuleRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.gray)
        ),
        HighlightRule(
            pattern: unorderedListRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.controlAccentColor)
        ),
        HighlightRule(
            pattern: orderedListRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.controlAccentColor)
        ),
        HighlightRule(
            pattern: buttonRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.windowBackgroundColor)
        ),
        HighlightRule(pattern: strikethroughRegex, formattingRules: [
            TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
            TextFormattingRule(key: .strikethroughColor, value: NSColor.labelColor)
        ]),
        HighlightRule(
            pattern: tagRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.highlightColor)
        ),
        HighlightRule(
            pattern: footnoteRegex,
            formattingRule: TextFormattingRule(key: .foregroundColor, value: NSColor.gray)
        ),
        HighlightRule(pattern: htmlRegex, formattingRules: [
            TextFormattingRule(key: .font, value: NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold)),
            TextFormattingRule(key: .foregroundColor, value: NSColor.windowBackgroundColor)
        ])
        ]
    
    var body: some View {
        VStack(spacing:0) {
            
            HStack {
                
                TextField("Title", text: $fileName)
                    .frame(maxWidth: 300)
                Spacer()
                
                Button("💾") {
                    save()
                }
                
                Button("Load") {
                    open()
                }
                
                Divider()
                    .frame(maxHeight:30)
                
                Button(action: {
                    print("Question ?")
                    popHelper.toggle()
                }, label: {
                    Image(systemName: "questionmark.diamond")
                })
                .popover(isPresented: $popHelper, content: {
                    VStack(alignment:.leading) {
                        HStack {
                            Image(systemName: "questionmark.diamond")
                            Text("Why a Markdown editor?")
                        }.font(.title2).foregroundColor(.orange)
                        Divider()
                        Group {
                            Text("Markdown is here to help:")
                            Text("You can write notes about your scenes.")
                            Text("This is done so you stay organized and focused")
                        }.foregroundColor(.gray)
                        Divider()
                        Group {
                            Text("Some basics:")
                            Text("# Makes a big font. If you do it again (##) the font of the title gets smaller and smaller")
                                .lineLimit(4)
                                .frame(height:50)
                            Text("* Makes the font italic. Double(**) makes the font bold.")
                                .lineLimit(3)
                                .frame(height:40)
                            Text("1. Starts a numbered list")
                            Text("-  Starts an unordered list")
                            Text("> Makes a nice code block")
                        }
                        .lineLimit(0)
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth:250)
                    .padding()
                })
            }
            .padding(6)
            
            HighlightedTextEditor(text: $text, highlightRules: rules)
                // optional modifiers
                .onCommit { print("commited") }
                .onEditingChanged { print("editing changed") }
                .introspect { editor in
                    // access underlying UITextView or NSTextView
                    // editor.textView.backgroundColor = .green
                }
        }
    }
    
    // MARK: - Methods
    
    /// Opens a file (.txt, or .md)
    func open() {
        
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a .txt, or .md file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        dialog.allowedFileTypes = ["md", "txt"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let textUrl = dialog.url, textUrl.isFileURL {
                if let data = try? Data(contentsOf: textUrl),
                   let dString = String(data: data, encoding: .utf8) {
                    self.text = dString
                    let name = textUrl.lastPathComponent
                    self.fileName = name
                    self.saveURL = textUrl
                }
            }
        }
    }
    
    /// Saves the markdown file (.md by default, or .txt)
    func save() {
        
        guard let data = text.data(using: .utf8) else {
            print("Could not save")
            return
        }
        
        if let url = saveURL {
            do {
                try data.write(to: url, options: .atomic)
                print("Saved successfully")
                return
            } catch {
                print("⚠️ There was a problem writing this file: \(error.localizedDescription)")
            }
        }
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save this file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["md", "txt"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                
                let path: String = result.path
                print("Save Path: \(path)")
                
                do {
                    try data.write(to: URL(fileURLWithPath: path))
                    print("File saved")
                    self.saveURL = result
                    let name = result.lastPathComponent
                    self.fileName = name
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

struct MarkdownEditor_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditor()
    }
}

// MARK: - Rules

private let headingRegex = try! NSRegularExpression(pattern: "^#{1,3}\\s.*$", options: [.anchorsMatchLines])
private let inlineCodeRegex = try! NSRegularExpression(pattern: "`[^`]*`", options: [])
private let codeBlockRegex = try! NSRegularExpression(
    pattern: "(`){3}((?!\\1).)+\\1{3}",
    options: [.dotMatchesLineSeparators]
)
private let linkOrImageRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
private let linkOrImageTagRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\[(.*?)\\]", options: [])
private let boldRegex = try! NSRegularExpression(pattern: "((\\*|_){2})((?!\\1).)+\\1", options: [])
private let underscoreEmphasisRegex = try! NSRegularExpression(pattern: "(?<!_)_[^_]+_(?!\\*)", options: [])
private let asteriskEmphasisRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)((?!\\1).)+\\1(?!\\*)", options: [])
private let boldEmphasisAsteriskRegex = try! NSRegularExpression(pattern: "(\\*){3}((?!\\1).)+\\1{3}", options: [])
private let blockquoteRegex = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
private let horizontalRuleRegex = try! NSRegularExpression(pattern: "\n\n(-{3}|\\*{3})\n", options: [])
private let unorderedListRegex = try! NSRegularExpression(pattern: "^(\\-|\\*)\\s", options: [.anchorsMatchLines])
private let orderedListRegex = try! NSRegularExpression(pattern: "^\\d*\\.\\s", options: [.anchorsMatchLines])
private let buttonRegex = try! NSRegularExpression(pattern: "<\\s*button[^>]*>(.*?)<\\s*/\\s*button>", options: [])
private let strikethroughRegex = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [])
private let tagRegex = try! NSRegularExpression(pattern: "^\\[([^\\[\\]]*)\\]:", options: [.anchorsMatchLines])
private let footnoteRegex = try! NSRegularExpression(pattern: "\\[\\^(.*?)\\]", options: [])
// courtesy https://www.regular-expressions.info/examples.html
private let htmlRegex = try! NSRegularExpression(
    pattern: "<([A-Z][A-Z0-9]*)\\b[^>]*>(.*?)</\\1>",
    options: [.dotMatchesLineSeparators, .caseInsensitive]
)
