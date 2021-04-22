//
//  SceneView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import SwiftUI
import SceneKit
import SpriteKit

struct SceneAView: View {
    var scene = SCNScene(named: "Scenes.scnassets/SpaceStation.scn")
    
    var cameraNode: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    var body: some View {
        ScenekitView()
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneAView()
    }
}

struct ScenekitView : NSViewRepresentable {
    
//    let scene = SCNScene(named: "Scenes.scnassets/SpaceStation.scn")!
    let scene = SCNScene(named: "Scenes.scnassets/monkey.scn")!

    func makeNSView(context: Context) -> SCNView {
        
        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        if let mokey = scene.rootNode.childNodes.first {
            let m = SCNMaterial()
            m.lightingModel = .physicallyBased
            m.roughness.contents = 0.6
            m.diffuse.contents = NSColor.red
            mokey.geometry?.insertMaterial(m, at: 0)
            
            // Debug
            let parts = mokey.geometry?.sources.description
            print("Parts: \(parts ?? "none")")
            
            // REVEALAGE
            /*
            let material = mokey.geometry!.materials.first!
            let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 256, height: 256), grayscale: true)
            material.setValue(SCNMaterialProperty(contents: texture), forKey: "noiseTexture")
            
            let modifierURL = Bundle.main.url(forResource: "dissolve.fragment", withExtension: "txt")!
            let modifierString = try! String(contentsOf: modifierURL)
            material.shaderModifiers = [
                SCNShaderModifierEntryPoint.fragment : modifierString
            ]
            
            let revealAnimation = CABasicAnimation(keyPath: "revealage")
            revealAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            revealAnimation.duration = 8
            revealAnimation.fromValue = 0.1
            revealAnimation.toValue = 1.0
            revealAnimation.isRemovedOnCompletion = true
            revealAnimation.autoreverses = true
            let scnRevealAnimation = SCNAnimation(caAnimation: revealAnimation)
            
            material.addAnimation(scnRevealAnimation, forKey: "Reveal")
            */
        }
        
        
        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.scene = scene
        
        // allows the user to manipulate the camera
        nsView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        nsView.showsStatistics = true
        
        // configure the view
        nsView.backgroundColor = NSColor.black
    }
}
