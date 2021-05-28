//
//  HelpPencilKitView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI

struct HelpPencilKitView: View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                
                HStack {
                    Image(systemName: "pencil")
                    Text("Pencil Kit")
                }
                .font(.title)
                .foregroundColor(.orange)
                
                Divider()
                
                Text("Using Apple Pencil").font(.title2).foregroundColor(.blue)
                Text("Apple pencil can be used to draw images on the iPad, and update the material in Material Machine View")
                
                Divider()
                
                // How to
                Group {
                    Text("Step 1").font(.title2).foregroundColor(.blue)
                    Text("Go to Material Machine View")
                    VStack {
                        Image(systemName:"shield.checkerboard")
                            .resizable()
                            .frame(width: 38, height: 42, alignment: .center)
                        //                                .padding(6)
                        Text("Material")
                    }
                    .padding(8)
                    .frame(width: 70, height: 80, alignment: .center)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    // .shadow(color: .white.opacity(0.4), radius: 6, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                    .onTapGesture {
                        NSApp.sendAction(#selector(AppDelegate.openDrawingView(_:)), to: nil, from: nil)
                    }
                }
                
                Group {
                    Text("Step 2").font(.title2).foregroundColor(.blue)
                    HStack {
                        Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                            .foregroundColor(.gray)
                            .background(Color.green)
                            .cornerRadius(8)
                        
                        Image(systemName: "cursorarrow.motionlines")
                        
                        Text("Hover the mouse by the window maximizer (next to close window)")
                    }
                    Text("Select Move to [person's name] iPad")
                        .padding(.vertical, 4)
                    Image("HelpPencilImage")
                }
                
                Group {
                    Text("Step 3").font(.title2).foregroundColor(.blue)
                    Text("Given a few seconds, the iPad screen should be updated, and displaying your mac screen")
                    Text("Grab you apple pencil, and paint on the screen")
                }
            }
            .padding()
        }
    }
}

struct HelpPencilKitView_Previews: PreviewProvider {
    static var previews: some View {
        HelpPencilKitView()
    }
}
