//
//  SpriteNoiseMaker.swift
//  Scene Machine
//
//  Created by Carlos Farini on 3/29/21.
//

import SwiftUI
import SpriteKit
import GameKit

struct SpriteNoiseMaker: View {
    
    @State var scene: GameScene = GameScene(size: CGSize(width: 600, height: 600))
    @ObservedObject var controller:SpriteKitNoiseController = SpriteKitNoiseController()
    @ObservedObject var gradControl:GradientController = GradientController()
    
    @State var noiseSelection:NoiseType = .Perlin
    @State var textureSize:TextureSize = .medium
    
    // Colors Sources
    // Color palette
    // Image Size: 256, 512, 1024, 2048, 4096
    
    @State var noisePop:Bool = false
    @State var gradientPop:Bool = false
    @State var sizePop:Bool = false
    @State var stops:[GradientStop] = []
    
    let dblFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    Text("Noise").foregroundColor(.orange).font(.title2)
                        .padding(.top, 8)
                    
                    Picker("Size", selection: $controller.textureSize) {
                        ForEach(TextureSize.allCases, id:\.self) { tSize in
                            Text(tSize.fullLabel)
                        }
                        .onChange(of: controller.textureSize, perform: { value in
                            //                        self.image = NSImage(size: value.size)
                            controller.updateSizes()
                            controller.updateNoise()
                        })
                    }
                    .frame(width: 150, alignment: .center)
                    Picker("Type", selection: $controller.noiseType) {
                        ForEach(NoiseType.allCases, id:\.self) { noiseType in
                            Text(noiseType.rawValue)
                        }
                    }
                    .onChange(of: controller.noiseType, perform: { value in
                        controller.updateNoise()
                    })
                    Divider()
                    Group {
                        HStack {
                            Text("Frequency")
                            Spacer()
                            TextField("", value: $controller.frequency, formatter:dblFormatter)
                                .frame(maxWidth:50)
                                .onChange(of: controller.frequency, perform: { value in
                                    controller.updateNoise()
                                })
                        }
                        HStack {
                            Text("Octaves")
                            Spacer()
                            TextField("", value: $controller.octaves, formatter:intFormatter)
                                .frame(maxWidth:50)
                                .onChange(of: controller.octaves, perform: { value in
                                    controller.updateNoise()
                                })
                        }
                        HStack {
                            Text("Persistency")
                            Spacer()
                            TextField("", value: $controller.persistance, formatter:dblFormatter)
                                .frame(maxWidth:50)
                                .onChange(of: controller.persistance, perform: { value in
                                    controller.updateNoise()
                                })
                        }
                        HStack {
                            Text("Lacunarity")
                            Spacer()
                            TextField("", value: $controller.lacunarity, formatter:dblFormatter)
                                .frame(maxWidth:50)
                                .onChange(of: controller.lacunarity, perform: { value in
                                    controller.updateNoise()
                                })
                        }
                        Divider()
                    }
                    
                    // Gradients
                    Group {
                        SpriteNoiseColorBar(controller: gradControl) { gradients in
                            var nColors:[NSNumber:NSColor] = [:]
                            for gradient in gradients {
                                let num = NSNumber(value:Float(gradient.location))
                                let col:NSColor = gradient.getNSColor()
                                nColors[num] = col
                            }
                            controller.noiseColors = nColors
                            controller.updateNoise()
                        }
                    }
                    
                    
                    // Buttons
                    Group {
                        HStack {
                            Button("Update") {
                                controller.updateNoise()
                            }
                            Button("+") {
                                gradControl.addGradient()
                            }
                            Button("Save") {
                                controller.openSavePanel()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 180, maxWidth: 250, alignment: .center)
                .padding(.horizontal, 6)
            }
            
            .frame(minWidth: 240, maxWidth: 280, alignment: .center)
            
            
            ZStack(alignment: .top) {
                
                ScrollView {
                    SpriteView(scene: controller.scene).frame(width: scene.size.width, height: scene.size.height)
                }
            }
        }
    }
}

struct SpriteNoiseColorBar: View {
    
    @ObservedObject var controller:GradientController
    
    let dblFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    
    /// Completion function. Returns an image
    var applied: (_ stops:[GradientStop]) -> Void = {_ in }
    
    var body: some View {
        VStack {
            Text("Colors").font(.title2).foregroundColor(.orange)
            
            ForEach(0..<controller.compGradient.count, id:\.self) { idx in
                VStack {
                    
                    Divider()
                    
                    HStack {
                        Text("#\(idx)")
                        ColorPicker("", selection: $controller.compGradient[idx].color)
                            
                        Spacer()
                        Text("\(controller.compGradient[idx].location)")
                    }
                    
                    
                    Slider(value: $controller.compGradient[idx].location, in: -1...1, minimumValueLabel: Text("-1"), maximumValueLabel: Text("1"), label: {
                        Text("")
                    })
                    
                }
            }
            
            Divider()
            
            // Buttons
            HStack {
                Button("Apply Color") {
                    applied(controller.compGradient)
                }
            }
        }
        .frame(width:200)
        .padding(.trailing, 6)
    }
}

struct SpriteNoiseMaker_Previews: PreviewProvider {
    static var previews: some View {
        SpriteNoiseMaker()
    }
}

//struct SpritePopover_Previews:PreviewProvider {
//    static var previews: some View {
//        SpriteNoiseColorBar(controller: GradientController())
//    }
//}

enum NoiseType:String, CaseIterable {
    case Perlin
    case Billow
    case Ridged
    case Voronoi
    case Cylinder
    case Sphere
    case Checker
}


