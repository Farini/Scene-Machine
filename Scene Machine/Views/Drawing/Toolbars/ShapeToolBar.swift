//
//  ShapeToolBar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/15/21.
//

import SwiftUI

//enum ShapeToolType:String, CaseIterable {
//    case Rectangle
//    case Circle
//}

struct ShapeToolBar: View {
    
    @ObservedObject var controller:DrawingPadController
    
    var body: some View {
        VStack {
            HStack {
                
                Picker("Type", selection: $controller.shapeInfo.shapeType) {
                    ForEach(ShapeType.allCases, id:\.self) { shape in
                        Text("\(shape.rawValue)")
                    }
                }
                .frame(maxWidth:160)
                
                Text("Size")
                TextField("SizeX", value: $controller.shapeInfo.pointEnds.width, formatter: NumberFormatter.scnFormat)
                    .frame(width:50)
                Text("x")
                TextField("SizeY", value: $controller.shapeInfo.pointEnds.height, formatter: NumberFormatter.scnFormat)
                    .frame(width:50)
                
                Spacer()
                
                // Stroke Color
                // Fill Color?
                // Color
                ColorPicker("Color", selection: $controller.foreColor)
                    .onChange(of: controller.foreColor, perform: { value in
                        //                        controller.addLayer()
                        controller.updateTool()
                    })
                
                Text("Width:")
                    
                TextField("Width", value: $controller.lineWidth, formatter: NumberFormatter.scnFormat)
                    .frame(width:50)
                    .onChange(of: controller.lineWidth, perform: { value in
                        //                        controller.addLayer()
                        controller.updateTool()
                    })
                
                Button("Make") {
                    print("make shape")
                }
            }
            .padding(8)
        }
    }
}

struct ShapeToolBar_Previews: PreviewProvider {
    static var previews: some View {
        ShapeToolBar(controller: DrawingPadController())
    }
}
