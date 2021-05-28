//
//  MMNodeView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/26/21.
//

import SwiftUI
import SceneKit
import Cocoa
import Foundation

struct MMMaterialNodeView:View {
    
    @ObservedObject var controller:MaterialMachineController
    @Binding var material:SCNMaterial // = SCNMaterial.example
    @Binding var matMode:MaterialMode // = .Diffuse
    @State var currentImage:NSImage?
    
    @State var materialName:String = "Untitled"
    
    @State var activeLink:Bool = false
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                
                // Material (Left)
                MMNodeView(matType: $matMode, matName: $materialName)
                    .onChange(of: materialName) { newMaterialName in
                        self.material.name = newMaterialName
                    }
                
                Divider()
                    .frame(height:200)
                
                // Middle
                VStack {
                    MMModeView(controller: controller)
                }
                .padding()
                
                Divider()
                    .frame(height:200)
                
                // Right
                MMNodeFXView(controller: controller, original: imageForMode(mode: self.matMode), effectImage: nil)
                
                Spacer()
            }
        }
    }
    
    func imageForMode(mode:MaterialMode) -> NSImage? {
        switch mode {
            case .Diffuse:
                return material.diffuse.contents as? NSImage
            case .AO:
                return material.ambientOcclusion.contents as? NSImage
            case .Roughness:
                return material.roughness.contents as? NSImage
            case .Emission:
                return material.emission.contents as? NSImage
            case .Normal:
                return material.normal.contents as? NSImage
        }
    }
    
}

struct MMNodeView:View {
    
    @Binding var matType:MaterialMode
    @Binding var matName:String
    
    var body: some View {
        VStack(alignment:.trailing) {
            ZStack {
                Rectangle()
                    .frame(height: 26, alignment: .center)
                    .foregroundColor(.red)
                Text("Material").font(.title2)
            }
            TextField("", text: $matName)
            Divider()
            HStack {
                Text("Diffuse")
                Spacer()
                Text(matType == .Diffuse ? "●":"○")
            }
            .background(matType == .Diffuse ? Color.orange.opacity(0.15):Color.clear)
            .cornerRadius(4, antialiased: true)
            .onTapGesture {
                matType = .Diffuse
            }
            
            HStack {
                Text("Roughness")
                Spacer()
                Text(matType == .Roughness ? "●":"○")
            }
            .background(matType == .Roughness ? Color.orange.opacity(0.15):Color.clear)
            .cornerRadius(4, antialiased: true)
            .onTapGesture {
                matType = .Roughness
            }
            
            HStack {
                Text("AO")
                Spacer()
                Text(matType == .AO ? "●":"○")
            }
            .background(matType == .AO ? Color.orange.opacity(0.15):Color.clear)
            .cornerRadius(4, antialiased: true)
            .help("Ambient Occlusion")
            .onTapGesture {
                matType = .AO
            }
            
            HStack {
                Text("Emission")
                Spacer()
                Text(matType == .Emission ? "●":"○")
            }
            .background(matType == .Emission ? Color.orange.opacity(0.15):Color.clear)
            .cornerRadius(4, antialiased: true)
            .onTapGesture {
                matType = .Emission
            }
            
            HStack {
                Text("Normal")
                Spacer()
                Text(matType == .Normal ? "●":"○")
            }
            .background(matType == .Normal ? Color.orange.opacity(0.15):Color.clear)
            .cornerRadius(4, antialiased: true)
            .onTapGesture {
                matType = .Normal
            }
        }
        .frame(width:120)
        .padding(6)
    }
}


struct MMNode_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            MMNodeView(matType: .constant(.Diffuse), matName: .constant("Material")).padding()
            Divider().frame(height:200)
            MMModeView(controller: MaterialMachineController()).padding()
            Divider().frame(height:200)
            MMNodeFXView(controller: MaterialMachineController(), original: nil, effectImage: nil)
                .padding()
        }
    }
}
