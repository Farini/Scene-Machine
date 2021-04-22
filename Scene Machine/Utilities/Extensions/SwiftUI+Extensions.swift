//
//  SwiftUI+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/22/21.
//

import Foundation
import SwiftUI

extension View {
    
    func snapShot() -> NSImage? {
        let controller = NSHostingController(rootView: self)
        
//        let rView = controller.rootView
        
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        print("Target Size: \(targetSize)")
        
        view.bounds = CGRect(origin: .zero, size: targetSize)
        
        
        //        let renderer = GraphicsImageRenderer(size: targetSize)
        //        return renderer.image { _ in
        //            layer.render
        //        }
        
        let image = view.asImage(size: CGSize(width: 1000, height: 1000))
        // image.draw(in: NSMakeRect(0, 0, targetSize.width, targetSize.height))
        
        
        //        let image:NSImage = NSImage(size: targetSize)
        //
        //        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(targetSize.width), pixelsHigh: Int(targetSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        //
        //        image.addRepresentation(rep)
        //        image.lockFocus()
        //
        ////        image.draw(at: NSPoint.zero, from: CGRect(origin: .zero, size: targetSize), operation: .overlay, fraction: 1.0) // = view.draw(NSRect(origin: .zero, size: targetSize))
        //
        //        let rect = NSMakeRect(0, 0, targetSize.width, targetSize.height)
        //        let ctx = NSGraphicsContext.current!.cgContext
        //        ctx.clear(rect)
        //        ctx.setFillColor(NSColor.black.cgColor)
        //        ctx.fill(rect)
        //
        //        image.unlockFocus()
        
        
        
        return image
    }
}

extension NSView {
    func asImage(size: CGSize) -> NSImage {
        let format = GraphicsImageRendererFormat()
        //        format.scale = 1.0
        return GraphicsImageRenderer(size: size, format: format).image { context in
            
            self.layer!.render(in: context.cgContext)
        }
    }
}
