//
//  SMUVMapView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/25/21.
//

import SwiftUI
import SceneKit

/** A View that displays a UVMap of a geometry */
struct SMUVMapView: View {
    
    var geometry:SCNGeometry
    var points:[CGPoint]
    @State var image:NSImage?
    
    var saveImgCallback:((NSImage) -> Void) = {_ in }
    
    @State var imgSize:CGSize = TextureSize.medium.size
    @State var showUVEdges:Bool = true
    @State var materialMode:MaterialMode = .Diffuse
    
    init(geometry:SCNGeometry, showEdges:Bool = true, callBack:@escaping ((NSImage) -> Void)) {
        
        // Geometry
        self.geometry = geometry
        self.showUVEdges = showEdges
        
        // Points
        if let textureMap = geometry.sources.first(where: { $0.semantic == .texcoord }) {
            self.points = textureMap.uv
        } else {
            self.points = []
        }
        
        // Image
        if let img = geometry.materials.first?.diffuse.contents as? NSImage {
            self.image = img
        } else if let path = geometry.materials.first?.diffuse.contents as? String,
                  let img = NSImage(byReferencingFile: path) {
            self.image = img
        } else if let url = geometry.materials.first?.diffuse.contents as? URL,
                  let img = NSImage(contentsOf: url) {
            self.image = img
        }
        
        // Callback
        self.saveImgCallback = callBack
    }
    
    var body: some View {
        VStack {
            
            // Toolbar
            HStack {
                Text("UVMap")
                
                Button("Load Image") {
                    print("Load an image")
                }
                
                Picker(selection: $materialMode, label: Text("Material")){
                    ForEach(MaterialMode.allCases, id:\.self) { mmode in
                        Text(mmode.rawValue)
                    }
                }
                .frame(width:180)
                
                Toggle("Edges", isOn: $showUVEdges)
                
                Spacer()
                
                Button("💾 Save") {
                    
                    if let image = uvTexture.snapShot(uvSize: CGSize(width: imgSize.width, height: imgSize.height)) {
//                        controller.saveUVMap(image: image)
                        self.saveImgCallback(image)
                    }
                }
            }
            
            ZStack {
                
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
                }
                
                if showUVEdges == true {
                    UVShape(uv:points)
                        .stroke(lineWidth: 0.5)
                        .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                        .background(Color.gray.opacity(0.1))
                        .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
                }
                
            }
            .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
        }
    }
    
    /// The texture drawn, without additional views, for `snapshot`
    var uvTexture: some View {
        ZStack {
            
            // Background Image
            Image(nsImage: image ?? NSImage(size: imgSize))
                .resizable()
                .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
            
            // Countours
            UVShape(uv:points)
                .stroke(lineWidth: 0.5)
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .background(Color.gray.opacity(0.1))
                .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
            
        }
        .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
    }
    
    func didChangeMaterialMode() {
        switch materialMode {
            case .Diffuse:
                // Image
                if let img = geometry.materials.first?.diffuse.contents as? NSImage {
                    self.image = img
                } else if let path = geometry.materials.first?.diffuse.contents as? String,
                          let img = NSImage(byReferencingFile: path) {
                    self.image = img
                } else if let url = geometry.materials.first?.diffuse.contents as? URL,
                          let img = NSImage(contentsOf: url) {
                    self.image = img
                }
            case .Roughness:
                if let img = geometry.materials.first?.roughness.contents as? NSImage {
                    self.image = img
                } else if let path = geometry.materials.first?.roughness.contents as? String,
                          let img = NSImage(byReferencingFile: path) {
                    self.image = img
                } else if let url = geometry.materials.first?.roughness.contents as? URL,
                          let img = NSImage(contentsOf: url) {
                    self.image = img
                }
            case .Normal:
                if let img = geometry.materials.first?.normal.contents as? NSImage {
                    self.image = img
                } else if let path = geometry.materials.first?.normal.contents as? String,
                          let img = NSImage(byReferencingFile: path) {
                    self.image = img
                } else if let url = geometry.materials.first?.normal.contents as? URL,
                          let img = NSImage(contentsOf: url) {
                    self.image = img
                }
            case .AO:
                if let img = geometry.materials.first?.ambientOcclusion.contents as? NSImage {
                    self.image = img
                } else if let path = geometry.materials.first?.ambientOcclusion.contents as? String,
                          let img = NSImage(byReferencingFile: path) {
                    self.image = img
                } else if let url = geometry.materials.first?.ambientOcclusion.contents as? URL,
                          let img = NSImage(contentsOf: url) {
                    self.image = img
                }
            case .Emission:
                if let img = geometry.materials.first?.emission.contents as? NSImage {
                    self.image = img
                } else if let path = geometry.materials.first?.emission.contents as? String,
                          let img = NSImage(byReferencingFile: path) {
                    self.image = img
                } else if let url = geometry.materials.first?.emission.contents as? URL,
                          let img = NSImage(contentsOf: url) {
                    self.image = img
                }
        }
    }
}

//struct SMUVMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        SMUVMapView()
//    }
//}
