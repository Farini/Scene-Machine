//
//  ImageBasics.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/12/21.
//

import Foundation
import SceneKit

/// A helper to identify the sizes of a texture
enum TextureSize:Double, CaseIterable {
    
    /// 256 x 256
    case small = 256
    
    /// 512 x 512
    case medSmall = 512
    
    /// 1024 x 1024
    case medium = 1024
    
    /// 2048 x 2048
    case medLarge = 2048
    
    /// 4096 x 4096
    case large = 4096
    
    /// The size of this texture
    var size:CGSize {
        return CGSize(width: self.rawValue, height: self.rawValue)
    }
    
    /// Convenience to get the `width` without the size
    var width:CGFloat {
        return CGFloat(self.rawValue)
    }
    
    /// Convenience to get the `height` without the size
    var height:CGFloat {
        return CGFloat(self.rawValue)
    }
    
    /// The label (name)
    var label:String {
        switch self {
            case .small: return "small \(self.rawValue)"
            case .medSmall: return "medSmall \(self.rawValue)"
            case .medium: return "medium \(self.rawValue)"
            case .medLarge: return "medLarge \(self.rawValue)"
            case .large: return "large \(self.rawValue)"
        }
    }
    
    /// The description of the size of this texture
    var fullLabel:String {
        switch self {
            case .small: return "256 x 256"
            case .medSmall: return "512 x 512"
            case .medium: return "1024 x 1024"
            case .medLarge: return "2048 x 2048"
            case .large: return "4096 x 4096"
        }
    }
}

