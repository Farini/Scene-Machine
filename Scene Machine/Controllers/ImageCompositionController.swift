//
//  ImageCompositionController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import Foundation
import CoreImage
import SwiftUI
import SpriteKit

enum CompositionType:String, CaseIterable {
    
    case CIAdditionCompositing
    case CIColorBlendMode
    case CIColorBurnBlendMode
    case CIColorDodgeBlendMode
    case CIDarkenBlendMode
    

    case CIDivideBlendMode

    case CIScreenBlendMode
    
    /* OTHER
    //    case CIDifferenceBlendMode
    //    case CIExclusionBlendMode
    //    case CIHardLightBlendMode
    //    case CIHueBlendMode
    //    case CILightenBlendMode
    //    case CILinearBurnBlendMode
    //    case CILinearDodgeBlendMode
    //    case CILuminosityBlendMode
    //    case CIMaximumCompositing
    //    case CIMinimumCompositing
    //    case CIMultiplyBlendMode
    //    case CIMultiplyCompositing
    //    case CIOverlayBlendMode
    //    case CIPinLightBlendMode
    //    case CISaturationBlendMode
    */
}


class ImageCompositionController:ObservableObject {
    
    @Published var backgroundImage:NSImage
    @Published var foregroundImage:NSImage
    @Published var resultImage:NSImage
    @Published var compositionType:CompositionType = .CIColorBlendMode
    
    init() {
        
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let texturecg:CGImage = texture.cgImage()
        
        let newImage = NSImage(named:"Example")!
        let imageB = NSImage(cgImage: texturecg, size: texture.size())
        
        self.backgroundImage = newImage
        self.foregroundImage = imageB
        self.resultImage = newImage
    }
    
    /// Applies Bloom to an image -> Deprecate? Keep it here for reference.
    static func applyFilterChain(to image: CIImage) -> CIImage {
        // The CIPhotoEffectInstant filter takes only an input image
        let colorFilter = CIFilter(name: "CIPhotoEffectProcess", parameters:
                                    [kCIInputImageKey: image])!
        
        // Pass the result of the color filter into the Bloom filter
        // and set its parameters for a glowy effect.
        let bloomImage = colorFilter.outputImage!.applyingFilter("CIBloom",
                                                                 parameters: [
                                                                    kCIInputRadiusKey: 50.0,
                                                                    kCIInputIntensityKey: 1.0
                                                                 ])
        
        // imageByCroppingToRect is a convenience method for
        // creating the CICrop filter and accessing its outputImage.
        let cropRect = CGRect(x: 350, y: 350, width: 150, height: 150)
        let croppedImage = bloomImage.cropped(to: cropRect)
        
        return croppedImage
    }
    
    /// Mixes 2 images
    func compositeImages() {
        
        // Background
        guard let backData = backgroundImage.tiffRepresentation,
              let backBitmap = NSBitmapImageRep(data: backData),
              let backCoreImage = CIImage(bitmapImageRep: backBitmap) else {
            print("Error [Back Image]: Something wrong with the image.")
            return
        }
        
        // Foreground
        guard let frontData = foregroundImage.tiffRepresentation,
              let frontBitmap = NSBitmapImageRep(data: frontData),
              let frontCoreImage = CIImage(bitmapImageRep: frontBitmap) else {
            print("Error [Front Image]: Something wrong with the image.")
            return
        }
        
        let context = CIContext()
        
        if let finalImage = self.apply(filter: self.compositionType, left: backCoreImage, right: frontCoreImage) {
            if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
                print("Final image in")
                // convert that to a UIImage
                let nsImage = NSImage(cgImage: cgimg, size:backgroundImage.size)
                self.resultImage = nsImage
                return
            }
        }
        print("⚠️ Error: No result Image")
   
    }
    
    func loadImage(foreground:Bool) {
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
                    if foreground { self.foregroundImage = image }
                    else { self.backgroundImage = image }
                }
            }
        }
    }
    
    func saveImage(){
        
        let data = resultImage.tiffRepresentation
        
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
}

extension ImageCompositionController {
    
    func apply(filter type:CompositionType, left:CIImage, right:CIImage) -> CIImage? {
        switch type {
            case .CIAdditionCompositing:
                let filter = CIFilter.additionCompositing()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
                
            case .CIColorBlendMode:
                let filter = CIFilter.colorBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
            case .CIColorBurnBlendMode:
                let filter = CIFilter.colorBurnBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
            case .CIColorDodgeBlendMode:
                let filter = CIFilter.colorDodgeBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
            case .CIDarkenBlendMode:
                let filter = CIFilter.darkenBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
            case .CIDivideBlendMode:
                let filter = CIFilter.divideBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
            case .CIScreenBlendMode:
                let filter = CIFilter.screenBlendMode()
                filter.backgroundImage = right
                filter.inputImage = left
                return filter.outputImage
        }
    }
}
