//
//  ImageFXController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 1/23/21.
//

import Foundation
import CoreImage
import SwiftUI
import SpriteKit
import CoreImage.CIFilterBuiltins

/**
 Made For the MAC. So we use NSImages
 */
class ImageFXController:ObservableObject {
    
    @Published var openingImage:NSImage
    @Published var secondImage:NSImage?
    @Published var textureSize:TextureSize = .medium
    
    @Published var previewImage:NSImage?
    @Published var undoImages:[NSImage] = []
    
    init(image:NSImage?) {
        // Init with an image or one will be created
        if let image = image {
            self.openingImage = image
        } else {
            self.openingImage = NSImage(named:"Checkerboard")!
        }
    }
    
    // MARK: - Saving
    
    //
    func openSavePanel(for image:NSImage) {
        
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
    
    /// Loads another image
    func loadImage() {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose an image";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let imageURL = dialog.url, imageURL.isFileURL {
                if let image = NSImage(contentsOf: imageURL) {
                    self.openingImage = image
                }
            }
        }
    }
    
    func previewUndo() {
        print("Previous Images: \(undoImages.count)")
        
        
        if let lastImage:NSImage = undoImages.last {
            // preview
            self.previewImage = lastImage
            undoImages.removeLast()
        }
    }
    
    func updateImage(new:NSImage, isPreview:Bool) {
        
        print("Context preview: \(previewImage == nil ? "No Preview":"Preview Image")")
        print("Undo Count: \(undoImages.count)")
        
        if let oldImage = previewImage {
            undoImages.append(oldImage)
        }
        
        if isPreview {
            self.previewImage = new
        } else {
            self.openingImage = new
        }
    }
    
    /// Adds the openingImage to undoImages array. Called before the FX_ View updates
    func backupImage() {
        undoImages.append(openingImage)
    }
    
    
    
    
    
    // MARK: - Efffects
    // [deprecate all below]
    /*
    func blurrImage(radius:Double = 10) {
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        let currentFilter = CIFilter.boxBlur()
        currentFilter.inputImage = inputCIImage
        currentFilter.radius = Float(radius)
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.openingImage = nsImage
        }
    }
    
    func crystallize() {
        
        self.secondImage = openingImage
        
        // guard let inputImage = NSImage(named: "Example") else { return }
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        
        let currentFilter = CIFilter.crystallize()
        currentFilter.inputImage = inputCIImage
        currentFilter.radius = 100
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.openingImage = nsImage
        }
    }
    
    func pixellate() {
        
        self.secondImage = openingImage
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        
        let currentFilter = CIFilter.pixellate()
        currentFilter.inputImage = inputCIImage
        currentFilter.scale = 100
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.openingImage = nsImage
        }
    }
    
    /// Mixes 2 images
    func mixImages() {
        
        guard let secondImage = secondImage else {
            print("no second image")
            return
        }
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        // Second
        let inputData2 = secondImage.tiffRepresentation!
        let bitmap2 = NSBitmapImageRep(data: inputData2)!
        let inputCIImage2 = CIImage(bitmapImageRep: bitmap2)
        
        let context = CIContext()
        
        let currentFilter = CIFilter.screenBlendMode()
        currentFilter.inputImage = inputCIImage
        currentFilter.backgroundImage = inputCIImage2
    
        let finalImage = currentFilter.outputImage!
        
        if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
            print("Final image in")
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.openingImage = nsImage
        }
    }
    
    func twirlDistortion() {
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        
        guard let currentFilter = CIFilter(name: "CITwirlDistortion") else { return }
        currentFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        currentFilter.setValue(NSNumber(value:100), forKey: kCIInputRadiusKey)
        currentFilter.setValue(CIVector(x: inputImage.size.width / 2, y:inputImage.size.height / 2), forKey: kCIInputCenterKey)
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.openingImage = nsImage
        }
    }
    
    func causticNoise() {
        
        // Save previous aside
        self.secondImage = openingImage
//        let inputImage = openingImage
//        let inputData = inputImage.tiffRepresentation!
//        let bitmap = NSBitmapImageRep(data: inputData)!
//        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        
        let currentFilter = CausticNoise()
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:openingImage.size)
            self.openingImage = nsImage
        }
    }
    
    func causticRefraction() {
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        let context = CIContext()
        
        let currentFilter = CausticRefraction()
        currentFilter.inputImage = inputCIImage
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:openingImage.size)
            self.openingImage = nsImage
        }
    }
    
    func lensFlare() {
        let context = CIContext()
        
        let currentFilter = LensFlare()
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:openingImage.size)
            self.openingImage = nsImage
        }
    }
    
    // MARK: - Metal Filters
    
    func metalColor() {
        
        let context = CIContext()
        
        let currentFilter = HexagonFilter() //MetalFilter()
        
        let inputImage = openingImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        currentFilter.inputImage = inputCIImage
        
        print("mc pre output")
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage() else { return }
        print("mc posr output")
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:openingImage.size)
            self.openingImage = nsImage
        }
    }
    
    func metalBlackToTransparent() {
        
        let inputImage:NSImage = openingImage
        
        guard let inputData = inputImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: inputData),
              let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
            
            print("Missing something. Check references.")
            fatalError()
        }
        
        // Create the filter
        let context = CIContext()
        let shade = BLKTransparent()
        shade.inputImage = inputCIImage
        shade.threshold = 0.15
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = shade.outputImage() else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:openingImage.size)
            self.openingImage = nsImage
        }
    }
    */
}
