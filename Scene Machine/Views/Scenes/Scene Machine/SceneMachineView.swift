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

    @State var selectedMaterial:SCNMaterial?
    
    @State private var popGeoImport:Bool = false
    @State private var popBackground:Bool = false
    @State private var popMaterial:Bool = false
    
    var body: some View {
        
        NavigationView {
            
            // Nodes + Materials
            ScrollView {
                VStack {
                    
                    // Node
                    HStack {
                        Text("●")
                        Text("Nodes")
                        Spacer()
                        Button("+") {
                            print("Add Node")
                            let newNode = SCNNode()
                            newNode.name = "Empty Node"
                            controller.scene.rootNode.addChildNode(newNode)
                        }
                    }
                    .font(.title2)
                    .foregroundColor(.orange)
                    
                    ForEach(controller.scene.rootNode.childNodes, id:\.self) { node in
                        SMNodeRow(controller: controller, node: node)
                            .padding(.vertical, 4)
                            
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
                        .padding(4)
                        .background(material == selectedMaterial ? Color.black.opacity(0.5):Color.clear)
                        .onTapGesture {
                            self.selectedMaterial = material
                            controller.selectedMaterial = material
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            
                            ForEach(LocalDatabase.shared.materials) { smMaterial in
                                Button(action: {
                                    print("Tapped ma")
                                    controller.substituteMaterials(current: material, candidate: smMaterial)
                                }, label: {
                                    Label("\(smMaterial.name ?? "untitled")", systemImage: "shield.checkerboard")
                                })
                            }
                        }))
                    }
                    
                    if let material = selectedMaterial {
                        SMMaterialView(controller: controller, material: material)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 6)
            }
            
            
            
            // Middle - Scene
            VStack {
                
                // Top Toolbar
                HStack {
                    
                    // Import
                    Button(action: {
                        popGeoImport.toggle()
                    }, label: {
                        Image(systemName:"square.and.arrow.down.fill").font(.title2)
                    })
                    .help("Import geometry")
                    .popover(isPresented: $popGeoImport) {
                        VStack {
                            Text("Add Geometry").font(.title2).foregroundColor(.orange)
                            Divider()
                            HStack {
                                Text("Import")
                                Spacer()
                                Button("Load file") {
                                    controller.loadPanel()
                                }
                            }
                            
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
                    
                    // Screenshot
                    Button(action:{
                        print("Screenshot")
                        // The View will take a screenshot and issue a NSSavePanel command.
                        NotificationCenter.default.post(Notification(name: .smScreenshotNotification))
                        
                    }, label:{
                        Image(systemName: "camera.circle.fill").font(.title2)
                    })
                    .help("Take a screenshot of the scene")
                    
                    // Save
                    Button("💾") {
                        controller.popSaveDialogue.toggle()
                    }
                    .help("Save Scene")
                    .popover(isPresented: $controller.popSaveDialogue) {
                        VStack {
                            SaveDialogue(controller: controller)
                                .padding()
                            
                        }
                    }
                    
                    Spacer()
                    
                    // Node Button (Middle)
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
                    
                    Spacer()
                    
                    // Right View Picker
                    Picker(selection: $controller.rightView, label: Image(systemName: "sidebar.right").font(.title2), content: {
                        ForEach(MachineRightView.allCases, id:\.self) { rightView in
                            Text(rightView.rawValue)
                        }
                    })
                    .frame(width:180)
                    .onChange(of: controller.rightView) { value in
                        if value == .UVMap {
                            if controller.selectedNode == nil {
                                controller.displayTemporaryMessage(string: "Select a node to see the UVMap")
                            }
                        }
                    }
                }
                .padding([.top, .leading, .trailing], 8)
                
                
                HSplitView {
                    
                    ZStack {
                        
                        // Scene
                        SMEventBackView(scene: controller.scene)
                            .sheet(isPresented: $controller.presentingTempAlert) {
                                TempAlert(message: controller.tempAlertMessage)
                            }
                        
                        if let scene = controller.topDownScene,
                           let cam = scene.rootNode.childNode(withName: "topdowncam", recursively: false) {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    SceneView(scene: scene, pointOfView: cam, options: [], preferredFramesPerSecond: 60, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
                                        .frame(width: 256, height: 256, alignment: .trailing)
                                }
                            }
                            
                                
                        }
                        
                        
                        if controller.isTouchingOptions {
                            VStack {
                                if let node = controller.selectedNode {
                                    Text("Node").font(.title2).foregroundColor(.orange)
                                    Button(node.isHidden ? "Show":"Hide") {
                                        node.isHidden.toggle()
                                        controller.selectedNode = nil
                                        controller.isTouchingOptions = false
                                    }
                                    Button(node.isPaused ? "Play":"Pause") {
                                        node.isPaused.toggle()
                                        controller.selectedNode = nil
                                        controller.isTouchingOptions = false
                                    }
                                    Button("De-Select") {
                                        controller.selectedNode = nil
                                    }
                                    
                                } else {
                                    Text("Point: \(controller.touchOptionsPoint.debugDescription)")
                                    // Drop node here?
                                    // import?
                                    // scene options?
                                }
                                
                                Button("Close") {
                                    controller.isTouchingOptions.toggle()
                                }
                            }
                            
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .frame(minWidth: 100, maxWidth: 300, minHeight: 200, maxHeight: 400)
                            .position(controller.touchOptionsPoint)
                        }
                    }
                    
//                    SceneView(scene: controller.scene, pointOfView: nil, options: [.allowsCameraControl, .autoenablesDefaultLighting], preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
//                        .frame(minWidth: 300, alignment: .trailing)
//                        .sheet(isPresented: $controller.presentingTempAlert, content: {
//                            TempAlert(message: controller.tempAlertMessage)
//                        })
                    
                    // Right View
                    switch controller.rightView {
                        case .FullView: EmptyView().frame(width: 1, height: 0, alignment: .trailing)
                        case .UVMap:
                            if let node = controller.selectedNode,
                               let geometry:SCNGeometry = node.geometry {
                                SMUVMapView(geometry: geometry) { snapShot in
                                    controller.saveUVMap(image: snapShot)
                                }
                                .frame(minWidth: 300, alignment: .trailing)
                            }
                        case .Shape:
                            
                            SMShapeEditorView(controller: controller)
                            .frame(minWidth: 300, alignment: .trailing)
                            
                        case .Settings:
                            SMSceneConfigView(controller: controller)
                                .frame(minWidth: 300, alignment: .trailing)
                            
                        case .Shaders:
                            if let node = controller.selectedNode,
                               let geometry = node.geometry {
                                SMShaderEditView(controller: controller, geometry: geometry)
                                    .frame(minWidth: 350, idealWidth: 400)
                            } else {
                                VStack {
                                    Text("No node selected")
                                    Text("Select a node with a Geometry to add a shader snippet").foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            
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
            .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
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
        .frame(width: imgSize.width, height: imgSize.height, alignment: .center)
    }
}

struct TempAlert: View {
    
    var message:String
    var hasTitle:Bool = false
    
    var body: some View {
        VStack {
            if hasTitle {
                Text("⚠️ Alert").font(.title).foregroundColor(.orange)
                Divider()
            }
            
            Text(message)
        }
        .padding(6)
        .frame(minWidth: 100, maxWidth: 250, minHeight: 50, maxHeight: 200, alignment: .center)
        .background(Color.black.opacity(0.45))
        .cornerRadius(12)
    }
}

struct SaveDialogue: View {
    
    @ObservedObject var controller:SceneMachineController
    
    enum SaveType {
        case Folder
        case File
    }
    
    @State var method:SaveType = .File
    
    @State var folderName:String = "Scenes"
    @State var sceneName:String = "MyScene"
    
    var body: some View {
        
        VStack(alignment:.leading) {
            Text("Save Scene Method").font(.title2).foregroundColor(.blue)
                //.padding(8)
            Divider()
            
            Text("You may export this scene to a '.scnassets' folder. This folder can only be saved in the Application's document directory.")
                .frame(minHeight: 80, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Picker(selection: $method, label: Text("Method:")) {
                Text("Folder").tag(SaveType.Folder)
                    .frame(width:100, alignment:.leading)
                Text("File").tag(SaveType.File)
                    .frame(width:100, alignment:.leading)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .frame(width:250)
            
            Divider()
            
            switch method {
                case .File:
                    Text("As a file, you may save it in .dae, or .scn format.")
                        .frame(height:40)
                case .Folder:
                    HStack {
                        Text("Folder:")
                        Spacer()
                        TextField("Folder name", text: $folderName)
                            .frame(width: 80)
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("Scene name:")
                        Spacer()
                        TextField("Folder name", text: $sceneName)
                            .frame(width: 80)
                    }
                    .padding(.horizontal)
            }
            
            Divider()
            
            HStack {
                Button("Save"){
                    switch method {
                        case .File: controller.saveScene()
                        case .Folder: controller.saveSceneWith(folder: folderName, sceneName: sceneName)
                    }
                }
                Spacer()
                Button("Cancel") {
                    controller.popSaveDialogue.toggle()
                }
            }.padding([.horizontal, .bottom], 8)
            
            
        }
        .frame(minWidth: 150, maxWidth: 250, minHeight: 250, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - Previews

struct SceneMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SceneMachineView()
    }
}

struct SceneMachineAlert_Previews: PreviewProvider {
    static var previews: some View {
        TempAlert(message: "Hello")
    }
}

// MARK: - Background NSView

/// Handles Mouse and Keyboard events
struct SMEventBackView: NSViewRepresentable {
    
    var scene:SCNScene
//    var nsView:SMEventSceneView
//    var eventCallback:((NSEvent) -> Void)
    
    func makeNSView(context: Context) -> SMEventSceneView {
        
        // Instantiate the SCNView and setup the scene
        let eventView = SMEventSceneView()
        eventView.scene = scene
        eventView.pointOfView = scene.rootNode.childNode(withName: "camera", recursively: true)
        eventView.allowsCameraControl = true
        
        return eventView
    }
    
    func updateNSView(_ nsView: SMEventSceneView, context: Context) {
        print("updates")
    }
    
}

class SMEventSceneView:SCNView {
    
    // Scene Options - Data that should be passed between and SAVED for continuation.
    // 1. PIP Scene (is displaying)
    // 2. SCNInteractionMode + SCNCameraController info
    // 3. PointOfView
    // 4. Autosave?
    // 5. Display node count/stats
    // 6. Scene name
    // 7. Rendering Mode?
    // 8. Panel (Node options)
    
    // Main mouse events
    
    /// Detects where the mouse was down last, to not interfere with camera moves.
    var lastDown:NSPoint = .zero
    
    override func mouseDown(with event: NSEvent) {
        
        print("mouse down")
        if lastDown == event.locationInWindow {
            
        } else {
            lastDown = event.locationInWindow
            defaultCameraController.beginInteraction(event.locationInWindow, withViewport: self.currentViewport.size)
        }
        
        
    }

    override func mouseUp(with event: NSEvent) {
        
        print("mouse up")
        
        // check what nodes are tapped
        let windowPoint:NSPoint = event.locationInWindow //gestureRecognize.location(in: view)
        let eventLocation = convert(windowPoint, from: nil)
        
        // Check if moving camera in scene
        if windowPoint != lastDown {
            // print("dragged")
//            defaultCameraController.continueInteraction(event.locationInWindow, withViewport: self.currentViewport.size, sensitivity: 1)
            defaultCameraController.endInteraction(event.locationInWindow, withViewport: currentViewport.size, velocity: CGPoint.zero)
            
            return
        }
        
        print("Touch point: \(eventLocation)")
        
        let hitResults = hitTest(eventLocation, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            
            // retrieved the first clicked object
            let result:SCNHitTestResult = hitResults.first!
            
            let node = result.node
            print("Node: \(node.name ?? "<untitled>")")
            
            let geo = result.geometryIndex
            // index of geometry element whose surface the search ray intersects
            // is this the material ?
            print("Geoindex: \(geo)")
            
            // Face
            //            let face:Int = result.faceIndex
            //            print("Touch face index: \(face)")
            //
            //            let c = result.localCoordinates
            //            print("Local coordinates: \(c)")
            //
            //            let d = result.localNormal
            //            print("Local normal: \(d)")
            
            NotificationCenter.default.post(name: .hitTestNotification, object: result)
        }
         
    }
    
    override func rightMouseDown(with event: NSEvent) {
        print("right mouse down")
        let windowPoint:NSPoint = event.locationInWindow //gestureRecognize.location(in: view)
        let eventLocation = convert(windowPoint, from: nil)
        
        print("Touch point: \(eventLocation)")
        let hitResults = hitTest(eventLocation, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            
            // retrieved the first clicked object
            let result:SCNHitTestResult = hitResults.first!
            
            let node = result.node
            print("Node: \(node.name ?? "<untitled>")")
            
            let geo = result.geometryIndex
            // index of geometry element whose surface the search ray intersects
            // is this the material ?
            print("Geoindex: \(geo)")
            
            // Face
            //            let face:Int = result.faceIndex
            //            print("Touch face index: \(face)")
            //
            //            let c = result.localCoordinates
            //            print("Local coordinates: \(c)")
            //
            //            let d = result.localNormal
            //            print("Local normal: \(d)")
            let convertedLocation = NSPoint(x: eventLocation.x, y: self.frame.size.height - eventLocation.y)
            NotificationCenter.default.post(name: .hitTestNotification, object: convertedLocation)
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        
    }
    
    // Touches
    
    override func touchesBegan(with event: NSEvent) {
        
    }
    
    override func touchesMoved(with event: NSEvent) {
        
    }
    
    override func touchesEnded(with event: NSEvent) {
        
    }
    
    // Keyboard
    
    override func keyUp(with event: NSEvent) {
        print("Key up: \(event.keyCode)")
        if event.keyCode == 123 {
            defaultCameraController.translateInCameraSpaceBy(x: -1, y: 0, z: 0)
        }
        if event.keyCode == 124 {
            defaultCameraController.translateInCameraSpaceBy(x: 1, y: 0, z: 0)
        }
        if event.keyCode == 125 {
            defaultCameraController.translateInCameraSpaceBy(x: 0, y: 0, z: 1)
        }
        if event.keyCode == 126 {
            defaultCameraController.translateInCameraSpaceBy(x: 0, y: 0, z: -1)
        }
        if event.keyCode == 83 {
            print("top")
            
            // keypad 1
            let emptyNode = SCNNode()
//            emptyNode.camera = SCNCamera()
            emptyNode.name = "placeholder"
            // let bbox = scene!.rootNode.boundingBox.max.y
            emptyNode.position = SCNVector3(0, 20, 0)
            scene!.rootNode.addChildNode(emptyNode)
            emptyNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
            
//            defaultCameraController.clearRoll()
            
//            defaultCameraController.endInteraction(event.locationInWindow, withViewport: currentViewport.size, velocity: CGPoint.zero)
//            defaultCameraController.inertiaEnabled = true
//            defaultCameraController.worldUp = SCNVector3(0, 0, 1)
            self.pointOfView = emptyNode
            defaultCameraController.pointOfView = emptyNode
            defaultCameraController.target = SCNVector3(0, 0, 0)
            
            defaultCameraController.interactionMode = .pan
            
            // Clear the node?
            // emptyNode.removeFromParentNode()
            
        }
    }
    
    override func viewDidMoveToWindow() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenshotNotification(_:)), name: .smScreenshotNotification, object: nil)
//        self.defaultCameraController = SCNCameraController()
//        defaultCameraController.beginInteraction(CGPoint.zero, withViewport: self.currentViewport.size)
//        defaultCameraController.continueInteraction(<#T##location: CGPoint##CGPoint#>, withViewport: <#T##CGSize#>, sensitivity: <#T##CGFloat#>)
//        defaultCameraController.endInteraction(<#T##location: CGPoint##CGPoint#>, withViewport: <#T##CGSize#>, velocity: <#T##CGPoint#>)
        
        defaultCameraController.interactionMode = .orbitTurntable
        defaultCameraController.pointOfView = nil
        
        print("Default Controller POV: \(defaultCameraController.pointOfView?.description ?? "na")")
        print("Default Controller TARGET: \(defaultCameraController.target)")
        
        //        defaultCameraController.translateInCameraSpaceBy(x: <#T##Float#>, y: <#T##Float#>, z: <#T##Float#>)
        // defaultCameraController.worldUp
//        self.defaultCameraController = // Create a
    }
    
    // Other
    @objc func screenshotNotification(_ notification:Notification) {
        let image = self.snapshot()
        
        
        // use NSSavePanel
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "UVMap layout";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["png", "jpg", "jpeg"]
        dialog.message = "Save UVMap"
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            // Pathname of the file
            if let result = dialog.url,
               let imageData = image.tiffRepresentation {
                do {
                    try imageData.write(to: result)
                } catch {
                    print("Error. Could not save image")
                }
                
            } else {
                print("Could not save image to the specified URL")
            }
        }
    }
}
