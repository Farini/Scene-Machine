//
//  FXStylizeView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/30/21.
//

import SwiftUI

struct FXStylizeView: View {
    enum StylizeType {
        case Cristalize
        case Edges
        case EdgeWork
        case LineOverlay
        case Spotlight
        case Bloom
        
        case SharpenLumina
        case UnsharpMask
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FXStylizeView_Previews: PreviewProvider {
    static var previews: some View {
        FXStylizeView()
    }
}
