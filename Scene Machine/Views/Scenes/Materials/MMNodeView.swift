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
    
    @State var materialName:String = "Untitled"
    
    @State var diffuseURL:URL?
    @State var diffuseColor:Color = .white
    @State var diffuseImage:NSImage?
    @State var diffuseIntensity:CGFloat = 1
    
    @State var metalnessURL:URL?
    @State var metalnessColor:Color = .white
    @State var metalnessImage:NSImage?
    @State var metalnesseIntensity:CGFloat = 1
    
    @State var roughnessURL:URL?
    @State var roughnessImage:NSImage?
    @State var roughnessIntensity:CGFloat = 1
    @State var roughnessValue:CGFloat = 0.5
    
    @State var occlusionURL:URL?
    @State var occlusionColor:Color = .white
    @State var occlusionImage:NSImage?
    @State var occlusionIntensity:CGFloat = 1
    
    @State var emissionURL:URL?
    @State var emissionColor:Color = .black
    @State var emissionImage:NSImage?
    @State var emissionValue:CGFloat = 0.0
    @State var emissionIntensity:CGFloat = 1
    
    @State var normalURL:URL?
    @State var normalColor:Color = .blue
    @State var normalImage:NSImage?
    @State var normalIntensity:CGFloat = 1
    
    @State var activeLink:Bool = false
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                
                // Material (Left)
                MMNodeView(matType: $matMode, matName: $materialName)
                    .onChange(of: materialName) { newMaterialName in
                        self.material.name = newMaterialName
                    }
                
                // Middle
                VStack {
                    switch matMode {
                        case .Diffuse:
                            Group {
                                HStack {
                                    Text("Diffuse")
                                    Spacer()
                                    ColorPicker("", selection: $diffuseColor)
                                        .onChange(of: diffuseColor, perform: { value in
                                            self.material.diffuse.contents = NSColor(diffuseColor)
                                        })
                                    Button(action: {
                                        print("Create new canvas")
                                        controller.createNewCanvas(mode: controller.materialMode)
                                    }, label: {
                                        Image(systemName: "doc.badge.plus")
                                    })
                                }
                                .frame(width: 180)
                                
                                if let image = diffuseImage {
                                    ZStack(alignment: .top) {
                                        Image(nsImage: image)
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                        
                                        Text("image")
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .Diffuse)
                                            }
                                        })
                                        return true
                                    }
                                    .onChange(of: material.diffuse) { value in
                                        if let img = value.contents as? NSImage {
                                            self.diffuseImage = img
                                        }
                                    }
                                    
                                } else {
                                    ZStack {
                                        // Droppable area
                                        Rectangle().foregroundColor(.gray.opacity(0.15))
                                            .frame(width: 180, height: 180)
                                        Text("[Drop Area]")
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .Diffuse)
                                            }
                                        })
                                        return true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                        case .Roughness:
                            Group {
                                Text("Roughness")
                                if let img = roughnessImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                                if let data = data {
                                                    self.droppedImage(data, type: .Roughness)
                                                }
                                            })
                                            return true
                                        }
                                        .onChange(of: material.roughness) { value in
                                            if let img = value.contents as? NSImage {
                                                self.roughnessImage = img
                                            }
                                        }
                                } else {
                                    // Droppable area
                                    ZStack {
                                        Rectangle().foregroundColor(.gray.opacity(0.15))
                                            .frame(width: 180, height: 180)
                                        if let scalar = material.roughness.contents as? Double {
                                            SliderInputView(value: Float(scalar), vRange: 0...1, title: "Value") { newValue in
                                                self.material.roughness.contents = Double(newValue)
                                                self.roughnessValue = CGFloat(newValue)
                                            }
                                            .frame(width:160)
                                        } else {
                                            VStack {
                                                Text("[Drop Area]")
                                                    .onTapGesture {
                                                        self.material.roughness.contents = roughnessValue
                                                    }
                                            }
                                        }
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .Roughness)
                                            }
                                        })
                                        return true
                                    }
                                    
                                }
                            }
                            
                        case .Emission:
                            Group {
                                
                                HStack {
                                    Text("Emission")
                                    Spacer()
                                    ColorPicker("", selection: $emissionColor)
                                        .onChange(of: emissionColor, perform: { value in
                                            self.material.emission.contents = NSColor(emissionColor)
                                        })
                                }
                                .frame(width: 120)
                                if let img = emissionImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .onChange(of: material.emission) { value in
                                            if let img = value.contents as? NSImage {
                                                self.emissionImage = img
                                            }
                                        }
                                } else if let img = material.emission.contents as? NSImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                                if let data = data {
                                                    self.droppedImage(data, type: .Emission)
                                                }
                                            })
                                            return true
                                        }
                                } else {
                                    // Droppable area
                                    ZStack {
                                        Rectangle().foregroundColor(.gray.opacity(0.15))
                                            .frame(width: 180, height: 180)
                                        VStack {
                                            Text("[Drop Area]")
                                            SliderInputView(value: Float(emissionValue), vRange: 0...1, title: "Value") { newValue in
                                                self.material.emission.contents = Double(newValue)
                                                self.emissionValue = CGFloat(newValue)
                                            }
                                            .frame(width:120)
                                        }
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .Emission)
                                            }
                                        })
                                        return true
                                    }
                                }
                            }
                        case .Normal:
                            Group {
                                Text("Normal")
                                if let img = normalImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                                if let data = data {
                                                    self.droppedImage(data, type: .Normal)
                                                }
                                            })
                                            return true
                                        }
                                        .onChange(of: material.normal) { value in
                                            if let img = value.contents as? NSImage {
                                                self.normalImage = img
                                            }
                                        }
                                } else {
                                    // Droppable area
                                    ZStack {
                                        Rectangle().foregroundColor(.gray.opacity(0.15))
                                            .frame(width: 180, height: 180)
                                        Text("[Drop Area]")
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .Normal)
                                            }
                                        })
                                        return true
                                    }
                                    
                                }
                            }
                        case .AO:
                            VStack {
                                Text("AO")
                                if let img = occlusionImage {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                                    if let dropImage = NSImage(contentsOf: uu) {
                                                        self.material.ambientOcclusion.contents = dropImage
                                                        self.occlusionURL = uu
                                                        self.occlusionImage = NSImage(contentsOf: uu)
                                                    }
                                                }
                                            })
                                            return true
                                        }
                                        .onChange(of: material.ambientOcclusion) { value in
                                            if let img = value.contents as? NSImage {
                                                self.occlusionImage = img
                                            }
                                        }
                                } else {
                                    // Droppable area
                                    ZStack {
                                        Rectangle().foregroundColor(.gray.opacity(0.15))
                                            .frame(width: 180, height: 180)
                                        Text("[Drop Area]")
                                    }
                                    .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                            if let data = data {
                                                self.droppedImage(data, type: .AO)
                                            }
                                        })
                                        return true
                                    }
                                }
                            }
                    }
                    
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear() {
            self.prepareUI()
        }
        .onChange(of: material) { value in
            print("*** material changed")
            self.prepareUI()
        }
    }
    
    func droppedImage(_ data:Data, type:MaterialMode) {
        guard let url = URL(dataRepresentation: data, relativeTo: nil) else {
            print("Could not get url")
            return
        }
        if let img = NSImage(contentsOf: url) {
            controller.uvImage = img
            switch type {
                case .Diffuse:
                    self.material.diffuse.contents = img
                    diffuseURL = url
                    diffuseImage = img
                case .AO:
                    self.material.ambientOcclusion.contents = img
                    occlusionURL = url
                    occlusionImage = img
                case .Roughness:
                    self.material.roughness.contents = img
                    roughnessURL = url
                    roughnessImage = img
                case .Emission:
                    self.material.emission.contents = img
                    emissionURL = url
                    emissionImage = img
                case .Normal:
                    self.material.normal.contents = img
                    normalURL = url
                    normalImage = img
            }
        }
        
    }
    
    func prepareUI() {
        
        self.materialName = material.name ?? "Untitled"
        
        // Diffuse
        if let difImage = material.diffuse.contents as? NSImage {
            print("d: img")
            self.diffuseImage = difImage
        } else if let difString = material.diffuse.contents as? String,
                  let difImage = NSImage(contentsOf: URL(fileURLWithPath: difString)) {
            print("d: str")
            self.diffuseImage = difImage
            self.diffuseURL = URL(fileURLWithPath: difString)
        } else if let difColor = material.diffuse.contents as? NSColor {
            print("d: col")
            self.diffuseColor = Color(difColor)
        } else {
            if let url = material.diffuse.contents as? URL {
                print("d: URL \(url)")
            }
            if let str = material.diffuse.contents as? String {
                print("d: STR \(str)")
            }
            print("d: else")
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
        }
        
        //        else if let color = material.roughness.contents as? NSColor {
        //            self.roughnessColor = Color(color)
        //        }
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

struct MMNodeFXView:View {
    
    // Apply the effect to the material property only.
    // That way, it will only save when the user saves the material.
    // or.....
    // Have an "apply" button, with an image view.
    // if you like the image, apply to the material and change the image
    
    var body: some View {
        VStack {
            Text("Effects")
            // Blur (disk, box)
            // Colorize
            // Contrast
            // Invert Colors
            // Normal shader
        }
    }
}
