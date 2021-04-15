//
//  SceneProgramView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

import SwiftUI
import SceneKit

struct SceneProgramView: View {
    
    @State var scene:SCNScene = buildScene()
    
    var body: some View {
        SceneView(scene: scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
            
    }
    
    static func buildScene() -> SCNScene {
        let scene = SCNScene()
        
        let plane = SCNPlane(width: 5, height: 5)
        plane.heightSegmentCount = 50
        plane.widthSegmentCount = 50
        
        let node = SCNNode(geometry: plane)
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = NSColor.red
        
        let noise = NSImage(named: "Example")
        material.displacement.contents = noise
        node.geometry?.insertMaterial(material, at: 0)
        
        // Program
//        let program = SCNProgram()
//        program.vertexFunctionName = "shipVertex" // "myVertex"
//        program.fragmentFunctionName = "shipFragment" //"myFragment"
//        material.program = program
//
//        let uv = SCNMaterialProperty(contents: noise!)
//        material.setValue(uv, forKey: "baseColorTexture")
        
        
        let sky = MDLSkyCubeTexture(name: "sky",
                          channelEncoding: .float16,
                          textureDimensions: vector_int2(128, 128),
                          turbidity: 0,
                          sunElevation: 1.5,
                          upperAtmosphereScattering: 0.5,
                          groundAlbedo: 0.5)
        
        scene.background.contents = sky
        scene.lightingEnvironment.contents = sky
        
        scene.rootNode.addChildNode(node)
        return scene
    }
}

struct SceneProgramView_Previews: PreviewProvider {
    static var previews: some View {
        SceneProgramView()
    }
}
