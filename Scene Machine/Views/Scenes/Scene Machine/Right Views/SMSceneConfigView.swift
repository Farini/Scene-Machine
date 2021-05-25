//
//  SMSceneConfigView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/25/21.
//

import SwiftUI
import SceneKit

struct SMSceneConfigView: View {
    
    @ObservedObject var controller:SceneMachineController
    
    @State private var popBackground:Bool = false
    @State private var popLightEnvironment:Bool = false
    
    var body: some View {
        VStack {
            Text("Scene Config")
            Divider()
            
            // Backgrounds
            Group {
                Text("Scene Background")
                Button("Background") {
                    popBackground.toggle()
                }
                .popover(isPresented: $popBackground) {
                    VStack {
                        Text("Backgrounds").font(.title2).foregroundColor(.blue)
                        ForEach(AppBackgrounds.allCases, id:\.self) { appBack in
                            HStack {
                                Text(appBack.rawValue)
                                Spacer()
                                Button("Change") {
                                    controller.changeBackground(back: appBack)
                                }
                            }
                        }
                    }
                    .frame(width:200)
                    .padding()
                }
                
                if let str = controller.scene.background.contents as? String {
                
                    let url = URL(fileURLWithPath: str)
                    let modStr = "\(url.lastPathComponent.replacingOccurrences(of: ".hdr", with: ""))Thumb"
                    
                    Text(modStr).foregroundColor(.orange).font(.footnote)
                    
                    if let img = NSImage(named:modStr) {
                        Image(nsImage: img)
                            .resizable()
                            .frame(width: 200, height: 100, alignment: .center)
                    }
                }
                
                Text("Lighting Environment")
                
                Button("Light Environment") {
                    popLightEnvironment.toggle()
                }
                .popover(isPresented: $popLightEnvironment) {
                    VStack {
                        Text("Light Environments").font(.title2).foregroundColor(.blue)
                        ForEach(AppBackgrounds.allCases, id:\.self) { appBack in
                            HStack {
                                Text(appBack.rawValue)
                                Spacer()
                                Button("Change") {
                                    controller.scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(appBack.content)"
                                }
                            }
                        }
                    }
                    .frame(width:200)
                    .padding()
                }
                
                if let str = controller.scene.lightingEnvironment.contents as? String {
                    
                    let url = URL(fileURLWithPath: str)
                    let modStr = "\(url.lastPathComponent.replacingOccurrences(of: ".hdr", with: ""))Thumb"
                    
                    Text(modStr).foregroundColor(.orange).font(.footnote)
                    
                    if let img = NSImage(named:modStr) {
                        Image(nsImage: img)
                            .resizable()
                            .frame(width: 200, height: 100, alignment: .center)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Text("Cameras")
                Spacer()
                Text("\(controller.cameras.count)")
            }
            .padding(.horizontal, 8)
            
            HStack {
                Text("Lights")
                Spacer()
                Text("\(controller.lights.count)")
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            Text("Stats")
            Text("Objects: \(controller.scene.rootNode.childNodes.count)")
        }
        .frame(minWidth: 200, maxWidth: 300, minHeight:0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
    }
}

struct SMSceneConfigView_Previews: PreviewProvider {
    static var previews: some View {
        SMSceneConfigView(controller: SceneMachineController())
    }
}
