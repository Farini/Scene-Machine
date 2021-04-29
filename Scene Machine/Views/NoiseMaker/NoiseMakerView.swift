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
                Text("Quick Noise").font(.title2)
                Spacer()
                Picker("Size", selection: $controller.textureSize) {
                    ForEach(TextureSize.allCases, id:\.self) { tSize in
                        Text(tSize.fullLabel)
                    }
                }
                .frame(width:220)
                
                // Smooth Slide
                Slider(value: $sliderVal, in: 0.1...1.0) { changed in
                    print("Slider Changed")
                    controller.generateNode(smooth:CGFloat(sliderVal))
                } label: {
                    Text("Smooth")
                }
                .frame(maxWidth:200)
                
                Button("Save") {
                    controller.openSavePanel()
                }
                
            }
            .padding(.horizontal)
            
            
            Divider()
            
            // Image ?
            ScrollView([.vertical, .horizontal]) {
                VStack {
                    HStack {
                        Spacer()
                        Image(nsImage: controller.currentImage)
                            .padding(25)
                        Spacer()
                        
                    }
                }
            }
        }
        .frame(minWidth: 700, maxWidth: 2048, minHeight: 600, maxHeight: 2048, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
    }
}

struct NoiseMakerView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseMakerView()
    }
}
