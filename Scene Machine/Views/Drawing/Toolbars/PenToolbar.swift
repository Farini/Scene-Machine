//
//  PenToolbar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/15/21.
//

import SwiftUI

struct PenToolbarView: View {
    
    @ObservedObject var controller:DrawingPadController
    
//    @State private var startPoint: CGPoint = CGPoint(x: 256, y: 256)
//    @State private var endPoint: CGPoint = CGPoint(x: 240, y: 256)
    
//    @State var allPoints:[PenPoint] = [PenPoint(CGPoint(x: 256, y: 256))]
//    @State private var lineWidth:Int = 3
    
    @State var drawnPaths:[PenPoint] = []
    @State var isPathClosed:Bool = false
    @State var isCurve:Bool = false
    @State var isMoving:Bool = true
    
    @State var strokeColor:Color = .red
    
    var body: some View {
        VStack {
            HStack {
                Button("f") {
//                    closePath()
                    controller.closePenPath()
                }
                .keyboardShortcut("f", modifiers: [])
                .help("f is for 'face'. It closes the path, creating an edge from the last point to the initial point.")
                Button("t") {
                    print("Terminate")
//                    drawnPaths.append(contentsOf: allPoints)
//                    allPoints = [PenPoint(CGPoint(x: 256, y: 256))]
                    controller.updatePen()
                }
                Divider()
                Spacer()
                Toggle(isOn: $controller.isPenPathCurved, label: {
                    Text("Curve")
                })
                
                Divider()
                
                // Color
                ColorPicker("Color", selection: $controller.foreColor)
                    .onChange(of: controller.foreColor, perform: { value in
//                        controller.addLayer()
                        controller.updateTool()
                    })
                
                // Width
                Text("Width \(Int(controller.lineWidth))")
                    .onChange(of: controller.lineWidth, perform: { value in
//                        controller.addLayer()
                        controller.updateTool()
                    })
                TextField("Width", value: $controller.lineWidth, formatter: NumberFormatter.scnFormat)
                    .frame(width:50)
                
                Slider(value: $controller.lineWidth, in: 1.0...15.0, step: 1.0)
                    .padding(4)
            }
            .frame(height:32, alignment: .center)
            .padding(.horizontal, 8)
            
            Divider()
        }
    }
}
struct PenToolbar_Previews: PreviewProvider {
    static var previews: some View {
        PenToolbarView(controller: DrawingPadController())
    }
}
