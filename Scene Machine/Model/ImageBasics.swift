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


/// Additional Geometries offered by the App
enum AppGeometries:String, CaseIterable {
    case Suzanne
    case Woman
    case Prototype
    
    func getGeometry() -> SCNNode? {
        //        var scene:SCNScene!
        var node:SCNNode?
        switch self {
            case .Suzanne:
                let scene = SCNScene(named: "Scenes.scnassets/monkey.scn")
                node = scene?.rootNode.childNode(withName: "Suzanne", recursively: false)?.clone()
            case .Woman:
                let scene = SCNScene(named: "Scenes.scnassets/Woman.scn")
                node = scene?.rootNode.childNode(withName: "Body_M_GeoRndr", recursively: false)?.clone()
            case .Prototype:
                let scene = SCNScene(named: "Scenes.scnassets/PrototypeCar.scn")
                node = scene?.rootNode.childNode(withName: "CarBody", recursively: false)?.clone()
        }
        return node
    }
}

/// Additional HDRI Images offered by the App
enum AppBackgrounds: String, CaseIterable {
    case Lava1
    case Lava2
    case SMB1
    case SMB2
    case SMB3
    
    var content:String {
        switch self {
            case .Lava1: return "LavaWorldBlur.hdr"
            case .Lava2: return "LavaWorldBlur2.hdr"
            case .SMB1: return "SMB_1.hdr"
            case .SMB2: return "SMB_2.hdr"
            case .SMB3: return "SMB_3.hdr"
        }
    }
}
