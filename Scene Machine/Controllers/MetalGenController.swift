//
//  MetalGenController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/28/21.
//

import Foundation
import Cocoa
import CoreImage

class MetalGenController:ObservableObject {
    
    @Published var textureSize:TextureSize
    @Published var image:NSImage {
        didSet {
            undoImages.append(image)
        }
    }
    @Published var previewImage:NSImage?
    @Published var undoImages:[NSImage] = []
    
    @Published var selection:MetalGenType = .CIGenerators
    @Published var zoomLevel:Double = 1.0
    
    func previewUndo() {
        print("Previous Images: \(undoImages.count)")
        if let lastImage:NSImage = undoImages.dropLast().first {
            // main image
//            self.image = lastImage
            // preview
            self.previewImage = lastImage
        }
    }
    
    func updatePreview(image:NSImage) {
        let oldImage = previewImage ?? image
        undoImages.append(oldImage)
        self.previewImage = image
    }
    
    func saveImage() {
        
        let data = image.tiffRepresentation
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                
                var finalURL = result
                
                // Make sure there is an extension...
                
                let path: String = result.path
                print("Picked Path: \(path)")
                
                var filename = result.lastPathComponent
                print("Filename: \(filename)")
                if filename.isEmpty {
                    filename = "Untitled"
                }
                
                let xtend = result.pathExtension.lowercased()
                print("Extension: \(xtend)")
                
                let knownImageExtensions = ["jpg", "jpeg", "png", "bmp", "tiff"]
                
                if !knownImageExtensions.contains(xtend) {
                    filename = "\(filename).png"
                    
                    let prev = finalURL.deletingLastPathComponent()
                    let next = prev.appendingPathComponent(filename, isDirectory: false)
                    finalURL = next
                }
                
                do {
                    try data?.write(to: finalURL)
                    print("File saved")
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    
    /// Colored Noise Image
    class func noiseImage(size:CGSize) -> NSImage {
        
        let noise = CIFilter.randomGenerator()
        let noiseImage = noise.outputImage!
        let context = CIContext()
        
        guard let cgimg = context.createCGImage(noiseImage, from: CGRect(origin: .zero, size: size)) else {
            print("Error: Could not ccreate image")
            return NSImage()
        }
        
        let nsImage = NSImage(cgImage: cgimg, size:size)
        return nsImage
    }
    
    init() {
        
        // Random Noise
        let noise = CIFilter.randomGenerator()
        let noiseImage = noise.outputImage!
        let context = CIContext()
        
        let tSize:TextureSize = .medium
        let imageSize:CGSize = tSize.size
        
        // Build Main Image
        var mainImage:NSImage!
        if let cgimg = context.createCGImage(noiseImage, from: CGRect(origin: .zero, size: imageSize)) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:imageSize)
            mainImage = nsImage
        } else {
            mainImage = NSImage(size: imageSize)
        }
        
        // Image and Size
        self.image = mainImage
        self.textureSize = tSize
    }
    
    init(select:MetalGenType) {
        self.textureSize = .medium
        self.image = MetalGenController.noiseImage(size: TextureSize.medium.size)
    }
    
}
