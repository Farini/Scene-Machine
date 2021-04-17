//
//  CompositionView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

import SwiftUI

struct CompositionView: View {
    
    @ObservedObject var controller = ImageCompositionController()
    
//    @State var image:NSImage? = NSImage(named:"Example")
    
//    @State var secondImage:NSImage?
    @State var isDisplayingSecondImage:Bool = false
    
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
    
    var body: some View {
        
        HStack(alignment:.top) {
            
            VStack(alignment:.leading) {
                Text("Tools").font(.title3).foregroundColor(.orange)
                Button("Mix Color") {
                    print("Printing....")
                }
                Button("Mix Image") {
                    print("Insert Image to mix")
                    controller.compositeImages()
                }
                Button("Sepia") {
                    print("Insert Image to mix")
                }
                Divider()
                Text("FX Properties").font(.title3).foregroundColor(.orange)
                Text("Select a tool").foregroundColor(.gray)
                /*
                 A method usually has a limited amount of UI to be implemented
                 i.e. Needs another image, or a slider input, etc.
                 */
                Divider()
                HStack {
                    Button("Save") {
                        print("Insert Image to mix")
                    }
                    Button("Save as...") {
                        print("Insert Image to mix")
                    }
                }
                
            }
            .frame(width:150)
            .padding(4)
            
            
            //            .background(Color.pink)
            
            Divider()
            
            ScrollView {
                VStack {
                    HStack {
                        // Left
                        Image(nsImage: controller.leftImage)
                            .resizable()
                            .frame(width:128, height:128)
                            .padding(8)
                        
                        Spacer()
                        VStack {
                            Picker(selection: $controller.compositionType, label: Text("Type"), content: {
                                ForEach(CompositionType.allCases, id:\.self) { cType in
                                    Text("\(cType.rawValue)")
                                }
                            })
                            Text("\(controller.compositionType.rawValue)")
                        }
                        
                        Spacer()
                        // Right
                        if let second = controller.rightImage {
                            Image(nsImage: second)
                                .resizable()
                                .frame(width:128, height:128)
                                .padding(8)
                        }
                    }
                    Image(nsImage: controller.resultImage)
                        .padding()
                }
                .frame(width: .infinity, height: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
        }
        .frame(minWidth: 500, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
        
    }
}

struct CompositionView_Previews: PreviewProvider {
    static var previews: some View {
        CompositionView()
    }
}
