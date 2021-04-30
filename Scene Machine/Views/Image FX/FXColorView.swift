//
//  FXColorView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct FXColorView: View {
    
    @State var sliderRange:ClosedRange<Float> = 0...1
    @State var value:Float = 0
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var colorType:ColorType = .Threshold
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"ModuleBake4")
    
    @State var isPreviewing:Bool = true
    
    @State var inputColor:Color = .white
    
    @State private var undoImages:[NSImage] = []
    
    var body: some View {
        VStack {
            Text("Color Effect").font(.title2).foregroundColor(.accentColor)
            Picker("", selection: $colorType) {
                ForEach(ColorType.allCases, id:\.self) { bType in
                    Text(bType.rawValue)
                }
            }
            
            Divider()
            
            switch colorType {
                case .Threshold:
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            //                            finish(Double(value))
                            print("Value changed")
                        })
                    HStack {
                        Spacer()
                        Text("Threshold: \(value)")
                        Spacer()
                    }
                    
                case .Monochrome:
                    // Color, and Intensity
                    ColorPicker("", selection:$inputColor)
                    
                    SliderInputView(value: 0.4, vRange: 0...1, title: "Intensity") { newValue in
                        self.value = Float(newValue)
                    }
                    .padding(.bottom, 20)
                    
                case .AbsoluteDifference:
                    Image("Example")
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            //                            finish(Double(value))
                            print("Value changed")
                        })
                    
                /*
                 A droppable image should be implemented here
                 */
                case .Gaussian:
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            // finish(Double(value))
                            print("Value changed")
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
                case .MaskedVariable:
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            // finish(Double(value))
                            print("Value changed")
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
                    Image("Example")
                /*
                 A droppable image should be implemented here
                 */
                case .MedianFilter:
                    // (No input)
                    Text("There is no input for this filter").foregroundColor(.gray)
                case .Motion:
                    // Radius and angle
                    // Radius
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            // finish(Double(value))
                            print("Value changed")
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
                    // Angle
                    /*
                     Use Vector from: Point Input
                     */
                    PointInput()
                case .NoiseReduction:
                    // Noise Level, Sharpness
                    // Default values: 0.02, 0.4
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            // finish(Double(value))
                            print("Value changed")
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
                /*
                 Needs another Slider - Sharpness
                 */
                
                case .Zoom:
                    // Center, Amount
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            // finish(Double(value))
                            print("Value changed")
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
                    /*
                     Center: Point Input
                     */
                    PointInput()
                    
            }
            
            Divider()
            
            // Button & Preview
            imgPreview
            
            HStack {
                Button("Apply") {
                    print("Apply effect")
                    self.apply()
                }
                Spacer()
                Button("↩️ Undo") {
                    if let lastImage = undoImages.dropLast().first {
                        self.image = lastImage
                    }
                }
                Button("🔄 Update") {
                    print("Update Preview")
                    self.undoImages.append(self.image!)
                    self.updatePreview()
                }
            }
        }
        .frame(width:250)
        .padding(8)
        .onAppear() {
//            self.image = controller.openingImage
            if let img = image {
                self.undoImages.append(img)
            }
        }
    }
    
    /// The preview Image
    var imgPreview: some View {
        VStack {
            Toggle("Preview", isOn: $isPreviewing)
            if isPreviewing {
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: 200, maxWidth: 250, minHeight: 200, maxHeight: 250, alignment: .center)
                        
                } else {
                    Text("No preview Image").foregroundColor(.gray).padding(12)
                }
            } else {
                Text("Preview is off").foregroundColor(.gray).padding(12)
            }
        }
    }
    
    // MARK: - Methods
    
    
    /// Updates the image preview
    func updatePreview() {
        print("Updating Preview")
        switch colorType {
            case .Threshold:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.colorThreshold()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.threshold = self.value
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .Monochrome:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.colorMonochrome()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.color = CIColor(cgColor: inputColor.cgColor!)
                    currentFilter.intensity = self.value
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
                
            default:
                print("Needs Implementation")
        }
    }
    
    /// Applies the effect
    func apply() {
        
        // To apply, pass a function from the parent view
        // and return a NSImage when the effects are ready
        guard let image = image else {
            print("No image")
            return
        }
        
        applied(image)
    }
    
    enum ColorType:String, CaseIterable {
        case Threshold
        
        case Monochrome
        
        case AbsoluteDifference
        
        
        
        
        case Gaussian
        case MaskedVariable
        case MedianFilter
        case Motion
        case NoiseReduction
        case Zoom
    }
}

struct FXColorView_Previews: PreviewProvider {
    static var previews: some View {
        FXColorView()
    }
}
