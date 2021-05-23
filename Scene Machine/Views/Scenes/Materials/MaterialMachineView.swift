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
//    @State var material:SCNMaterial = SCNMaterial.example
    
    init() {
        drawController = DrawingPadController()
    }
    
    var body: some View {
        NavigationView {
            
            // Left
            List() {
//                Text("Materials")
                Section(header: Text("Materials")){
                    ForEach(controller.materials) { material in
                        Text("M \(material.name ?? "untitled")")
                            .onTapGesture {
                                print("tappy")
                                controller.updateGeometryMaterial(material: material)
                            }
                    }
                }
                // My materials
                // Library
                // Images?
            }
            .frame(minWidth: 0, maxWidth: 200, maxHeight: .infinity, alignment: .center)
            
            // Middle
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
                        .frame(width:150)
                        .onChange(of: controller.geoOption) { value in
                            controller.updateNode()
                        }
                        
                        // Background Picker
                        Picker("Back", selection:$controller.sceneBackground) {
                            ForEach(AppBackgrounds.allCases, id:\.self) { back in
                                Text(back.rawValue)
                            }
                        }
                        .frame(width:150)
                        .onChange(of: controller.sceneBackground) { value in
                            controller.changeBackground()
                        }
                        
//                        ColorPicker("Color", selection: $controller.baseColor)
//                            .onChange(of: controller.baseColor) { value in
//                                controller.changedColor()
//                            }
                        Button("Load") {
                            controller.loadPanel()
                        }
                    }
                    .frame(height:30)
                    
                    // Scene
                    SceneView(scene: controller.scene, pointOfView: nil, options: SceneView.Options.allowsCameraControl, preferredFramesPerSecond: 40, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                        .frame(minWidth: 400, maxWidth: .infinity, alignment: .top)
                    
                    Divider()
                }
                .frame(minWidth: 300, maxWidth: 900, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                // Nodes
                MMMaterialNodeView(material: $controller.material)
                    .padding()
                    .onChange(of: controller.material, perform: { value in
                        controller.updateGeometryMaterial(material: value)
                    })
            }
            
            DrawingPadView()
            // Right
            // UV + Paint + color
        }
    }
}
enum SubMatType:String, CaseIterable {
    case Diffuse, Roughness, Emission, Normal, AO
}

struct MMMaterialNodeView:View {
    
    @Binding var material:SCNMaterial // = SCNMaterial.example
    
    @State var diffuseURL:URL?
    @State var diffuseColor:Color = .white
    @State var diffuseImage:NSImage?
    @State var diffuseIntensity:CGFloat = 1
    
    @State var metalnessURL:URL?
    @State var metalnessColor:Color = .white
    @State var metalnessImage:NSImage?
    @State var metalnesseIntensity:CGFloat = 1
    
    @State var roughnessURL:URL?
//    @State var roughnessColor:Color = .white
    @State var roughnessImage:NSImage?
    @State var roughnessIntensity:CGFloat = 1
    @State var roughnessValue:CGFloat = 0.5
    
    @State var occlusionURL:URL?
    @State var occlusionColor:Color = .white
    @State var occlusionImage:NSImage?
    @State var occlusionIntensity:CGFloat = 1
    
    @State var emissionURL:URL?
    @State var emissionColor:Color = .white
    @State var emissionImage:NSImage?
    @State var emissionValue:CGFloat = 0.0
    @State var emissionIntensity:CGFloat = 1
    
    @State var normalURL:URL?
    @State var normalColor:Color = .white
    @State var normalImage:NSImage?
    @State var normalIntensity:CGFloat = 1
    
    @State var activeLink:Bool = false
    
    @State var matType:SubMatType = .Diffuse
    
    var body: some View {
        VStack {
            HStack(spacing:12) {
                MMNodeView(matType: $matType)
                
                VStack {
                    switch matType {
                        case .Diffuse:
                            Group {
                                HStack {
                                    Text("Diffuse")
                                    Spacer()
                                    ColorPicker("", selection: $diffuseColor)
                                        .onChange(of: diffuseColor, perform: { value in
                                            self.material.diffuse.contents = NSColor(diffuseColor)
                                        })
                                }
                                .frame(width: 120)
                                
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
//            self.material = value
            self.prepareUI()
        }
    }
    
    func droppedImage(_ data:Data, type:SubMatType) {
        guard let url = URL(dataRepresentation: data, relativeTo: nil) else {
            print("Could not get url")
            return
        }
        if let img = NSImage(contentsOf: url) {
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
        // Diffuse
        if let difString = material.diffuse.contents as? String,
           let difImage = NSImage(contentsOf: URL(fileURLWithPath: difString)) {
            self.diffuseImage = difImage
            self.diffuseURL = URL(fileURLWithPath: difString)
        }
        if let difImage = material.diffuse.contents as? NSImage {
            self.diffuseImage = difImage
        } else if let difColor = material.diffuse.contents as? NSColor {
            self.diffuseColor = Color(difColor)
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
    
    @Binding var matType:SubMatType
    
    var body: some View {
        VStack(alignment:.trailing) {
            ZStack {
                Rectangle()
                    .frame(height: 26, alignment: .center)
                    .foregroundColor(.red)
                Text("Material").font(.title2)
            }
            Divider()
            HStack {
                Text("Diffuse")
                Text(matType == .Diffuse ? "●":"○")
            }
            .onTapGesture {
                matType = .Diffuse
            }
            HStack {
                Text("Roughness")
                Text(matType == .Roughness ? "●":"○")
            }
            .onTapGesture {
                matType = .Roughness
            }
            HStack {
                Text("AO")
                Text(matType == .AO ? "●":"○")
            }
            .onTapGesture {
                matType = .AO
            }
            HStack {
                Text("Emission")
                Text(matType == .Emission ? "●":"○")
            }
            .onTapGesture {
                matType = .Emission
            }
            HStack {
                Text("Normal")
                Text(matType == .Normal ? "●":"○")
            }
            .onTapGesture {
                matType = .Normal
            }
        }
        .frame(width:120)
        .padding(6)
    }
}

struct MaterialMachineView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialMachineView()
            .frame(width:900)
    }
}

//struct MMNode_Previews: PreviewProvider {
//    static var previews: some View {
//        MMMaterialNodeView(material: SCNMaterial.example)
//    }
//}
