//
//  SwiftUI+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/22/21.
//

import Foundation
import SwiftUI

extension View {
    
    func snapShot(uvSize:CGSize) -> NSImage? {
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: uvSize.width, height: uvSize.height),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
       
        window.contentView = NSHostingView(rootView: self)
        
//        window.makeKeyAndOrderFront(self)
        
        let cto = window.contentView!
        
        let img = cto.image()
        
        return img
    }
}

extension NSView {
    
    func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
    
    func asImage(size: CGSize) -> NSImage {
        let format = GraphicsImageRendererFormat()
        //        format.scale = 1.0
        return GraphicsImageRenderer(size: size, format: format).image { context in
            
            self.layer!.render(in: context.cgContext)
        }
    }
}
