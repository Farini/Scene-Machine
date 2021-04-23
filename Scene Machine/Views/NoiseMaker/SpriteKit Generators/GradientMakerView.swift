//
//  GradientMakerView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/12/21.
//

import SwiftUI

struct GradientMakerView: View {
    
    @ObservedObject var controller = GradientController()
    
    var conclusion:([GradientStop]?) -> Void
    
    var body: some View {
        VStack {
            Group {
                Text("Gradients").font(.title)
                Text("Color")
                Divider()
                    .frame(width:250)
            }
            
            Group {
                ForEach(controller.compGradient) { grad in
                    GradientStopRow(controller: controller, stop: grad)
                }
            }
      
            Rectangle()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: makeGradient(), startPoint: .leading, endPoint: .trailing))
                .frame(width: 200, height: 20, alignment: .center)
            Divider()
                .frame(width:250)
            
            HStack {
                Button("Setup") {
                    print("Setup Gradient")
                    conclusion(controller.compGradient)
                }
                Button("Add") {
                    controller.addGradient()
                }
            }
            
            .padding(.bottom)
        }
        
    }
    
    func makeGradient() -> Gradient {
        var stops:[Gradient.Stop] = []
        
        for gc in controller.compGradient {
            stops.append(Gradient.Stop(color: gc.color, location: gc.location))
        }
        
        let gradient = Gradient(stops: stops)
        return gradient
    }
}

struct GradientStopRow: View {
    
    @ObservedObject var controller:GradientController
    @State var stop:GradientStop
    @State var number:Int = 0
    
    var body: some View {
        HStack {
            ColorPicker("+", selection: $stop.color)
                .onChange(of: stop.color, perform: { value in
                    controller.setcolor(color: value, stop: stop)
                })
            Slider(value: $stop.location, in: 0...1)
                .frame(width:200)
                .padding(.horizontal)
                .onChange(of: stop.location, perform: { value in
                    number += 1
                    controller.changeit(stop: self.stop)
                })
            Button("\(number)") {
                controller.changeit(stop: self.stop)
            }
        }
    }
    
}

struct GradientMakerView_Previews: PreviewProvider {
    
    static var previews: some View {
        GradientMakerView { _ in
            
        }
    }
}

class GradientStop:Identifiable {
    var id:UUID = UUID()
    var color:Color
    var location:CGFloat
    
    init(color:Color, location:CGFloat) {
        self.color = color
        self.location = location
    }
    
    static func basicExample() -> [GradientStop] {
        let g1 = GradientStop(color: .white, location: 0)
        let g2 = GradientStop(color: .black, location: 1)
        return [g1, g2]
    }
}
