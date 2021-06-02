
#include <metal_stdlib>
using namespace metal;

// Pragma - Constants
//https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_palettes
//https://en.wikipedia.org/wiki/Relative_luminance
//https://en.wikipedia.org/wiki/Grayscale
//constant float3 kRec709Luma  = float3(0.2126, 0.7152, 0.0722);
//constant float3 kRec601Luma  = float3(0.299 , 0.587 , 0.114);
constant float pi = 3.141592653589;
//constant float3 kRec2100Luma = float3(0.2627, 0.6780, 0.0593);

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float SDFHorizLine(float2 coords ) {
        float v = 0.5-coords.y;
        float2  g = float2(0.0,-1.0);
        return abs(v)/length(g);
    }
    
    float SDFVertLine(float2 coords ) {
        float v = coords.x - 0.5;
        float2  g = float2(1.0,0.0);
        return abs(v)/length(g);
    }
    
    float SDFCircle(float2 coords) {
        coords.x -= 0.5;
        coords.y -= 0.5;
        float v = coords.x * coords.x + coords.y * coords.y - 0.001;
        float2  g = float2(2.0 * coords.x, 2.0 * coords.y);
        return v/length(g);
    }
    
    float circuitNoise(float2 x, sampler image) {
        float2 p = floor(x);
        float2 f = fract(x);
        float2 uv = p.xy + f.xy*f.xy*(3.0-2.0*f.xy);
        float2 xPoint = uv; //(uv+118.4)/256.0;
        float2 sCoord = float2(xPoint.x, xPoint.y); // -100.0
        return image.sample(sCoord).x; // texture( iChannel0, (uv+118.4)/256.0, -100.0 ).x;
    }
    
    float coinFlip(float2 sampleAt, float2 seed, sampler image) {
        return circuitNoise(sampleAt / seed, image) > 0.5 ? 1 : 0;
    }
    
    float3 RenderTilePixel (float leftType, float topType, float rightType, float bottomType, float percentX, float percentY) {
        float col = 1.0;
        
        if ((leftType == 1 && percentX < 0.5) ||
            (rightType == 1 && percentX > 0.5))
            col = min(col, SDFHorizLine(float2(percentX,percentY)));
        
        if ((topType == 1 && percentY < 0.5) ||
            (bottomType == 1 && percentY > 0.5))
            col = min(col, SDFVertLine(float2(percentX,percentY)));
        
        if (leftType != rightType || topType != bottomType)
            col = min(col, SDFCircle(float2(percentX,percentY)));
        
        col = smoothstep(0.09,0.11,col);
        // col = 1.0 - step(col, 0.1);
        return mix(float3(0.125,0.125,0.125),float3(1,1,1),col);
    }
    
    
    
    float3 renderScreen(float2 pixel, float tile_size, sampler image) {
        float tileX = floor(pixel.x / tile_size);
        float tileY = floor(pixel.y / tile_size);
        
        float tileOffsetX = fract(pixel.x / tile_size);
        float tileOffsetY = fract(pixel.y / tile_size);
        
        // calculate our tile edges, making sure to be coherent with our neighbors!
        int leftType   = coinFlip(float2(tileX-1.0,tileY    ), float2(0.12,0.37), image);
        int rightType  = coinFlip(float2(tileX,    tileY    ), float2(0.12,0.37), image);
        int topType    = coinFlip(float2(tileX,    tileY-1.0), float2(0.41,0.73), image);
        int bottomType = coinFlip(float2(tileX,    tileY    ), float2(0.41,0.73), image);
        
        // render the tile pixel!
        return RenderTilePixel(leftType,topType,rightType,bottomType,tileOffsetX,tileOffsetY);
    }
    
    float4 circuit(sampler image, float2 size, destination dest) {
        // float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        // declarations
        float tile_size = 0.15;
        float tile_padding = 0.05;
        float tile_scale = 1.5;
        
        // parts
        float2 pixel = dest.coord() / size;
        pixel.y = 1.0 - pixel.y;
        pixel.y = pixel.y - 0.5 + (tile_size + tile_padding) * 2.0 + tile_padding * 0.5;
        
        float aspectRatio = 1; //size.x / size.y;
        pixel.x -= 0.5;
        pixel.x *= aspectRatio;
        pixel.x += (tile_size + tile_padding) * 2.0 + tile_padding * 0.5;
        
        float3 color = float3(0,0,0);
        
        float scale = 0.5 + tile_scale; //* (sin(iTime*0.33) * 0.5 + 0.5);
        
        color = renderScreen(pixel*scale, tile_size, image);//+ iTime * TILE_SCROLL);
        
        return float4(color, 1.0);
    }
    
}}
