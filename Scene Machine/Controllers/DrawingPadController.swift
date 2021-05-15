//
//  DrawingPadController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/14/21.
//

import Cocoa
import SwiftUI

class DrawingPadController:ObservableObject {
    
    @Published var textureSize:TextureSize = .medSmall // 512
    
    @Published var selectedTool:DrawingTool = .Pencil
    
    @Published var layers:[DrawingLayer] = []
    @Published var currentLayer:DrawingLayer?
    
    // Current Layer properties
    @Published var foreColor:Color = .white
    @Published var backColor:Color = Color(white: 0.01).opacity(0.1)
    @Published var lineWidth:CGFloat = 3
    
    @Published var images:[NSImage] = []
    
    // Background
    @Published var backImage:NSImage?
    @Published var backGrid:Bool = false
    
    // Pencil
    @Published var pencilCurrent:PencilStroke = PencilStroke()
    @Published var pencilArray:[PencilStroke] = []
    
    // Pen
    @Published var penPoints:[PenPoint] = [PenPoint(CGPoint(x: 20, y: 20))]
    
    func addLayer() {
        // Are there modifications currently?
        // If yes, then add a layer
        // if not, ignore
        print("Current Layers: \(layers.count)")
        
        let newLayer = DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        
        if currentLayer == layers.last {
            currentLayer = newLayer
        } else {
            if currentLayer?.hasModifications() == true {
                layers.append(currentLayer!)
            }
            currentLayer = newLayer
        }
        
        switch selectedTool {
            case .Pencil:
                newLayer.pencilStrokes = pencilArray + [pencilCurrent]
            case .Pen:
                newLayer.penPoints = penPoints
            case .Shape:
                print("Not sure yet")
        }
//        layers.append(newLayer)
        
        self.pencilCurrent = PencilStroke()
        self.pencilArray = []
        self.penPoints = []
        
    }
    
    func addPencil(stroke:PencilStroke) {
        let layer = currentLayer ?? DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        if currentLayer == nil { currentLayer = layer }
        currentLayer?.pencilStrokes.append(stroke)
        layers.append(currentLayer!)
    }
    
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
                    self.backImage = image
                }
            }
        }
    }
}
