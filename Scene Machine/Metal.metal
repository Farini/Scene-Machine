//
//  Metal.metal
//  Scene Machine
//
//  Created by Carlos Farini on 1/23/21.
//

#include <metal_stdlib>
//#include <CoreImage/CoreImage.h>
using namespace metal;



//extern "C" {
//    namespace coreimage {
//        float4 passthroughFilterKernel(sampler src) {
//            float4 output = src.sample(src.coord());
//            return output;
//        }
//    }
//}


//kernel vec4 mainImage(float time, float tileSize) {
//
//    vec2 uv = destCoord() / tileSize;
//
//    vec2 p = mod(uv * 6.28318530718, 6.28318530718) - 250.0;
//
//    vec2 i = vec2(p);
//    float c = 1.0;
//    float inten = .005;
//
//    for (int n = 0; n < 5; n++)
//    {
//        float t = time * (1.0 - (3.5 / float(n+1)));
//        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
//        c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
//    }
//    c /= 5.0;
//    c = 1.17-pow(c, 1.4);
//    vec3 colour = vec3(pow(abs(c), 8.0));
//    colour = clamp(colour, 0.0, 1.0);
//
//    return vec4(colour, 1.0);
//}
