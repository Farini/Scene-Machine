//
//  DrawingPadToolbar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/14/21.
//

import SwiftUI

struct DrawingPadToolbar: View {
    
    @State private var imageSize:TextureSize = TextureSize.medSmall // 512
    
    var body: some View {
        HStack {
            Picker(selection: $imageSize, label: Text("")) {
                ForEach(TextureSize.allCases, id:\.self) { texSize in
                    Text("\(texSize.fullLabel)")
                }
            }
            .frame(maxWidth:100)
            
            Button("💾") {
//                save()
                print("Tool")
            }
            .help("Saves the image")
            
            Button("Open") {
//                loadImage()
                print("Tool")
            }
            .help("Improves the image")
            
            Button("⬆️") {
//                improve()
                print("Tool")
            }
            .help("Improves the image")
            
            Button("Tool") {
                print("Tool")
            }
            Spacer()
            Button("Bar") {
                print("Bar")
            }
        }
    }
}

struct DrawingPadToolbar_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadToolbar()
    }
}
