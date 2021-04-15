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

// Filter Categories
/*
 CICategoryBlur
 CICategoryColorAdjustment
 CICategoryColorEffect
 CICategoryCompositeOperation
 CICategoryDistortionEffect
 CICategoryGenerator
 CICategoryGeometryAdjustment
 CICategoryGradient
 CICategoryHalftoneEffect
 CICategoryReduction
 CICategorySharpen
 CICategoryStylize
 CICategoryTileEffect
 CICategoryTransition
 */

enum CompositionType:String, CaseIterable {
    
    case CIAdditionCompositing
    case CIColorBlendMode
    case CIColorBurnBlendMode
    case CIColorDodgeBlendMode
//    case CIDarkenBlendMode
//    case CIDifferenceBlendMode
//    case CIDivideBlendMode
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
//    case CIScreenBlendMode
}


class ImageCompositionController:ObservableObject {
    
    @Published var leftImage:NSImage
    @Published var rightImage:NSImage?
    @Published var resultImage:NSImage
    @Published var compositionType:CompositionType = .CIColorBlendMode
    
    init() {
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let texturecg:CGImage = texture.cgImage()
//
//        let context = CIContext()
//        let ciimage = CIImage(cgImage: img)
//        let newCIImage = ImageCompositionController.applyFilterChain(to: ciimage)
//        let newCGImage = context.createCGImage(newCIImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150)))!
//        let newImage = NSImage(cgImage: newCGImage, size: CGSize(width: 150, height: 150))
        let newImage = NSImage(named:"Example")!
        let imageB = NSImage(cgImage: texturecg, size: texture.size())
        
        self.leftImage = newImage
        self.rightImage = imageB
        self.resultImage = newImage//.copy() as! NSImage
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
    
    func mixImages() {
        
        // Image Left
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = leftImage.cgImage(forProposedRect: nil, context: nil, hints: nil) ?? texture.cgImage()
        let ciimg = CIImage(cgImage: img)
        
        // Image Right
        let newTexture = SKTexture.init(noiseWithSmoothness: 0.85, size: CGSize(width: 512, height: 512), grayscale: true)
        let newRightImage = NSImage(cgImage: newTexture.cgImage(), size: newTexture.size())
        self.rightImage = newRightImage
        
        // Result
        let newImage = ciimg.composited(over: CIImage(cgImage:newTexture.cgImage()))
        
        let rep = NSCIImageRep(ciImage: newImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        self.resultImage = nsImage
    }
    
    /// Mixes 2 images
    func compositeImages() {
        
        guard let secondImage = rightImage else {
            print("no second image")
            return
        }
        
        let inputImage = leftImage
        let inputData = inputImage.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: inputData)!
        let inputCIImage = CIImage(bitmapImageRep: bitmap)
        
        // Second
        let inputData2 = secondImage.tiffRepresentation!
        let bitmap2 = NSBitmapImageRep(data: inputData2)!
        let inputCIImage2 = CIImage(bitmapImageRep: bitmap2)
        
        let context = CIContext()
        
        var currentFilter = CIFilter.screenBlendMode() // CIFilter & Composite op
        switch self.compositionType {
            case .CIAdditionCompositing: currentFilter = CIFilter.additionCompositing()
            case .CIColorBlendMode: currentFilter = CIFilter.colorBlendMode()
            case .CIColorBurnBlendMode: currentFilter = CIFilter.colorBurnBlendMode()
            case .CIColorDodgeBlendMode: currentFilter = CIFilter.colorDodgeBlendMode()
        }
        currentFilter.inputImage = inputCIImage
        currentFilter.backgroundImage = inputCIImage2
        
        let finalImage = currentFilter.outputImage!
        
        if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
            print("Final image in")
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
            self.resultImage = nsImage
        }
    }
    
    func changeRightImage(new image:NSImage) {
        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let ciImage = CIImage(cgImage: cgImage)
            
            let rep = NSCIImageRep(ciImage: ciImage)
            let nsImage = NSImage(size: rep.size)
            nsImage.addRepresentation(rep)
            
            self.rightImage = nsImage
        }else{
            print("Failed to change right image")
        }
    }
    
    func buildFilterDictionary() {
        print("Filter Dictionary")
        let filters = CIFilter.filterNames(inCategory: "CICategoryCompositeOperation")
        for filterName in filters {
            print("Filter name: \(filterName)")
        }
    }
}
