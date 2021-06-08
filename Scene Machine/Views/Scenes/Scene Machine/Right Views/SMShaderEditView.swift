//
//  SMShaderEditView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/4/21.
//

import SwiftUI
import SceneKit

enum ShaderType:String, CaseIterable {
    case Geometry
    case Surface
    case Lighting
    case Fragment
}

struct SMShaderEditView: View {
    
    @ObservedObject var controller:SceneMachineController
    
    @State var geometry:SCNGeometry
    @State var materials:[SCNMaterial] = []
    
    @State var selectedMaterial:SCNMaterial?
    @State var shaderType:ShaderType = .Surface
    @State var text:String = "// Write shader snippet here."
    
    @State var popMaterial:Bool = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Shader snippet")
                Button("Material") {
                    popMaterial.toggle()
                }
                .popover(isPresented: $popMaterial, content: {
                    HStack {
                        Text("Geometry")
                        Spacer()
                        Button("Select") {
                            self.selectedMaterial = nil
                        }
                    }
                    ForEach(materials) { material in
                        HStack {
                            Text(material.name ?? "untitled")
                            Spacer()
                            Button("Select") {
                                self.selectedMaterial = material
                            }
                        }
                    }
                })
                Spacer()
                Picker("Shader", selection: $shaderType) {
                    ForEach(ShaderType.allCases, id:\.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .frame(width:160)
                .onChange(of: shaderType) { value in
                    didSelectShaderType()
                }
                
                Button("💾") {
                    print("save")
                    
                    switch shaderType {
                        case .Fragment: selectedMaterial?.shaderModifiers = [.fragment: text]
                        case .Surface: selectedMaterial?.shaderModifiers = [.surface: text]
                        case .Lighting: selectedMaterial?.shaderModifiers = [.lightingModel: text]
                        case .Geometry: selectedMaterial?.shaderModifiers = [.geometry: text]
                    }
                }
            }
            .padding(.horizontal, 4)
            
            VSplitView {
                switch shaderType {
                    case .Geometry:
                        MacEditorTextView(
                            text: .constant(geometryShaderTypeHeaders),
                            isEditable: true,
                            font: .monospacedSystemFont(ofSize: 14, weight: .light),
                            fontColor: .gray
                        )
                        .foregroundColor(.gray)
                    case .Surface:
                        MacEditorTextView(
                            text: .constant(surfaceShaderTypeHeaders),
                            isEditable: true,
                            font: .monospacedSystemFont(ofSize: 14, weight: .light),
                            fontColor: .gray
                        )
                        .foregroundColor(.gray)
                    case .Lighting:
                        MacEditorTextView(
                            text: .constant(lightingShaderTypeHeaders),
                            isEditable: true,
                            font: .monospacedSystemFont(ofSize: 14, weight: .light),
                            fontColor: .gray
                        )
                        .foregroundColor(.gray)
                    case .Fragment:
                        MacEditorTextView(
                            text: .constant(fragmentShaderTypeHeaders),
                            isEditable: true,
                            font: .monospacedSystemFont(ofSize: 14, weight: .light),
                            fontColor: .gray
                        )
                        .foregroundColor(.gray)
                }
                
                Divider().frame(height:6)
                
                MacEditorTextView(
                    text: $text,
                    isEditable: true,
                    font: .monospacedSystemFont(ofSize: 14, weight: .light)
                )
                .onChange(of: selectedMaterial, perform: { value in
                    self.didSelectShaderType()
                })
            }
            
            
        }
        .onAppear() {
            loadMaterials()
        }
    }
    
    func valueOfText() -> String? {
        if text.isEmpty { return nil }
        if text == "// Write shader snippet here." { return nil }
        return text
    }
    
    func saveShaderType() {
        switch shaderType {
            case .Geometry:
                if let material = selectedMaterial {
                    if let _ = material.shaderModifiers {
                        material.shaderModifiers![.geometry] = valueOfText()
                    } else {
                        if let written = valueOfText() {
                            material.shaderModifiers = [.geometry:written]
                        } else {
                            material.shaderModifiers = nil
                        }
                    }
                } else if let _ = geometry.shaderModifiers {
                    geometry.shaderModifiers![.geometry] = valueOfText()
                } else if let txt = valueOfText() {
                    geometry.shaderModifiers = [.geometry:txt]
                }
                
                
                
            case .Fragment:
                if let material = selectedMaterial {
                    if let _ = material.shaderModifiers {
                        material.shaderModifiers![.fragment] = valueOfText()
                    } else {
                        if let written = valueOfText() {
                            material.shaderModifiers = [.fragment:written]
                        } else {
                            material.shaderModifiers = nil
                        }
                    }
                } else if let _ = geometry.shaderModifiers {
                    geometry.shaderModifiers![.fragment] = valueOfText()
                } else if let txt = valueOfText() {
                    geometry.shaderModifiers = [.fragment:txt]
                }
                
            case .Lighting:
                if let material = selectedMaterial {
                    if let _ = material.shaderModifiers {
                        material.shaderModifiers![.lightingModel] = valueOfText()
                    } else {
                        if let written = valueOfText() {
                            material.shaderModifiers = [.lightingModel:written]
                        } else {
                            material.shaderModifiers = nil
                        }
                    }
                } else if let _ = geometry.shaderModifiers {
                    geometry.shaderModifiers![.lightingModel] = valueOfText()
                } else if let txt = valueOfText() {
                    geometry.shaderModifiers = [.lightingModel:txt]
                }
                
            case .Surface:
                if let material = selectedMaterial {
                    if let _ = material.shaderModifiers {
                        material.shaderModifiers![.surface] = valueOfText()
                    } else {
                        if let written = valueOfText() {
                            material.shaderModifiers = [.surface:written]
                        } else {
                            material.shaderModifiers = nil
                        }
                    }
                } else if let _ = geometry.shaderModifiers {
                    geometry.shaderModifiers![.surface] = valueOfText()
                } else if let txt = valueOfText() {
                    geometry.shaderModifiers = [.surface:txt]
                }
        }
    }
    
    func didSelectShaderType() {
        switch shaderType {
            case .Geometry:
                if let material = selectedMaterial {
                    self.text = material.shaderModifiers?[.geometry] ?? "// Write shader snippet here."
                } else {
                    self.text = geometry.shaderModifiers?[.geometry] ??  "// Write shader snippet here."
                }
            case .Fragment:
                if let material = selectedMaterial {
                    self.text = material.shaderModifiers?[.fragment] ?? "// Write shader snippet here."
                } else {
                    self.text = geometry.shaderModifiers?[.fragment] ??  "// Write shader snippet here."
                }
            case .Lighting:
                if let material = selectedMaterial {
                    self.text = material.shaderModifiers?[.lightingModel] ?? "// Write shader snippet here."
                } else {
                    self.text = geometry.shaderModifiers?[.lightingModel] ??  "// Write shader snippet here."
                }
            case .Surface:
                if let material = selectedMaterial {
                    self.text = material.shaderModifiers?[.surface] ?? "// Write shader snippet here."
                } else {
                    self.text = geometry.shaderModifiers?[.surface] ??  "// Write shader snippet here."
                }
        }
    }
    
    func loadMaterials() {
        self.materials = geometry.materials
        self.selectedMaterial = geometry.materials.first
        self.didSelectShaderType()
    }
}

struct SMShaderEditView_Previews: PreviewProvider {
    static var previews: some View {
        SMShaderEditView(controller: SceneMachineController(), geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
        
    }
}

// MARK: - Shader Headers

fileprivate var surfaceShaderTypeHeaders:String {
    return """
        /*
        Access: ReadWrite
        Stages: Fragment shader only
        */
        struct {
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
        } scn_frame;
        
        struct {
        float4x4 modelTransform;
        float4x4 inverseModelTransform;
        float4x4 modelViewTransform;
        float4x4 inverseModelViewTransform;
        float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
        float4x4 modelViewProjectionTransform;
        float4x4 inverseModelViewProjectionTransform;
        float2x3 boundingBox;
        float2x3 worldBoundingBox;
        } scn_node;
        
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
        float4 emission;                 // Emission property of the fragment
        float2 emissionTexcoord;         // Emission texture coordinates
        float shininess;                 // Shininess property of the fragment
        float fresnel;                   // Fresnel property of the fragment
        float ambientOcclusion;          // Ambient occlusion term of the fragment
        } _surface;

        """
}

fileprivate var geometryShaderTypeHeaders:String {
    return """
        /*
        Access: ReadWrite
        Stages: Vertex shader only
        */
        struct {
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
        } scn_frame;
        
        struct {
        float4x4 modelTransform;
        float4x4 inverseModelTransform;
        float4x4 modelViewTransform;
        float4x4 inverseModelViewTransform;
        float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
        float4x4 modelViewProjectionTransform;
        float4x4 inverseModelViewProjectionTransform;
        float2x3 boundingBox;
        float2x3 worldBoundingBox;
        } scn_node;
        
        struct SCNShaderGeometry {
        float4 position;
        float3 normal;
        float4 tangent;
        float4 color;
        float2 texcoords[kSCNTexcoordCount];
        } _geometry;
        """
}

fileprivate var lightingShaderTypeHeaders:String {
    return """
        /*
        Access: ReadOnly
        Stages: Vertex shader and fragment shader
        Structures: All the structures available from the SCNShaderModifierEntryPointSurface entry point
        */
        struct {
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
        } scn_frame;
        
        struct {
        float4x4 modelTransform;
        float4x4 inverseModelTransform;
        float4x4 modelViewTransform;
        float4x4 inverseModelViewTransform;
        float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
        float4x4 modelViewProjectionTransform;
        float4x4 inverseModelViewProjectionTransform;
        float2x3 boundingBox;
        float2x3 worldBoundingBox;
        } scn_node;
        
        
        /*
        Access: ReadWrite
        Stages: Vertex shader and fragment shader
        */
        struct SCNShaderLightingContribution {
        float3 ambient;
        float3 diffuse;
        float3 specular;
        } _lightingContribution;
        
        /*
        Access: ReadOnly
        Stages: Vertex shader and fragment shader
        */
        struct SCNShaderLight {
        float4 intensity;
        float3 direction; // Direction from the point on the surface toward the light (L)
        } _light;

        """
}

fileprivate var fragmentShaderTypeHeaders:String {
    return """
        /*
        Access: ReadOnly
        Stages: Fragment shader only
        Structures: All the structures available from the SCNShaderModifierEntryPointSurface entry point
        */
        
        struct {
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
        } scn_frame;
        
        struct {
        float4x4 modelTransform;
        float4x4 inverseModelTransform;
        float4x4 modelViewTransform;
        float4x4 inverseModelViewTransform;
        float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
        float4x4 modelViewProjectionTransform;
        float4x4 inverseModelViewProjectionTransform;
        float2x3 boundingBox;
        float2x3 worldBoundingBox;
        } scn_node;
        
        /*
        Access: ReadWrite
        Stages: Fragment shader only
        */
        struct SCNShaderOutput {
        float4 color;
        } _output;

        """
}
