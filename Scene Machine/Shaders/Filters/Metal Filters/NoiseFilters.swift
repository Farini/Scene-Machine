//
//  NoiseFilters.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/4/21.
//

import CoreGraphics
import Cocoa

/// Standart `Voronoi` Shader
class VoronoiFilter: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var tileCount:Int = 10
    var time:Int = 3
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "voronoi", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
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
        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(tileSize), y: CGFloat(tileSize)))
        let tileCT = Float(tileCount)
        let timeN = Float(time)
        
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, tileCT, timeN])
    }
}

/// Caustic (Electric/Cloud) Noise
class CausticNoiseMetal: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    
    /// Size of the image
    var tileSize:Float = 512.0
    
    /// Random factor
    var time:Int = 1
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "caustic", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
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
        let nTime:Float = Float(time)
        
        return kernel.apply(extent: inputImage.extent, arguments: [src, nTime, tileSize])
    }
}

/// A Random Color Warping Shader
class PlasmaFilter: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var time:Float = 1
    var iterations:Float = 5
    var sharpness:Float = 1
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kern = try? CIColorKernel(functionName: "plasma", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
        self.kernel = kern
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
        //        let iterations:Float = 5
        //        let sharpness:Float = 1
        
        // plasma(sample_t sample, float time, float iterations, float sharpness, float scale, destination dest) {
        return kernel.apply(extent: inputImage.extent, arguments: [src, time, iterations, sharpness, tileSize])
    }
}
