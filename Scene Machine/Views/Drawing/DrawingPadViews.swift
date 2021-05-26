//
//  DrawingPad.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/2/21.
//

import SwiftUI

struct DrawingPadView: View {
    
    @ObservedObject var controller:DrawingPadController
    
    @State private var currentDrawing:PencilStroke = PencilStroke()
    
    @State var imageOverlay:NSImage?
    
    /// The callback that updates the Material with the drawn image
    var imageCallback:((NSImage) -> Void) = {_ in }
    
    // Layers
    @State private var isReordering = false
    @State private var isShowingLayersList:Bool = false
    
    init(image:NSImage, mode:MaterialMode, callback:@escaping ((NSImage) -> Void)) {
        controller = DrawingPadController(image: image, size: image.size)
        controller.textureSize = .medium
        imageCallback = callback
    }
    
    var body: some View {
            
            VStack {
                
                // Top Bar
                HStack {
                    Text("Paint")
                        .font(.title2).foregroundColor(.orange)
                    
                    Picker(selection: $controller.textureSize, label: Text("")) {
                        ForEach(TextureSize.allCases, id:\.self) { texSize in
                            Text("\(texSize.fullLabel)")
                        }
                    }
                    .frame(maxWidth:100)
                    
                    Picker("", selection: $controller.selectedTool) {
                        ForEach(DrawingTool.allCases, id:\.self) { drawTool in
                            Text(drawTool.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth:250)
                    .onChange(of: controller.selectedTool) { newTool in 
                        controller.didChangeTool(new: newTool)
                    }
                    
                    Spacer()
                    
                    Button("Open") {
                        controller.loadImage()
                    }
                    .help("Opens an Image")
                    
                    Button("Layers") {
                        isShowingLayersList.toggle()
                    }
                    .popover(isPresented: $isShowingLayersList) {
                        List() {
                            Section(header: Text("Layers").foregroundColor(.orange)) {
                                ForEach(controller.layers) { layer in
                                    HStack {
                                        Text("\(layer.name ?? "< Untitled >")")
                                            .foregroundColor(controller.selectedLayer == layer ? .orange:.white)
                                        
                                        Spacer()
                                        Button(action: {
                                            controller.layers.removeAll(where: {$0.id == layer.id})
                                        }, label: {
                                            Image(systemName: "trash")
                                        })
                                        Button(action: {
                                            controller.layers.first(where: { $0.id == layer.id })!.isVisible.toggle()
                                        }, label: {
                                            Image(systemName: layer.isVisible ? "eye":"eye.slash")
                                        })
                                        
                                    }
                                    .onTapGesture {
                                        controller.selectedLayer = layer
                                    }
                                    .onLongPressGesture {
                                        withAnimation {
                                            self.isReordering = true
                                        }
                                    }
                                }
                                .onMove(perform: { indices, newOffset in
                                    controller.layers.move(fromOffsets: indices, toOffset: newOffset)
                                })
                            }
                        }
                        .frame(minWidth: 200, maxWidth: 300, alignment: .center)
                    }
                    
                    Button(action: {
                        controller.improve()
                    }, label: {
                        Image(systemName: "wand.and.stars")
                    })
                    .help("Improves the image")
                    
                    Button(action: {
                        print("Grid")
                    }, label: {
                        Image(systemName: "rectangle.split.3x3.fill")
                    })
                    
                    Button("💾") {
                        save()
                    }
                    .help("Saves the image")
                    .keyboardShortcut("s", modifiers: [.command])
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                // Tool Bar
                switch controller.selectedTool {
                    case .Pencil:
                        PencilToolbarView(controller: controller)
                            .padding(.horizontal, 8)
                    case .Pen:
                        PenToolbarView(controller: controller)
                    case .Shape:
                        ShapeToolBar(controller: controller)
                }
                
                Divider()
                
                // Drawing View
                ScrollView([.horizontal, .vertical]) {
                    ZStack(alignment: .center) {
                        
                        ForEach(controller.layers) { layer in
                            if layer.isVisible {
                                DrawingLayerView(controller: controller, layer: layer)
                                    .frame(width:controller.textureSize.size.width, height:controller.textureSize.size.height)
                            }
                        }
                        
                        if let image = controller.backImage {
                            Image(nsImage:image)
                                .resizable()
                                .frame(width:controller.textureSize.size.width, height:controller.textureSize.size.height)
                        }
                        
                        switch controller.selectedTool {
                            case .Pencil:
                                PencilDrawingPad(controller: controller, currentDrawing: $currentDrawing, size: $controller.textureSize)
                                    .frame(width:controller.textureSize.size.width, height:controller.textureSize.size.height)
                            case .Pen:
                                PenDrawingPad(controller: controller, isPathClosed: $controller.isPenPathClosed, isCurve: $controller.isPenPathCurved)
                            case .Shape:
                                ShapeDrawingPad(controller: controller, position:$controller.shapeInfo.pointStarts, size:$controller.shapeInfo.pointEnds)
                        }
                    }
                    .frame(width:controller.textureSize.size.width, height:controller.textureSize.size.height)
                    
                    // Image Update -> Callback
                    .onChange(of: controller.images) { imageArray in
//                        print("Updating image")
                        if let lastImage = imageArray.last {
                            print("DrawingPadView -> Image callback. \(lastImage.size)")
                            self.imageCallback(lastImage)
                        } else {
                            print("No last image")
                        }
                        
                    }
                }
            }
    }
    
    /// Convert to NSImage, and choose file to save
    func save() {
        
        let snapShot = FlattenedDrawingView(controller: controller, layers: controller.layers, backImage: controller.backImage, foreImage: nil, backShape: nil, foreShape: nil).snapShot(uvSize: controller.textureSize.size)
        
        if let image = snapShot {

            let data = image.tiffRepresentation

            let dialog = NSSavePanel() //NSOpenPanel();

            dialog.title                   = "Save drawing image";
            dialog.showsResizeIndicator    = true;
            dialog.showsHiddenFiles        = false;
            dialog.message = "Save the image. Choose 'png' is there is transparency"
            dialog.allowedFileTypes = ["png", "jpg", "jpeg"]

            if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                let result = dialog.url // Pathname of the file

                if let result = result {

                    do {
                        try data?.write(to: result)
                        print("File saved")
                    } catch {
                        print("ERROR: \(error.localizedDescription)")
                    }
                }
            } else {
                // User clicked on "Cancel"
                return
            }
        }
        
    }
    
    /// Reordering `controller.layers`
    func move(from source: IndexSet, to destination: Int) {
        controller.layers.move(fromOffsets: source, toOffset: destination)
        withAnimation {
            isReordering = false
        }
    }
    
}

// MARK: - Layers

/**
 Suitable for screenshots. Can convert to image */
struct FlattenedDrawingView: View {
    
    @ObservedObject var controller:DrawingPadController
    var layers:[DrawingLayer]
    
    var backImage:NSImage?
    var foreImage:NSImage?
    
    var backShape:Path?
    var foreShape:Path?
    
    var body: some View {
        ZStack(alignment: .center) {
            
            if let image = backImage {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
            } else if let path = backShape {
                Path(path.cgPath)
                    .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
            }
            
            ForEach(layers) { layer in
                if layer.isVisible {
                    DrawingLayerView(controller: controller, layer: layer)
                        .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
                }
            }
            
            if let image = foreImage {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
            } else if let path = foreShape {
                Path(path.cgPath)
                    .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height, alignment: .center)
            }
        }
        .frame(width: controller.textureSize.size.width, height: controller.textureSize.size.height)
    }
}

/**
    How: There is enough info to draw both pen and pencil
    Draw from `DrawingLayer` Object */
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


struct DrawingPad_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadView(image: NSImage(), mode: .Diffuse, callback: { newImage in
            print("new image: \(newImage.size)")
        })
            .frame(width: 600)
    }
}

