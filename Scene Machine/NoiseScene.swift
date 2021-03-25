//
//  NoiseScene.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import Foundation
import SpriteKit

class NoiseScene:SKScene {
    
    var smoothness:CGFloat = 0.5
    
    override init(size: CGSize) {
        print("Custom init with size: \(size)")
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        print("Did move to view")
    }
    
    func addNoise(noise:SKSpriteNode) {
        print("Adding noise")
        self.addChild(noise)
    }
}
