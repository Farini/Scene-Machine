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
    @Published var selection:MetalGenType = .CIGenerators
    
    @Published var image:NSImage {
        didSet {
            undoImages.append(image)
        }
    }
    @Published var previewImage:NSImage?
    @Published var undoImages:[NSImage] = []
    
    @Published var zoomLevel:Double = 1.0
    
    func previewUndo() {
        
        print("Previous Images: \(undoImages.count)")
        
        
        if let lastImage:NSImage = undoImages.last {
            // preview
            self.previewImage = lastImage
            undoImages.removeLast()
        }
    }
    
//    func updatePreview(image:NSImage) {
//
//        let oldImage = previewImage ?? image
//        undoImages.append(oldImage)
//        self.previewImage = image
//    }
    
    func updateImage(new:NSImage, isPreview:Bool) {
        
        print("Context preview: \(previewImage == nil ? "No Preview":"Preview Image")")
        print("Undo Count: \(undoImages.count)")
        
        if let oldImage = previewImage {
            undoImages.append(oldImage)
        }
        
        if isPreview {
            self.previewImage = new
        } else {
            self.image = new
        }
        
    }
    
    func saveImage() {
        
        let data = image.tiffRepresentation
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["jpg", "jpeg", "png", "bmp", "tiff"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                
                do {
                    try data?.write(to: result)
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
