//
//  ImageBasics.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/12/21.
//

import Foundation

/// A helper to identify the sizes of a texture
enum TextureSize:Double, CaseIterable {
    
    /// 256
    case small = 256
    
    /// 512
    case medSmall = 512
    
    // 1024
    case medium = 1024
    
    /// 2048
    case medLarge = 2048
    
    /// 4096
    case large = 4096
    
    var size:CGSize {
        return CGSize(width: self.rawValue, height: self.rawValue)
    }
    
    var label:String {
        switch self {
            case .small: return "small \(self.rawValue)"
            case .medSmall: return "medSmall \(self.rawValue)"
            case .medium: return "medium \(self.rawValue)"
            case .medLarge: return "medLarge \(self.rawValue)"
            case .large: return "large \(self.rawValue)"
        }
    }
}
