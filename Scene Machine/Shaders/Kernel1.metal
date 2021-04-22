//
//  Kernel1.metal
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

#include <metal_stdlib>
using namespace metal;

// Pragma - Constants
//https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_palettes
//https://en.wikipedia.org/wiki/Relative_luminance
//https://en.wikipedia.org/wiki/Grayscale
constant float3 kRec709Luma  = float3(0.2126, 0.7152, 0.0722);
constant float3 kRec601Luma  = float3(0.299 , 0.587 , 0.114);
//constant float3 kRec2100Luma = float3(0.2627, 0.6780, 0.0593);

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 myColor(sample_t s) {
        
        return s.grba;
    }
    
    float4 colorTransform(sampler src) {
        float4 color = src.sample(src.coord());
//        float2 uv = src.coord()
        return float4(color.r, 0.0, color.b, 1.0);
    }
    
    /** GREAT IDEA
     Make a Shader that Takes a black pixel and transform into a transparent pixel
     */
    float4 makeBlackTransparent(sample_t sample, float threshold) {
        float4 filtered = (sample.r < threshold && sample.g < threshold && sample.b < threshold) == true ? float4(0):float4(sample.r, sample.g, sample.b, sample.a);
//        float2 uv = sample.coord()
        return filtered;
    }
    
    float4 caustic(sample_t sample, float time, float tileSize, destination dest) {
        
        float2 uv = dest.coord() / tileSize;
        
        float2 p = fmod(uv * 6.28318530718, 6.28318530718) - 250.0;
        
        float2 i = float2(p);
        float c = 1.0;
        float inten = .005;
        
        for (int n = 0; n < 5; n++) {
            float t = time * (1.0 - (3.5 / float(n+1)));
            i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
            c += 1.0/length(float2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
        }
     
        c /= 5.0;
        c = 1.17-pow(c, 1.4);
        float3 colour = float3(pow(abs(c), 8.0));
        colour = clamp(colour, 0.0, 1.0);
        
        return float4(colour, 1.0);
    }
    
    float4 hexagons(sample_t sample, destination dest) {
        
        float2 iResolution = float2(1,1); //scn_frame.inverseResolution;
//        float2 iResolution = float2(1,1);
        
        float2 uv = (dest.coord() - 0.5 * iResolution.xy/iResolution.y); // * iResolution.xy) / iResolution.y; //_surface.position.xy; //(_surface.diffuseTexcoord-0.5*iResolution.xy)/iResolution.y;
        float3 col = float3(0);
        
        uv *= 2;
        
        float2 r = float2(1, 1.73);
        float2 h = r * 0.5;
        float2 a = (uv - r * floor(uv/r)) - h; //fract(uv)-0.5; // (uv - r * floor(uv / r)) - h; //fract(uv)-0.5; //fmod(uv, r)-h; //fract(uv)-0.5;
        float2 b = ((uv - h) - r * floor((uv-h)/r)) - h; //fract(uv-0.5)-0.5; // ((uv-0.5) - r * floor((uv-0.5)/r)) - h; //fract(uv-0.5)-0.5; //fmod(uv-h, r)-h; // fract(uv-0.5)-0.5;
        
        // func
        float2 gv;
        if (length(a)<length(b)) {
            gv = a;
        } else {
            gv = b;
        }
        // end func
        
        // func HexDist
        uv = abs(gv);
        float c = dot(uv, normalize(float2(1,1.73)));
        c = max(c, uv.x);
        // col += step(c, .2);
        
        float2 hid = uv-gv;
        // float x = atan(gv.x / gv.y);
        float y = 0.5 - c;
        float4 hexCoords = float4(gv.x, y, hid.x, hid.y);
        float blackThick = 0.01;
        
        // Draw
        float d = smoothstep(0.02, blackThick, hexCoords.y); //hexCoords.y;
        // float d = smoothstep(0.02, blackThick, hexCoords.y*sin(hexCoords.z*hexCoords.w+scn_frame.time));
        
        col.rg = hexCoords.xy;
        col += d;
        
        return float4(col, 1);
    }
    
    // MARK: - Black & White
    
    float lumin601(float3 p)
    {
        return dot(p.rgb, kRec601Luma);
    }
    
    float lumin709(float3 p)
    {
        return dot(p.rgb, kRec709Luma);
    }
    
    float4 thresholdFilter(sample_t image, float threshold)
    {
        float4 pix = unpremultiply(image);
        float luma = lumin601(pix.rgb);
        pix.rgb = float3(step(threshold, luma));
        return premultiply(pix);
    }
    
    // MARK: - Other
    // A general kernel
    float4 appendix2(sampler originalImage, sampler depthMap, destination dest) {
        float2 c = dest.coord();
        float depth = depthMap.sample(depthMap.coord()).r;
        float distortAmount = (1.0 - min(depth, 1.0)) * 100.0;
        
        float columnWidth = 150.0;
        float columnIndex = floor(c.x / columnWidth);
        
        float2 sampleCoord;
        if (int(columnIndex) % 2 == 0) {
            sampleCoord = float2(c.x, c.y + distortAmount);
        } else {
            sampleCoord = float2(c.x, c.y - distortAmount);
        }
        
        return originalImage.sample(originalImage.transform(sampleCoord));
    }

    // Warp kernel
    // In this example, we create a tiling effect. This is achieved by returning
    // the same sampling coordinate for pixels that lie within the same tile.
    float2 appendix3(destination dest) {
        // Get the coordinate of the pixel in the output image
        float2 c = dest.coord();
        // Define the width and height of a tile
        const float2 tileSize = float2(200.0, 300.0);
        // Make coordinates within the same tile sample from the same coordinate
        // Ex. if tileSize.x == 5.0:
        //  0.0 <= c.x <  5.0  -->  sampleCoord.x ==  0.0
        //  5.0 <= c.x < 10.0  -->  sampleCoord.x ==  5.0
        // 10.0 <= c.x < 15.0  -->  sampleCoord.x == 10.0
        float2 sampleCoord = float2(
                                    floor(c.x / tileSize.x) * tileSize.x,
                                    floor(c.y / tileSize.y) * tileSize.y
                                    );
        return sampleCoord;
    }

    // Color kernel
    float4 appendix4(sample_t originalImage) {
        float value = (originalImage.r + originalImage.g + originalImage.b) / 3.0;
        return float4(float3(value), originalImage.a);
    }
    
    float4 appendix6(sample_t originalImage, sample_t depthMap) {
        float depth = depthMap.r;
        
        float4 tintColor = appendix4(originalImage);
        float tintAmount = max(min((depth - 0.5) / (1.0 - 0.5), 1.0), 0.0);
        return float4(
                      originalImage.r * (1.0 - tintAmount) + tintColor.r * tintAmount,
                      originalImage.g * (1.0 - tintAmount) + tintColor.g * tintAmount,
                      originalImage.b * (1.0 - tintAmount) + tintColor.b * tintAmount,
                      1.0
                      );
    }


    // Tint kernel
    float4 appendix5(sampler originalImage, sampler depthMap, destination d) {
        float4 originalColor = originalImage.sample(originalImage.coord());
        float4 tintColor = appendix4(originalColor);
        
        float tintAmount = d.coord().x / originalImage.size().x;
        return float4(
                      originalColor.r * (1.0 - tintAmount) + tintColor.r * tintAmount,
                      originalColor.g * (1.0 - tintAmount) + tintColor.g * tintAmount,
                      originalColor.b * (1.0 - tintAmount) + tintColor.b * tintAmount,
                      1.0
                      );
    }
    
    // Color kernel
    float4 task5(sample_t foreground, sample_t background, sample_t depthMap) {
        /*
         1. Define a constant for a threshold. Its value is the approximate distance from the camera in meters
         2. Read out the value of the red color channel from the depth map (the `r` property on `depthMap`).
         3. Compare the depth value to your threshold.
         4. Return `foreground` if closer than threshold, else return `background`.
         */
        
        //            float threshold = <#value#>;
        //            float depthValue = depthMap.<#colorchannel#>;
        //            if (<#compare#>) {
        //                return <#    #>;
        //            } else {
        //                return <#    #>;
        //            }
        
        return foreground; // Remove this line
    }

    // A general kernel
    // The destination parameter is optional for general kernel. Must be last.
    float4 appendix7(sampler originalImage, sampler depthMap, destination d) {
        // Take sample from samplers at coordinate that matches output/destination space
        float4 colorSample = originalImage.sample(originalImage.coord());
        float4 depthSample = depthMap.sample(depthMap.coord());
        
        // Change color of foreground
        float4 foreground = float4(// Blue channel directly from color sampler
                                   colorSample.b,
                                   // Green channel as gradient from top to bottom using size() of color sampler
                                   d.coord().y / originalImage.size().y,
                                   // Green channel from on depth sampler
                                   depthSample.r,
                                   1);
        
        // Distort background by tiling
        // Tile width is determined based on the depth value in each pixel
        float depth = depthSample.r;
        float tileWidth = depth * 20.0;
        float2 sampleCoord = float2(
                                    floor(d.coord().x / tileWidth) * tileWidth,
                                    floor(d.coord().y / tileWidth) * tileWidth
                                    );
        // Sample background from the new coordinate.
        // We need to use the .transform method to translate destination
        // space (absolute pixel values) to input/color space (normalized pixel values)
        float4 background = originalImage.sample(originalImage.transform(sampleCoord));
        
        // Use the `task5` kernel function directly to combine foreground and background based on depth map.
        return task5(foreground, background, depthSample);
    }
    
    // MARK: - More
    
    float4 sketch(sampler src, float texelWidth, float texelHeight, float intensity40) {
        float size = 1.25f + (intensity40 / 100.0f) * 2.0f;
        
        float minVal = 1.0f;
        float maxVal = 0.0f;
        for (float x = -size; x < size; ++x) {
            for (float y = -size; y < size; ++y) {
                float4 color = src.sample(src.coord() + float2(x * texelWidth, y * texelHeight));
                float val = (color.r + color.g + color.b) / 3.0f;
                if (val > maxVal) {
                    maxVal = val;
                } else if (val < minVal) {
                    minVal = val;
                }
            }
        }
        
        float range = 5.0f * (maxVal - minVal);
        
        float4 outColor(pow(1.0f - range, size * 1.5f));
        outColor = float4((outColor.r + outColor.g + outColor.b) / 3.0f > 0.75f ? float3(1.0f) : outColor.rgb, 1.0f);
        return outColor;
    }
    
    // Although this doesn't work, you can see how to get coords of a pixel
    float4 davidHayward(sampler image, float factor)
    {
        float2 xy = samplerCoord(image).xy;
        float4 c0 = sample(image, samplerCoord(image));
        c0 = unpremultiply(c0); //umul(c0);

        xy = samplerCoord(image).xy + float2(factor, 0);
        float4 c1 = sample(image, xy);
        c1 = unpremultiply(c1); // umul(c1);

        xy = samplerCoord(image).xy + float2(-factor, 0);
        float4 c2 = sample(image, xy);
        c2 = unpremultiply(c2); //umul(c2);

        xy = samplerCoord(image).xy + float2(0, factor);
        float4 c3 = sample(image, xy);
        c3 = unpremultiply(c3); //umul(c3);

        xy = samplerCoord(image).xy + float2(0, -factor);
        float4 c4 = sample(image, xy);
        c4 = unpremultiply(c4); // umul(c4);

        float4 cmax = max(max(max(max(c0, c1), c2), c3), c4);


        return premultiply(c0 / cmax); //pmul( c0 / cmax );
    }
    
    float4 vignetteMetal(sample_t image, float2 center, float radius, float alpha, destination dest) {
        
        float distance2 = distance(dest.coord(), center);
        
        float darken = 1.0 - (distance2 / radius * alpha);
        image.rgb *= darken;
        
        return image.rgba;
    }
    
    float2 pixellateMetal(float radius,destination dest) {
        float2 positionOfDestPixel, centerPoint;
        positionOfDestPixel = dest.coord();
        centerPoint.x = positionOfDestPixel.x - fmod(positionOfDestPixel.x, radius * 2.0) + radius;
        centerPoint.y = positionOfDestPixel.y - fmod(positionOfDestPixel.y, radius * 2.0) + radius;
        
        return centerPoint;
    }
    
    // It is possible to use the following....
    // see: https://tech.unifa-e.com/entry/2019/05/17/185120
    /*
     extension CIImage {
     func laplacian(metalLib: Data) -> CIImage? {
     guard let kernel = try? CIKernel(functionName: "laplacian", fromMetalLibraryData: metalLib) else {
     return self
     }
     
     let correctedImage = kernel.apply(extent: extent, roiCallback: { i, r in r }, arguments: [self])
     return correctedImage
     }
     }
     
     guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
     fatalError("Not found default.metallib.")
     }
     guard let data = try? Data(contentsOf: url) else {
     fatalError("The default.metallib can not read as Data.")
     }
     
     let image = UIImage(named: "lena.png")!
     let ciImage = CIImage(image: image)
     let laplacianImage = ciImage?.laplacian(metalLib: data)
     */
    void laplacian(sampler_h s, group::destination_h dest) {
        float2 dc = dest.coord();
        half4 g1 = s.gatherX(s.transform(dc + float2(-0.5,-0.5)));
        half4 g2 = s.gatherX(s.transform(dc + float2( 1.5,-0.5)));
        half4 g3 = s.gatherX(s.transform(dc + float2(-0.5, 1.5)));
        half4 g4 = s.gatherX(s.transform(dc + float2( 1.5, 1.5)));
        
        half r1 = (g1.y -4 * g1.z + g1.w + g2.w + g3.y);
        half r2 = (g2.y -4 * g2.z + g2.w + g1.z + g4.x);
        half r3 = (g3.x -4 * g3.y + g3.w + g1.z + g4.x);
        half r4 = (g4.x -4 * g4.y + g4.w + g2.w + g3.y);
        
        dest.write(half4(r1, r1, r1, 1), half4(r2, r2, r2, 1), half4(r3, r3, r3, 1), half4(r4, r4, r4, 1));
    }
    
    float4 threshold_binary(sample_t source, float threshold) {
        float4 image = premultiply(source);
        float y = 0.299 * image.r + 0.587 * image.g + 0.114 * image.b; // BT.601
        float binary = y < threshold ? 0.0 : 1.0;
        return float4(binary, binary, binary, 1.0);
    }
    
    
    /*
     return HDRZebraFilter.kernel.apply(extent: input.extent,
     arguments: [input, inputTime])
     see: https://www.paraches.com/archives/7722
     */
    float4 HDRZebra (coreimage::sample_t s, float time, coreimage::destination dest)
    {
        float diagLine = dest.coord().x + dest.coord().y;
        float zebra = fract(diagLine/20.0 + time*2.0);
        if ((zebra > 0.5) && (s.r > 1 || s.g > 1 || s.b > 1))
            return float4(2.0, 0.0, 0.0, 1.0);
        return s;
    }
    
    
   

}}

