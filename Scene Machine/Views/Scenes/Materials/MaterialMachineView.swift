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
    @ObservedObject var drawController:DrawingPadController
    
    init() {
        drawController = DrawingPadController()
    }
    
    var body: some View {
        NavigationView {
            
            // Left
            List() {
                Section(header: Text("Materials")){
                    ForEach(controller.materials) { material in
                        Text("\(material.name ?? "untitled")")
                            .onTapGesture {
                                print("tappy")
                                controller.updateGeometryMaterial(material: material)
                            }
                    }
                }
                
                Section(header: Text("DB Materials")){
                    ForEach(controller.dbMaterials) { material in
                        Text("\(material.name ?? "untitled")")
                            .onTapGesture {
                                controller.didSelectDBMaterial(dbMaterial: material)
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Delete") {
                                    controller.dbMaterials.removeAll(where: { $0.id == material.id })
                                    material.delete()
                                }
                            }))
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: 200, maxHeight: .infinity, alignment: .center)
            
            // Middle - Scene and Nodes
            VSplitView {
                VStack {
                    
                    // Tools
                    HStack {
                        
                        // Load another Geometry
                        Button(action: {
                            controller.loadPanel()
                        }, label: {
                            Image(systemName: "square.and.arrow.down.fill")
                        })
                        .help("Load geometry from file")
                        
                        // Save
                        Button("💾") {
                            controller.saveMaterialToDatabase()
                        }
                        .help("saves the material")
                        
                        Spacer()
                        
                        // Geometry Picker
                        Picker("Geometry", selection: $controller.geoOption) {
                            ForEach(MMGeometryOption.allCases, id:\.self) { geo in
                                Text(geo.rawValue)
                            }
                        }
                        .frame(width:160)
                        .onChange(of: controller.geoOption) { value in
                            controller.updateNode()
                        }
                        
                        // Background Picker
                        Picker("Back", selection:$controller.sceneBackground) {
                            ForEach(AppBackgrounds.allCases, id:\.self) { back in
                                Text(back.rawValue)
                            }
                        }
                        .frame(width:120)
                        .onChange(of: controller.sceneBackground) { value in
                            controller.changeBackground()
                        }
                    }
                    .frame(height:30)
                    .padding(.horizontal, 8)
                    .background(Color.black.opacity(0.25))
                    
                    // Scene
                    SceneView(scene: controller.scene, pointOfView: nil, options: SceneView.Options.allowsCameraControl, preferredFramesPerSecond: 40, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                        .frame(minWidth: 400, maxWidth: .infinity, alignment: .top)
                    
                    Divider()
                }
                .frame(minWidth: 400)
                
                // Nodes
                ScrollView(.horizontal, showsIndicators: true) {
                    
                    MMMaterialNodeView(controller: controller, material: $controller.material, matMode: $controller.materialMode)
                        .padding()
                        .onChange(of: controller.material) { value in
                            controller.updateGeometryMaterial(material: value)
                        }
                }
            }
            .frame(minWidth: 400, maxWidth: .infinity)
            
            // Right View: UV Map
            if controller.uvImage != nil {
                ZStack {
                    DrawingPadView(image: controller.uvImage!, mode: controller.materialMode) { newImage in
                        controller.updateUVImage(image: newImage)
                    }
                }
            } else {
                Text("No current Image").foregroundColor(.gray)
                .frame(maxWidth:200)
            }
        }
    }
}

struct MaterialMachineView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialMachineView()
            .frame(width:900, height:600)
    }
}
