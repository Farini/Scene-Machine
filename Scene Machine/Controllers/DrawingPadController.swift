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
        
        let newLayer = DrawingLayer(tool: selectedTool, color: NSColor(foreColor), lineWidth: lineWidth)
        switch selectedTool {
            case .Pencil:
                newLayer.pencilStrokes = pencilArray + [pencilCurrent]
            case .Pen:
                newLayer.penPoints = penPoints
            case .Shape:
                print("Not sure yet")
        }
        layers.append(newLayer)
        
        self.pencilCurrent = PencilStroke()
        self.pencilArray = []
        self.penPoints = []
        
        if currentLayer == layers.last {
            currentLayer = newLayer
        } else {
            if currentLayer?.hasModifications() == true {
                layers.append(currentLayer!)
            }
            currentLayer = newLayer
        }
        
    }
}
