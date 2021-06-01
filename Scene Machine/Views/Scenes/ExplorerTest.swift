//
//  ExplorerTest.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/31/21.
//

import SwiftUI
import SceneKit

struct ExplorerTest: View {
    
    @ObservedObject var controller = ExplorerController()
    
    var body: some View {
        VStack {
            HStack {
                Text("Explorer")
                Button("Go") {
                    if let b = controller.scene.rootNode.childNode(withName: "protagonist", recursively: false), let bp = b.physicsBody {
                        
                        let force = simd_make_float4(0, 0, -2, 0)
                        let ccc = controller.scene.rootNode.childNode(withName: "protagonist", recursively: false)!
                        let rotatedForce = simd_mul(ccc.simdTransform, force)
                        let vectorForce = SCNVector3(x:CGFloat(rotatedForce.x), y:CGFloat(rotatedForce.y), z:CGFloat(rotatedForce.z))
                        bp.applyForce(vectorForce, asImpulse: true)
                    }
                }
                .keyboardShortcut("w", modifiers: [])
                
                
                Button("Turn L") {
                    controller.turnLeft()
                }
                .keyboardShortcut("a", modifiers: [])
                
                /*
                 @discussion The transform is the combination of the position, rotation and scale defined below. So when the transform is set, the receiver's position, rotation and scale are changed to match the new transform.
                 */
                Button("Turn R") {
                    controller.turnRight()
                }
                .keyboardShortcut("d", modifiers: [])
                
                Spacer()
                Text(controller.turnData)
            }
            
            ZStack(alignment: .topLeading) {
                ExplorerSceneView(scene: controller.scene, controller: controller)
                Text(controller.renderData)
                    .frame(width: 128, height:150)
                    .padding()
                    .background(Color.black.opacity(0.2))
                
            }
            
//            SceneView(scene: controller.scene, pointOfView: controller.scene.rootNode.childNode(withName: "camnode", recursively: false)!, options: [], preferredFramesPerSecond: 60, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
                
        }
    }
    
    
}

struct ExplorerTest_Previews: PreviewProvider {
    static var previews: some View {
        ExplorerTest()
    }
}


// MARK: - Background NSView

/// Handles Mouse and Keyboard events
struct ExplorerSceneView: NSViewRepresentable {
    
    var scene:SCNScene
    var controller:ExplorerController
    
    //    var nsView:SMEventSceneView
    //    var eventCallback:((NSEvent) -> Void)
    
    func makeNSView(context: Context) -> ExplorerNSView {
        
        // Instantiate the SCNView and setup the scene
        let eventView = ExplorerNSView()
        eventView.scene = scene
        eventView.pointOfView = scene.rootNode.childNode(withName: "camnode", recursively: true)
        eventView.allowsCameraControl = false
        eventView.preferredFramesPerSecond = 50
        eventView.antialiasingMode = .multisampling2X
        eventView.controller = controller
        
        controller.reportStatus(string: "Made NSView")
        
        return eventView
    }
    
    func updateNSView(_ nsView: ExplorerNSView, context: Context) {
        print("updates")
    }
    
}

class ExplorerNSView:SCNView, SCNSceneRendererDelegate {
    
    var controller:ExplorerController?
    
    // Main mouse events
    
    /// Detects where the mouse was down last, to not interfere with camera moves.
    var lastDown:NSPoint = .zero
    var startTime:Double = 0
    var deltaTime:Double = 0
    
    override func mouseDown(with event: NSEvent) {
        print("mouse down")
        lastDown = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        print("mouse up")
        
        // check what nodes are tapped
        let windowPoint:NSPoint = event.locationInWindow //gestureRecognize.location(in: view)
        let eventLocation = convert(windowPoint, from: nil)
        
        // Check if moving camera in scene
        if windowPoint != lastDown {
            print("dragged")
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
        
        controller?.reportStatus(string: "Key up: \(event.keyCode)")
    }
    
    override func viewDidMoveToSuperview() {
        delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if startTime == 0 { startTime = time }
        deltaTime = time - startTime
        
        var renderString = ""
        
        renderString += "Time: \(Int(deltaTime))\n"
        
        guard let protagonist = scene?.rootNode.childNode(withName: "protagonist", recursively: false) else {
            print("Error. No protagonist")
            return
        }
        
        protagonist.presentation.physicsBody?.resetTransform()
        
        let angleY = protagonist.presentation.eulerAngles.z.toDegrees()
        renderString += String(format: "Pres: %.2f, r %.2f\n", arguments: [Double(angleY)])
        
        let curangleY = protagonist.eulerAngles.z.toDegrees()
        renderString += String(format: "Curr: %.2f, r %.2f\n", arguments: [Double(curangleY)])
        
        let body = protagonist.physicsBody!
        
        let veloZ:String = "Z: \(body.velocity.z)"//String(format: "⏱ Speed \n Z: %.2f\n", [body.velocity.z])
        let veloX:String = "X: \(body.velocity.x)"//String(format: " X: %.2f", [body.velocity.x])
        
        renderString += veloZ.prefix(8)
        renderString += "\n"
        renderString += veloX.prefix(8)
        // renderString += "\n \(body.velocity.toString())"
        
        controller?.reportRenderer(string: renderString)
    }
}
