//
//  DrawingView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/1/21.
//

import SwiftUI



struct DrawingView: View {
    
    @State private var startPoint: CGPoint = CGPoint(x: 256, y: 256)
    @State private var endPoint: CGPoint = CGPoint(x: 240, y: 256)
    
    @State var allPoints:[PenPoint] = [PenPoint(CGPoint(x: 256, y: 256))]
    @State private var lineWidth:Int = 3
    
    @State var drawnPaths:[PenPoint] = []
    @State var isPathClosed:Bool = false
    @State var isCurve:Bool = false
    @State var isMoving:Bool = true
    
    @State var strokeColor:Color = .red
    
    var body: some View {
        VStack {
            HStack {
                Button("f") {
                    closePath()
                }
                .keyboardShortcut("f", modifiers: [])
                .help("f is for 'face'. It closes the path, creating an edge from the last point to the initial point.")
                Button("t") {
                    print("Terminate")
                    drawnPaths.append(contentsOf: allPoints)
                    allPoints = [PenPoint(CGPoint(x: 256, y: 256))]
                }
                Divider()
                Spacer()
                Toggle(isOn: $isCurve, label: {
                    Text("Curve")
                })
                
                ShortCounterInput(title: "Width", value: $lineWidth, range: 1...20)
                    .frame(width:150)
                
                ColorPicker("Stroke", selection: $strokeColor)
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
                    allPoints.append(PenPoint(adjPoint, curved: isCurve))
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
                                        let rPoint = PenPoint((CGPoint(x: ended.location.x, y: ended.location.y)), curved: true)
                                        
                                        allPoints.append(rPoint)
                                        
                                    } else {
                                        allPoints.append(PenPoint(CGPoint(x: ended.location.x, y: ended.location.y)))
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
                                        let dPoint = PenPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = newPoint
                                        dPoint.control2 = allPoints.last!.control2
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }
                                    .onEnded({ ended in
                                        let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                        let dPoint = PenPoint(allPoints.last!.point, curved: true)
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
                                        let dPoint = PenPoint(allPoints.last!.point, curved: true)
                                        dPoint.control1 = allPoints.last!.control1
                                        dPoint.control2 = newPoint
                                        allPoints.removeLast()
                                        allPoints.append(dPoint)
                                    }
                                    .onEnded({ ended in
                                        let newPoint = CGPoint(x: ended.location.x, y: ended.location.y)
                                        let dPoint = PenPoint(allPoints.last!.point, curved: true)
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
    
    func closePath() {
        isPathClosed = true
    }
}

struct DrawingPointView: View {
    
    var point:PenPoint
    
    var body: some View {
        if point.isCurve {
            qPoint
        } else {
            cPoint
        }
    }
    
    var cPoint: some View {
        Rectangle()
            .frame(width: 16, height: 16)
            .foregroundColor(.green)
        
    }
    var qPoint: some View {
        Circle()
            .frame(width: 16, height: 16)
            .foregroundColor(.green)
    }
}
import SceneKit
struct DrawingCanvas:NSViewRepresentable {
    
    var tapCallback:((CGPoint) -> Void)
    
    class Coordinator:NSObject {
        var tappedCallback:((CGPoint) -> Void)
        init(tappedCallback: @escaping ((CGPoint) -> Void)) {
            self.tappedCallback = tappedCallback
        }
        @objc func tapped(gesture:NSClickGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            
            self.tappedCallback(point)
        }
    }
    
    func makeNSView(context: Context) -> some NSView {
        let v = NSView(frame: .zero)
        v.layer?.backgroundColor = NSColor.red.cgColor
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        v.addGestureRecognizer(gesture)
        return v
    }
    
    func makeCoordinator() -> DrawingCanvas.Coordinator {
        return Coordinator(tappedCallback: self.tapCallback)
    }
    
    func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<DrawingCanvas>) {
        
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
    }
}


