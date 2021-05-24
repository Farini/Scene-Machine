//
//  UVMapView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/24/21.
//

import Foundation
import SwiftUI

/**
 UVMapView: Use it to take screenshots of UVMap
 */
struct UVMapView: View {
    
    /// The size of the image
    var size:CGSize
    
    /// The background Image (if any)
    var image:NSImage?
    
    /// The UV Texture points
    var uvPoints:[CGPoint]
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .top) {
                
                // Background Image
                Image(nsImage: image ?? NSImage(size: size))
                    .resizable()
                    .frame(width: size.width, height: size.height)
                
                // Countours
                UVShape(uv:uvPoints)
                    .stroke(lineWidth: 0.5)
                    .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                    .background(Color.gray.opacity(0.1))
                    .frame(width: size.width, height: size.height)
                
                Spacer()
            }
            .frame(width: size.width, height: size.height)
            
        }
        .frame(width: size.width, height: size.height)
    }
}
