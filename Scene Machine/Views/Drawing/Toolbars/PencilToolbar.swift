//
//  PencilToolbar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/15/21.
//

import SwiftUI

struct PencilToolbarView: View {
    
    @ObservedObject var controller:DrawingPadController
    
//    @State private var colorPickerShown = false
    
    var body: some View {
        HStack {
            
            Button("↩️") {
                if controller.layers.isEmpty == false {
                    controller.layers.removeLast()
                }
            }
            .help("Removes the last Drawing")
            
            Button("❌") {
                controller.currentLayer?.pencilStrokes = []
            }
            .help("Clear the drawings")
            
            Button("+") {
                controller.newLayer()
            }
            .help("Add new layer")
            
            Divider()
            
            // Color
            ColorPicker("Color", selection: $controller.foreColor)
                .onChange(of: controller.foreColor, perform: { value in
                    controller.updateTool()
                })
            
            // Width
            Text("Width \(Int(controller.lineWidth))")
                
            TextField("Width", value: $controller.lineWidth, formatter: NumberFormatter.scnFormat)
                .frame(width:50)
                .onChange(of: controller.lineWidth, perform: { value in
                    controller.updateTool()
                })
            
            Slider(value: $controller.lineWidth, in: 1.0...15.0, step: 1.0)
                .padding(4)
        }
        .frame(height:32, alignment: .center)
    }
}
