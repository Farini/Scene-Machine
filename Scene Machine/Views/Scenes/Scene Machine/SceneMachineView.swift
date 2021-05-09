//
//  SceneMachineView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/27/21.
//

import SwiftUI
import SceneKit

struct SceneMachineView: View {
    
    @ObservedObject var controller = SceneMachineController()
//    @State private var selectedGeometry:SCNGeometry?
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
            
            // Geometries + Materials
            ScrollView {
                VStack {
                    
                    // Node
                    HStack {
                        Text("●")
                        Text("Nodes")
                        Spacer()
                    }
                    .font(.title2)
                    .foregroundColor(.orange)
                    
                    ForEach(controller.scene.rootNode.childNodes, id:\.self) { node in
                        SMNodeRow(controller: controller, node: node)
                            .padding(.vertical, 4)
                            .contextMenu {
                                if node.geometry != nil {
                                    Button("Delete") {
                                        controller.removeGeometry(geo: node.geometry!)
                                    }
                                }
                                Button("Hide/Unhide") {
                                    node.isHidden.toggle()
                                }
                                Button("Pause/Unpause") {
                                    node.isPaused.toggle()
                                }
                            }
                            .onTapGesture {
                                controller.selectedNode = node
                            }
                    }
                    
                    // Geometries
                    HStack {
                        Image(systemName: "pyramid.fill")
                        Text("Geometries")
                        Spacer()
                    }
                    .font(.title2)
                    .foregroundColor(.orange)
                    
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
//                        MaterialView(material: material)
                        SMMaterialView(material: material)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 6)
            }
            
            // Middle - Scene
            VStack {
                
                // Top Toolbar
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
                    
                    if let theNode = controller.selectedNode {
                        Button("\(theNode.name ?? "Node")") {
                            controller.isNodeOptionSelected.toggle()
                        }
                        .popover(isPresented: $controller.isNodeOptionSelected) {
                            VStack {
                                Text("\(theNode.name ?? "Node")")
                                NodeXYZInput(node: theNode)
                            }
                            .padding(8)
                            .frame(minWidth:300)
                            
                            VStack {
                                Text("\(theNode.name ?? "Node")")
                                SceneView(scene: self.sceneWithWired(node: theNode.clone()), pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 30, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
                                    .frame(width: 300, height: 300, alignment: .center)
                            }
                            .padding(8)
                            .frame(minWidth:300)
                        }
//                        Button("\(theNode.name ?? "Geom")") {
//                            controller.isNodeOptionSelected.toggle()
//                        }
//                        .popover(isPresented: $controller.isNodeOptionSelected) {
//
//                        }
                    }
                    
                    Button("Program") {
                        controller.addProgram()
                    }
                    .help("Adds a glowing box, created in Metal")
                    
                    Toggle("UVMap", isOn: $displayUVMap)
                        .onChange(of: displayUVMap, perform: { value in
                            if value == true { controller.rightView = .UVMap } else { controller.rightView = .Empty }
                        })
                    Button("Save UV") {
                        
                        print("saving UVMap")
                        if let image = uvView.snapShot(uvSize: CGSize(width: 1024, height: 1024)) {
                            controller.saveUVMap(image: image)
                        } else {
                            // Display an error message
                        }
                    }
                    .disabled(controller.selectedNode?.geometry == nil)
                    
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
                    // Scene
                    SceneView(scene: controller.scene, pointOfView: nil, options: [.allowsCameraControl, .autoenablesDefaultLighting], preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                        .frame(minWidth: 300, alignment: .trailing)
                        .sheet(isPresented: $controller.presentingTempAlert, content: {
                            TempAlert(message: controller.tempAlertMessage)
                        })
                        
                    // UVMap
                    if displayUVMap {
                        if let node = controller.selectedNode,
                           let geometry:SCNGeometry = node.geometry,
                           let uvMap:[CGPoint] = controller.inspectUVMap(geometry: geometry) {
                            ScrollView([.vertical, .horizontal], showsIndicators:true) {
                                HStack {
                                    UVMapStack(geometry: geometry, points: uvMap)
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
    
    var uvView: some View {
        
        if let node = controller.selectedNode,
           let geometry = node.geometry,
           let uvPoints:[CGPoint] = controller.inspectUVMap(geometry: geometry) {
            return UVShape(uv: uvPoints)
                .stroke(lineWidth: 0.5)
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .background(Color.clear)
                .frame(width:1024, height:1024, alignment: .center)
        } else {
            return UVShape(uv: [])
                .stroke(lineWidth: 0.5)
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .background(Color.clear)
                .frame(width:1024, height:1024, alignment: .center)
        }
    }
    func sceneWithWired(node:SCNNode) -> SCNScene {
        let newScene = SCNScene()
        newScene.rootNode.addChildNode(node)
        node.geometry?.firstMaterial?.fillMode = .lines
        newScene.background.contents = NSColor.gray
        return newScene
    }
}

struct SMGeometryRow: View {
    
    @ObservedObject var controller:SceneMachineController
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
                Spacer()
                Button(action: {
                    controller.removeGeometry(geo: geometry)
                }, label: {
                    Image(systemName: "trash")
                })
            }
        }
        .padding(4)
        .background(isSelected ? Color.black:Color.clear)
        .cornerRadius(isSelected ? 8:0)
        .frame(width:200)
    }
}

struct UVMapStack: View {
    
    var geometry:SCNGeometry
    var points:[CGPoint]
    var image:NSImage?
    
    init(geometry:SCNGeometry, points:[CGPoint]) {
        self.geometry = geometry
        self.points = points
        
        if let difMap = geometry.materials.first?.diffuse {
            print("Diffuse map loaded")
            if let cont = difMap.contents as? String {
                print("Did let contents as String")
                if let imagePath = Bundle.main.path(forResource: cont, ofType: nil, inDirectory: "Scenes.scnassets") {
                    print("image path in")
                    if let nsimage = NSImage(byReferencingFile: imagePath) {
                        print("image 1 in")
                        self.image = nsimage
                    } else if let nsimage = NSImage(contentsOfFile: imagePath) {
                        print("image 2 in")
                        self.image = nsimage
                    }
                } else {
                    print("no image path")
                    if let nsimage = NSImage(contentsOfFile: cont) {
                        print("Another source")
                        self.image = nsimage
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("UVMap")
            ZStack {
                
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 1024, height: 1024, alignment: .center)
                }
                
                UVShape(uv:points)
                    .stroke(lineWidth: 0.5)
                    .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                    .background(Color.gray.opacity(0.1))
                    .frame(width: 1024, height: 1024, alignment: .center)
                
            }
        }
    }
}

struct TempAlert: View {
    
    var message:String
    var body: some View {
        VStack {
            Text("⚠️ Alert").font(.title).foregroundColor(.orange)
            Text(message)
        }
        .padding()
    }
}

struct SceneMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SceneMachineView()
    }
}
