/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020-2021
 *  https://twitter.com/tholanda
 *
 *  MIT license
 */

/**
 For a better TextView: https://github.com/kyle-n/HighlightedTextEditor
 */

import Cocoa
import SwiftUI

struct SimplerView:View {
    @State var text:String = "{ \n    planets { \n        name \n    }\n}"
    var body: some View {
        MacEditorTextView(
            text: $text,
            isEditable: true,
            font: .systemFont(ofSize: 14)
        )
    }
}

struct MacEditorTextView: NSViewRepresentable {
    
    @Binding var text: String
    var isEditable: Bool = true
    var font: NSFont?    = .systemFont(ofSize: 14, weight: .regular)
    var fontColor: NSColor = NSColor.labelColor
    
    var onEditingChanged: () -> Void       = {}
    var onCommit        : () -> Void       = {}
    var onTextChange    : (String) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: text,
            isEditable: isEditable,
            font: font,
            foreColor: fontColor
        )
        textView.tDelegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditorTextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: MacEditorTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onCommit()
        }
    }
}

// MARK: - Preview

struct MacEditorTextView_Previews: PreviewProvider {
    static var previews: some View {
        SimplerView()
//        Text("Preview Text")
//        Group {
//            MacEditorTextView(
//                text: .constant("{ \n    planets { \n        name \n    }\n}"),
//                isEditable: true,
//                font: .systemFont(ofSize: 14)
//                //font: .userFixedPitchFont(ofSize: 14)
//            )
            // .environment(\.colorScheme, .dark)
            // .previewDisplayName("Dark Mode")
            
//            MacEditorTextView(
//                text: .constant("{ \n    planets { \n        name \n    }\n}"),
//                isEditable: false
//            )
            // .environment(\.colorScheme, .light)
            // .previewDisplayName("Light Mode")
//        }
    }
}


// MARK: - CustomTextView
class CustomTextView: NSView {
    
    var isEditable: Bool
    var font: NSFont?
    var foreColor:NSColor?
    var tDelegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.textBackgroundColor
        textView.delegate                = self.tDelegate
        textView.drawsBackground         = true
        textView.font                    = self.font
        textView.isEditable              = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = foreColor ?? NSColor.labelColor
        textView.allowsUndo              = true
        
        return textView
    }()
    
    // MARK: - Init
    init(text: String, isEditable: Bool, font: NSFont?, foreColor:NSColor? = NSColor.labelColor) {
        self.font       = font
        self.isEditable = isEditable
        self.text       = text
        self.foreColor = foreColor
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
}
