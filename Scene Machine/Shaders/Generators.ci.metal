
#include <metal_stdlib>
using namespace metal;

// Pragma - Constants
//https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_palettes
//https://en.wikipedia.org/wiki/Relative_luminance
//https://en.wikipedia.org/wiki/Grayscale
constant float pi = 3.1415926535897;



#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    // Common Funcs
    
    
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
    
    
    
    // MARK: - Voronoi Gems
    /*
     Rounded Voronoi Borders
     -----------------------
     
     Fabrice came up with an interesting formula to produce more evenly distributed Voronoi values.
     I'm sure there are more interesting ways to use it, but I like the fact that it facilitates
     the creation of more rounded looking borders. I'm sure there are more sophisticated ways to
     produce more accurate borders, but Fabrice's version is simple and elegant.
     
     The process is explained below. The link to the original is below also.
     
     I didn't want to cloud the example with too much window dressing, so just for fun, I tried
     to pretty it up by using as little code as possible.
     
     // 2D version
     2D trabeculum - FabriceNeyret2
     https://www.shadertoy.com/view/4dKSDV
     
     // 3D version
     hypertexture - trabeculum - FabriceNeyret2
     https://www.shadertoy.com/view/ltj3Dc
     
     // Straight borders - accurate geometric solution.
     Voronoi - distances - iq
     https://www.shadertoy.com/view/ldl3W8
     
     */
    
    /*
    // vec2 to vec2 hash.
    float2 hash22(float2 p, float iTime) {
        
        // Faster, but doesn't disperse things quite as nicely as other combinations. :)
        float n = sin(dot(p, float2(41, 289)));
        //return fract(vec2(262144, 32768)*n)*.75 + .25;
        
        // Animated.
        p = fract(float2(262144, 32768)*n);
        return sin( p*6.2831853 + iTime )*.35 + .65;
        
    }
    
    // IQ's polynomial-based smooth minimum function.
    float smin( float a, float b, float k ){
        
        float h = clamp(.5 + .5*(b - a)/k, 0., 1.);
        return mix(b, a, h) - k*h*(1. - h);
    }
    
    // 2D 3rd-order Voronoi: This is just a rehash of Fabrice Neyret's version, which is in
    // turn based on IQ's original. I've simplified it slightly, and tidied up the "if-statements,"
    // but the clever bit at the end came from Fabrice.
    //
    // Using a bit of science and art, Fabrice came up with the following formula to produce a more
    // rounded, evenly distributed, cellular value:
    
    // d1, d2, d3 - First, second and third closest points (nodes).
    // val = 1./(1./(d2 - d1) + 1./(d3 - d1));
    //
    float Voronoi(float2 p) {
        
        float2 g = floor(p), o; p -= g;
        
        float3 d = float3(1); // 1.4, etc.
        
        float r = 0.;
        
        for(int y = -1; y <= 1; y++){
            for(int x = -1; x <= 1; x++){
                
                o = float2(x, y);
                o += hash22(g + o, 1) - p;
                
                r = dot(o, o);
                
                // 1st, 2nd and 3rd nearest squared distances.
                d.z = max(d.x, max(d.y, min(d.z, r))); // 3rd.
                d.y = max(d.x, min(d.y, r)); // 2nd.
                d.x = min(d.x, r); // Closest.
                
            }
        }
        
        d = sqrt(d); // Squared distance to distance.
        
        // Fabrice's formula.
        return min(2./(1./max(d.y - d.x, .001) + 1./max(d.z - d.x, .001)), 1.);
        // Dr2's variation - See "Voronoi Of The Week": https://www.shadertoy.com/view/lsjBz1
        //return min(smin(d.z, d.y, .2) - d.x, 1.);
        
    }
    
    float2 hMap(float2 uv) {
        
        // Plain Voronoi value. We're saving it and returning it to use when coloring.
        // It's a little less tidy, but saves the need for recalculation later.
        float h = Voronoi(uv*6.);
        
        // Adding some bordering and returning the result as the height map value.
        float c = smoothstep(0., fwidth(h) * 2, h - .09)*h;
        c += (1.-smoothstep(0., fwidth(h) * 3, h - .22)) * c * .5;
        
        // Returning the rounded border Voronoi, and the straight Voronoi values.
        return float2(c, h);
        
    }
    
    float4 voronoiGems(sampler sample, float2 size, float time, destination dest) {
        
        // Moving screen coordinates.
        float2 uv = dest.coord()/size.y + float2(-.2, .05); 
        
        // Obtain the height map (rounded Voronoi border) value, then another nearby.
        float2 c = hMap(uv);
        float2 c2 = hMap(uv + .004);
        
        // Take a factored difference of the values above to obtain a very, very basic gradient value.
        // Ie. - a measurement of the bumpiness, or bump value.
        float b = max(c2.x - c.x, 0.)*16.;
        
        // Use the height map value to produce some color. It's all made up on the spot, so don't pay it
        // too much attention.
        //
        float3 col = float3(0.05, 1, 1)*c.x; // Red base.
        
        float sv = Voronoi(uv*16. + c.y)*.66 + (1.-Voronoi(uv*48. + c.y*2.))*.34; // Finer overlay pattern.
        col = col*.85 + float3(1, .7, .5)*sv*sqrt(sv)*.3; // Mix in a little of the overlay.
        // float cy = c.y;
        col += (1. - col)*(1.-smoothstep(0., fwidth(c.y)*3., c.y - .22))*c.x; // Highlighting the border.
        col *= col; // Ramping up the contrast, simply because the deeper color seems to look better.
        
        // Taking a pattern sample a little off to the right, ramping it up, then combining a bit of it
        // with the color above. The result is the flecks of yellowy orange that you see. There's no physics
        // behind it, but the offset tricks your eyes into believing something's happening. :)
        sv = col.x*Voronoi(uv*6. + .5);
        col += float3(.7, 1, .3)*pow(sv, 4.)*8.;
        
        // Apply the bump - or a powered variation of it - to the color for a bit of highlighting.
        col += float3(.5, .7, 1)*(b*b*.5 + b*b*b*b*.5);
        
        
        // Basic gamma correction
        return float4(sqrt(clamp(col, 0., 1.)), 1);
        
    }
     */
    
    
    /*
     Triangular Grid
     03/2016
     seb chevrel
     */
    

    
    float mod(float x, float y) {
        return x - y * floor(x / y);
    }
    
    float triGrid(float2 p, float stepSize, float vertexSize,float lineSize) {
        
        // triangle rotation matrices
        float2 v60 = float2( cos(pi/3.0), sin(pi/3.0));
        float2 vm60 = float2(cos(-pi/3.0), sin(-pi/3.0));
        float2x2 rot60 = float2x2(v60.x,-v60.y,v60.y,v60.x);
        float2x2 rotm60 = float2x2(vm60.x,-vm60.y,vm60.y,vm60.x);
        
        
        // equilateral triangle grid
        float2 fullStep= float2( stepSize , stepSize*v60.y);
        float2 halfStep=fullStep/2.0;
        float2 grid = floor(p/fullStep);
        float2 offset = float2( (mod(grid.y,2.0)==1.0) ? halfStep.x : 0. , 0.);
        // tiling
        float2 uv = float2(mod(p.x+offset.x, fullStep.x) - halfStep.x, mod(p.y+offset.y,fullStep.y)-halfStep.y);
        float d2=dot(uv,uv);
        return vertexSize/d2 + // vertices
        max( abs(lineSize/(uv*rotm60).y), // lines -60deg
            max ( abs(lineSize/(uv*rot60).y), // lines 60deg
                 abs(lineSize/(uv.y)) )); // h lines
    }
    
    float4 triangleGridMain(sampler image, float2 size, float time, destination dest) {
        
        // float time = 1.;//iTime*0.1;
        
        // screen space
        float2 uv = dest.coord() /size - float2(0.5,0.5*size.y/size.x);
        
        //uv=vec2(uv.y,-uv.x);
        float2 uv2 = (uv+float2(time,time*0.3));
        
        float stepSize = 0.1;
        float vertSize = 0.00005;
        float lineSize = 0.003;
        float3 lineColor = float3(1,1,1);
        
        float3 color = triGrid(uv2, stepSize, vertSize, lineSize) * lineColor;
        
        // output
        return float4(color, 1.0);
    }
    
    float4 petals(sample_t sample, float2 size, int method, destination dest) {
        
        
        float2 st = dest.coord()/size;
        //st *= 4.;
        
        float3 color = float3(0.0);
        
        // Position of center
        float2 pos = float2(0.5)-st;
        
        float r = length(pos)*2.0;
        float a = atan(pos.y/pos.x)+0.5; // +0.5 here makes it such as the paralel petal points to the bottom of the image
        
        // in case method doesnt match, we get 3 leaves
        float f = cos(a*3.);
        
        if (method == 0) {
            f = cos(a*3.);                        // 3 leaves
        } else if (method == 1) {
            f = abs(cos(a*3.));                         // 6 leaves
        } else if (method == 2) {
            f = abs(cos(a*2.5))*.5+.3;                  // 5 thick leaves
        } else if (method == 3) {
            f = abs(cos(a*12.)*sin(a*3.))*.8+.1;        // Splash like
        } else if (method == 4) {
            f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5; // Cog
        }
        
        color = float3( 1.-smoothstep(f, f+0.02, r));
        
        return float4(color, 1.0);
    }
    
    float4 nGon(sample_t sample, float2 size, int sides, destination dest) {
        
        float2 uv = (dest.coord() - .5 * size.xy) / size.y;
        // float3 col = float3(0);
        
        // size
        uv *= 5;
        float2 gv = fract(uv) - 0.5;
        
        //vec2 st = dest.coord()/size;
        // gv.x *= size.x/size.y;
        float3 color = float3(0.0);
        float d = 0.0;
        
        // Remap the space to -1. to 1.
        gv = gv *2.-1.;
        
        // Number of sides of your shape
        int N = sides;
        
        // Angle and radius from the current pixel
        float a = atan(gv.x/gv.y)+pi;
        float r = pi*2/float(N);
        
        // Shaping function that modulate the distance
        d = cos(floor(.5+a/r)*r-a)*length(gv);
        
        color = float3(1.0-smoothstep(.4,.41,d));
        // color = vec3(d);
        
        return float4(color,1.0);
    }
    
    // corner holes
    
    float2 rotate2D(float2 st, float angle){
        st -= 0.5;
        st =  float2x2(cos(angle),-sin(angle),
                    sin(angle),cos(angle)) * st;
        st += 0.5;
        return st;
    }
    
    float2 tile(float2 st, float zoom){
        st *= zoom;
        return fract(st);
    }
    
    float box(float2 st, float2 size, float smoothEdges){
        size = float2(0.250,0.65)-size*0.5;
        float2 aa = float2(smoothEdges*0.5);
        float2 uv = smoothstep(size, size+aa, st);
        uv *= smoothstep(size, size+aa, float2(1.0)- st);
        return uv.x*uv.y;
    }
    
    float4 cornerHoles(sample_t sample, float2 size, int method, destination dest) {
        
        float2 st = dest.coord()/size;
        float3 color = float3(0.0);
        
        // Divide the space in 4
        st = tile(st,4.);
        
        // Use a matrix to rotate the space 45 degrees
        st = rotate2D(st, pi*0.75);
        
        // Draw a square
        color = float3(box(st, float2(0.680,0.680), 0.01));
        // color = vec3(st,0.0);
        
        return float4(color, 1.0);
    }
    

}}
