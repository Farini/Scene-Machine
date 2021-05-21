//
//  MaterialMachineView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/20/21.
//

import SwiftUI
import SceneKit

struct MaterialMachineView: View {
    
    @ObservedObject var controller = MaterialMachineController()
    
    var body: some View {
        NavigationView {
            
            // Left
            List() {
                Text("Materials")
                // My materials
                // Library
                // Images?
            }
            
            // Middle
            VSplitView {
                VStack {
                    HStack {
                        
                        // Geometry Picker
                        Picker("Geo", selection: $controller.geoOption) {
                            ForEach(MMGeometryOption.allCases, id:\.self) { geo in
                                Text(geo.rawValue)
                            }
                        }
                        .frame(width:150)
                        .onChange(of: controller.geoOption) { value in
                            controller.updateNode()
                        }
                        
                        // Background Picker
                        Picker("Back", selection:$controller.sceneBackground) {
                            ForEach(AppBackgrounds.allCases, id:\.self) { back in
                                Text(back.rawValue)
                            }
                        }
                        .frame(width:150)
                        .onChange(of: controller.sceneBackground) { value in
                            controller.changeBackground()
                        }
                        
                        ColorPicker("Color", selection: $controller.baseColor)
                            .onChange(of: controller.baseColor) { value in
                                controller.changedColor()
                            }
                    }
                    .frame(height:30)
                    
                    
                    SceneView(scene: controller.scene, pointOfView: nil, options: SceneView.Options.allowsCameraControl, preferredFramesPerSecond: 40, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                }
                
                MMMaterialNodeView()
            }
            
            DrawingPadView()
            // Right
            // UV + Paint + color
        }
    }
}
enum SubMatType:String, CaseIterable {
    case Diffuse, Roughness, Emission, Normal, AO
}
struct MMMaterialNodeView:View {
    
    @State var material:SCNMaterial = SCNMaterial.example
    
    @State var diffuseURL:URL?
    @State var diffuseColor:Color = .white
    @State var diffuseImage:NSImage = NSImage()
    @State var diffuseIntensity:CGFloat = 1
    
    @State var metalnessURL:URL?
    @State var metalnessColor:Color = .white
    @State var metalnessImage:NSImage = NSImage()
    @State var metalnesseIntensity:CGFloat = 1
    
    @State var roughnessURL:URL?
    @State var roughnessColor:Color = .white
    @State var roughnessImage:NSImage = NSImage()
    @State var roughnessIntensity:CGFloat = 1
    @State var roughnessValue:CGFloat = 0.5
    
    @State var occlusionURL:URL?
    @State var occlusionColor:Color = .white
    @State var occlusionImage:NSImage = NSImage()
    @State var occlusionIntensity:CGFloat = 1
    
    @State var emissionURL:URL?
    @State var emissionColor:Color = .white
    @State var emissionImage:NSImage = NSImage()
    @State var emissionIntensity:CGFloat = 1
    
    @State var normalURL:URL?
    @State var normalColor:Color = .white
    @State var normalImage:NSImage = NSImage()
    @State var normalIntensity:CGFloat = 1
    
    @State var matType:SubMatType = .Diffuse
    
    var body: some View {
        VStack {
            HStack(spacing:12) {
                MMNodeView(matType: matType)
                
                VStack {
                    switch matType {
                        case .Diffuse:
                            VStack {
                                Text("Diffuse")
                                //                    Text("Value")
                                if let imgStr = material.diffuse.contents as? String,
                                   let img = NSImage(named: imgStr) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                } else {
                                    // Droppable area
                                    Rectangle().foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                }
                            }
                            .padding()
                            
                        case .Roughness:
                            VStack {
                                Text("Roughness")
                                if let img = material.roughness.contents as? NSImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                } else {
                                    // Droppable area
                                    Rectangle().foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                }
                                Text("Value \(material.roughness.contents as? Double ?? 0.0)")
                            }
                        case .Emission:
                            VStack {
                                Text("Emission")
                                if let img = material.emission.contents as? NSImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                } else {
                                    // Droppable area
                                    Rectangle().foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                }
                                Text("Value \(material.emission.contents as? Double ?? 0.0)")
                                //                    ColorPick
                                
                            }
                        case .Normal:
                            VStack {
                                Text("Normal")
                                if let img = material.emission.contents as? NSImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                } else {
                                    // Droppable area
                                    Rectangle().foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                }
                            }
                        case .AO:
                            VStack {
                                Text("AO")
                                if let img = material.ambientOcclusion.contents as? NSImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                } else {
                                    // Droppable area
                                    Rectangle().foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                }
                            }
                    }
                    
                }
            }
        }
        .onAppear() {
            self.prepareUI()
        }
        .onChange(of: material) { value in
//            self.material = value
            self.prepareUI()
        }
    }
    
    func prepareUI() {
        // Diffuse
        if let difImage = material.diffuse.contents as? NSImage {
            self.diffuseImage = difImage
        } else if let difColor = material.diffuse.contents as? NSColor {
            self.diffuseColor = Color(difColor)
        }
        // Metalness
        if let metalImage = material.metalness.contents as? NSImage {
            self.metalnessImage = metalImage
        } else if let color = material.metalness.contents as? NSColor {
            self.metalnessColor = Color(color)
        }
        // Roughness
        if let image = material.roughness.contents as? NSImage {
            self.roughnessImage = image
        } else if let color = material.roughness.contents as? NSColor {
            self.roughnessColor = Color(color)
        }
        // Emission
        if let image = material.emission.contents as? NSImage {
            self.emissionImage = image
        } else if let color = material.emission.contents as? NSColor {
            self.emissionColor = Color(color)
        }
        // Normal
        if let image = material.normal.contents as? NSImage {
            self.normalImage = image
        } else if let color = material.displacement.contents as? NSColor {
            self.normalColor = Color(color)
        }
    }
}

struct MMNodeView:View {
    
    @State var matType:SubMatType
    
    var body: some View {
        VStack(alignment:.trailing) {
            ZStack {
                Rectangle()
                    .frame(height: 26, alignment: .center)
                    .foregroundColor(.red)
                Text("Material").font(.title2)
            }
            Divider()
            HStack {
                Text("Diffuse")
                Text(matType == .Diffuse ? "●":"○")
            }
            HStack {
                Text("Roughness")
                Text(matType == .Roughness ? "●":"○")
            }
            HStack {
                Text("AO")
                Text(matType == .AO ? "●":"○")
            }
            HStack {
                Text("Emission")
                Text(matType == .Emission ? "●":"○")
            }
            HStack {
                Text("Normal")
                Text(matType == .Normal ? "●":"○")
            }
        }
        .frame(width:120)
        .padding(6)
    }
}

struct MaterialMachineView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialMachineView()
    }
}

struct MMNode_Previews: PreviewProvider {
    static var previews: some View {
        MMMaterialNodeView()
    }
}
