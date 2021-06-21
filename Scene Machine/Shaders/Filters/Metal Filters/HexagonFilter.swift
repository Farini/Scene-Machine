//
//  HexagonFilter.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Cocoa
import CoreImage

// MARK: - Hexagons

/// Simple Hexagons. Tiled, and scalable.
class HexagonFilter: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    
    /// The size of the image
    var tileSize:Float = 512.0
    
    /// Number of tiles in each direction
    var tilecount:Int = 5
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "hexagons", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // caustic
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        let src = CISampler(image: inputImage)
        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(tileSize), y: CGFloat(tileSize)))
        let fTile = Float(tilecount)
        
        return kernel.apply(extent: inputImage.extent, arguments: [src, fTile, vec])
    }
}

/// Truchet Tiles
class TruchetFilter: CIFilter {
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var tileCount:Int = 8
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "truchet", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
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
        let count = Float(tileCount)
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        return kernel.apply(extent: inputImage.extent, arguments: [src, count, vec])
    }
}

/// Very Basic Waves
class WavesFilter: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var tileCount:Int = 8
    var time:Double = 1.0
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "waves", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
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
        let fTile = Float(tileCount)
        let fTime = Float(time)
        
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, fTile, fTime])
    }
}

/// Moving Waves (Moving tiles) - Epitrochoidal style.
class EpitrochoidalWaves:CIFilter {
    // epitrochoidal_taps
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    
    /// Size of output image (retuired)
    var tileSize:Float = 512.0
    
    /// Zoom. Defaults to 4
    var zoom:Int = 4
    
    /// Time. defaults to 1
    var time:Float = 1
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "epitrochoidal_taps", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
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
        let fZoom = Float(zoom)
        
        // float2 size, float zoom, float time, destination dest
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, fZoom, time])
    }
}


