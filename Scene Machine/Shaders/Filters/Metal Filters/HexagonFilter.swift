//
//  HexagonFilter.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Cocoa
import CoreImage

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

class CausticNoiseMetal: CIFilter {
    
    private var kernel:CIColorKernel
    var inputImage:CIImage?
    var tileSize:Float = 512.0
    
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
        
        if inputImage == nil {
            let baseImage = NSImage(size: NSSize(width: CGFloat(tileSize), height: CGFloat(tileSize)))
            guard let inputData = baseImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: inputData),
                  let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
                return nil
            }
            self.inputImage = inputCIImage
        }
        
        guard let inputImage = inputImage else {return nil}
        
        let src = CISampler(image: inputImage)
        //        let callback: CIKernelROICallback = {
        //            (index, rect) in
        //            return rect.insetBy(dx: 0, dy: 0)
        //        }
        //        caustic(sample_t sample, float time, float tileSize, destination dest)
        return kernel.apply(extent: inputImage.extent, arguments: [src, 1.0, tileSize])
    }
}
