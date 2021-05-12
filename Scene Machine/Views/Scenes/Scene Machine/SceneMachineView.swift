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

    @State private var selectedMaterial:SCNMaterial?
    
    @State private var popGeoImport:Bool = false
    @State private var popBackground:Bool = false
    
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
                    
                    Divider()
                    
                    
                    // Geometries
//                    HStack {
//                        Image(systemName: "pyramid.fill")
//                        Text("Geometries")
//                        Spacer()
//                    }
//                    .font(.title2)
//                    .foregroundColor(.orange)
//
//                    Divider()
                    
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
                        .padding(4)
                        .background(material == selectedMaterial ? Color.black.opacity(0.5):Color.clear)
                        .onTapGesture {
                            self.selectedMaterial = material
                        }
                    }
                    
                    if let _ = selectedMaterial {
                        SMMaterialView(material: self.selectedMaterial!)
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
                            Text("Add Geometry").font(.title2).foregroundColor(.orange)
                            Divider()
                            ForEach(AppGeometries.allCases, id:\.self) { appGeo in
                                HStack {
                                    Text(appGeo.rawValue)
                                    Spacer()
                                    Button("Add") {
                                        controller.addAppGeometry(geo: appGeo)
                                    }
                                }
                            }
                        }
                        .frame(width:200)
                        .padding()
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
                                SceneView(scene: self.sceneWithWired(node: theNode.flattenedClone()), pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 30, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
                                    .frame(width: 300, height: 300, alignment: .center)
                            }
                            .padding(8)
                            .frame(minWidth:300)
                        }

                    }
                    
//                    else {
//                        Button("+ Shape") {
//                            controller.rightView = .Shape
//                        }
//                    }
                    
//                    Button("Program") {
//                        controller.addProgram()
//                    }
//                    .help("Adds a glowing box, created in Metal")
                    
//                        Toggle("UVMap", isOn: $displayUVMap)
//                            .onChange(of: displayUVMap, perform: { value in
//                                if value == true { controller.rightView = .UVMap } else { controller.rightView = .Empty }
//                            })
                    Spacer()
//                    Button("Save UV") {
//
//                        print("saving UVMap")
//                        if let image = uvView.snapShot(uvSize: CGSize(width: 1024, height: 1024)) {
//                            controller.saveUVMap(image: image)
//                        } else {
//                            // Display an error message
//                        }
//                    }
//                    .disabled(controller.selectedNode?.geometry == nil)
                    
                    // Segment
                    Picker(selection: $controller.rightView, label: Image(systemName: "rectangle.righthalf.inset.fill"), content: {
                        ForEach(MachineRightView.allCases, id:\.self) { rightView in
                            Text(rightView.rawValue)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width:180)
                    
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
                    
                    switch controller.rightView {
                        case .Empty: EmptyView().frame(width: 0, height: 0, alignment: .center)
                        case .UVMap:
                            if let node = controller.selectedNode,
                               let geometry:SCNGeometry = node.geometry,
                               let uvMap:[CGPoint] = controller.inspectUVMap(geometry: geometry) {
                                ScrollView([.vertical, .horizontal], showsIndicators:true) {
                                    HStack {
                                        UVMapStack(controller: controller, geometry: geometry, points: uvMap)
                                    }
                                    .padding(30)
                                }
                                .frame(minWidth: 300, alignment: .trailing)
                            }
                        case .Shape:
                            ScrollView([.vertical, .horizontal], showsIndicators:true) {
                                SMShapeEditorView(controller: controller)
                            }
                            .frame(minWidth: 300, alignment: .trailing)
                    }
                }
                
            }
            .frame(minWidth: 600)
        }
    }
    
    /// Returns a scene containing the node in "wire" mode, like quickLook.
    func sceneWithWired(node:SCNNode) -> SCNScene {
        
        let newScene = SCNScene()
        newScene.rootNode.addChildNode(node)
        
        // Create ew material, so we don't mess with the existing
        let newMaterial = SCNMaterial()
        newMaterial.diffuse.contents = node.geometry?.firstMaterial?.diffuse.contents ?? NSColor.white
        newMaterial.fillMode = .lines
        node.geometry?.insertMaterial(newMaterial, at: 0)
        
        newScene.background.contents = NSColor.darkGray
        return newScene
    }
}
/*
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
*/

struct UVMapStack: View {
    
    @ObservedObject var controller:SceneMachineController
    var geometry:SCNGeometry
    var points:[CGPoint]
    var image:NSImage?
    
    @State var imgSize:CGSize = TextureSize.medium.size
    @State var showUVEdges:Bool = true
    
    // Note: Make background droppable URL, and check image size
    
    init(controller:SceneMachineController, geometry:SCNGeometry, points:[CGPoint]) {
        self.controller = controller
        self.geometry = geometry
        self.points = points
        
        if let difMap = geometry.materials.first?.diffuse {
            print("Diffuse map loaded")
            if let cont = difMap.contents as? String {
                print("Did let contents as String")
                if let imagePath = Bundle.main.path(forResource: cont, ofType: nil, inDirectory: "Scenes.scnassets") {
                    print("Image in App Bundle")
                    if let nsimage = NSImage(byReferencingFile: imagePath) {
                        print("image 1 in")
                        self.image = nsimage
                        self.imgSize = nsimage.size
                    } else if let nsimage = NSImage(contentsOfFile: imagePath) {
                        print("image 2 in")
                        self.image = nsimage
                        self.imgSize = nsimage.size
                    }
                } else {
                    print("Image in User's file")
                    if let nsimage = NSImage(contentsOfFile: cont) {
                        print("Another source")
                        self.image = nsimage
                        self.imgSize = nsimage.size
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            
            // Toolbar
            HStack {
                Text("UVMap")
                
                Button("Load Image") {
                    print("Load an image")
                }
                
                Spacer()
                
                Button("💾 Save") {
                    print("Save UVMap contours")
                    
                    if let image = uvTexture.snapShot(uvSize: CGSize(width: imgSize.width, height: imgSize.height)) {
                        controller.saveUVMap(image: image)
                    } else {
                        // Display an error message
                        // Send it to controller
                    }
                }
            }
            
            ZStack {
                
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
                }
                
                UVShape(uv:points)
                    .stroke(lineWidth: 0.5)
                    .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                    .background(Color.gray.opacity(0.1))
                    .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
                
            }
        }
    }
    
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
