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
                let rPoint = CGPoint(x: (CGFloat(multiplier) * value.location.x) / 200, y: (CGFloat(multiplier) * value.location.y) / 200)
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

struct CounterInput: View {
    
    @Binding var value:Int
    
    var range:ClosedRange<Int> = 1...10
    var title:String
    
    @State private var minusEnabled:Bool = true
    @State private var plusEnabled:Bool = true
    
    var body: some View {
        VStack {
            Text(title).font(.title3)
                .padding(.vertical, 6)
            HStack {
                
                Image(systemName: minusEnabled ? "minus.circle.fill" : "minus.circle")
                    .onTapGesture {
                        if value > range.lowerBound {
                            value -= 1
                            plusEnabled = true
                        }
                        if value == range.lowerBound {
                            minusEnabled = false
                            plusEnabled = true
                        }
                    }
                Spacer()
                Text("\(value)")
                Spacer()
                Image(systemName: plusEnabled ? "plus.circle.fill" : "plus.circle")
                    .onTapGesture {
                        if value < range.upperBound {
                            value += 1
                            minusEnabled = true
                        }
                        if value == range.upperBound {
                            plusEnabled = false
                            minusEnabled = true
                        }
                    }
            }
            .font(.title3)
            .frame(maxWidth:200)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

struct ShortCounterInput: View {
    
    var title:String
    @Binding var value:Int
    var range:ClosedRange<Int> = 1...10
    
    @State private var minusEnabled:Bool = true
    @State private var plusEnabled:Bool = true
    
    var body: some View {
        HStack {
            HStack {
                
                Image(systemName: minusEnabled ? "minus.circle.fill" : "minus.circle")
                    .onTapGesture {
                        if value > range.lowerBound {
                            value -= 1
                            plusEnabled = true
                        }
                        if value == range.lowerBound {
                            minusEnabled = false
                            plusEnabled = true
                        }
                    }
                Spacer()
                Text(title).font(.title3)
                    .padding(.vertical, 6)
                Text("\(value)")
                Spacer()
                Image(systemName: plusEnabled ? "plus.circle.fill" : "plus.circle")
                    .onTapGesture {
                        if value < range.upperBound {
                            value += 1
                            minusEnabled = true
                        }
                        if value == range.upperBound {
                            plusEnabled = false
                            minusEnabled = true
                        }
                    }
            }
            .font(.title3)
            .frame(maxWidth:200)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

import SceneKit
struct NodeXYZInput:View {
    
    @State var node:SCNNode
    
    var body: some View  {
        VStack {
            Text("Position").font(.headline).foregroundColor(.orange)
            HStack {
                Text("X")
                TextField("X", value: $node.position.x, formatter: NumberFormatter.scnFormat)
                Text("Y")
                TextField("Y", value: $node.position.y, formatter: NumberFormatter.scnFormat)
                Text("Z")
                TextField("Z", value: $node.position.z, formatter: NumberFormatter.scnFormat)
            }
            Divider()
            Text("Euler Angles").font(.headline).foregroundColor(.orange)
            HStack {
                Text("X")
                TextField("X", value: $node.eulerAngles.x, formatter: NumberFormatter.scnFormat)
                Text("Y")
                TextField("Y", value: $node.eulerAngles.y, formatter: NumberFormatter.scnFormat)
                Text("Z")
                TextField("Z", value: $node.eulerAngles.z, formatter: NumberFormatter.scnFormat)
            }
            Divider()
            Text("Scale").font(.headline).foregroundColor(.orange)
            HStack {
                Text("X")
                TextField("X", value: $node.scale.x, formatter: NumberFormatter.scnFormat)
                Text("Y")
                TextField("Y", value: $node.scale.y, formatter: NumberFormatter.scnFormat)
                Text("Z")
                TextField("Z", value: $node.scale.z, formatter: NumberFormatter.scnFormat)
            }
        }
        .padding(.horizontal, 4)
        
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

struct CounterInput_Previews: PreviewProvider {
    static var previews: some View {
        CounterInput(value: .constant(2), title: "Test")
        ShortCounterInput(title: "Stroke", value: .constant(5), range: 1...10)
        NodeXYZInput(node:SCNNode()).frame(width:300)
        
    }
}
