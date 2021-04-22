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
    
    init(image:NSImage?) {
        // Init with an image or one will be created
        if let image = image {
            self.openingImage = image
        } else {
            self.openingImage = NSImage(named:"Example")!
        }
    }
    
    // MARK: - Saving
    
    // This opens the Finder, but not to save...
    func openSavePanel(for image:NSImage) {
        
        let data = image.tiffRepresentation
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                if result.isFileURL {
                    print("Picked a file")
                } else {
                    // this doesn't happen
                    print("Picked what?")
                }
                let path: String = result.path
                print("Picked Path: \(path)")
                
                
                do {
                    try data?.write(to: URL(fileURLWithPath: path))
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
    
    // MARK: - Efffects
    
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
}

class CausticNoise: CIFilter {
    
    var inputTime: CGFloat = 1
    var inputTileSize: CGFloat = 640
    var inputWidth: CGFloat = 640
    var inputHeight: CGFloat = 640
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Caustic Noise",
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 1,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1000,
                          kCIAttributeType: kCIAttributeTypeScalar],
            "inputTileSize": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDefault: 640,
                              kCIAttributeDisplayName: "Tile Size",
                              kCIAttributeMin: 10,
                              kCIAttributeSliderMin: 10,
                              kCIAttributeSliderMax: 2048,
                              kCIAttributeType: kCIAttributeTypeScalar],
            "inputWidth": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 640,
                           kCIAttributeDisplayName: "Width",
                           kCIAttributeMin: 0,
                           kCIAttributeSliderMin: 0,
                           kCIAttributeSliderMax: 1280,
                           kCIAttributeType: kCIAttributeTypeScalar],
            "inputHeight": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 640,
                            kCIAttributeDisplayName: "Height",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 1280,
                            kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let causticNoiseKernel = CIColorKernel(
        source: "kernel vec4 mainImage(float time, float tileSize) " +
            "{ " +
            "    vec2 uv = destCoord() / tileSize; " +
            
            "    vec2 p = mod(uv * 6.28318530718, 6.28318530718) - 250.0; " +
            
            "    vec2 i = vec2(p); " +
            "    float c = 1.0; " +
            "    float inten = .005; " +
            
            "    for (int n = 0; n < 5; n++) " +
            "    { " +
            "        float t = time * (1.0 - (3.5 / float(n+1))); " +
            "        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x)); " +
            "        c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten))); " +
            "    } " +
            "    c /= 5.0;" +
            "    c = 1.17-pow(c, 1.4);" +
            "    vec3 colour = vec3(pow(abs(c), 8.0));" +
            "    colour = clamp(colour, 0.0, 1.0);" +
            
            "    return vec4(colour, 1.0);" +
            "}"
    )
    
    override var outputImage: CIImage! {
        
        guard let causticNoiseKernel = causticNoiseKernel else {
            return nil
        }
        
        let extent = CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight)
        
        return causticNoiseKernel.apply(extent: extent, arguments: [inputTime, inputTileSize])
    }
}

class CausticRefraction: CIFilter {
    
    var inputImage: CIImage?
    var inputRefractiveIndex: CGFloat = 4.0
    var inputLensScale: CGFloat = 50
    var inputLightingAmount: CGFloat = 1.5
    var inputTime: CGFloat = 1
    var inputTileSize: CGFloat = 640
    var inputSoftening: CGFloat = 3
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Caustic Refraction",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputText": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSString",
                          kCIAttributeDisplayName: "Text",
                          kCIAttributeDefault: "Filterpedia",
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRefractiveIndex": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 4.0,
                                     kCIAttributeDisplayName: "Refractive Index",
                                     kCIAttributeMin: -4.0,
                                     kCIAttributeSliderMin: -10.0,
                                     kCIAttributeSliderMax: 10,
                                     kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLensScale": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 50,
                               kCIAttributeDisplayName: "Lens Scale",
                               kCIAttributeMin: 1,
                               kCIAttributeSliderMin: 1,
                               kCIAttributeSliderMax: 100,
                               kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLightingAmount": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 1.5,
                                    kCIAttributeDisplayName: "Lighting Amount",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 5,
                                    kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 1,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1000,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTileSize": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDefault: 640,
                              kCIAttributeDisplayName: "Tile Size",
                              kCIAttributeMin: 10,
                              kCIAttributeSliderMin: 10,
                              kCIAttributeSliderMax: 2048,
                              kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSoftening": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 3,
                               kCIAttributeDisplayName: "Softening",
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 20,
                               kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
              let refractingKernel = refractingKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        
        let r2 = CausticNoise().outputImage!.applyingFilter("CIGaussianBlur",
                                                            parameters: [kCIInputRadiusKey: inputSoftening])
        
        let arguments:[Any] = [
            inputImage,
            r2,
            inputRefractiveIndex,
            inputLensScale,
            inputLightingAmount]
        
        return refractingKernel.apply(extent: extent, roiCallback: {
            (index, rect) in
            return rect
        }, arguments: arguments)
    }
    
    let refractingKernel = CIKernel(
        source: "float lumaAtOffset(sampler source, vec2 origin, vec2 offset)" +
            "{" +
            " vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;" +
            " float luma = dot(pixel, vec3(0.2126, 0.7152, 0.0722));" +
            " return luma;" +
            "}" +
            
            
            "kernel vec4 lumaBasedRefract(sampler image, sampler refractingImage, float refractiveIndex, float lensScale, float lightingAmount) \n" +
            "{ " +
            " vec2 d = destCoord();" +
            
            " float northLuma = lumaAtOffset(refractingImage, d, vec2(0.0, -1.0));" +
            " float southLuma = lumaAtOffset(refractingImage, d, vec2(0.0, 1.0));" +
            " float westLuma = lumaAtOffset(refractingImage, d, vec2(-1.0, 0.0));" +
            " float eastLuma = lumaAtOffset(refractingImage, d, vec2(1.0, 0.0));" +
            
            " vec3 lensNormal = normalize(vec3((eastLuma - westLuma), (southLuma - northLuma), 1.0));" +
            
            " vec3 refractVector = refract(vec3(0.0, 0.0, 1.0), lensNormal, refractiveIndex) * lensScale; " +
            
            " vec3 outputPixel = sample(image, samplerTransform(image, d + refractVector.xy)).rgb;" +
            
            " outputPixel += (northLuma - southLuma) * lightingAmount ;" +
            " outputPixel += (eastLuma - westLuma) * lightingAmount ;" +
            
            " return vec4(outputPixel, 1.0);" +
            "}"
    )
}

class LensFlare: CIFilter {
    
    var inputOrigin = CIVector(x: 150, y: 150)
    var inputSize = CIVector(x: 640, y: 640)
    
    var inputColor = CIVector(x: 0.5, y: 0.2, z: 0.3)
    var inputReflectionBrightness: CGFloat = 0.25
    
    var inputPositionOne: CGFloat = 0.15
    var inputPositionTwo: CGFloat = 0.3
    var inputPositionThree: CGFloat = 0.4
    var inputPositionFour: CGFloat = 0.45
    var inputPositionFive: CGFloat = 0.6
    var inputPositionSix: CGFloat = 0.75
    var inputPositionSeven: CGFloat = 0.8
    
    var inputReflectionSizeZero: CGFloat = 20
    var inputReflectionSizeOne: CGFloat = 25
    var inputReflectionSizeTwo: CGFloat = 12.5
    var inputReflectionSizeThree: CGFloat = 5
    var inputReflectionSizeFour: CGFloat = 20
    var inputReflectionSizeFive: CGFloat = 35
    var inputReflectionSizeSix: CGFloat = 40
    var inputReflectionSizeSeven: CGFloat = 20
    
    override var attributes: [String : Any] {
    let positions: [String : Any] = [
        "inputPositionOne": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.15,
                                kCIAttributeDisplayName: "Position One",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionTwo": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.3,
                                kCIAttributeDisplayName: "Position Two",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionThree": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.4,
                                kCIAttributeDisplayName: "Position Three",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionFour": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.45,
                                kCIAttributeDisplayName: "Position Four",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionFive": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.6,
                                kCIAttributeDisplayName: "Position Five",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionSix": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.75,
                                kCIAttributeDisplayName: "Position Six",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputPositionSeven": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 0.8,
                                kCIAttributeDisplayName: "Position Seven",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
    ]
    
    let sizes: [String : Any] = [
        "inputReflectionSizeZero": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 20,
                                    kCIAttributeDisplayName: "Size Zero",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeOne": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 25,
                                    kCIAttributeDisplayName: "Size One",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeTwo": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 12.5,
                                    kCIAttributeDisplayName: "Size Two",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeThree": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 5,
                                        kCIAttributeDisplayName: "Size Three",
                                        kCIAttributeMin: 0,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 100,
                                        kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeFour": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 20,
                                    kCIAttributeDisplayName: "Size Four",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeFive": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 35,
                                    kCIAttributeDisplayName: "Size Five",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeSix": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 40,
                                    kCIAttributeDisplayName: "Size Six",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputReflectionSizeSeven": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 20,
                                        kCIAttributeDisplayName: "Size Seven",
                                        kCIAttributeMin: 0,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 100,
                                        kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputSize": [kCIAttributeIdentity: 0,
                        kCIAttributeClass: "CIVector",
                        kCIAttributeDisplayName: "Image Size",
                        kCIAttributeDefault: CIVector(x: 640, y: 640),
                        kCIAttributeType: kCIAttributeTypeOffset]
    ]
    
    let attributes: [String : Any] = [
        kCIAttributeFilterDisplayName: "Lens Flare",
        
        "inputOrigin": [kCIAttributeIdentity: 0,
                        kCIAttributeClass: "CIVector",
                        kCIAttributeDisplayName: "Light Origin",
                        kCIAttributeDefault: CIVector(x: 150, y: 150),
                        kCIAttributeType: kCIAttributeTypePosition],
        
        "inputColor": [kCIAttributeIdentity: 0,
                        kCIAttributeClass: "CIVector",
                        kCIAttributeDisplayName: "Color",
                        kCIAttributeDefault: CIVector(x: 0.5, y: 0.2, z: 0.3),
                        kCIAttributeType: kCIAttributeTypeColor],
        
        "inputReflectionBrightness": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 0.25,
                                        kCIAttributeDisplayName: "Reflection Brightness",
                                        kCIAttributeMin: 0,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 1,
                                        kCIAttributeType: kCIAttributeTypeScalar]
    ]
    
    return attributes + positions + sizes
}
    
    
    let sunbeamsFilter = CIFilter(name: "CISunbeamsGenerator", parameters: ["inputStriationStrength": 0])
    
    var colorKernel = CIColorKernel(source:
                                        "float brightnessWithinHexagon(vec2 coord, vec2 center, float v)" +
                                        "{" +
                                        "   float h = v * sqrt(3.0);" +
                                        "   float x = abs(coord.x - center.x); " +
                                        "   float y = abs(coord.y - center.y); " +
                                        "   float brightness = (x > h || y > v * 2.0) ? 0.0 : smoothstep(0.5, 1.0, (distance(destCoord(), center) / (v * 2.0))); " +
                                        "   return ((2.0 * v * h - v * x - h * y) >= 0.0) ? brightness  : 0.0;" +
                                        "}" +
                                        
                                        "kernel vec4 lensFlare(vec2 center0, vec2 center1, vec2 center2, vec2 center3, vec2 center4, vec2 center5, vec2 center6, vec2 center7," +
                                        "   float size0, float size1, float size2, float size3, float size4, float size5, float size6, float size7, " +
                                        "   vec3 color, float reflectionBrightness) " +
                                        "{" +
                                        "   float reflectionO = brightnessWithinHexagon(destCoord(), center0, size0); " +
                                        "   float reflection1 = reflectionO + brightnessWithinHexagon(destCoord(), center1, size1); " +
                                        "   float reflection2 = reflection1 + brightnessWithinHexagon(destCoord(), center2, size2); " +
                                        "   float reflection3 = reflection2 + brightnessWithinHexagon(destCoord(), center3, size3); " +
                                        "   float reflection4 = reflection3 + brightnessWithinHexagon(destCoord(), center4, size4); " +
                                        "   float reflection5 = reflection4 + brightnessWithinHexagon(destCoord(), center5, size5); " +
                                        "   float reflection6 = reflection5 + brightnessWithinHexagon(destCoord(), center6, size6); " +
                                        "   float reflection7 = reflection6 + brightnessWithinHexagon(destCoord(), center7, size7); " +
                                        
                                        "   return vec4(color * reflection7 * reflectionBrightness, reflection7); " +
                                        "}"
    )
    
    
    override var outputImage: CIImage!
    {
        guard let
                colorKernel = colorKernel else
        {
            return nil
        }
        
        let extent = CGRect(x: 0, y: 0, width: inputSize.x, height: inputSize.y)
        let center = CIVector(x: inputSize.x / 2, y: inputSize.y / 2)
        
        let localOrigin = CIVector(x: center.x - inputOrigin.y, y: center.y - inputOrigin.y)
        let reflectionZero = CIVector(x: center.x + localOrigin.x, y: center.y + localOrigin.y)
        
        let reflectionOne = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionOne)
        let reflectionTwo = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionTwo)
        let reflectionThree = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionThree)
        let reflectionFour = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionFour)
        let reflectionFive = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionFive)
        let reflectionSix = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionSix)
        let reflectionSeven = inputOrigin.interpolateTo(target: reflectionZero, value: inputPositionSeven)
        
        sunbeamsFilter?.setValue(inputOrigin, forKeyPath: kCIInputCenterKey)
        sunbeamsFilter?.setValue(inputColor, forKey: kCIInputColorKey)
        
        let sunbeamsImage = sunbeamsFilter!.outputImage!
        
        let arguments = [
            reflectionZero, reflectionOne, reflectionTwo, reflectionThree, reflectionFour, reflectionFive, reflectionSix, reflectionSeven,
            inputReflectionSizeZero, inputReflectionSizeOne, inputReflectionSizeTwo, inputReflectionSizeThree, inputReflectionSizeFour,
            inputReflectionSizeFive, inputReflectionSizeSix, inputReflectionSizeSeven,
            inputColor, inputReflectionBrightness] as [Any]
        
        let lensFlareImage = colorKernel.apply(
            extent: extent,
            arguments: arguments)?.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 2])
        
        return lensFlareImage?.applyingFilter(
            "CIAdditionCompositing",
            parameters: [kCIInputBackgroundImageKey: sunbeamsImage]).cropped(to: extent)
    }
}

class MetalFilter: CIFilter {
    
    private var kernel: CIColorKernel
    
    var inputImage: CIImage?
    
    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "myColor", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        return kernel.apply(extent: inputImage.extent, arguments: [inputImage])
    }
}

class HexagonFilter: CIFilter {
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "caustic", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        let src = CISampler(image: inputImage)
//        let callback: CIKernelROICallback = {
//            (index, rect) in
//            return rect.insetBy(dx: 0, dy: 0)
//        }
//        caustic(sample_t sample, float time, float tileSize, destination dest)
        return kernel.apply(extent: inputImage.extent, arguments: [src, 1.0, 512.0])
    }
}

/**
 A CIFilter that uses a Metal function that converts a black pixel (or almost black) to a transparent pixel.
 */
class BLKTransparent: CIFilter {
    
    private var kernel: CIColorKernel
    
    var inputImage: CIImage?
    var threshold: Float?
    
    override init() {
        
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "makeBlackTransparent", fromMetalLibraryData: data) else { fatalError() } // makeBlackTransparent
        self.kernel = kkk
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        return kernel.apply(extent: inputImage.extent, arguments: [inputImage, threshold ?? 0.15]) // 0.15 is threshold
    }
}


func + <T, U>(left: Dictionary<T, U>, right: Dictionary<T, U>) -> Dictionary<T, U>
{
    var target = Dictionary<T, U>()
    
    for (key, value) in left
    {
        target[key] = value
    }
    
    for (key, value) in right
    {
        target[key] = value
    }
    
    return target
}
/*
extension NSBezierPath
{
    func interpolatePointsWithHermite(interpolationPoints : [CGPoint])
    {
        let n = interpolationPoints.count - 1
        
        for ii in 0 ..< n
        {
            var currentPoint = interpolationPoints[ii]
            
            if ii == 0
            {
                self.move(to: interpolationPoints[0])
            }
            
            var nextii = (ii + 1) % interpolationPoints.count
            var previi = (ii - 1 < 0 ? interpolationPoints.count - 1 : ii-1);
            var previousPoint = interpolationPoints[previi]
            var nextPoint = interpolationPoints[nextii]
            let endPoint = nextPoint;
            var mx : CGFloat = 0.0
            var my : CGFloat = 0.0
            
            if ii > 0
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5;
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
            
            currentPoint = interpolationPoints[nextii]
            nextii = (nextii + 1) % interpolationPoints.count
            previi = ii;
            previousPoint = interpolationPoints[previi]
            nextPoint = interpolationPoints[nextii]
            
            if ii < n - 1
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) * 0.5;
                my = (currentPoint.y - previousPoint.y) * 0.5;
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
            
            self.curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}
*/

extension CIVector
{
    func toArray() -> [CGFloat]
    {
        var returnArray = [CGFloat]()
        
        for i in 0 ..< self.count
        {
            returnArray.append(self.value(at: i))
        }
        
        return returnArray
    }
    
    func normalize() -> CIVector
    {
        var sum: CGFloat = 0
        
        for i in 0 ..< self.count
        {
            sum += self.value(at: i)
        }
        
        if sum == 0
        {
            return self
        }
        
        var normalizedValues = [CGFloat]()
        
        for i in 0 ..< self.count
        {
            normalizedValues.append(self.value(at: i) / sum)
        }
        
        return CIVector(values: normalizedValues,
                        count: normalizedValues.count)
    }
    
    func multiply(value: CGFloat) -> CIVector
    {
        let n = self.count
        var targetArray = [CGFloat]()
        
        for i in 0 ..< n
        {
            targetArray.append(self.value(at: i) * value)
        }
        
        return CIVector(values: targetArray, count: n)
    }
    
    func interpolateTo(target: CIVector, value: CGFloat) -> CIVector
    {
        return CIVector(
            x: self.x + ((target.x - self.x) * value),
            y: self.y + ((target.y - self.y) * value))
    }
}
