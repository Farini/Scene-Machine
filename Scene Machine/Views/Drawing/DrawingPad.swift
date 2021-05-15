//
//  DrawingPad.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/2/21.
//

import SwiftUI

struct DrawingPadView: View {
    
    @ObservedObject var controller = DrawingPadController()
    
    @State private var currentDrawing: PencilStroke = PencilStroke()
    @State private var drawings: [PencilStroke] = [PencilStroke]()
//    @State private var color: Color = Color(white: 0.95)
//    @State private var lineWidth: CGFloat = 3.0
    
//    @State private var madeImage:[NSImage] = []
//    @State private var tool:DrawingTool = .Pencil
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Paint")
                    .font(.title2).foregroundColor(.orange)
                
                Picker(selection: $controller.textureSize, label: Text("")) {
                    ForEach(TextureSize.allCases, id:\.self) { texSize in
                        Text("\(texSize.fullLabel)")
                    }
                }
                .frame(maxWidth:100)
                
                Button("💾") {
                    save()
                }
                .help("Saves the image")
                
                Button("Open") {
                    controller.loadImage()
                }
                .help("Improves the image")
                
                Button("⬆️") {
                    controller.improve()
                }
                .help("Improves the image")
                
                Picker("", selection: $controller.selectedTool) {
                    ForEach(DrawingTool.allCases, id:\.self) { drawTool in
                        Text(drawTool.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            DrawingToolbar(controller: controller)
                .padding(.horizontal, 8)
            
            
            Divider()
            
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    
                    ForEach(controller.layers) { layer in
                        if layer.isVisible {
                            DrawingLayerView(controller: controller, layer: layer)
                        }
                    }
                    
                    if let nsimage = controller.backImage {
                        Image(nsImage: nsimage)
                            .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height)
                    }
                    
//                    DrawingPad(currentDrawing: $currentDrawing,
//                               drawings: $drawings,
//                               color: $color,
//                               lineWidth: $lineWidth,
//                               size: $controller.textureSize)
                    DrawingPad(controller: controller, currentDrawing: $currentDrawing, size: $controller.textureSize)
                }
                
            }
        }
    }
    
    func save() {
//        let snapShot:NSImage? = DrawingPad(currentDrawing: $currentDrawing,
//                                           drawings: $drawings,
//                                           color: $color,
//                                           lineWidth: $lineWidth,
//                                           size: $controller.textureSize).snapShot(uvSize: controller.textureSize.size)
//        if let image = snapShot {
//
//            let data = image.tiffRepresentation
//
//            let dialog = NSSavePanel() //NSOpenPanel();
//
//            dialog.title                   = "Save drawing image";
//            dialog.showsResizeIndicator    = true;
//            dialog.showsHiddenFiles        = false;
//            dialog.message = "Save the image. Choose 'png' is there is transparency"
//            dialog.allowedFileTypes = ["png", "jpg", "jpeg"]
//
//            if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
//                let result = dialog.url // Pathname of the file
//
//                if let result = result {
//
//                    do {
//                        try data?.write(to: result)
//                        print("File saved")
//                    } catch {
//                        print("ERROR: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                // User clicked on "Cancel"
//                return
//            }
//        }
        
    }
}

/**
    How: There is enough info to draw both pen and pencil
    Draw from `DrawingLayer` Object
 */
struct DrawingLayerView: View {
    
    @ObservedObject var controller:DrawingPadController
    var layer:DrawingLayer
    
    var body: some View {
        GeometryReader { geometry in
            
            Path { path in
                for drawing in layer.pencilStrokes {
                    self.add(drawing: drawing, toPath: &path)
                }
                if let startPoint = layer.penPoints.first {
                    path.move(to: startPoint.point)
                    for penPoint in layer.penPoints {
                        if penPoint.isCurve {
                            path.addCurve(to: penPoint.point, control1: penPoint.control1!, control2: penPoint.control2!)
                        } else {
                            path.addLine(to: penPoint.point)
                        }
                    }
                }
            }
            .stroke(layer.colorData.getColor(), style: StrokeStyle(lineWidth: layer.lineWidth, lineCap: .round, lineJoin: .bevel, miterLimit: .pi, dash: [], dashPhase: 0))
            
        }
        .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height)
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


struct DrawingPad: View {
    
    @ObservedObject var controller:DrawingPadController
//    @Binding var layer
    @Binding var currentDrawing: PencilStroke
//    @Binding var drawings: [PencilStroke]
//    @Binding var color: Color
//    @Binding var lineWidth: CGFloat
    
    @Binding var size:TextureSize // = TextureSize.medium.size
    
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

struct DrawingToolbar: View {
    
    @ObservedObject var controller:DrawingPadController
    
    @State private var colorPickerShown = false
    
    var body: some View {
        HStack {
            
            Button("↩️") {
//                if self.drawings.count > 0 {
//                    self.drawings.removeLast()
//                }
//                controller.currentLayer?.pencilStrokes.removeLast()
                if controller.layers.isEmpty == false {
                    controller.layers.removeLast()
                }
            }
            .help("Removes the last Drawing")
            
            Button("❌") {
//                self.drawings = [PencilStroke]()
                controller.currentLayer?.pencilStrokes = []
            }
            .help("Clear the drawings")
            
            Button("+") {
                controller.addLayer()
            }
            .help("Add new layer")
            
            Divider()
            
            ColorPicker("Color", selection: $controller.foreColor)
                .onChange(of: controller.foreColor, perform: { value in
                    controller.addLayer()
                })
            
            Text("Width \(Int(controller.lineWidth))")
                .onChange(of: controller.lineWidth, perform: { value in
                    controller.addLayer()
                })
            TextField("Width", value: $controller.lineWidth, formatter: NumberFormatter.scnFormat)
                .frame(width:50)
            
            Slider(value: $controller.lineWidth, in: 1.0...15.0, step: 1.0)
                .padding(4)
        }
        .frame(height:32, alignment: .center)
    }
}

struct DrawingPad_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadView()
    }
}

