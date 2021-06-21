//
//  SwiftUI+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/22/21.
//

import Foundation
import SwiftUI

// MARK: - Screenshots

extension View {
    
    /// Takes a snapshot of the current view, and outputs an `NSImage`
    func snapShot(uvSize:CGSize) -> NSImage? {
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: uvSize.width, height: uvSize.height),
            styleMask: [.fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
       
        window.contentView = NSHostingView(rootView: self)
        
        // Uncomment below to see what this view looks like
        // window.makeKeyAndOrderFront(self)
        
        let cto = window.contentView!
        
        let img = cto.image()
        
        return img
    }
}

extension NSView {
    
    /// Extracts a representation of the view, and converts it to an `NSImage`
    func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
    
    /// Gets a GraphicsImageRenderer (See ImageRenderer) with the appropriate size.
    func asImage(size: CGSize) -> NSImage {
        let format = GraphicsImageRendererFormat()
        //        format.scale = 1.0
        return GraphicsImageRenderer(size: size, format: format).image { context in
            
            self.layer!.render(in: context.cgContext)
        }
    }
}

extension NumberFormatter {
    
    /// Formatter with 4 decimal and integer digits
    static var scnFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 4
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    /// Two fraction digits
    static var doubleDigit: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
}

/** A Closable window, that the user can close without crashing the app.
 This is especially useful for non-permanent windows (no strong reference) that can be displayed multiple times */
class ClosableWindow: NSWindow {
    override func close() {
        self.orderOut(NSApp)
    }
}
