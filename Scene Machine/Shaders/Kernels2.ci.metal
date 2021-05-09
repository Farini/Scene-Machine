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
    
    /** Takes a black pixel and transform into a transparent pixel */
    float4 makeBlackTransparent(sample_t sample, float threshold) {
        float4 filtered = (sample.r < threshold && sample.g < threshold && sample.b < threshold) == true ? float4(0):float4(sample.r, sample.g, sample.b, sample.a);
        //        float2 uv = sample.coord()
        return filtered;
    }
    
    /// Opposite of black transparent. White
    float4 makeWhiteTransparent(sample_t sample, float threshold) {
        float4 filtered = (sample.r > 1 - threshold && sample.g > 1 - threshold && sample.b > 1 - threshold) == true ? float4(0):float4(sample.r, sample.g, sample.b, sample.a);
        //        float2 uv = sample.coord()
        return filtered;
    }
    
    
    
    // MARK: - Noises
    
    // Smoke noise: https://www.shadertoy.com/view/MsdGWn
    // PerlinMix noise: https://www.shadertoy.com/view/MdGSzt
    // water noise: https://www.shadertoy.com/view/Mt2SzR
    // Perlin cloud like: https://www.shadertoy.com/view/4lB3zz
    
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
    
    float4 plasma(sample_t sample, float time, float iterations, float sharpness, float scale, destination dest) {
        
        float2 uv = dest.coord() / scale;
        // float2 uv0=uv;
        float4 i = float4(1.0, 1.0, 1.0, 0.0);
        
        for(int s = 0;s < int(iterations); s++) {
            float2 r = float2(cos(uv.y * i.x - i.w + time / i.y),sin(uv.x * i.x - i.w + time / i.y)) / i.z;
            r+= float2(-r.y,r.x) * 0.3;
            uv.xy+=r;
            i *= float4(1.93, 1.15, (2.25 - sharpness), time * i.y);
        }
        
            float r = sin(uv.x-time)*0.5+0.5;
            float b=sin(uv.y+time)*0.5+0.5;
            float g=sin((uv.x+uv.y+sin(time))*0.5)*0.5+0.5;
            return float4(r,g,b,1.0);
    }
    
    // random number
    float Noise21(float2 p) {
        // randomzie
        p = fract(p * float2(234.34, 435.345));
        p += dot(p, p + 34.23);
        return fract(p.x * p.y);
    }
    
    // MARK: - Tiled Noise
    
    // Truchet
    float4 truchet(sample_t sample, float tileCount, float2 size, destination dest) {
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        float3 col = float3(0);
        
        // size
        uv *= tileCount;
        
        float2 gv = fract(uv) - 0.5;
        float2 id = floor(uv); // id of the tile
        float width = 0.12; // width of truchet
        
        float n = Noise21(id); // Returns a random number between 0 and 1
        
        //gv.x *= -1; // flip diagonals
        
        if (n < 0.5) gv.x *= -1; // 50% chance to flip diagonals
        float d = abs(abs(gv.x + gv.y) - 0.5); // distance
        d = length(gv-sign(gv.x+gv.y+0.001) * 0.5) - 0.5;
        
        float mask = smoothstep(0.01, -0.01, abs(d) - width);
        
        col += mask;
        // col += n;
        
        // Make the red grid
        //        if (gv.x>.48 || gv.y>.48) {
        //            col = float3(1, 0, 0);
        //        }
        
        // col.rg = gv;
        
        return float4(col, 1);
        
    }
    
    // Draws a maze. Like a trouchet, but with straight lines
    float4 maze(sample_t sample, float tileCount, float2 size, destination dest) {
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        float3 col = float3(0);
        
        // size
        uv *= tileCount;
        
        float2 gv = fract(uv) - 0.5;
        float2 id = floor(uv); // id of the tile
        float width = 0.12; // width of truchet
        
        float n = Noise21(id); // Returns a random number between 0 and 1
        
        //gv.x *= -1; // flip diagonals
        
        if (n < 0.5) gv.x *= -1; // 50% chance to flip diagonals
        float d = abs(abs(gv.x + gv.y) - 0.5); // distance
        float mask = smoothstep(0.01, -0.01, d - width);
        
        col += mask;
        // col += n;
        
        // Make the red grid
        //        if (gv.x>.48 || gv.y>.48) {
        //            col = float3(1, 0, 0);
        //        }
        
        // col.rg = gv;
        
        return float4(col, 1);
        
    }
    
    // Checkerboard, with tiles varying from black to white
    float4 randomBlackToWhiteTiles(sample_t sample, float2 size, destination dest) {
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        float3 col = float3(0);
        
        uv *= 5;
        
        float2 gv = fract(uv) - 0.5;
        float2 id = floor(uv); // id of the tile
        
        float n = Noise21(id);
        
        //        float width = 0.1; // width of truchet
        
        gv.x *= -1; // flip diagonals
        
        //        float mask = smoothstep(0.01, -0.01, abs(gv.x + gv.y) - width);
        
        // col += mask;
        col += n;
        
        // red contour
        if (gv.x>.48 || gv.y>.48) {
            col = float3(1, 0, 0);
        }
        
        // col.rg = gv;
        
        return float4(col, 1);
    }
    
    // Random position
    float2 Noise22(float2 p) {
        float3 a = fract(p.xyx * float3(123.34, 234.34, 345.65));
        a += dot(a, a + 34.45);
        return fract(float2(a.x*a.y, a.y*a.z));
    }
    
    float4 voronoi(sample_t sample, float2 size, float tilecount, float time, destination dest) {
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        //        float m = 0;
        float t = time;
        
        uv *= tilecount;
        float2 gv = fract(uv) - 0.5;
        float2 id = floor(uv);
        
        float minDist = 100;
        
        for (float y=-1; y<=1; y++) {
            for (float x=-1; x<1; x++) {
                float2 offset = float2(x, y);
                
                float2 n = Noise22(id+offset);
                float2 p = offset+sin(n*t)*0.5;
                
                if (time < 3) {
                    p -= gv; // use for manhattan distance
                }
                
                
                // Euclidean distance
                float d = length(gv-p);
                
                if (time < 3) {
                    // Manhattan Distance
                    d = abs(p.x) + abs(p.y);
                }
                
                if(d<minDist) {
                    minDist = d;
                }
            }
        }
        
        // 1- to invert colors, minDist to keep
        float3 col = float3(minDist);
        
        return float4(col, 1.0);
    }
    
    // Waves
    // Look into Trochoidal Waves
    // More on waves: https://www.shadertoy.com/view/Ml2XWy
    // Sick wave: https://www.shadertoy.com/view/4tXXW7
    float4 waves(sample_t sample, float2 size, float tilecount, float time, destination dest) {
        
        float2 uv = (dest.coord()) / size.y;
        //        float2 uv = (dest.coord() - .2 * size.xy) / size.y;
        
        float color = 0.0;
        
        // test amp
        float amplitude = cos(uv.x * 30.0 + time * 2.0) * 2.0; // Height
        float multex = uv.x * 6.0; // Bigger >> black, Smaller >. White
        
        //        if (dest.coord().x > (size.x / 2)) {
        color += sin(multex + sin(time + uv.y * 90 + amplitude)) * 0.5;
        //        } else {
        //            color -= sin(multex + sin(time + uv.y * 90 + amplitude)) * 0.5;
        //        }
        
        
        float3 finalColor = float3(color, color, color);
        
        return float4(finalColor, 1.0);
    }
    
    // MARK: - Tiles
    // Hexagons
    
    float HexDist(float2 p) {
        p = abs(p);
        float c = dot(p, normalize(float2(1, 1.73)));
        c = max(c, p.x);
        return c;
    }
    
    float4 HexCoords(float2 uv) {
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
        
        float x = atan(gv.x / gv.y);
        
        float y = 0.5 - HexDist(gv);
        
        float2 id = uv-gv;
        
        return float4 (x, y, id.x, id.y);
    }
    
    float4 hexagons(sample_t sample, float tileCount, float2 size, destination dest) {
        
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        float3 col = float3(0);
        
        uv *= tileCount;
        
        float4 hc = HexCoords(uv);
        float blackThick = 1;
        
        // Draw
        float c = smoothstep(0.01, 0.05, hc.y * 1/blackThick);
        
        col += c;
        
        return float4(col, 1);
    }
    
    // Checkerboard. pass size, tilecount(num of tiles), randomize: 0..<.5 = Gradient, .5..<1 = White, 1...10 = Random black
    float4 checkerboard(sample_t sample, float2 size, float tilecount, float randomize, destination dest) {
        
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        
        float3 col = float3(0);
        
        uv *= tilecount;
        
        float2 gv = fract(uv) - 0.5;
        float2 id = floor(uv); // id of the tile
        
        if (randomize >= 1.0) {
            // Noise (randomized tiles)
            float n = Noise21(id);
            col += n;
        } else if (randomize < 0.5) {
            // red contour
            if (gv.x>.48 || gv.y>.48) {
                col = float3(1, 0, 0);
            } else {
                // Gradient
                col.gb = gv;
            }
        } else if (randomize >= 0.5) {
            // white
            float width = 0.1;
            float mask = smoothstep(0.01, -0.01, abs(gv.x + gv.y) - width);
            col += mask;
        }
        
        return float4(col, 1);
    }
    
    
    // Bricks
    
    //normal functions
    // original: https://www.shadertoy.com/view/wt3Sz4
    //both function are modified version of https://www.shadertoy.com/view/XtV3z3
    // Normal Tutorial: https://www.shadertoy.com/view/XtV3z3
    
    // Other tiles
    // variant of https://shadertoy.com/view/4dVyDw
    // variant with separate shape func here: https://www.shadertoy.com/view/ldVczc
    // variant with shape groups and more shapes: https://www.shadertoy.com/view/ldGyzd
    // variant with basketweave: https://www.shadertoy.com/view/XdtBzn
    // groups of shapes, fork of https://shadertoy.com/view/ldVczc
    // previous fork of https://shadertoy.com/view/lsVyRK
    
    float sincosbundle(float val) {
        return sin(cos(2.*val) + sin(4.*val)- cos(5.*val) + sin(3.*val))*0.05;
    }
    
    //color function
    float3 brickColor(float2 uv) {
        
        float2 coord = floor(uv);
        float2 gv = fract(uv);
        
        float movingValue = -0.0;
        //for randomness in brick pattern
        movingValue = -sincosbundle(coord.y)*2.;
        
        float edgePos = 1.5;
        float3 lineColor = float3(0.845);
        float3 brickColor = float3(0.45,0.29,0.23);
        
        float mx = uv.y;
        float my = 2.0;
        
        float modolo = mx - my * floor(mx / my);
        float offset = floor(modolo)*(edgePos);
        float verticalEdge = abs(cos(uv.x + offset));
        
        float3 brick = brickColor - movingValue;
        
        bool vrtEdge = step( 1. - 0.01, verticalEdge) == 1.;
        bool hrtEdge = gv.y > (0.9) || gv.y < (0.1);
        
        if(hrtEdge || vrtEdge)
            return lineColor;
        return brick;
    }
    
    float lum(float2 uv) {
        float3 rgb = brickColor(uv);
        return 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
    }
    
    float3 brickNormal(float2 uv) {
        float r = 0.02;
        
        float x0 = lum(float2(uv.x + r, uv.y));
        float x1 = lum(float2(uv.x - r, uv.y));
        float y0 = lum(float2(uv.x, uv.y - r));
        float y1 = lum(float2(uv.x, uv.y + r));
        
        //NOTE: Controls the "smoothness"
        float s = 1.0;
        float3 n = normalize(float3(x1 - x0, y1 - y0, s));
        
        float3 p = float3(uv * 2.0 - 1.0, 0.0);
        float3 v = float3(0.0, 0.0, 1.0);
        
        float3 l = v - p;
        float d_sqr = l.x * l.x + l.y * l.y + l.z * l.z;
        l *= (1.0 / sqrt(d_sqr));
        
        float3 h = normalize(l + v);
        
        float dot_nl = clamp(dot(n, l), 0.0, 1.0);
        float dot_nh = clamp(dot(n, h), 0.0, 1.0);
        
        float color = lum(uv) * pow(dot_nh, 14.0) * dot_nl * (1.0 / d_sqr);
        color = pow(color, 1.0 / 2.2);
        
        return (n * 0.5 + 0.5);
        
    }
    
    float4 bricks(sample_t sample, float2 size, float tilecount, float time, destination dest) {
        float2 uv = (dest.coord()) / size.y;
        uv *= tilecount;
        
        float3 color = float3(0);
        
        if (time < 1) {
            color = brickNormal(uv);
        } else {
            color = brickColor(uv);
        }
        
        return float4(color, 1.0);
        
    }
    
    // MARK: - Normal
    
    // https://www.shadertoy.com/view/XtV3z3
    
    float texLum(float3 lcolor) {
        // float3 rgb = color.rgb;
        // return float(0.2126 * lcolor.r + 0.7152 * lcolor.g + 0.0722 * lcolor.b);
        return (lcolor.r + lcolor.g + lcolor.b) / 3.;
    }
   
    float4 normalMap(sampler image, float2 size, destination dest) {
        
        //float2 uv = dest.coord() / size.xy;
        // float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        float2 texelSize = 1.0 / size.xy;
        
        float2 spoint =  float2(dest.coord().x, size.y-dest.coord().y); //size - dest.coord();
        
        float dx = 0;
        float dy = 0;
        
        dx -= texLum(image.sample(float2(spoint.x - texelSize.x, spoint.y - texelSize.y)).rgb) * 1.0;
        dx -= texLum(image.sample(float2(spoint.x - texelSize.x, spoint.y)).rgb) * 2.0;
        dx -= texLum(image.sample(float2(spoint.x - texelSize.x, spoint.y + texelSize.y)).rgb) * 1.0;
        dx += texLum(image.sample(float2(spoint.x + texelSize.x, spoint.y - texelSize.y)).rgb) * 1.0;
        dx += texLum(image.sample(float2(spoint.x + texelSize.x, spoint.y)).rgb) * 2.0;
        dx += texLum(image.sample(float2(spoint.x + texelSize.x, spoint.y + texelSize.y)).rgb) * 2.0;
        
        dy -= texLum(image.sample(float2(spoint.x - texelSize.x, spoint.y - texelSize.y)).rgb) * 1.0;
        dy -= texLum(image.sample(float2(spoint.x, spoint.y - texelSize.y)).rgb) * 2.0;
        dy -= texLum(image.sample(float2(spoint.x + texelSize.x, spoint.y - texelSize.y)).rgb) * 1.0;
        dy += texLum(image.sample(float2(spoint.x - texelSize.x, spoint.y + texelSize.y)).rgb) * 1.0;
        dy += texLum(image.sample(float2(spoint.x, spoint.y + texelSize.y)).rgb) * 2.0;
        dy += texLum(image.sample(float2(spoint.x + texelSize.x, spoint.y + texelSize.y)).rgb) * 1.0;
        
        float nx = dx;
        float ny = dy;
        
        float3 norm = float3(nx, ny, sqrt(1.0 - nx*nx - ny*ny));
        float4 fragColor = float4(norm * float3(0.5, 0.5, 1.0) + float3(0.5, 0.5, 0.0), 1.0);
        
        return fragColor;
        
        
//        float3 lcolor = image.sample(spoint).rgb;
//        float lumina = texLum(lcolor);
//
//        return float4(lcolor.r, lumina, lumina, 1); // float4(lumina/2, lumina/3, lumina, 1.0);
        
        
        
        /*
        float2 uv = dest.coord() / size.xy;
        float sstep = 1 / size.x;
        float sampx = image.sample(float2(uv.x+sstep, uv.y)).r;
        float sampy = image.sample(float2(uv.x, uv.y+sstep)).r;
        
        // float2 remedy = float2(image.sample(sampx), image.sample(sampy));
        float2 dxy = image.sample(uv).r - float2(sampx, sampy);
        
        float3 n = float4(normalize(float3(dxy * 0.1 / sstep, 1)), image.sample(uv).r).rgb * 0.5 + 0.5;
        float4 res = float4(n, 1);
        return res;
        */
        
        
        /*
        float r = 1.0 / size.x;
        float2 uv = dest.coord(); // * r;
        
        float x0 = texLum(image.sample(float2(uv.x + 1, uv.y)));
        float x1 = texLum(image.sample(float2(uv.x - r, uv.y)));
        float y0 = texLum(image.sample(float2(uv.x, uv.y + 1)));
        float y1 = texLum(image.sample(float2(uv.x, uv.y - r)));
        
        // smoothness
        float smooth = 0.6;
        float3 n = normalize(float3(x1 - x0, y1 - y0, smooth));
        float3 color = n * 0.5 + 0.5;
                          
        return float4(color, 1.0);
        */
        
        /*
        float2 uv = (dest.coord() / size.xy); //- .5 * size.xy) / size.y;
        float2 uvs = 2.0 / size;
        
        // uv.y = 1.0 - uv.y;
        
        float M =image.sample(uv).r;
        float L =image.sample(uv + float2(uvs.x,0)).r;
        float R =image.sample(uv + float2(-uvs.x, 0)).r;
        float U =image.sample(uv + float2(0, uvs.y)).r;
        float D =image.sample(uv + float2(0., -uvs.y)).r;
        float X = ((R-M)+(M-L))*.5;
        float Y = ((D-M)+(M-U))*.5;
        
        float strength = 0.01;
        float4 N = float4(normalize(float3(X, Y, strength)), 1.0);
        float4 col = float4(N.xyz * 0.5 + 0.5, 1.0);
        return col;
         */
    }
    
    // MARK: - Black & White
    
    // Ambient Occlusion
    // https://www.shadertoy.com/view/Ms23Wm
//    void mainImage( out vec4 fragColor, in vec2 fragCoord )
//    {
//
//        // sample zbuffer (in linear eye space) at the current shading point
//        float zr = 1.0-texture( iChannel0, fragCoord.xy / iResolution.xy ).x;
//
//        // sample neighbor pixels
//        float ao = 0.0;
//        for( int i=0; i<8; i++ )
//        {
//            // get a random 2D offset vector
//            vec2 off = -1.0 + 2.0*texture( iChannel1, (fragCoord.xy + 23.71*float(i))/iChannelResolution[1].xy ).xz;
//            // sample the zbuffer at a neightbor pixel (in a 16 pixel radious)
//            float z = 1.0-texture( iChannel0, (fragCoord.xy + floor(off*16.0))/iResolution.xy ).x;
//            // accumulate occlusion if difference is less than 0.1 units
//            ao += clamp( (zr-z)/0.1, 0.0, 1.0);
//        }
//        // average down the occlusion
//        ao = clamp( 1.0 - ao/8.0, 0.0, 1.0 );
//
//        vec3 col = vec3(ao);
//
//        // uncomment this one out for seeing AO with actual image/zbuffer
//        //col *= texture( iChannel0, fragCoord.xy / iResolution.xy ).xyz;
//
//        fragColor = vec4(col,1.0);
//    }
    
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
    
    // MARK: - More Effects
    
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
//    void laplatian(sampler_h s, group::destination_h dest) {
//        float2 dc = dest.coord();
//        half4 g1 = s.gatherX(s.transform(dc + float2(-0.5,-0.5)));
//        half4 g2 = s.gatherX(s.transform(dc + float2( 1.5,-0.5)));
//        half4 g3 = s.gatherX(s.transform(dc + float2(-0.5, 1.5)));
//        half4 g4 = s.gatherX(s.transform(dc + float2( 1.5, 1.5)));
//
//        half r1 = (g1.y -4 * g1.z + g1.w + g2.w + g3.y);
//        half r2 = (g2.y -4 * g2.z + g2.w + g1.z + g4.x);
//        half r3 = (g3.x -4 * g3.y + g3.w + g1.z + g4.x);
//        half r4 = (g4.x -4 * g4.y + g4.w + g2.w + g3.y);
//
//        dest.write(half4(r1, r1, r1, 1), half4(r2, r2, r2, 1), half4(r3, r3, r3, 1), half4(r4, r4, r4, 1));
//    }
    
    float4 laplatian(sampler_h s, destination dest) {
        
        float2 dc = dest.coord();
        
        half4 g1 = s.gatherX(s.transform(dc + float2(-0.5,-0.5)));
        half4 g2 = s.gatherX(s.transform(dc + float2( 1.5,-0.5)));
        half4 g3 = s.gatherX(s.transform(dc + float2(-0.5, 1.5)));
        half4 g4 = s.gatherX(s.transform(dc + float2( 1.5, 1.5)));
        
        half r1 = (g1.y -4 * g1.z + g1.w + g2.w + g3.y);
        half r2 = (g2.y -4 * g2.z + g2.w + g1.z + g4.x);
        half r3 = (g3.x -4 * g3.y + g3.w + g1.z + g4.x);
//        half r4 = (g4.x -4 * g4.y + g4.w + g2.w + g3.y);
        
//        float4 reds = float4(r1, r2, r3, 1);
//        float4
        
        return float4(r1, r2, r3, 1);
        // float4(half4(r1, r1, r1, 1), half4(r2, r2, r2, 1), half4(r3, r3, r3, 1), half4(r4, r4, r4, 1));
//        return float4(float4(r1, r1, r1, 1), float4(r2, r2, r2, 1), float4(r3, r3, r3, 1), float4(r4, r4, r4, 1));
//        return col;
    }
    
    float4 threshold_binary(sample_t source, float threshold) {
        float4 image = premultiply(source);
        float y = 0.299 * image.r + 0.587 * image.g + 0.114 * image.b; // BT.601
        float binary = y < threshold ? 0.0 : 1.0;
        return float4(binary, binary, binary, 1.0);
    }
    
    
    /*
     Apple's WWDC20 HDR Zebra
     */
    float4 HDRZebra (coreimage::sample_t s, float time, coreimage::destination dest)
    {
        float diagLine = dest.coord().x + dest.coord().y;
        float zebra = fract(diagLine/20.0 + time*2.0);
        if ((zebra > 0.5) && (s.r > 1 || s.g > 1 || s.b > 1))
            return float4(2.0, 0.0, 0.0, 1.0);
        return s;
    }
    
    
    // Epitrochoidal Waves: https://www.shadertoy.com/view/4tXXW7
    // Just Awesome!
    
    //From tekF: https://www.shadertoy.com/view/ltXGWS
    float cells(float4 p){
        p = fract(p/2.0)*2.0;
        p = min( p, 2.0-p );
        return min(length(p),length(p-1.0));
    }
    float noise42d(float4 p, float time)
    {
        p*= 2.4;
        p.x += sin(p.z+p.y+p.w+time);
        return pow(cells(p),2.)-.6;
    }
    //Using n+2 dimensional noise to create seamless repetition on two axes
    float tap4d(float2 p, float time) {
        float c = 4; // number of passes
        // float zoom = 3;
        
        float x = cos(p.x)-cos(p.x*c);
        float y = sin(p.x)-sin(p.x*c);
        
        float xx = cos(p.y)-cos(p.y*c);
        float yy = sin(p.y)-sin(p.y*c);
        
        float4 z = float4(x, xx, y, yy);
        z *= .33;
        
        return noise42d(z, time);
    }
    
    float4 epitrochoidal_taps(sample_t source, float2 size, float zoom, float time, destination dest) {
        float2 p = dest.coord().xy / size.xy;
        p.x *= size.x/size.y;
        p.x += time*0.1;
        p.y -= 0.05;
        
        p *= zoom;
        float3 col = float3(tap4d(p, time));
        float4 finale = float4(col, 1.0);
        return finale;
    }
}}

