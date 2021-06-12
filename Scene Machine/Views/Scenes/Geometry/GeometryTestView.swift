//
//  GeometryTestView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/12/21.
//

import SwiftUI
import SceneKit

struct GeometryTestView: View {
    
    @State var scene:SCNScene = SCNScene()
    @State var geoinfo:String = ""
    
    struct MYVertex {
        var x:Float, y:Float, z:Float    // position
        var nx:Float, ny:Float, nz:Float; // normal
        var s:Float, t:Float;       // texture coordinates
    }
    
    var body: some View {
        VStack {
            Text("Geometry")
            
            HSplitView {
                SceneView(scene: scene, pointOfView: nil, options: [.allowsCameraControl], preferredFramesPerSecond: 30, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
                VStack {
                    Text("Geometry Info")
                    Spacer()
                    ScrollView {
                        Text(geoinfo)
                    }
                }
                .frame(width:300)
                
            }
            
        }
        .onAppear() {
            makeGeometry()
        }
    }
    
    
    func makeGeometry() {
        var vertices:[SCNVector3] = []
        for z in 0...1 {
            for y in 0...1 {
                for x in 0...1 {
                    let v1 = SCNVector3(x, y, z)
                    vertices.append(v1)
                }
            }
        }
        
        let gSource = SCNGeometrySource(vertices: vertices)
        let geo = SCNGeometry(sources: [gSource], elements: nil)
        
        
        
        geo.materials = [SCNMaterial.example]
        geo.firstMaterial?.fillMode = .lines
        
        let node = SCNNode(geometry: geo)
        
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        box.firstMaterial = SCNMaterial.example
        let node2 = SCNNode(geometry: box)
        node2.position.x = 2
        
        var gds:String = ""
        
        for gSource in box.sources {
            if gSource.semantic == .vertex {
                let verts = gSource.vertices
                for v in verts {
                    gds += "\n\(v.toString())"
                }
            }
        }
        
        self.geoinfo = gds
        
        scene.rootNode.addChildNode(node)
        scene.rootNode.addChildNode(node2)
    }
    
    
}

struct GeometryTestView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryTestView()
    }
}
