//
//  AppConstants.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/9/21.
//

import Foundation
import SceneKit

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

enum AppTextures: String, CaseIterable {
    
    case AsphaltDiffuse
    case AsphaltNormal
    case AsphaltRoughness
    
    case WallDiffuse
    case WallNormal
    
    case WoodDiffuse
    case WoodNormal
    
    case UVGrid
    case UVLabels
    
    var image:NSImage? {
        return NSImage(named: self.rawValue)
    }
    
    var labelName:String {
        switch self  {
            case .AsphaltDiffuse: return "Asphalt Diffuse"
            case .AsphaltNormal: return "Asphalt Normal"
            case .AsphaltRoughness: return "Asphalt Roughness"
            case .WallDiffuse: return "Wall Diffuse"
            case .WallNormal: return "Wall Normal"
            case .WoodDiffuse: return "Wood Diffuse"
            case .WoodNormal: return "Wood Normal"
            case .UVGrid: return "UV Grid"
            case .UVLabels: return "UV Labels"
        }
    }
}
