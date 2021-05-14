//
//  DrawingPad.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/2/21.
//

import SwiftUI

struct DrawingPadView: View {
    
    @State private var currentDrawing: PencilStroke = PencilStroke()
    @State private var drawings: [PencilStroke] = [PencilStroke]()
    @State private var color: Color = Color(white: 0.95)
    @State private var lineWidth: CGFloat = 3.0
    
    // To Add
    // -----------------
    // Save Button
    // Image size
    // ---
    @State private var imageSize:TextureSize = TextureSize.medSmall // 512
    @State private var madeImage:[NSImage] = []
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Paint")
                    .font(.title2).foregroundColor(.orange)
                
                Picker(selection: $imageSize, label: Text("")) {
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
                    loadImage()
                }
                .help("Improves the image")
                
                Button("⬆️") {
                    improve()
                }
                .help("Improves the image")
                
                
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            DrawingToolbar(color: $color, drawings: $drawings, lineWidth: $lineWidth)
                .padding(.horizontal, 8)
            
            Divider()
            
            ScrollView([.horizontal, .vertical]) {
                ZStack {
//                    ForEach(0..<madeImage.count) { idx in
//                        let image = madeImage[idx]
//                        Image(nsImage: image)
//                    }
                    if let nsimage = madeImage.last {
                        Image(nsImage: nsimage)
                            .frame(width: imageSize.size.width, height: imageSize.size.height)
                    }
                    
                    DrawingPad(currentDrawing: $currentDrawing,
                               drawings: $drawings,
                               color: $color,
                               lineWidth: $lineWidth,
                               size: $imageSize)
                }
                
            }
        }
    }
    
    func improve() {
        // take snapshot
        let snapShot:NSImage? = DrawingPad(currentDrawing: $currentDrawing,
                                           drawings: $drawings,
                                           color: $color,
                                           lineWidth: $lineWidth,
                                           size: $imageSize).snapShot(uvSize: imageSize.size)
        
        
        // get image
        guard let inputImage = snapShot,
              let inputImgData = inputImage.tiffRepresentation,
              let inputBitmap = NSBitmapImageRep(data:inputImgData),
              let coreImage = CIImage(bitmapImageRep: inputBitmap) else {
            print("⚠️ No Image")
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.boxBlur()
        filter.inputImage = coreImage
        filter.radius = Float(lineWidth / 2)
        
        guard let blurredCI = filter.outputImage else {
            print("⚠️ No Blurred image")
            return
        }
        
        // Center, radius, refraction, width
        let sharpen = CIFilter.unsharpMask()
        sharpen.inputImage = blurredCI
        sharpen.radius = Float(lineWidth)
//        sharpen.sharpness = 0.99
        sharpen.intensity = 1
        
              
        guard let output = sharpen.outputImage,
              let cgOutput = context.createCGImage(output, from: output.extent)
        else {
            print("⚠️ No output image")
            return
        }
        
        let filteredImage = NSImage(cgImage: cgOutput, size: imageSize.size)
        madeImage.append(filteredImage)
        
        
        // run blur filter
        // run de-noise filter
        // get image
        // update ui
    }
    
    func save() {
        let snapShot:NSImage? = DrawingPad(currentDrawing: $currentDrawing,
                                  drawings: $drawings,
                                  color: $color,
                                  lineWidth: $lineWidth,
                                  size: $imageSize).snapShot(uvSize: imageSize.size)
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
    
    func loadImage() {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a scene file.";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        dialog.allowedFileTypes = ["png", "jpg", "tiff"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url, url.isFileURL {
                print("Loaded: \(url.absoluteString)")
                if let image = NSImage(contentsOf: url) {
//                    if image.size != imageSize.size
                    madeImage = [image]
                }
            }
        }
    }
}

struct DrawingPad: View {
    
    @Binding var currentDrawing: PencilStroke
    @Binding var drawings: [PencilStroke]
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    
    @Binding var size:TextureSize // = TextureSize.medium.size
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for drawing in self.drawings {
                    self.add(drawing: drawing, toPath: &path)
                }
                self.add(drawing: self.currentDrawing, toPath: &path)
            }
            .stroke(self.color, style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .bevel, miterLimit: .pi, dash: [], dashPhase: 0))
//            .stroke(style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round, miterLimit: .pi, dash: [], dashPhase: 0))
            
//            .stroke(self.color, lineWidth: self.lineWidth)
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
                        self.drawings.append(self.currentDrawing)
                        self.currentDrawing = PencilStroke()
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
    
    @Binding var color: Color
    @Binding var drawings: [PencilStroke]
    @Binding var lineWidth: CGFloat
    
    @State private var colorPickerShown = false
    
    // To Add
    // -----------------
    // Save Button
    // Image size
    // ---
    // Background Color
    // Background Image
    // Background Grid
    // ---
    // Stroke type
    
    var body: some View {
        HStack {
            
            Button("↩️") {
                if self.drawings.count > 0 {
                    self.drawings.removeLast()
                }
            }
            .help("Removes the last Drawing")
            
            Button("❌") {
                self.drawings = [PencilStroke]()
            }
            .help("Clear the drawings")
            
            Divider()
            
            ColorPicker("Color", selection: $color)
            
            Text("Width \(Int(lineWidth))")
            Slider(value: $lineWidth, in: 1.0...15.0, step: 1.0)
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

