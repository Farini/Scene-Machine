//
//  DrawingPadController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/14/21.
//

import Cocoa
import SwiftUI
import SceneKit

class DrawingPadController:ObservableObject {
    
    @Published var textureSize:TextureSize = .medSmall // 512
    
    @Published var selectedTool:DrawingTool = .Pencil
    
    @Published var currentLayer:DrawingLayer?
    @Published var layers:[DrawingLayer] = []
    @Published var selectedLayer:DrawingLayer?
    
    // Current Layer properties
    @Published var foreColor:Color = .white
    @Published var backColor:Color = Color(white: 0.1).opacity(0.1)
    @Published var lineWidth:CGFloat = 3
    
    // Background
    @Published var backImage:NSImage = NSImage()
    @Published var backGrid:Bool = false
    
    // Pencil
    @Published var pencilCurrent:PencilStroke = PencilStroke()
    @Published var pencilArray:[PencilStroke] = []
    @Published var images:[NSImage] = []
    
    // Pen
    @Published var penPoints:[PenPoint] = [PenPoint(CGPoint(x: 20, y: 20)), PenPoint(CGPoint(x: 40, y: 20))]
    @Published var isPenPathClosed:Bool = false
    @Published var isPenPathCurved:Bool = false
    
    // Shape
    @Published var shapeInfo:ShapeInfo = ShapeInfo()
    
    /// Creates a new layer. If the current layer has modifications, it adds to the array of layers.
    func newLayer() {
        // Are there modifications currently?
        // If yes, then add a layer
        // if not, ignore
        print("Current Layers: \(layers.count)")
        
        let newLayer = DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        
        if currentLayer?.hasModifications() == true {
            print("Current Layer has modifications")
            
            if currentLayer == layers.last {
                print("Current layer = last")
                layers.removeLast()
                layers.append(currentLayer!)
            } else {
                layers.append(currentLayer!)
            }
            currentLayer = nil
            
        } else {
            print("Current layer != last")
            self.currentLayer = newLayer
        }
        
        switch selectedTool {
            case .Pencil:
                newLayer.pencilStrokes = pencilArray + [pencilCurrent]
                newLayer.penPoints = []
                
            case .Pen:
                newLayer.pencilStrokes = []
                newLayer.penPoints = penPoints
                
            case .Shape:
                print("Not sure yet")
        }
        
        self.pencilCurrent = PencilStroke()
        self.pencilArray = []
        
        if selectedTool == .Pen {
            self.penPoints = [PenPoint(CGPoint(x: 20, y: 20)), PenPoint(CGPoint(x: 40, y: 20))]
        } else {
            self.penPoints = []
        }
    }
    
    // Updates colors and line Width
    func updateTool() {
        currentLayer?.colorData = ColorData(suiColor: foreColor)
        currentLayer?.lineWidth = lineWidth
    }
    
    // Selected a different tool
    func didChangeTool(new:DrawingTool) {
        
        print("Changed Tool: \(new.rawValue)")
        
        if let drawingLayer = currentLayer, drawingLayer.hasModifications() {
            
            if !drawingLayer.penPoints.isEmpty {
                drawingLayer.penPoints = self.penPoints
            }
            
            if drawingLayer == layers.last {
                layers.removeLast()
            }
            layers.append(drawingLayer)
            self.currentLayer = nil
        }
        
        self.currentLayer = DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        
        switch new {
            case .Pen:
                currentLayer?.penPoints = [PenPoint(CGPoint(x: 20, y: 20)), PenPoint(CGPoint(x: 40, y: 20))]
                self.penPoints = [PenPoint(CGPoint(x: 20, y: 20)), PenPoint(CGPoint(x: 40, y: 20))]
            case .Pencil:
                currentLayer?.pencilStrokes = []
            case .Shape:
                print("Not sure")
        }
        
    }
    
    // MARK: - Pencil
    
    func addPencil(stroke:PencilStroke) {
        
//        print("Adding pencil stroke")
        
        if let drawingLayer = currentLayer {
            
            currentLayer!.pencilStrokes.append(stroke)
            if drawingLayer == layers.last {
                print("Pencil current = last")
                layers.removeLast()
                layers.append(drawingLayer)
            } else {
                print("Pencil - New Layer")
                layers.append(drawingLayer)
            }
        } else {
            
            print("Pencil - Creating layer")
            currentLayer = DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
            currentLayer?.pencilStrokes.append(stroke)
            
            layers.append(currentLayer!)
        }
        
        self.makeImage()
        
    }
    
    // MARK: - Pen
    
    func updatePen() {
        let layer = currentLayer ?? DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        if currentLayer == nil { currentLayer = layer }
        currentLayer?.penPoints = penPoints
        layers.append(currentLayer!)
    }
    
    func closePenPath() {
        
        if isPenPathClosed == false {
            let closing = PenPoint(penPoints.first!.point)
            penPoints.append(closing)
        } else {
            if penPoints.count > 2 {
                penPoints.removeLast()
            } else {
                print("Cannot close a path with 2 points or less")
            }
        }
        isPenPathClosed.toggle()
    }
    
    // MARK: - Others
    
    func improve() {
        /*
        // take snapshot
        let snapShot:NSImage? = DrawingPad(currentDrawing: currentLayer,
                                           drawings: currentLayer?.pencilStrokes,
                                           color: $color,
                                           lineWidth: $lineWidth,
                                           size: $controller.textureSize).snapShot(uvSize: controller.textureSize.size)
        
        
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
        
        let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
        madeImage.append(filteredImage)
        
        */
        // run blur filter
        // run de-noise filter
        // get image
        // update ui
    }
    
    /// Transforms this drawing to an Image
    func makeImage() {
        // print("making image")
        
        let snapShot = FlattenedDrawingView(controller: self, layers: layers, backImage: backImage, foreImage: nil, backShape: nil, foreShape: nil).snapShot(uvSize: textureSize.size)
        
        if let snapImage = snapShot {
            print("Adding snapshot to images")
            self.images.append(snapImage)
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
                    self.backImage = image
                }
            }
        }
    }
    
    init(image:NSImage? = nil, size:CGSize? = nil) {
        if let image = image {
            self.backImage = image
        }

    }
}
