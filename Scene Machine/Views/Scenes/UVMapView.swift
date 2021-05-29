//
//  UVMapView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/24/21.
//

import Foundation
import SwiftUI

/** UVMapView: Use it to take screenshots of UVMap */
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

/**
 A `Shape` showing a UVMap.
 Initialize this class with the `UV` points from a geometry's source texCoord.
 See: https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit */
struct UVShape: Shape {
    
    var uv:[CGPoint]
    
    // MARK:- functions
    func path(in rect: CGRect) -> Path {
        
        // Path
        var path = Path()
        
        // Start in first
        path.move(to: uv.first!)
        
        var substack:[CGPoint] = []
        
        for uvPoint in uv {
            
            if uvPoint == .zero { break }
            
            if substack.count >= 3 {
                
                path.closeSubpath()
                substack = []
                
                substack.append(uvPoint)
                path.move(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                
            } else if substack.isEmpty {
                
                path.move(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                substack.append(uvPoint)
                
            } else {
                
                path.addLine(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                substack.append(uvPoint)
            }
        }
        
        path.closeSubpath()
        
        return path
    }
}
