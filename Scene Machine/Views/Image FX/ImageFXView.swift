//
//  ImageFXView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

enum FXState {
    case empty
    case Blurr
    case Color
}

struct ImageFXView: View {
    
    @ObservedObject var controller:ImageFXController = ImageFXController(image: nil)
    
    @State private var popover:Bool = false
    @State private var state:FXState = .empty
    
    @State var sliderValue:Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                switch state {
                    case .empty:
                        Text("Select filter type").foregroundColor(.gray)
                    case .Blurr:
                        FXBlurrView(applied: { img in
                                        apply(image: img) },
                                    image: controller.openingImage,
                                    isPreviewing: true)
                    case .Color:
                        FXColorView(value: 1,
                                    applied: { (image) in
                            apply(image: image)},
                                    image: controller.openingImage,
                                    inputColor: .white)
                        
                    default:
                        Text("Left View")
                        Text("Needs implementation")
                }
                Spacer()
            }
            
            VStack {
                
                // Top Bar
                HStack {
                    
                    Button("Save") {
                        self.saveImage()
                    }
                    
                    Button("Load") {
                        // Load an image
                        print("Load an image")
                        controller.loadImage()
                    }
                    
                    Divider().frame(height:32)
                    
                    Button("Blur") {
//                        let v = CIVector(values: [2, 3, 4], count: 3)
                        self.state = .Blurr
                    }
                    
                    Button("Color") {
                        self.state = .Color
                    }
                    
                    Spacer()
                    
                    Button("More") {
                        popover.toggle()
                    }
                    .popover(isPresented: $popover) {
                        VStack {
                            
                            Group {
                                Button("Blurr") {
                                    //                                        controller.blurrImage()
                                    self.state = .Blurr
                                }
                                Button("Crystalize") {
                                    controller.crystallize()
                                }
                                Button("Pixellate") {
                                    controller.pixellate()
                                }
                                Button("Twirl") {
                                    controller.twirlDistortion()
                                }
                            }
                            
                            Group {
                                Button("Caustic Noise") {
                                    controller.causticNoise()
                                }
                                Button("Caustic Refraction") {
                                    controller.causticRefraction()
                                }
                                Button("Lens Flare") {
                                    controller.lensFlare()
                                }
                            }
                            
                            Button("Metal Color") {
                                controller.metalColor()
                            }
                            Button("Black2Alpha") {
                                controller.metalBlackToTransparent()
                            }
                            Button("Mix last") {
                                controller.mixImages()
                            }
                            .disabled(controller.secondImage == nil)
                            
                            Divider()
                            Button("Save") {
                                self.saveImage()
                            }
                        }
                        .padding()
                    }
                }
                .padding(.horizontal, 8)
                
                Divider()
                
                // Current Image
                ScrollView {
                    Image(nsImage: controller.openingImage)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
            }
        }
    }
    

    /// Used When Filter views wants to Apply image
    func apply(image:NSImage) {
        // Set the image in the controller
        controller.openingImage = image
    }
    
    func saveImage() {
        
        // Saving with SwiftUI
        // https://stackoverflow.com/questions/56645819/how-to-open-file-dialog-with-swiftui-on-platform-uikit-for-mac
        // Swift 5
        // https://ourcodeworld.com/articles/read/1117/how-to-implement-a-file-and-directory-picker-in-macos-using-swift-5
        
        controller.openSavePanel(for: controller.openingImage)
    }
    
}

struct InputSlider: View {
    
    var sliderRange:ClosedRange<Float> = 0...1
    
    @State var value:Float = 0
    
    var finish: (_ value:Double) -> Void = {_ in }
    
    var body: some View {
        VStack {
            Slider(value: $value, in: sliderRange)
                .onChange(of: value, perform: { value in
                    finish(Double(value))
                })
            HStack {
                Button("/10") {
                    print("divide magnitude")
                }
                Spacer()
                Text("Value: \(value)")
                Spacer()
                Button("x10") {
                    print("multiply magnitude")
                }
            }
        }
    }
}

struct ImageFXView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFXView()
    }
}

struct InputViews_Previews: PreviewProvider {
    static var previews: some View {
        InputSlider()
    }
}

extension NumberFormatter {
    static var slider:NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }
}
