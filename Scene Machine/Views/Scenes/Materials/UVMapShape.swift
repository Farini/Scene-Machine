//
//  UVMapShape.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/22/21.
//

import Foundation
import SwiftUI

/**
 A `Shape` showing a UVMap.
 See: https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit */
struct UVShape: Shape {
    
    var uv:[CGPoint]
    //    let multi:CGFloat = 10
    
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
