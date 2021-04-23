//
//  BLKTransparent.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Foundation
import CoreImage

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

