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
                        Text("M \(material.name ?? "untitled")")
                            .onTapGesture {
                                print("tappy")
                                controller.updateGeometryMaterial(material: material)
                            }
                    }
                }
                
                Section(header: Text("DB Materials")){
                    ForEach(controller.dbMaterials) { material in
                        Text("M \(material.name ?? "untitled")")
                            .onTapGesture {
                                print("tappy. Decide what to do with tap")
//                                controller.updateGeometryMaterial(material: material)
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
                        
                        // Geometry Picker
                        Picker("Geo", selection: $controller.geoOption) {
                            ForEach(MMGeometryOption.allCases, id:\.self) { geo in
                                Text(geo.rawValue)
                            }
                        }
                        .frame(width:120)
                        .onChange(of: controller.geoOption) { value in
                            controller.updateNode()
                        }
                        
                        // Load another Geometry
                        Button("Load") {
                            controller.loadPanel()
                        }
                        .help("Loads another geometry from a file")
                        
                        Spacer()
                        
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
                        
                        Button("Save") {
                            controller.saveMaterialToDatabase()
                        }
                    }
                    .frame(height:30)
                    .padding(.horizontal, 8)
                    
                    // Scene
                    SceneView(scene: controller.scene, pointOfView: nil, options: SceneView.Options.allowsCameraControl, preferredFramesPerSecond: 40, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                        .frame(minWidth: 400, maxWidth: .infinity, alignment: .top)
                    
                    Divider()
                }
                .frame(minWidth: 300, maxWidth: 900, maxHeight: .infinity, alignment: .center)
                
                // Nodes
                MMMaterialNodeView(controller: controller, material: $controller.material, matMode: $controller.materialMode)
                    .padding()
                    .onChange(of: controller.material) { value in
                        controller.updateGeometryMaterial(material: value)
                    }
            }
            
            // Right View: UV Map
            if controller.uvImage != nil {
                ZStack {
                    DrawingPadView(image: controller.uvImage!, mode: controller.materialMode) { newImage in
                        controller.updateUVImage(image: newImage)
                    }
                }
            } else {
                Text("No current Image").foregroundColor(.gray).frame(width: 80)
            }
        }
    }
}

struct MaterialMachineView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialMachineView()
            .frame(width:900)
    }
}
