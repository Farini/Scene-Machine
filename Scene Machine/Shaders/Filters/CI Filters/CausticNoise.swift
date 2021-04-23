//
//  CausticNoise.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Foundation
import CoreImage

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
