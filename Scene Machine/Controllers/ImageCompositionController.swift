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

class ImageCompositionController:ObservableObject {
    
//    @Published var noises:[String]
//    @Published var currentImage:NSImage
    @Published var leftImage:NSImage
    @Published var rightImage:NSImage?
    @Published var resultImage:NSImage?
    
    init() {
//        self.noises = ["Tester"]
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
//        let image = NSImage(cgImage: img, size: texture.size())
//        self.leftImage = image
        
        let context = CIContext()                                               // 1
        
//        let filter = CIFilter(name: "CISepiaTone")!                           // 2
//        filter.setValue(0.95, forKey: kCIInputIntensityKey)
//        let ciimage = CIImage(cgImage: img)                                   // 3
//        filter.setValue(ciimage, forKey: kCIInputImageKey)
//        let result = filter.outputImage!                                      // 4
        
        let ciimage = CIImage(cgImage: img)
//        let cgImage = context.createCGImage(result, from: result.extent)        // 5
//        let newImage = NSImage(cgImage: cgImage!, size: CGSize(width: 512, height: 512))
        
        let newCIImage = ImageCompositionController.applyFilterChain(to: ciimage)
        let newCGImage = context.createCGImage(newCIImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150)))!
        let newImage = NSImage(cgImage: newCGImage, size: CGSize(width: 150, height: 150))
    
        self.leftImage = newImage
    }
    
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
//        var tmpResult:CIImage?
//        let rightCIImage = CIImage(cgImage: newTexture.cgImage())
        let newRightImage = NSImage(cgImage: newTexture.cgImage(), size: newTexture.size())
        self.rightImage = newRightImage
        
        // Result
        let newImage = ciimg.composited(over: CIImage(cgImage:newTexture.cgImage()))
        
        let rep = NSCIImageRep(ciImage: newImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        self.resultImage = nsImage
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
    }
}
