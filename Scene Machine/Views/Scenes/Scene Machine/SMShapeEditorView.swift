//
//  SMShapeEditorView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/10/21.
//

import SwiftUI

struct SMShapeEditorView: View {
    
    @ObservedObject var controller:SceneMachineController
    
    @State private var startPoint: CGPoint = CGPoint(x: 256, y: 256)
    @State private var endPoint: CGPoint = CGPoint(x: 226, y: 256)
    
    @State var allPoints:[DPoint] = [DPoint(CGPoint(x: 256, y: 256))]
    @State private var lineWidth:Int = 3
    
    @State var drawnPaths:[DPoint] = []
    @State var isPathClosed:Bool = false
    @State var isCurve:Bool = false
    @State var isMoving:Bool = true
    
    @State var strokeColor:Color = .white
    
    var body: some View {
        VStack {
            // Toolbar
            HStack {
                Button("f") {
                    closePath()
                }
                .keyboardShortcut("f", modifiers: [])
                .help("f is for 'face'. It closes the path, creating an edge from the last point to the initial point.")
                Button("t") {
                    print("Terminate")
                    drawnPaths.append(contentsOf: allPoints)
                    allPoints = [DPoint(CGPoint(x: 256, y: 256))]
                }
                Divider()
                Spacer()
                Toggle(isOn: $isCurve, label: {
                    Text("Curve")
                })
                
                ShortCounterInput(title: "Width", value: $lineWidth, range: 1...20)
                    .frame(width:150)
                
                ColorPicker("Stroke", selection: $strokeColor)
                
                Button("Make Shape") {
                    self.createShape()
                }
            }
            .frame(height:43)
            .padding(.horizontal, 8)
            
            Divider()
            
            ZStack {
                
                // Canvas: NSView on bottom of the stack.
                DrawingCanvas { location in
                    
                    if isMoving {
                        allPoints.removeLast()
                    }
                    
                    let adjPoint = CGPoint(x: location.x, y: 512 - location.y)
                    allPoints.append(DPoint(adjPoint, curved: isCurve))
                    endPoint = adjPoint
                }
                
                // Currently drawing Path
                Path { (path) in
                    path.move(to: startPoint)
                    // path.addLine(to: endPoint)
                    for point in allPoints {
                        if point.isCurve {
                            path.addCurve(to: point.point, control1: point.control1!, control2: point.control2!)
                        } else {
                            path.addLine(to: point.point)
                        }
                    }
                    if isPathClosed {
                        path.closeSubpath()
                    }
                }
                .strokedPath(StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .square, lineJoin: .round))
                .foregroundColor(strokeColor)
                
                //Circle 1
                Circle()
                    .frame(width: 16, height: 16)
                    .position(startPoint)
                    .foregroundColor(.blue.opacity(0.5))
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    self.startPoint = CGPoint(x: value.location.x, y: value.location.y)
                                })
                
                //Circle 2
                DrawingPointView(point: allPoints.last!)
                    .frame(width: 16, height: 16)
                    .position(endPoint)
                    .foregroundColor(.accentColor.opacity(0.5))
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    self.endPoint = CGPoint(x: value.location.x, y: value.location.y)
                                }
                                .onEnded({ ended in
                                    if isCurve {
                                        let rPoint = DPoint((CGPoint(x: ended.location.x, y: ended.location.y)), curved: true)
                                        
                                        allPoints.append(rPoint)
                                        
                                    } else {
                                        allPoints.append(DPoint(CGPoint(x: ended.location.x, y: ended.location.y)))
                                    }
                                    
                                }))
                    .contextMenu {
                        Button("Other") {
                            
                        }
                        Button("Curve") {
                            self.isCurve.toggle()
                            allPoints.last?.toggleCurve()
                        }
                        Button("Close") {
                            closePath()
                        }
                    }
                Color.clear
                
                if allPoints.last!.isCurve == true {
                    makePath(from: allPoints.last!.point, to: allPoints.last!.control1!)
                        .strokedPath(StrokeStyle(lineWidth: CGFloat(1), lineCap: .square, lineJoin: .round))
                        .foregroundColor(.white.opacity(0.3))
                    Circle().frame(width: 12, height: 12).position(allPoints.last!.control1!) // ?? allPoints.last!.point)
                        .gesture(DragGesture()
                                    .onChanged { (value) in
                                        let newPoint = CGPoint(x: value.location.x, y: value.location.y)
                                        let dPoint = DPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = newPoint
                                        dPoint.control2 = allPoints.last!.control2
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }
                                    .onEnded({ ended in
                                        let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                        let dPoint = DPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = newPoint
                                        dPoint.control2 = allPoints.last!.control2
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }))
                    
                    
                    makePath(from: allPoints.last!.point, to: allPoints.last!.control2!)
                        .strokedPath(StrokeStyle(lineWidth: CGFloat(1), lineCap: .square, lineJoin: .round))
                        .foregroundColor(.white.opacity(0.3))
                    Circle().frame(width: 12, height: 12).position(allPoints.last!.control2!) // ?? allPoints.last!.point)
                        .gesture(DragGesture()
                                    .onChanged { (value) in
                                        let newPoint = CGPoint(x: value.location.x, y: value.location.y)
                                        let dPoint = DPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = allPoints.last!.control1
                                        dPoint.control2 = newPoint
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }
                                    .onEnded({ ended in
                                        let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                        let dPoint = DPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = allPoints.last!.control1
                                        dPoint.control2 = newPoint
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }))
                    
                }
            }
            .frame(width: 512, height: 512, alignment: .center)
        }
    }
    
    func makePath(from:CGPoint, to:CGPoint) -> Path {
        var newPath = Path()
        newPath.move(to: from)
        newPath.addLine(to: to)
        return newPath
    }
    
    func createShape() {
        // Initialize the path.
        let path = NSBezierPath()
        
        let firstPoint = self.allPoints.first!.point
        
        // Specify the point that the path should start get drawn.
//        path.move(to: self.allPoints.first!.point)
        path.move(to: .zero)
        
        let remainingPoints = Array(allPoints.dropFirst())
        
        for point in remainingPoints {
            if point.isCurve {
                path.curve(to: NSPoint(x: point.point.x - firstPoint.x, y: point.point.y - firstPoint.y), controlPoint1: NSPoint(x: point.control1!.x - firstPoint.x, y: point.control1!.y - firstPoint.y), controlPoint2: NSPoint(x: point.control2!.x - firstPoint.x, y: point.control2!.y - firstPoint.y))
            } else {
                path.line(to: CGPoint(x: point.point.x - firstPoint.x, y: point.point.y - firstPoint.y))
            }
        }
        
//        path.close()
        
        controller.makeShape(path: path)
    }
    
    func closePath() {
        isPathClosed = true
    }
}

struct SMShapeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SMShapeEditorView(controller:SceneMachineController())
    }
}
