//
//  TileFilters.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/4/21.
//

import CoreImage
import Cocoa

// MARK: - Tiles

/// A Filter that generates a Checkerboard
class CheckerMetal: CIFilter {
    
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var tileCount:Int = 5
    
    enum Method:Float, CaseIterable {
        case Gradient = 0.2
        case White = 0.6
        case Random = 1.1
    }
    var method:Method = .Gradient
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "checkerboard", fromMetalLibraryData: data) else { fatalError() }
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
        let rnd = method.rawValue
        let count = Float(tileCount)
        
        // Checkerboard. pass size, tilecount(num of tiles), randomize: 0..<.5 = Gradient, .5..<1 = White, 1...10 = Random black
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, count, rnd])
    }
}

/// A filter that generates random directions of diagonals in tiles, representing a Maze
class RandomMaze: CIFilter {
    
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    var imageSize:Float = 512.0
    var tileCount:Int = 8
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "maze", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(imageSize), height: CGFloat(imageSize)))
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
        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(imageSize), y: CGFloat(imageSize)))
        let fTile = Float(tileCount)
        
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        return kernel.apply(extent: inputImage.extent, arguments: [src, fTile, vec])
    }
}

/// Tiled Filter with Brick Pattern
class BricksFilter: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    var tileCount:Int = 8
    var time:Double = 1.0
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "bricks", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
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

/// Laces going over+under other laces. Tiled.
class InterlacedTiles: CIFilter {
    
    private var kernel: CIColorKernel
    
    var inputImage: CIImage?
    
    var color1:NSColor = .red
    var color2:NSColor = .blue
    var size:CGSize = CGSize(width: 1024, height: 1024)
    var tileSize:CGFloat = 10
    
    override init() {
        let url = Bundle.main.url(forResource: "Kernels2.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "interlace", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: size.width, height: size.height))
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
        let vec = CIVector(cgPoint: CGPoint(x: size.width, y: size.height))
        let fColor1 = CIVector(values: [color1.redComponent, color1.greenComponent, color1.blueComponent], count: 3)
        let fColor2 = CIVector(values: [color2.redComponent, color2.greenComponent, color2.blueComponent], count: 3)
        let fTileSize = Float(tileSize)
        
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        return kernel.apply(extent: inputImage.extent, arguments: [src, fColor1, fColor2, vec, fTileSize])
    }
}

/// Triangles mirrorred and connected. Tiled.
class TriangledGrid: CIFilter {
    
    private var kernel:CIKernel
    var inputImage:CIImage?
    var tileSize:CGSize = TextureSize.medium.size
    var time:Float = 1
    
    override init() {
        let url = Bundle.main.url(forResource: "Generators.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kern = try? CIKernel(functionName: "triangleGridMain", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons
        self.kernel = kern
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(tileSize.width), height: CGFloat(tileSize.height)))
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
        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(tileSize.width), y: CGFloat(tileSize.height)))
        //        let time:Float = 1
        
        // plasma(sample_t sample, float time, float iterations, float sharpness, float scale, destination dest) {
        return kernel.apply(extent: inputImage.extent, roiCallback: {
            (index, rect) in
            return rect // .insetBy(dx: 0, dy: 0)
        }, arguments: [src, vec, time])
    }
    
}

/// Segments (Edges) connecting dots, resembling a circuit. Tiled.
class CircuitMaker: CIFilter {
    
    private var kernel:CIKernel
    var inputImage:CIImage?
    //    var margin:Int = 10
    var imageSize:Float = 1024
    
    override init() {
        let url = Bundle.main.url(forResource: "Generators.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIKernel(functionName: "circuit", fromMetalLibraryData: data) else { fatalError() } // myColor // hexagons // truchet
        // float4 truchet(sample_t sample, float2 size, destination dest) {
        self.kernel = kkk
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = AppTextures.colorNoiseTexture(tSize: .medium)
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
        //        let fMargin = Float(margin)
        
        return kernel.apply(extent: inputImage.extent, roiCallback: {
            (index, rect) in
            return rect // .insetBy(dx: 0, dy: 0)
        }, arguments: [src, size])
    }
}

/// Gives the original image an effect similar to corner radius.
class CornerHoles: CIFilter {
    
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    var imgSize:Float = 512.0
    var tileCount:Int = 5
    var time:Float = 1.0
    
    override init() {
        let url = Bundle.main.url(forResource: "Generators.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "cornerHoles", fromMetalLibraryData: data) else { fatalError() }
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(imgSize), height: CGFloat(imgSize)))
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
        let vec = CIVector(cgPoint: CGPoint(x: CGFloat(imgSize), y: CGFloat(imgSize)))
        let count = CGFloat(tileCount)
        
        // cornerHoles(sample_t sample, float2 size, int method, destination dest)
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, count])
    }
}

/// A Checkerboard that scales back and forth over time
class ScalingCheckerboard: CIFilter {
    
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    var imgSize:CGFloat = TextureSize.medium.size.width
    var tileCount:Int = 5
    var time:Float = 1.0
    
    override init() {
        let url = Bundle.main.url(forResource: "Generators.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "scaledCheckerboard", fromMetalLibraryData: data) else { fatalError() }
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: imgSize, height: imgSize))
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
        let vec = CIVector(cgPoint: CGPoint(x: imgSize, y: imgSize))
        let count = Float(tileCount)
        
        // scaledCheckerboard(sample_t sample, float2 size, float tileCount, float time, destination dest)
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, count, time])
    }
}

/// 3 Capsules overlapping in the center. Tiled.
class TricapsuleGrid: CIFilter {
    
    private var kernel:CIColorKernel
    
    var inputImage:CIImage?
    var imgSize:CGFloat = TextureSize.medium.size.width
    var tileCount:Int = 5
    var time:CGFloat = 1.0
    
    override init() {
        let url = Bundle.main.url(forResource: "Generators.ci", withExtension: "metallib")!
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        guard let kkk = try? CIColorKernel(functionName: "tricapsuleGrid", fromMetalLibraryData: data) else { fatalError() }
        self.kernel = kkk
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: imgSize, height: imgSize))
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
        let vec = CIVector(cgPoint: CGPoint(x: imgSize, y: imgSize))
        let count = Float(tileCount)
        
        // scaledCheckerboard(sample_t sample, float2 size, float tileCount, float time, destination dest)
        return kernel.apply(extent: inputImage.extent, arguments: [src, vec, count, time])
    }
}
