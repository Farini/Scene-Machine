//
//  MetalOthersView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/28/21.
//

import SwiftUI

struct MetalOthersView: View {
    
    @ObservedObject var controller:MetalGenController
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    @State private var stepCount1:Int = 1
    @State private var stepCount2:Int = 10
    
    @State private var center:CGPoint = CGPoint.zero
    @State private var color0 = Color.black
    @State private var color1 = Color.white
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    
    @State private var undoImages:[NSImage] = []
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    enum MetalTileType:String, CaseIterable {
        case Hexagons
        case Checkerboard
        // case Voronoi
        case RandomMaze
        case Truchet
        // New
//        case Epitrochoidal
    }
    
    @State var tileType:MetalTileType = .Hexagons
    
    var body: some View {
        VStack {
            Text("Other Generators").foregroundColor(.orange).font(.title2)
        }
    }
    
    // MARK: - Update & Apply
}

struct MetalOthersView_Previews: PreviewProvider {
    static var previews: some View {
        MetalOthersView(controller: MetalGenController(select: .Other))
    }
}
