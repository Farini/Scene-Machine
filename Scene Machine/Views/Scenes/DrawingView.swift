//
//  DrawingView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/1/21.
//

import SwiftUI

protocol PointMaker {
    func makeMarks() -> [CGPoint]
}

class DPoint:Codable, Identifiable, PointMaker {
    
    var id:UUID
    var point:CGPoint
    var control1:CGPoint?
    var control2:CGPoint?
    var isCurve:Bool
    
    init(_ point:CGPoint, curved:Bool? = false) {
        
        self.point = point
        self.id = UUID()
        self.isCurve = curved!
        if curved == true {
            self.control1 = CGPoint(x: point.x + 5, y: point.x + 5)
            self.control2 = CGPoint(x: point.x - 5, y: point.x - 5)
        }
    }
    
    func toggleCurve() {
        isCurve.toggle()
    }
    
    func move(to:CGPoint) {
        self.point = to
    }
    
    func moveControl(_ idx:Int, newPoint:CGPoint) {
        if idx == 1 { self.control1 = newPoint }
        if idx == 2 { self.control2 = newPoint }
    }
    
    func makeMarks() -> [CGPoint] {
        if !isCurve {
            return [point]
        } else {
            return [point, control1!, control2!]
        }
    }
}

struct DrawingView: View {
    
    @State private var startPoint: CGPoint = CGPoint(x: 256, y: 256)
    @State private var endPoint: CGPoint = CGPoint(x: 240, y: 256)
    
    @State var allPoints:[DPoint] = [DPoint(CGPoint(x: 256, y: 256))]
    @State private var lineWidth:Int = 3
    
    @State private var thePath:Path = Path()
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
                
                CounterInput(value: $lineWidth, range: 1...10, title: "Line")
                Toggle(isOn: $isCurve, label: {
                    Text("Curve")
                })
                
                ColorPicker("Stroke", selection: $strokeColor)
            }

            ZStack {
                
                DrawingBackground { location in

                    if isMoving {
                        allPoints.removeLast()
                    }
                    
                    let adjPoint = CGPoint(x: location.x, y: 512 - location.y)
                    allPoints.append(DPoint(adjPoint, curved: isCurve))
                    endPoint = adjPoint
                }
                
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
    
    func closePath() {
        isPathClosed = true
    }
}

struct DrawingPointView: View {
    
    var point:DPoint
    
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

struct DrawingBackground:NSViewRepresentable {
    
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
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        v.addGestureRecognizer(gesture)
        return v
    }
    
    func makeCoordinator() -> DrawingBackground.Coordinator {
        return Coordinator(tappedCallback: self.tapCallback)
    }
    
    func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<DrawingBackground>) {
        
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
    }
}

