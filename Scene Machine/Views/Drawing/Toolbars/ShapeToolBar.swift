//
//  ShapeToolBar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/15/21.
//

import SwiftUI

enum ShapeToolType:String, CaseIterable {
    case Rectangle
    case Circle
}

struct ShapeToolBar: View {
    
    @ObservedObject var controller:DrawingPadController
    @State var shapeType:ShapeToolType = .Rectangle
    
    var body: some View {
        VStack {
            HStack {
                
                Picker("Shape type", selection: $shapeType) {
                    ForEach(ShapeToolType.allCases, id:\.self) { shape in
                        Text("\(shape.rawValue)")
                    }
                }
                .frame(maxWidth:180)
                
                Spacer()
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
