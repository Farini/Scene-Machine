//
//  ImageCompositionView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import SwiftUI

// DEPRECATE

/// DEPRECATE
struct ImageCompositionView: View {
    
    @ObservedObject var controller:ImageCompositionController = ImageCompositionController()
    @State var sliderVal:Float = Float(0.5)
    
    @State private var imageUrls: [Int: URL] = [:]
    @State private var active = 0
    
    var body: some View {
        
        HSplitView {
            // Left
            List {
                Button("Change (Add)") {
                    print("Should Add")
                }
                Button("MixImages") {
                    print("Sepia")
//                    controller.mixImages()
                }
                Button("Filter dic") {
//                    controller.buildFilterDictionary()
                }
                Slider(value: $sliderVal, in: 0...1) { changed in
                    print("Slider Changed")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth:180, maxWidth:200, idealHeight: 1024, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            // Right
            ScrollView {
                VStack(spacing:8) {
                    HStack {
                        VStack(alignment: .center) {
                            Text("Left Image")
                            // Left
                            Image(nsImage: controller.backgroundImage)
                                .resizable()
                                .frame(width: 128, height: 128, alignment: .center)
                        }
                        
                        VStack {
                            Text("Right Image")
                            // Right
                            if let right = controller.foregroundImage {
                                Image(nsImage: right)
                                    .resizable()
                                    .frame(width: 128, height: 128, alignment: .center)
                            } else {
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .frame(width: 128, height: 128, alignment: .center)
                            }
                        }
                    }
                    .padding()
                    
                    VStack {
                        Text("Result")
                        // Result
                        if let image = controller.resultImage {
                            Image(nsImage: image)
                                .resizable()
                                .frame(width: 256, height: 256, alignment: .center)
                        }else{
                            Image(systemName: "questionmark")
                                .resizable()
                                .frame(width: 256, height: 256, alignment: .center)
                        }
                    }
                }
            }
            .frame(minWidth:712, maxWidth:1200, minHeight:512, idealHeight: 600, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
        }
    }
}

struct ImageCompositionView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCompositionView()
    }
}

