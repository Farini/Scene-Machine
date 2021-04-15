//
//  Kernel1.metal
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 myColor(sample_t s) {
        
        return s.grba;
    }
    
}}

