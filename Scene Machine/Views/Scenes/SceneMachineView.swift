//
//  SceneMachineView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/27/21.
//

import SwiftUI
import SceneKit

/// Additional Geometries offered by the App
enum AppGeometries:String, CaseIterable {
    case Suzanne
    case Woman
    case Prototype
    
    func getGeometry() -> SCNNode? {
//        var scene:SCNScene!
        var node:SCNNode?
        switch self {
            case .Suzanne:
                let scene = SCNScene(named: "Scenes.scnassets/monkey.scn")
                node = scene?.rootNode.childNode(withName: "Suzanne", recursively: false)?.clone()
            case .Woman:
                let scene = SCNScene(named: "Scenes.scnassets/Woman.scn")
                node = scene?.rootNode.childNode(withName: "Body_M_GeoRndr", recursively: false)?.clone()
            case .Prototype:
                let scene = SCNScene(named: "Scenes.scnassets/PrototypeCar.scn")
                node = scene?.rootNode.childNode(withName: "CarBody", recursively: false)?.clone()
        }
        return node
    }
}

enum AppBackgrounds: String, CaseIterable {
    case Lava1
    case Lava2
    case SMB1
    case SMB2
    case SMB3
    
    var content:String {
        switch self {
            case .Lava1: return "LavaWorldBlur.hdr"
            case .Lava2: return "LavaWorldBlur2.hdr"
            case .SMB1: return "SMB_1.hdr"
            case .SMB2: return "SMB_2.hdr"
            case .SMB3: return "SMB_3.hdr"
        }
    }
}

struct SceneMachineView: View {
    
    @ObservedObject var controller = SceneMachineController()
    @State private var selectedGeometry:SCNGeometry?
    @State private var selectedMaterial:SCNMaterial?
    
    @State private var displayUVMap:Bool = false
    @State private var popGeoImport:Bool = false
    @State private var popBackground:Bool = false
    
    // Additional Objects:
    // Monkey
    // Woman
    // Prototype
    // Walls?
    
    // Background Images
    // Procedural Sky
    // Some Blender
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    // Geometries
                    HStack {
                        Image(systemName: "pyramid.fill")
                        Text("Geometries")
                        Spacer()
                    }
                    .font(.title2)
                    .foregroundColor(.orange)
                    
                    ForEach(controller.geometries) { geometry in
                        SMGeometryRow(geometry: geometry, isSelected: selectedGeometry == geometry)
                            .onTapGesture {
                                if selectedGeometry == geometry {
                                    selectedGeometry = nil
                                } else {
                                    self.selectedGeometry = geometry
                                }
                            }
                    }
                    Divider()
                    
                    // Materials
                    HStack {
                        Image(systemName: "shield.checkerboard")
                        Text("Materials")
                        Spacer()
                    }
                    .font(.title2)
                    .foregroundColor(.orange)
                    
                    ForEach(controller.materials) { material in
                        HStack {
                            Image(systemName: "shield.checkerboard")
                            Text("\(material.name ?? "untitled")")
                            Spacer()
                        }
                        .onTapGesture {
                            self.selectedMaterial = material
                        }
                    }
                    if let material = selectedMaterial {
                        MaterialView(material: material)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 6)
            }
            
            
            // Middle - Scene
            VStack {
                HStack {
                    
                    Button("+ Geometry") {
                        popGeoImport.toggle()
                    }
                    .popover(isPresented: $popGeoImport) {
                        VStack {
                            ForEach(AppGeometries.allCases, id:\.self) { appGeo in
                                HStack {
                                    Text(appGeo.rawValue)
                                    Spacer()
                                    Button("Add") {
                                        controller.addAppGeometry(geo: appGeo)
                                    }
                                }
                                .frame(width:200)
                            }
                        }
                    }
                    Button("Load") {
                        print("load")
                        controller.loadPanel()
                    }
                    Button("Save") {
                        print("save")
                        controller.saveScene()
                    }
                    Spacer()
                    
                    Button("Program") {
                        controller.addProgram()
                        
                    }
                    Toggle("UVMap", isOn: $displayUVMap)
                        .onChange(of: displayUVMap, perform: { value in
                            if value == true { controller.rightView = .UVMap } else { controller.rightView = .Empty }
                        })
                    Button("+ Back") {
                        popBackground.toggle()
                    }
                    .popover(isPresented: $popBackground) {
                        VStack {
                            ForEach(AppBackgrounds.allCases, id:\.self) { appBack in
                                HStack {
                                    Text(appBack.rawValue)
                                    Spacer()
                                    Button("Change") {
                                        controller.changeBackground(back: appBack)
                                    }
                                }
                                .frame(width:200)
                            }
                        }
                    }
                }
                .padding([.top, .leading, .trailing], 8)
                
                
                HSplitView {
                    SceneView(scene: controller.scene, pointOfView: nil, options: [.allowsCameraControl, .autoenablesDefaultLighting], preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                        .frame(minWidth: 300, alignment: .trailing)
                    
                    if displayUVMap {
                        if let geometry = selectedGeometry,
                           let uvMap = controller.inspectUVMap(geometry: geometry) {
                            ScrollView([.vertical, .horizontal], showsIndicators:true) {
                                HStack {
                                    ZStack {
                                        
                                        
                                        UVShape(uv:uvMap)
                                            .stroke(lineWidth: 0.5)
                                            .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                                            .background(Color.gray.opacity(0.1))
                                            .frame(width: 1024, height: 1024, alignment: .center)
                                        
//                                        if let m = geometry.materials.first?.diffuse.contents as? String {
                                            //                                           let img = NSImage(byReferencingFile: m) { //diffuse.contents as? NSImage {
                                            Image("Scenes.scnassets/UVMaps/WomanDiffuse.png")
                                                .resizable()
                                                .frame(width: 1024, height: 1024, alignment: .center)
//                                        }
                                    }
                                    
                                }
                                .padding(30)
                            }
                            .frame(minWidth: 300, alignment: .trailing)
                        }
                    }
                }
                
            }
            .frame(minWidth: 600, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct SMGeometryRow: View {
    
    var geometry:SCNGeometry
    var isSelected:Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "pyramid")
                Text("\(geometry.name ?? "< untitled >")")
                Spacer()
                Text("● \(geometry.sources.compactMap({ $0.vectorCount }).reduce(0, +))")
            }
            HStack {
                Text("Elements: \(geometry.elementCount)")
                Text("Materials: \(geometry.materials.count)")
            }
        }
        .background(isSelected ? Color.black:Color.clear)
        .padding(4)
        .frame(width:200)
    }
}

struct SceneMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SceneMachineView()
    }
}
