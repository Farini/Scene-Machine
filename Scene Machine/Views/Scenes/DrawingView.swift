//
//  DrawingView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/1/21.
//

import SwiftUI


struct DPoint:Codable, Identifiable {
    
    var id:UUID
    var point:CGPoint
    var control1:CGPoint?
    var control2:CGPoint?
    var isCurve:Bool
    
    init(_ point:CGPoint) {
        self.point = point
        self.id = UUID()
        self.isCurve = false
    }
}

struct DrawingView: View {
    
    @State private var startPoint: CGPoint = CGPoint(x: 512, y: 512)
    @State private var endPoint: CGPoint = CGPoint(x: 0, y: 1)
    
    @State private var allPoints:[DPoint] = [DPoint(.zero)]
    @State private var lineWidth:Int = 3
    
    @State private var thePath:Path = Path()
    @State var isPathClosed:Bool = false
    @State var isCurve:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button("Close") {
                    closePath()
                }
                .keyboardShortcut("f", modifiers: [])
                
                CounterInput(value: $lineWidth, range: 1...10, title: "Line")
            }
//            GeometryReader { geometry in
//
//            }
            ZStack {
                Path { (path) in
                    path.move(to: startPoint)
                    // path.addLine(to: endPoint)
                    for point in allPoints {
                        if point.isCurve {
                            path.addCurve(to: point.point, control1: point.control1 ?? point.point, control2: point.control2 ?? point.point)
                        } else {
                            path.addLine(to: point.point)
                        }
                        
                        
                    }
                    if isPathClosed {
                        path.closeSubpath()
                    }
                }
                .strokedPath(StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .square, lineJoin: .round))
                .foregroundColor(.red)
                
                //Circle 1
                Circle()
                    .frame(width: 16, height: 16)
                    .position(startPoint)
                    .foregroundColor(.blue)
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    self.startPoint = CGPoint(x: value.location.x, y: value.location.y)
                                })
                
                //Circle 2
                Circle()
                    .frame(width: 16, height: 16)
                    .position(endPoint)
                    .foregroundColor(.green)
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    self.endPoint = CGPoint(x: value.location.x, y: value.location.y)
                                    
                                }
                                .onEnded({ ended in
                                    if isCurve {
                                        var rPoint = DPoint((CGPoint(x: ended.location.x, y: ended.location.y)))
                                        rPoint.isCurve = true
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
                        }
                        Button("Close") {
                            closePath()
                        }
                    }
                Color.clear
            }
            .frame(width: 1024, height: 1024, alignment: .center)
            
        }
        
        
    }
    
    func closePath() {
        isPathClosed = true
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
    }
}

