//
//  BLKTransparent.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Foundation
import CoreImage
import Cocoa

/**
 A CIFilter that uses a Metal function that converts a black pixel (or almost black) to a transparent pixel.
 */
class BLKTransparent: CIFilter {
    
    private var kernel: CIColorKernel
    
    var inputImage: CIImage?
    var threshold: Float?
    
    override init() {
        
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
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

class WHITransparent: CIFilter {
    private var kernel: CIColorKernel
    
    var inputImage: CIImage?
    var threshold: Float?
    
    override init() {
        
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "makeWhiteTransparent", fromMetalLibraryData: data) else { fatalError() } // makeBlackTransparent
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

// Laplatian
class LaplatianFilter: CIFilter {
    
    private var kernel:CIKernel
    var inputImage:CIImage?
    var tileSize:Float = 1024
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIKernel(functionName: "laplatian", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(tileSize), height: CGFloat(tileSize)))
            guard let inputData = baseImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: inputData),
                  let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
                print("Missing something")
                return nil
            }
            self.inputImage = inputCIImage
        }
        
        guard let inputImage = inputImage else {return nil}
        
        let src = CISampler(image: inputImage)
//        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(tileSize), y: CGFloat(tileSize)))
        //        let fTile = Float(tileCount)
        //        let fTime = Float(time)
        
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        return kernel.apply(extent: inputImage.extent, roiCallback: {
            (index, rect) in
            return rect // .insetBy(dx: 0, dy: 0)
        }, arguments: [src])
    }
}

// Sketch
class SketchFilter: CIFilter {

    private var kernel:CIKernel
    var inputImage:CIImage?
    var tileSize:Float = 1024
    var tWidth:Float = 1
    var tHeight:Float = 1
    var intensity:Float = 1
    
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIKernel(functionName: "sketch", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(tileSize), height: CGFloat(tileSize)))
            guard let inputData = baseImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: inputData),
                  let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
                print("Missing something")
                return nil
            }
            self.inputImage = inputCIImage
        }
        
        guard let inputImage = inputImage else {return nil}
        
        // sketch(sampler src, float texelWidth, float texelHeight, float intensity40)
        
        let src = CISampler(image: inputImage)
//        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(tileSize), y: CGFloat(tileSize)))
        let fWidth = tWidth
        let fHeight = tHeight
        let fIntense = intensity
        
        return kernel.apply(extent: inputImage.extent, roiCallback: {
            (index, rect) in
            return rect // .insetBy(dx: 0, dy: 0)
        }, arguments: [src, fWidth, fHeight, fIntense])
    }
}

// Tiling
class TileMaker: CIFilter {
    
    private var kernel:CIKernel
    var inputImage:CIImage?
    var margin:Int = 10
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIKernel(functionName: "tilingEngine", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        self.kernel = kkk
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(1024), height: CGFloat(1024)))
            guard let inputData = baseImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: inputData),
                  let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
                print("Missing something")
                return nil
            }
            self.inputImage = inputCIImage
        }
        
        guard let inputImage = inputImage else {return nil}
        
        // sketch(sampler src, float texelWidth, float texelHeight, float intensity40)
        
        let src = CISampler(image: inputImage)
        let imsize = inputImage.extent.size
        let size = CIVector(cgPoint: CGPoint(x: imsize.width, y: imsize.height))
        let fMargin = Float(margin)
        
        return kernel.apply(extent: inputImage.extent, roiCallback: {
            (index, rect) in
            return rect // .insetBy(dx: 0, dy: 0)
        }, arguments: [src, size, fMargin])
    }
}
