//
//  Scene_MachineTests.swift
//  Scene MachineTests
//
//  Created by Carlos Farini on 12/2/20.
//

import XCTest
@testable import Scene_Machine

extension CGFloat {
    
    /// Returns the value of this angle converted to Radians
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
    
    /// Returns the value of this angle converted to Degrees
    func toDegrees() -> CGFloat {
        return self * 180 / .pi
    }
}

class Scene_MachineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAppResources() throws {
        
        print("APP RESOURCES")
        
        let geometries = AppGeometries.allCases
        let backgrounds = AppBackgrounds.allCases
        let textures = AppTextures.allCases
        
        print("\n\n\t APP GEOMETRIES")
        for geometry in geometries {
            print("Geometry: \(geometry.rawValue)")
        }
        
        print("\n\n\t APP BACKGROUNDS")
        for background in backgrounds {
            print("Background: \(background.rawValue)")
        }
        
        print("\n\n\t APP TEXTURES")
        for texture in textures {
            print("Texture: \(texture.rawValue) Size: \(texture.image?.size ?? CGSize.zero)")
        }
    }
    
    func testFolders() throws {
        let subdirectories = LocalDatabase.shared.getSubdirectories()
        for dir in subdirectories {
            print("Directory: \(dir.path)")
        }
    }
    
    func testMaterials() throws {
        
        let materials = LocalDatabase.shared.materials
        for m in materials {
            print("Material: \(m.name ?? "<untitled>")")
        }
        XCTAssert(materials.count > 0)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            // This is taking 7.1 seconds!
            let explorerTest = ExplorerController()
            let children = explorerTest.scene.rootNode.childNodes
            print("Direct Children: \(children.count)")
            
        }
    }

}
