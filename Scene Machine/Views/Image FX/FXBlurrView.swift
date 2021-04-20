//
//  FXBlurrView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct FXBlurrView: View {
    
    @State var sliderRange:ClosedRange<Float> = 0...1
    @State var value:Float = 0
    var finish: (_ value:Double) -> Void = {_ in }
    
    @State var blurrType:BlurrType = .Box
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Example")
    
    @State var isPreviewing:Bool = true
    
    var body: some View {
        VStack {
            Text("Blurr Effect").font(.title2).foregroundColor(.accentColor)
            Picker("", selection: $blurrType) {
                ForEach(BlurrType.allCases, id:\.self) { bType in
                    Text(bType.rawValue)
                }
            }
            
            Divider()
            
            switch blurrType {
                case .Box:
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            finish(Double(value))
                        })
                    HStack {
                        Button("/10") {
                            print("divide magnitude")
                        }
                        Spacer()
                        Text("Radius: \(value)")
                        Spacer()
                        Button("x10") {
                            print("multiply magnitude")
                            if sliderRange.lowerBound == 0 {
                                self.sliderRange = 1...10
                                self.value = 5
                            }
                        }
                    }
                case .Disc:
                    Slider(value: $value, in: sliderRange)
                        .onChange(of: value, perform: { value in
                            finish(Double(value))
                        })
                    HStack {
                        Button("/10") {
                            print("divide magnitude")
                        }
                        Spacer()
                        Text("Radius: \(value)")
                        Spacer()
                        Button("x10") {
                            print("multiply magnitude")
                        }
                    }
                case .Gaussian:
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
                case .MaskedVariable:
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
                /*
                 Needs another Slider - Sharpness
                 */
                
                case .Zoom:
                    // Center, Amount
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
                /*
                 Center: Point Input
                 */
                PointInput()
                default:
                    Text("Needs Implementation")
            }
            
            Divider()
            
            // Button & Preview
            imgPreview
            
            HStack {
                Button("Apply") {
                    print("Apply effect")
                }
                Spacer()
                Button("Update Preview") {
                    print("Update Preview")
                    self.updatePreview()
                }
                Toggle("Preview", isOn: $isPreviewing)
            }
            
        }
        .frame(width:250)
        .padding(8)
    }
    
    var imgPreview: some View {
        VStack {
            if isPreviewing {
                if let img = image {
                    Text("Preview")
                    Image(nsImage: img)
                } else {
                    Text("No preview Image").foregroundColor(.gray).padding(12)
                }
            } else {
                Text("Preview is off").foregroundColor(.gray).padding(12)
            }
        }
    }
    
    func updatePreview() {
        print("Updating Preview")
        switch blurrType {
            case .Box:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.boxBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.radius = self.value
                    
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
    
    enum BlurrType:String, CaseIterable {
        case Box
        case Disc
        case Gaussian
        case MaskedVariable
        case MedianFilter
        case Motion
        case NoiseReduction
        case Zoom
    }
}

/// A View to input a CGPoint. For Image Filters
struct PointInput:View {
    
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint = CGPoint.zero
    
    // How to calculate point? see:
    // https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui
    
    var body: some View {
        VStack {
            Text("CGPoint Input")
            let tap = TapGesture().onEnded { tapLocation = dragLocation }
            let drag = DragGesture(minimumDistance: 0).onChanged { value in
                dragLocation = value.location
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
        }
        .frame(width: 200, height: 200, alignment: .center)
    }
}

struct FXBlurrView_Previews: PreviewProvider {
    static var previews: some View {
        FXBlurrView()
    }
}

struct PointInput_Previews: PreviewProvider {
    static var previews: some View {
        PointInput()
    }
}
