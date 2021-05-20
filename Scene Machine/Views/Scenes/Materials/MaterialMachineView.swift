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
            }
            
            // Middle
            VStack {
                HStack {
                    
                    // Geometry Picker
                    Picker("Geometry", selection: $controller.geoOption) {
                        ForEach(MMGeometryOption.allCases, id:\.self) { geo in
                            Text(geo.rawValue)
                        }
                    }
                    .frame(width:150)
                    .onChange(of: controller.geoOption) { value in
                        controller.updateNode()
                    }
                    
                    // Background Picker
                    Picker("Background", selection:$controller.sceneBackground) {
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
                
                
                SceneView(scene: controller.scene, pointOfView: nil, options: SceneView.Options.allowsCameraControl, preferredFramesPerSecond: 40, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
            }
            
            // Right
            // UV + Paint + color
        }
    }
}

struct MaterialMachineView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialMachineView()
    }
}
