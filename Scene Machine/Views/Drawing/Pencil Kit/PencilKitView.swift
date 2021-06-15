//
//  PencilKitView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI
import PencilKit

fileprivate enum InkTypes:String, CaseIterable {
    case marker
    case pen
    case pencil
    
    var pkInkType:PKInk.InkType {
        switch self {
            case .marker: return .marker
            case .pen: return .pen
            case .pencil: return .pencil
        }
    }
}

struct PencilKitView: View {
    
    @State var drawing:PKDrawing = PKDrawing()
    @State var image:NSImage = NSImage(size: CGSize(width: 256, height: 256))
    
    @State var strokePoints:[PKStrokePoint] = []
    
    // Toolbar settings
    @State fileprivate var inkType:InkTypes = .pen
    @State var inkColor:Color = .yellow
    @State var strokeWidth:CGFloat = 6.0
    
    
    var body: some View {
        
        VStack {
            PencilKitToolbar(color:$inkColor, inkType: $inkType, strokeSize: $strokeWidth)
            
            // Image Container
            VStack {
                Image(nsImage: image)
                    .gesture(DragGesture()
                        .onChanged { (value) in
                            if strokePoints.isEmpty {
                                let p = value.startLocation
                                let strike = PKStrokePoint(location: p, timeOffset: 0, size: CGSize(width:strokeWidth, height: strokeWidth), opacity: 1, force: 1, azimuth: 0, altitude: 0)
                                    strokePoints.append(strike)
                            }
                                
                            let strike = PKStrokePoint(location: value.location, timeOffset: 0.1, size: CGSize(width: strokeWidth, height: strokeWidth), opacity: 1, force: 1, azimuth: 0, altitude: 0)
                                strokePoints.append(strike)
                        }
                        .onEnded{ ended in
                            let strike = PKStrokePoint(location: ended.location, timeOffset: 0.1, size: CGSize(width: strokeWidth, height: strokeWidth), opacity: 1, force: 1, azimuth: 0, altitude: 0)
                            strokePoints.append(strike)
                                
                            let trans = CGAffineTransform(translationX: 0, y: 0)
                            let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
                            let stroke = PKStroke(ink: makeInk(), path: path, transform: trans, mask: nil)
                            let newDrawing = PKDrawing(strokes: [stroke])
                                
                            self.drawing.append(newDrawing)
                                
                            self.image = self.drawing.image(from: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)), scale: 1)
                            self.strokePoints = []
                        }
                )
            }
            .background(Color.black.opacity(0.1))
            .frame(width: 600, height: 350, alignment: .center)
            .onAppear() {
                createDrawing()
            }
        }
    }
    
    func makeInk() -> PKInk {
        return PKInk(inkType.pkInkType, color: NSColor(inkColor))
    }
    
    
    
    /// Creates a blob of drawing (mostly for testing)
    func createDrawing() {
        // To create a stroke, we need:
        // ink, path, transform, mask
//        let ink = PKInk(.pen, color: .yellow)
//        let strike1 = PKStrokePoint(location: CGPoint(x: 15, y: 10), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
//        let strike2 = PKStrokePoint(location: CGPoint(x: 25, y: 15), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
//        let strike3 = PKStrokePoint(location: CGPoint(x: 30, y: 15), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
//        let strike4 = PKStrokePoint(location: CGPoint(x: 35, y: 20), timeOffset: 0.1, size: CGSize(width: 8, height: 8), opacity: 1, force: 1, azimuth: 1, altitude: 0)
//        let path = PKStrokePath(controlPoints: [strike1, strike2, strike3, strike4], creationDate: Date())
//        let transform = CGAffineTransform(rotationAngle: 1)
        
        // let stroke = PKStroke(ink: ink, path: path, transform: transform, mask: nil)
        
        self.drawing = PKDrawing(strokes: [])
        
        self.image = self.drawing.image(from: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)), scale: 2)
        
    }
}

struct PencilKitToolbar: View {
    
    @Binding var color:Color
    @Binding fileprivate var inkType:InkTypes
    @Binding var strokeSize:CGFloat
    
    @State private var isShowingSizeSlider:Bool = false
    
    var body: some View {
        HStack {
            Text("Pencil Toolbar").font(.title2)
            
            Picker("", selection: $inkType) {
                ForEach(InkTypes.allCases, id:\.self) { ink in
                    Text(ink.rawValue)
                }
            }
            .frame(width:120)
            
            Spacer()
            
            
            
            Group {
                Button(action: {
                    isShowingSizeSlider.toggle()
                }, label: {
                    Image(systemName: "scribble")
                })
//                .onLongPressGesture {
//                    isShowingSizeSlider.toggle()
//                }
                .popover(isPresented: $isShowingSizeSlider) {
                    VStack {
                        Slider(value: $strokeSize, in: 0.3...20)
                            .frame(width:200)
                        .padding()
                    }
                }
                TextField("Width", value: $strokeSize, formatter: NumberFormatter.doubleDigit)
                    .frame(width:60)
            }
            
            ColorPicker("", selection: $color)

        }
        .padding(6)
        .background(Color.black.opacity(0.15))
    }
    
    func makeRange() -> ClosedRange<CGFloat> {
        let rMin:CGFloat = min(0.3, strokeSize / 3.0)
        let rMax:CGFloat = max(40, (strokeSize * 10.0).rounded() / 10.0)
        return rMin...rMax
    }
}

struct PencilKitView_Previews: PreviewProvider {
    static var previews: some View {
        PencilKitView()
    }
}
