//
//  Drawing.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/14/21.
//

import Cocoa

/// The Tool used to draw a layer
enum DrawingTool:String, Codable, CaseIterable {
    case Pencil
    case Pen
    case Shape
}

extension CGLineJoin:Codable {}
extension CGLineCap:Codable {}

/// One Layer that composes a whole image
class DrawingLayer:Codable {
    
    var id:UUID
    var name:String?
    
    var colorData:ColorData
    var lineWidth:CGFloat
    
    var lineJoin:CGLineJoin?     // (Int): miter, round, bevel
    var lineCap:CGLineCap?       // (Int): butt, round, square
    
    var tool:DrawingTool
    var pencilStrokes:[PencilStroke] = []
    var penPoints:[PenPoint] = []
    var shapeInfo:[ShapeInfo] = []
    
    var sublayers:[DrawingLayer] = []
    
    init(tool:DrawingTool, color:NSColor, lineWidth:CGFloat) {
        self.id = UUID()
        self.name = tool.rawValue
        self.colorData = ColorData(nsColor: color)
        self.lineWidth = lineWidth
        self.tool = tool
    }
    
    /// Gets the `NSColor` equivalent
    func color() -> NSColor {
        return colorData.makeNSColor()
    }
}

// MARK: - Pencil

/// A Series of points, connected from the first. For the `Pencil` tool.
struct PencilStroke:Codable {
    var points: [CGPoint] = [CGPoint]()
}

// MARK: - Pen

/// A point marked with a pen. Can be curved (with control points) or straight.
class PenPoint:Codable, Identifiable {
    
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
    
    /// Switches between straight and curved lines
    func toggleCurve() {
        isCurve.toggle()
    }
    
    /// Changes the `point` original property
    func move(to:CGPoint) {
        self.point = to
    }
    
    /// Moves the control points
    func moveControl(_ idx:Int, newPoint:CGPoint) {
        if idx == 1 { self.control1 = newPoint }
        if idx == 2 { self.control2 = newPoint }
    }
    
}

// MARK: - Shapes

/// Defines some basic hape types
enum ShapeType:String, Codable, CaseIterable {
    case Circle
    case Ellise
    case Capsule
    case Rectangle
    case RectRadius4
    case RectRadius8
    case RectRadius12
}

/// Data related to Shape
struct ShapeInfo:Codable {
    var shapeType:ShapeType
    var pointStarts:CGPoint
    var pointEnds:CGPoint
    var extraPoints:[CGPoint] = []
}
