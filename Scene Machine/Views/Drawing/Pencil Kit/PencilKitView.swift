//
//  PencilKitView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI
import PencilKit

struct PencilKitView: View {
    
    @State var drawing:PKDrawing = PKDrawing()
    @State var image:NSImage?
    
    @State var strokePoints:[PKStrokePoint] = []
    @State var ink = PKInk(.pencil, color: .yellow)
    @State var strokeSize:CGSize = CGSize(width: 6, height: 6)
    
    @State var cursorString:String = ""
    
    var body: some View {
        VStack {
            Text("Pencil \(cursorString)")
            if let image = image {
                Image(nsImage: image)
                    .gesture(DragGesture()
                                .onChanged { (value) in
                                    NSCursor.crosshair.set()
                                    if strokePoints.isEmpty {
                                        let p = value.startLocation
                                        let strike = PKStrokePoint(location: p, timeOffset: 0, size: strokeSize, opacity: 1, force: 1, azimuth: 0, altitude: 0)
                                        strokePoints.append(strike)
                                    }
                                    
                                    let strike = PKStrokePoint(location: value.location, timeOffset: 0.1, size: strokeSize, opacity: 1, force: 1, azimuth: 0, altitude: 0)
                                    strokePoints.append(strike)
                                }
                                .onEnded({ ended in
                                    let strike = PKStrokePoint(location: ended.location, timeOffset: 0.1, size: strokeSize, opacity: 1, force: 1, azimuth: 0, altitude: 0)
                                    strokePoints.append(strike)
                                    let cursor = NSCursor.current.image.size
                                    // print("Cursor size: \(cursor)")
                                    self.cursorString = "\(cursor)"
                                    let trans = CGAffineTransform(translationX: 0, y: 0)
                                    
                                    // let ink = PKInk(.pen, color: .yellow)
                                    
                                    let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
                                    let stroke = PKStroke(ink: ink, path: path, transform: trans, mask: nil) //PKStroke(ink: ink, path: path)
                                    let newDrawing = PKDrawing(strokes: [stroke])
                                    
                                    self.drawing.append(newDrawing)
                                    
                                    self.image = self.drawing.image(from: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)), scale: 1)
                                    self.strokePoints = []
                                    
                                }))
            }
            
        }
        .background(Color.black.opacity(0.1))
        .frame(width: 600, height: 400, alignment: .center)
        .onAppear() {
            createDrawing()
        }
        
    }
    
    /// Creates a blob of drawing (mostly for testing)
    func createDrawing() {
        // To create a stroke, we need:
        // ink, path, transform, mask
        let ink = PKInk(.pen, color: .yellow)
        let strike1 = PKStrokePoint(location: CGPoint(x: 15, y: 10), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
        let strike2 = PKStrokePoint(location: CGPoint(x: 25, y: 15), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
        let strike3 = PKStrokePoint(location: CGPoint(x: 30, y: 15), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
        let strike4 = PKStrokePoint(location: CGPoint(x: 35, y: 20), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
        let path = PKStrokePath(controlPoints: [strike1, strike2, strike3, strike4], creationDate: Date())
        let transform = CGAffineTransform(rotationAngle: 1)
        
        let stroke = PKStroke(ink: ink, path: path, transform: transform, mask: nil)
        self.drawing = PKDrawing(strokes: [stroke])
        self.image = self.drawing.image(from: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)), scale: 2)
    }
}

struct PencilKitView_Previews: PreviewProvider {
    static var previews: some View {
        PencilKitView()
    }
}
