//
//  SuzanneSceneView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import SwiftUI
import SceneKit

struct SuzanneSceneView: View {
    
    @State var selectedColor:Color = .red
    
    var subColor:NSColor = SubMaterialData(spectrum: 1, sColor: ColorData(r: 1, g: 0.1, b: 0.1, a: 1)).specColor!.makeNSColor()
    
    @State var scene = SCNScene(named: "Scenes.scnassets/monkey.scn")!
    @State private var roughness:Float = 0.6
    @State private var materials:[SCNMaterial] = []
    
    var body: some View {
        HStack {
            VStack {
                Group {
                    Text("Materials")
                    ForEach(materials, id:\.name!) { material in
                        Text("\(material.name ?? "na")")
                    }
                    if materials.isEmpty {
                        Text("No materials").foregroundColor(.gray)
                    }
                }
                
                Group {
                    Text("Setup")
                    
                    HStack {
                        ColorPicker("Selected Color", selection: $selectedColor)
                    }
                    Rectangle()
                        .foregroundColor(Color(subColor))
                        .frame(maxWidth:150, maxHeight:50)
                    
                    Text("Roughness")
                    Slider(value: $roughness, in: 0...1)
                        .frame(width:130)
                }
                .padding(.top, 8)
                
                
                Button("Update") {
                    print("Change Color")
                    self.didChangeColor()
                }
            }
            .frame(minWidth:150)
//            ScenekitView()
            SceneView(scene: self.scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
        }
    }
    
    func didChangeColor() {
        
        if let mokey = scene.rootNode.childNodes.first {
            
            // Previous
            let m = SCNMaterial()
            m.name = "Skin"
            m.lightingModel = .physicallyBased
            m.roughness.contents = self.roughness
            m.diffuse.contents = NSColor(self.selectedColor)
            
            // New
            let newMat = SceneMaterial()
            let diffColor = ColorData(suiColor: self.selectedColor) //buildObject(color: NSColor(self.selectedColor))
            let diffData = SubMaterialData(spectrum: 0, sColor: diffColor)
            newMat.diffuse = diffData
            
            //let skin = newMat.make() //SceneMaterial.skinExample()
            let mat:SCNMaterial = newMat.make()
            
            if let mColor = mat.diffuse.contents as? Color {
                print("** MCOLOR \(mColor.description)")
            } else if let sColor = mat.diffuse.contents as? NSColor {
                print("** SCOLOR \(sColor.description)")
            } else {
                print("** NOCOLOR \(mat.diffuse.contents.debugDescription)")
            }
            
            mat.name = "Skin2"
            print("New: \(mat)")
            
            mokey.geometry!.insertMaterial(mat, at: 0)
            
            let ball = SCNSphere(radius: 1.0)
            ball.materials = [m]
            
            let ballNode = SCNNode(geometry: ball)
            ballNode.position.z = 5
            scene.rootNode.addChildNode(ballNode)
            
            // Current Materials
            if let monkeyMaterials:[SCNMaterial] = mokey.geometry?.materials {
                self.materials = monkeyMaterials
            }
            
            // Debug
            let parts = mokey.geometry?.sources.description
            print("Parts: \(parts ?? "none")")
        } else {
            print("No monkey was found in scene")
        }
            
    }
}

struct SuzanneSceneView_Previews: PreviewProvider {
    static var previews: some View {
        SuzanneSceneView()
    }
}
