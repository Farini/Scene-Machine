//
//  ToolDrawingPads.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/15/21.
//

import SwiftUI

// MARK: - Drawing Pads

struct PencilDrawingPad: View {
    
    @ObservedObject var controller:DrawingPadController
    
    // Pencil
    @Binding var currentDrawing: PencilStroke
    
    // Size
    @Binding var size:TextureSize
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                //                for drawing in self.drawings {
                //                    self.add(drawing: drawing, toPath: &path)
                //                }
                self.add(drawing: self.currentDrawing, toPath: &path)
            }
            .stroke(controller.foreColor,
                    style: StrokeStyle(lineWidth: controller.lineWidth, lineCap: .round, lineJoin: .bevel, miterLimit: .pi, dash: [], dashPhase: 0))
            
            .background(Color(white: 0.01).opacity(0.05))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        let currentPoint = value.location
                        if currentPoint.y >= 0
                            && currentPoint.y < geometry.size.height {
                            self.currentDrawing.points.append(currentPoint)
                        }
                    })
                    .onEnded({ (value) in
                        //                        self.drawings.append(self.currentDrawing)
                        //                        self.currentDrawing = PencilStroke()
                        controller.addPencil(stroke: currentDrawing)
                        currentDrawing.points = []
                    })
            )
        }
        .frame(width: size.size.width, height: size.size.height)
    }
    
    private func add(drawing: PencilStroke, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }
}

struct PenDrawingPad: View {
    
    @ObservedObject var controller:DrawingPadController
    
    // Pen Points
    @State private var startPoint: CGPoint = CGPoint(x: 20, y: 20)
    @State private var endPoint: CGPoint = CGPoint(x: 40, y: 20)
    //    @State var allPoints:[PenPoint] = []
    
    @Binding var isPathClosed:Bool
    @Binding var isCurve:Bool
    
    @State var isMoving:Bool = true
    
    var body: some View {
        
        ZStack {
            
            // Canvas: NSView on bottom of the stack.
            DrawingCanvas { location in
                
                print("Controller pen points: \(controller.penPoints.count)")
                
                if isMoving {
                    controller.penPoints.removeLast()
                }
                
                let adjPoint = CGPoint(x: location.x, y: 512 - location.y)
                controller.penPoints.append(PenPoint(adjPoint, curved: isCurve))
                endPoint = adjPoint
            }
            
            // Currently drawing Path
            Path { (path) in
                path.move(to: startPoint)
                
                for point in controller.penPoints {
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
            .strokedPath(StrokeStyle(lineWidth: CGFloat(controller.lineWidth), lineCap: .square, lineJoin: .round))
            .foregroundColor(controller.foreColor)
            
            //Circle 1
            Circle()
                .frame(width: 16, height: 16)
                .position(startPoint)
                .foregroundColor(.blue.opacity(0.5))
                .gesture(DragGesture()
                            .onChanged { (value) in
                                self.startPoint = CGPoint(x: value.location.x, y: value.location.y)
                                controller.penPoints.first!.point = value.location
                            })
            
            //Circle 2
            DrawingPointView(point: controller.penPoints.last ?? PenPoint(endPoint))
                .frame(width: 16, height: 16)
                .position(endPoint)
                .foregroundColor(.accentColor.opacity(0.5))
                .gesture(DragGesture()
                            .onChanged { (value) in
                                self.endPoint = CGPoint(x: value.location.x, y: value.location.y)
                            }
                            .onEnded({ ended in
                                if isCurve {
                                    let rPoint = PenPoint((CGPoint(x: ended.location.x, y: ended.location.y)), curved: true)
                                    
                                    controller.penPoints.append(rPoint)
                                    
                                } else {
                                    controller.penPoints.append(PenPoint(CGPoint(x: ended.location.x, y: ended.location.y)))
                                }
                                
                            }))
                .contextMenu {
                    Button("Other") {
                        
                    }
                    Button("Curve") {
                        self.isCurve.toggle()
                        controller.penPoints.last?.toggleCurve()
                    }
                    Button("Close") {
                        closePath()
                    }
                }
            Color.clear
            
            if controller.penPoints.last!.isCurve == true {
                
                makePath(from: controller.penPoints.last!.point, to: controller.penPoints.last!.control1!)
                    .strokedPath(StrokeStyle(lineWidth: CGFloat(1), lineCap: .square, lineJoin: .round))
                    .foregroundColor(.white.opacity(0.3))
                
                Circle().frame(width: 12, height: 12).position(controller.penPoints.last!.control1!) // ?? allPoints.last!.point)
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    let newPoint = CGPoint(x: value.location.x, y: value.location.y)
                                    let dPoint = PenPoint(controller.penPoints.last!.point, curved: true)
                                    dPoint.control1 = newPoint
                                    dPoint.control2 = controller.penPoints.last!.control2
                                    controller.penPoints.removeLast()
                                    controller.penPoints.append(dPoint)
                                }
                                .onEnded({ ended in
                                    let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                    let dPoint = PenPoint(controller.penPoints.last!.point, curved: true)
                                    dPoint.control1 = newPoint
                                    dPoint.control2 = controller.penPoints.last!.control2
                                    controller.penPoints.removeLast()
                                    controller.penPoints.append(dPoint)
                                }))
                
                
                makePath(from: controller.penPoints.last!.point, to: controller.penPoints.last!.control2!)
                    .strokedPath(StrokeStyle(lineWidth: CGFloat(1), lineCap: .square, lineJoin: .round))
                    .foregroundColor(.white.opacity(0.3))
                
                Circle().frame(width: 12, height: 12).position(controller.penPoints.last!.control2!) // ?? allPoints.last!.point)
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    let newPoint = CGPoint(x: value.location.x, y: value.location.y)
                                    let dPoint = PenPoint(controller.penPoints.last!.point, curved: true)
                                    dPoint.control1 = controller.penPoints.last!.control1
                                    dPoint.control2 = newPoint
                                    controller.penPoints.removeLast()
                                    controller.penPoints.append(dPoint)
                                }
                                .onEnded({ ended in
                                    let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                    let dPoint = PenPoint(controller.penPoints.last!.point, curved: true)
                                    dPoint.control1 = controller.penPoints.last!.control1
                                    dPoint.control2 = newPoint
                                    controller.penPoints.removeLast()
                                    controller.penPoints.append(dPoint)
                                }))
                
            }
        }
        .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
        //        .onAppear() {
        //            self.allPoints = [startPoint, endPoint]
        //        }
    }
    
    func makePath(from:CGPoint, to:CGPoint) -> Path {
        var newPath = Path()
        newPath.move(to: from)
        newPath.addLine(to: to)
        return newPath
    }
    
    func closePath() {
        isPathClosed = true
    }
}

struct ShapeDrawingPad: View {
    
    @ObservedObject var controller:DrawingPadController
    
    // Drawing anything we need a rectange
//    @State var rectangle:CGRect = CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: 80, height: 40))
    @Binding var position:CGPoint
    @Binding var size:CGSize
    
    var body: some View {
        ZStack(alignment:.leading) {
            switch controller.shapeInfo.shapeType {
                case .Rectangle:
                    Rectangle()
                        .strokeBorder(controller.foreColor, lineWidth: controller.lineWidth, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) //(controller.foreColor)
                        
//                        .foregroundColor(controller.backColor)
                        .cornerRadius(8)
                        .offset(CGSize(width: position.x, height: position.y))
                        .frame(width: size.width, height: size.height)
                        .gesture(DragGesture()
                                    .onChanged { (value) in
                                        print("Drag: \(value.location)")
                                        position = CGPoint(x: value.location.x, y: value.location.y)
                                        
                                    })
                case .Circle:
                    
                    Circle()
                        .strokeBorder(controller.foreColor, lineWidth: controller.lineWidth, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .foregroundColor(controller.backColor)
                        
                        //.position(controller.shapeInfo.pointStarts)
                        .offset(CGSize(width: position.x, height: position.y))
                        .frame(width: size.width, height: size.height)
                        
                        .gesture(DragGesture()
                                    .onChanged { (value) in
                                        print("Drag: \(value.location)")
                                        position = CGPoint(x: value.location.x, y: value.location.y)
                                        
                                    })
                    
                case .Ellipse:
                    
                    Ellipse()
                        .strokeBorder(controller.foreColor, lineWidth: controller.lineWidth, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .foregroundColor(controller.backColor)
                        .cornerRadius(8)
                        
                        //.position(controller.shapeInfo.pointStarts)
                        .offset(CGSize(width: position.x, height: position.y))
                        .frame(width: size.width, height: size.height)
                        
                        .gesture(DragGesture()
                                    .onChanged { (value) in
                                        print("Drag: \(value.location)")
                                        position = CGPoint(x: value.location.x, y: value.location.y)
                                        
                                    })
                    
                default: Text("default")
            }
        }
        .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.white.opacity(0.05))
    }
}
