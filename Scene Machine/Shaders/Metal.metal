//
//  Metal.metal
//  Scene Machine
//
//  Created by Carlos Farini on 1/23/21.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 inverseModelTransform;
    float4x4 modelViewTransform;
    float4x4 inverseModelViewTransform;
    float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
    float4x4 modelViewProjectionTransform;
    float4x4 inverseModelViewProjectionTransform;
    float2x3 boundingBox;
    float2x3 worldBoundingBox;
}; //scn_node;

typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
} MyVertexInput;

struct SimpleVertex
{
    float4 position [[position]];
    float4 color;
};

/*
 Access: ReadWrite
 Stages: Fragment shader only
 */
struct SCNFrame{
    float4x4    viewTransform;
    float4x4    inverseViewTransform; // transform from view space to world space
    float4x4    projectionTransform;
    float4x4    viewProjectionTransform;
    float4x4    viewToCubeTransform; // transform from view space to cube texture space (canonical Y Up space)
    float4      ambientLightingColor;
    float4        fogColor;
    float3        fogParameters; // x:-1/(end-start) y:1-start*x z:exp
    float2      inverseResolution;
    float       time;
    float       sinTime;
    float       cosTime;
    float       random01;
    // new in OSX 10.12 / iOS 10.0
    float       environmentIntensity;
    float4x4    inverseProjectionTransform;
    float4x4    inverseViewProjectionTransform;
}; // scn_frame;

struct SCNShaderSurface {
    float3 view;                     // Direction from the point on the surface toward the camera (V)
    float3 position;                 // Position of the fragment
    float3 normal;                   // Normal of the fragment (N)
    float3 tangent;                  // Tangent of the fragment
    float3 bitangent;                // Bitangent of the fragment
    float4 ambient;                  // Ambient property of the fragment
    float2 ambientTexcoord;          // Ambient texture coordinates
    float4 diffuse;                  // Diffuse property of the fragment. Alpha contains the opacity.
    float2 diffuseTexcoord;          // Diffuse texture coordinates
    float4 specular;                 // Specular property of the fragment
    float2 specularTexcoord;         // Specular texture coordinates
    float4 emission;                 // Emission property of the fragment
    float2 emissionTexcoord;         // Emission texture coordinates
    float4 multiply;                 // Multiply property of the fragment
    float2 multiplyTexcoord;         // Multiply texture coordinates
    float4 transparent;              // Transparent property of the fragment
    float2 transparentTexcoord;      // Transparent texture coordinates
    float4 reflective;               // Reflective property of the fragment
    float metalness;                 // Metalness property of the fragment
    float2 metalnessTexcoord;        // Metalness texture coordinates
    float roughness;                 // Roughness property of the fragment
    float2 roughnessTexcoord;        // Metalness texture coordinates
    float4 selfIllumination;         // Self illumination property of the fragment
    float2 selfIlluminationTexcoord; // Self illumination texture coordinates
//    float4 emission;                 // Emission property of the fragment
//    float2 emissionTexcoord;         // Emission texture coordinates
    float shininess;                 // Shininess property of the fragment
    float fresnel;                   // Fresnel property of the fragment
    float ambientOcclusion;          // Ambient occlusion term of the fragment
}; // _surface;



vertex SimpleVertex myVertex(MyVertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                             constant MyNodeBuffer& scn_node [[buffer(1)]],
                             constant SCNShaderSurface& surface [[buffer(2)]])
{
    SimpleVertex vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    
//    float v = 1 - (abs(cos(surface.position.y * 6.28) + sin(surface.position.x * 6.28)) * .5);
    
    float minColor = 1/16;
//    float tmod = trunc(scn_frame.time / 16.0) + 0.5;
    
    float vertical = (4 - surface.position.y - 16 * scn_frame.sinTime * surface.position.y); //* abs(scn_frame.sinTime);
    float posy = vertical * minColor;
    float ppart = floor(surface.position.y * 16) * scn_frame.sinTime;
    
    // Colors
    float blu = posy; //max(minColor, vertical);
    float green = vertical; // ppart * v
//    float red = v;
    
//    float change = (1 * scn_frame.sinTime)*surface.position.y;
    
    float4 color = float4(ppart, green, blu, 1);
    vert.color = color;
    
    return vert;
    
}

fragment float4 myFragment(SimpleVertex in [[stage_in]],
                          constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                          constant MyNodeBuffer& scn_node [[buffer(1)]],
                          constant SCNShaderSurface& surface [[buffer(2)]])
{
    half4 color;
    // color = half4(1.0 ,0.0 ,0.0, 1.0);

    float v = 1 - (abs(cos(surface.position.y * 6.28) + sin(surface.position.x * 6.28)) * .5);

    float minColor = 1/16;
    float tmod = trunc(scn_frame.time / 16.0) + 0.5;

    float vertical = (4 - surface.position.y - 16 * scn_frame.sinTime * surface.position.y); //* abs(scn_frame.sinTime);
//    float posy = vertical * minColor;
//    float ppart = floor(surface.position.y * 16) * scn_frame.sinTime;

    // Colors
    float blu = max(minColor, vertical);
    float green = vertical; // ppart * v
    float red = v;

//    float change = (1 * scn_frame.sinTime)*surface.position.y;
    
    color = half4(red, green, blu, 1);
    float3 semi = float3(vertical, tmod * vertical, blu);
    
//    surface.emission = float4(red, green, blu, 1);
    
    return float4(semi, 1.0);
}

// ATTEMPT 2


struct VertexIn {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
    float3 normal [[attribute(SCNVertexSemanticNormal)]];
    float2 uv [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct Uniforms {
    float4x4 modelViewProjectionTransform;
    float4x4 normalTransform;
    float4x4 modelViewTransform;
    float4x4 modelTransform;
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float4 viewLightPosition;
    float4 viewPosition;
    float2 uv;
};

vertex VertexOut shipVertex(VertexIn in [[ stage_in ]],
                            constant float3& lightPosition [[buffer(2)]],
                            constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                            constant Uniforms& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * in.position;
    out.normal = (scn_node.normalTransform * float4(in.normal, 0)).xyz;
    out.viewLightPosition = scn_frame.viewTransform * float4(lightPosition, 1);
    out.viewPosition = scn_node.modelViewTransform * in.position;
    out.uv = in.uv;
    return out;
}

fragment float4 shipFragment(VertexOut in [[stage_in]],
                             texture2d<float> baseColorTexture [[texture(0)]]) {
    constexpr sampler s(filter::linear);
    float4 baseColor = baseColorTexture.sample(s, in.uv);
    
    float3 lightDirection = (normalize(in.viewLightPosition - in.viewPosition)).xyz;
    float diffuseIntensity = saturate(dot(normalize(in.normal), lightDirection));
    return baseColor * diffuseIntensity;
}
