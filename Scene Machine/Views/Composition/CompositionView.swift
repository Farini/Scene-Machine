//
//  CompositionView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

import SwiftUI

struct CompositionView: View {
    
    @ObservedObject var controller = ImageCompositionController()
    
    @State var isDisplayingSecondImage:Bool = false
    @State private var dragOver:Bool = false
    @State private var zoomLevel:Double = 1.0
    
    var body: some View {
        
        NavigationView {
            
            // Left
            ScrollView {
                
                VStack(alignment:.leading) {
                    
                    Group {
                        Text("Tools").font(.title3).foregroundColor(.orange)
                        
                        HStack {
                            
                            
                        }
                        
                        Picker(selection: $controller.compositionType, label: Text("Type"), content: {
                            ForEach(CompositionType.allCases, id:\.self) { cType in
                                Text("\(cType.rawValue)")
                            }
                        })
                        .frame(width:180)
                        
                        Text("\(controller.compositionType.rawValue)")
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("Background")
                        Text("\(Int(controller.backgroundImage.size.width)) x \(Int(controller.backgroundImage.size.height))")
                        
                    }
                    
                    Image(nsImage: controller.backgroundImage)
                        .resizable()
                        .frame(width:200, height:200)
                        .padding(8)
                        .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
//                                        self.droppedImage = dropImage
                                        controller.backgroundImage = dropImage
                                    }
                                }
                            })
                            return true
                        }
                    
                    HStack {
                        Text("Foreground")
                        Text("\(Int(controller.foregroundImage.size.width)) x \(Int(controller.foregroundImage.size.height))")
                    }
                    
                    Image(nsImage: controller.foregroundImage)
                            .resizable()
                            .frame(width:200, height:200)
                            .padding(8)
                            .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                    if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                        if let dropImage = NSImage(contentsOf: uu) {
                                            
                                            DispatchQueue.main.async {
                                                controller.foregroundImage = dropImage
                                            }
                                            
                                        }
                                    }
                                })
                                return true
                            }
                    
                    /*
                     A method usually has a limited amount of UI to be implemented
                     i.e. Needs another image, or a slider input, etc.
                     */
                    Divider()
                    HStack {

                        Button("Flip Order") {
                            let oldBack = controller.backgroundImage
                            let oldFront = controller.foregroundImage
                            controller.foregroundImage = oldBack
                            controller.backgroundImage = oldFront
                        }
                        .help("Flips foreground and background images.")
                        
                        Button("Mix Image") {
                            print("Insert Image to mix")
                            controller.compositeImages()
                        }
                        .help("Runs the composite filter and updates the result image")
                    }
                    Spacer()
                }
                
            }
            .frame(minWidth:220, maxWidth:300)
            .padding(8)
            
            // Right
            VStack {
                
                // Toolbar
                HStack {
                    
                    Button(action: {
                        controller.loadImage(foreground: false)
                    }, label: {
                        Image(systemName:"square.and.arrow.up")
                        Text("Background")
                    })
                    
                    Button(action: {
                        controller.loadImage(foreground: true)
                    }, label: {
                        Image(systemName:"square.and.arrow.up")
                        Text("Foreground")
                    })
                    
                    Spacer()
                    
                    // Save
                    Button(action: {
                        controller.saveImage()
                    }, label: {
                        Image(systemName:"square.and.arrow.down")
                        Text("Save")
                    })
                    
                    Spacer()
                    
                    // Zoom -
                    Button(action: {
                        if zoomLevel > 0.25 {
                            zoomLevel -= 0.2
                        }
                    }, label: {
                        Image(systemName:"minus.magnifyingglass")
                    }).font(.title2)
                    
                    // Zoom Label
                    let zoomString = String(format: "x %.2f", zoomLevel)
                    Text(zoomString)
                    
                    // Zoom +
                    Button(action: {
                        if zoomLevel <= 8 {
                            zoomLevel += 0.2
                        }
                    }, label: {
                        Image(systemName:"plus.magnifyingglass")
                    }).font(.title2)
                    
                }
                .padding(6)
                .background(Color.black.opacity(0.2))
                
                
                // Image View
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                
                    Image(nsImage: controller.resultImage)
                        .resizable()
                        .frame(width: controller.resultImage.size.width * CGFloat(zoomLevel), height: controller.resultImage.size.height * CGFloat(zoomLevel), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
            }
            
            
        }
        .frame(minWidth: 800, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
        
    }
}

struct CompositionView_Previews: PreviewProvider {
    static var previews: some View {
        CompositionView()
            .frame(minWidth: 800, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
    }
}

/*
 COMPOSITION TYPES
 
 CIAdditionCompositing
 CIColorBlendMode
 CIColorBurnBlendMode
 CIColorDodgeBlendMode
 CIDarkenBlendMode
 CIDifferenceBlendMode
 CIDivideBlendMode
 CIExclusionBlendMode
 CIHardLightBlendMode
 CIHueBlendMode
 CILightenBlendMode
 CILinearBurnBlendMode
 CILinearDodgeBlendMode
 CILuminosityBlendMode
 CIMaximumCompositing
 CIMinimumCompositing
 CIMultiplyBlendMode
 CIMultiplyCompositing
 CIOverlayBlendMode
 CIPinLightBlendMode
 CISaturationBlendMode
 CIScreenBlendMode
 */
