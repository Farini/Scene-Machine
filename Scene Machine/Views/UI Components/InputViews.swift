//
//  InputViews.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/24/21.
//

import Foundation
import SwiftUI

/// A View to input a CGPoint. For Image Filters
struct PointInput:View {
    
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint = CGPoint.zero
    
    /// Change this if CGPoint can be different than 200 x 200
    @State var multiplier: Float = 1.0
    
    /// Completion function.
    var finished: (_ value:CGPoint) -> Void = {_ in }
    
    // How to calculate point? see:
    // https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui
    
    var body: some View {
        VStack {
            Text("CGPoint Input")
            let tap = TapGesture().onEnded { tapLocation = dragLocation }
            let drag = DragGesture(minimumDistance: 0).onChanged { value in
                dragLocation = value.location
                let rPoint = CGPoint(x: CGFloat(multiplier) * value.location.x, y: CGFloat(multiplier) * value.location.y)
                finished(rPoint)
            }.sequenced(before: tap)
            ZStack {
                Text("\(dragLocation.x) x \(dragLocation.y)").foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: 200, height: 200, alignment:.center)
                    .foregroundColor(Color.white.opacity(0.1))
                    .gesture(drag)
                Circle()
                    .frame(width: 10, height: 10, alignment: .topLeading)
                    .foregroundColor(.red)
                    .offset(x: dragLocation.x - 100, y: dragLocation.y - 100)
                
            }
            .frame(width: 200, height: 200, alignment: .center)
        }
    }
}

/// A View to input a CGPoint. For Image Filters
struct DirectionVectorInput:View {
    
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint = CGPoint.zero
    var origin:CGPoint = CGPoint(x: 100, y: 100)
    
    // How to calculate point? see:
    // https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui
    
    var body: some View {
        VStack {
            Text("Vector Input")
            let tap = TapGesture().onEnded { tapLocation = dragLocation }
            let drag = DragGesture(minimumDistance: 0).onChanged { value in
                dragLocation = value.location
            }.sequenced(before: tap)
            ZStack {
                Text("Vec: \(origin.x - dragLocation.x) \(origin.y - dragLocation.y)")
                Rectangle()
                    .frame(width: 200, height: 200, alignment:.center)
                    .foregroundColor(Color.white.opacity(0.1))
                    .gesture(drag)
                Circle()
                    .frame(width: 10, height: 10, alignment: .topLeading)
                    .foregroundColor(.red)
                    .offset(x: dragLocation.x - 100, y: dragLocation.y - 100)
                
            }
            .frame(width: 200, height: 200, alignment: .center)
        }
    }
}

/// An Effective Slider
struct SliderInputView: View {
    
    @State var value:Float
    @State var vRange:ClosedRange<Float> = 0...1
    @State var title:String = ""
    
    /// Completion function.
    var finished: (_ value:Double) -> Void = {_ in }
    
    var body: some View {
        VStack {
            let leftTitle = String(format: "%.2f", arguments: [vRange.lowerBound])
            let rightTitle = String(format: "%.2f", arguments: [vRange.upperBound])
            Text(title.isEmpty ? "Input":"\(title)")
            Slider(value: $value, in: vRange)
                .onChange(of: value, perform: { _ in
                    didSlide()
                })
            HStack {
                Text(leftTitle)
                Spacer()
                Text("\(value)")
                Spacer()
                Text(rightTitle)
            }
            .offset(x: 0, y: -12)
        }
        .padding(8)
        .frame(minWidth: 100, maxWidth: 250, minHeight: 40, maxHeight: 100, alignment: .top)
        .padding(.bottom, 10)
    }
    
    func didSlide() {
        let dbl = Double(value)
        self.finished(dbl)
    }
}

struct PointInput_Previews: PreviewProvider {
    static var previews: some View {
        PointInput()
    }
}

struct SliderInput_Previews: PreviewProvider {
    static var previews: some View {
        SliderInputView(value: 0.5)
    }
}

struct PointInput3_Previews: PreviewProvider {
    static var previews: some View {
        DirectionVectorInput()
    }
}
