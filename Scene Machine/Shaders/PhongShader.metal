//
//  PhongShader.metal
//  Scene Machine
//
//  Created by Carlos Farini on 4/30/21.
//

/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A shader using using the Phong shading model for the Metal Shader Showcase. This is a simple and frequently used shader that many developers will implement. The technique is accomplished by computing an ambient, diffuse, and specular component and adds them together to get the final color.
 */

//#include <metal_stdlib>
//#include <metal_common>
//#include <simd/simd.h>
// #include "AAPLSharedTypes.h"

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

//
////using namespace metal;
//
//constant float3 light_position = float3(50.0, 100.0, 50.0);
//constant float4 light_color = float4(1.0, 1.0, 1.0, 1.0);
//constant float4 materialAmbientColor = float4(0.3, 0.5, 0.9, 1.0);
//constant float4 materialDiffuseColor = float4(0.4, 0.6, 1.0, 1.0);
//constant float4 materialSpecularColor = float4(1.0, 1.0, 1.0, 1.0);
//constant float  materialShine = 50.0;
//
//typedef struct {
//    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
//    float3 normal  [[ attribute(SCNVertexSemanticNormal) ]];
//    float4 color [[ attribute(SCNVertexSemanticColor) ]];
//} MyVertexInput;
//
//struct MyNodeBuffer {
//    float4x4 modelTransform;
//    float4x4 modelViewTransform;
//    float4x4 normalTransform;
//    float4x4 modelViewProjectionTransform;
//};
//
//struct ColoredVertex
//{
//    float4 position [[position]];
//    float3 normal;
//    float4 color;
//
//    float3 eye_direction_cameraspace;
//    float3 light_direction_cameraspace;
//};
//
//vertex ColoredVertex myVertex(MyVertexInput in [[ stage_in ]],
//                              constant SCNSceneBuffer& scn_frame [[buffer(0)]],
//                              constant MyNodeBuffer& scn_node [[buffer(1)]]
//                              )
//{
//    float3 normal = in.normal;
//
//
//    ColoredVertex vert;
//    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
//
//    vert.color = in.color;
//    vert.normal = (scn_node.normalTransform * float4(normal, 1.0)).xyz;
//
//    float4 vertex_position_modelspace = float4(in.position, 1.0f );
//
//    float3 vertex_position_cameraspace = ( scn_node.modelViewTransform * vertex_position_modelspace ).xyz;
//    vert.eye_direction_cameraspace = float3(0.0f,0.0f,0.0f) - vertex_position_cameraspace;
//
//    float3 light_position_cameraspace = ( scn_frame.viewTransform * float4(light_position,1.0f)).xyz;
//    vert.light_direction_cameraspace = light_position_cameraspace + vert.eye_direction_cameraspace;
//
//    return vert;
//}
//
//fragment half4 myFragment(ColoredVertex in [[stage_in]])
//{
//    half4 color;
//
//    float4 ambient_color = materialAmbientColor;
//
//    float3 n = normalize(in.normal);
//    float3 l = normalize(in.light_direction_cameraspace);
//    float n_dot_l = saturate( dot(n, l) );
//
//    float4 diffuse_color = light_color * n_dot_l * materialDiffuseColor;
//
//    float3 e = normalize(in.eye_direction_cameraspace);
//    float3 r = -l + 2.0f * n_dot_l * n;
//    float e_dot_r =  saturate( dot(e, r) );
//    float4 specular_color = materialSpecularColor * light_color * pow(e_dot_r, materialShine);
//
//    color = half4(ambient_color + diffuse_color + specular_color);
//
//    return color;
//}

// Global constants
constant float3 light_position = float3(-1.0, 1.0, -1.0);
constant float4 light_color = float4(1.0, 1.0, 1.0, 1.0);
constant float4 materialAmbientColor = float4(0.18, 0.18, 0.18, 1.0);
constant float4 materialDiffuseColor = float4(0.4, 0.4, 0.4, 1.0);
constant float4 materialSpecularColor = float4(1.0, 1.0, 1.0, 1.0);
constant float  materialShine = 50.0;

// Apple
//struct ColorInOut {
//    float4 position [[position]];
//    float3 normal_cameraspace;
//    float3 eye_direction_cameraspace;
//    float3 light_direction_cameraspace;
//};

// Mine

typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float3 normal  [[ attribute(SCNVertexSemanticNormal) ]];
    float4 color [[ attribute(SCNVertexSemanticColor) ]];
} MyVertexInput;

struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
};

struct ColoredVertex
{
    float4 position [[position]];
    float3 normal;
    float4 color;
    
    float3 eye_direction_cameraspace;
    float3 light_direction_cameraspace;
};

//struct VertexOutput {
//    float4 position [[ position ]];
//    float4 color;
//    float2 texcoord;
//};



vertex ColoredVertex cVertex(MyVertexInput in [[ stage_in ]],
                              constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                              constant MyNodeBuffer& scn_node [[buffer(1)]]
                              )
{
    float3 normal = in.normal;
    
    
    ColoredVertex vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    
    vert.color = in.color;
    vert.normal = (scn_node.normalTransform * float4(normal, 1.0)).xyz;
    
    float4 vertex_position_modelspace = float4(in.position, 1.0f );
    
    float3 vertex_position_cameraspace = ( scn_node.modelViewTransform * vertex_position_modelspace ).xyz;
    vert.eye_direction_cameraspace = float3(0.0f,0.0f,0.0f) - vertex_position_cameraspace;
    
    float3 light_position_cameraspace = ( scn_frame.viewTransform * float4(light_position,1.0f)).xyz;
    vert.light_direction_cameraspace = light_position_cameraspace + vert.eye_direction_cameraspace;
    
    return vert;
}

fragment half4 cFragment(ColoredVertex in [[stage_in]])
{
    half4 color;
    
    float4 ambient_color = materialAmbientColor;
    
    float3 n = normalize(in.normal);
    float3 l = normalize(in.light_direction_cameraspace);
    float n_dot_l = saturate( dot(n, l) );
    
    float4 diffuse_color = light_color * n_dot_l * materialDiffuseColor;
    
    float3 e = normalize(in.eye_direction_cameraspace);
    float3 r = -l + 2.0f * n_dot_l * n;
    float e_dot_r =  saturate( dot(e, r) );
    float4 specular_color = materialSpecularColor * light_color * pow(e_dot_r, materialShine);
    
    color = half4(ambient_color + diffuse_color + specular_color);
    
    return color;
}

/*
// Phong vertex shader function
vertex ColorInOut phong_vertex(device packed_float3* vertices [[ buffer(0) ]],
                               device packed_float3* normals [[ buffer(1) ]],
                               constant AAPL::uniforms_t& uniforms [[ buffer(2) ]],
                               unsigned int vid [[ vertex_id ]])
{
    ColorInOut out;

    float4x4 model_matrix = uniforms.model_matrix;
    float4x4 view_matrix = uniforms.view_matrix;
    float4x4 projection_matrix = uniforms.projection_matrix;
    float4x4 mvp_matrix = projection_matrix * view_matrix * model_matrix;
    float4x4 model_view_matrix = view_matrix * model_matrix;

    // Calculate the position of the object from the perspective of the camera
    float4 vertex_position_modelspace = float4(float3(vertices[vid]), 1.0f );
    out.position = mvp_matrix * vertex_position_modelspace;

    // Calculate the normal from the perspective of the camera
    float3 normal = normals[vid];
    out.normal_cameraspace = (normalize(model_view_matrix * float4(normal, 0.0f))).xyz;

    // Calculate the view vector from the perspective of the camera
    float3 vertex_position_cameraspace = ( view_matrix * model_matrix * vertex_position_modelspace ).xyz;
    out.eye_direction_cameraspace = float3(0.0f,0.0f,0.0f) - vertex_position_cameraspace;

    // Calculate the direction of the light from the position of the camera
    float3 light_position_cameraspace = ( view_matrix * float4(light_position,1.0f)).xyz;
    out.light_direction_cameraspace = light_position_cameraspace + out.eye_direction_cameraspace;

    return out;
}

// Phong fragment shader function
fragment half4 phong_fragment(ColorInOut in [[stage_in]])
{
    half4 color;

    // Get the ambient color (the color that represents all the light that bounces around
    // the scene and illuminates the object).
    float4 ambient_color = materialAmbientColor;

    // Calculate the diffuse color (the color of the object given by direct illumination).
    // This is done by using the dot product between the surface normal and the light
    // vector to estimate how much the suface is facing towards the light.
    float3 n = normalize(in.normal_cameraspace);
    float3 l = normalize(in.light_direction_cameraspace);
    float n_dot_l = saturate( dot(n, l) );

    float4 diffuse_color = light_color * n_dot_l * materialDiffuseColor;

    // Calculate the specular color (the color given by the bright higlight of a shiny
    // object). This is done by using the dot product to calculate how close the
    // reflection of the light is pointing towards the viewer (e). The angle is raised by
    // the materialShine factor to control the size of the highlight.
    float3 e = normalize(in.eye_direction_cameraspace);
    float3 r = -l + 2.0f * n_dot_l * n;
    float e_dot_r =  saturate( dot(e, r) );
    float4 specular_color = materialSpecularColor * light_color * pow(e_dot_r, materialShine);

    // Combine the ambient, specular and diffuse colors to get the final color
    color = half4(ambient_color + diffuse_color + specular_color);

    return color;
};

*/


// Generate a texture.
void kernel kernel_function(uint2                           gid         [[ thread_position_in_grid ]],
                            texture2d<float, access::write> outTexture  [[texture(0)]])
{
    // Check if the pixel is within the bounds of the output texture
    if ((gid.x >= outTexture.get_width()) ||
        (gid.y >= outTexture.get_height()))
    {
        // Return early if the pixel is out of bounds
        return;
    }
    float2 textureSize = float2(outTexture.get_width(),
                                outTexture.get_height());
    float2 position = float2(gid);
    float4 pixelColor = float4(position/textureSize, 0.0, 1.0);
    pixelColor.y = 1.0 - pixelColor.y;  // invert the green component.
    outTexture.write(pixelColor, gid);
}
