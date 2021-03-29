//
//  NoiseMakerView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 3/29/21.
//

import SwiftUI

struct NoiseMakerView: View {
    
    @ObservedObject var controller:NoiseController = NoiseController()
    @State var sliderVal:Float = Float(0.5)
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Noise Maker").font(.title)
                Button("Save panel") {
                    controller.openSavePanel()
                }
                // Button Bar ?
                Slider(value: $sliderVal, in: 0...1) { changed in
                    print("Slider Changed")
                    controller.generateNode(smooth:CGFloat(sliderVal))
                }
                .frame(maxWidth:200)
            }
            
            
            Divider()
            // Image ?
            Image(nsImage: controller.currentImage)
        }
        .frame(minWidth: 700, maxWidth: 2048, minHeight: 600, maxHeight: 2048, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
    }
}

struct NoiseMakerView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseMakerView()
    }
}
