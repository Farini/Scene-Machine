//
//  SMNodeRow.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/7/21.
//

import SwiftUI
import SceneKit



struct SMNodeRow: View {
    
    @ObservedObject var controller:SceneMachineController
    var node:SCNNode
    
    // Renaming
    @State private var isRenamingNode:Bool = false
    @State private var nodeRenameStr:String = ""
    
    private var formatter:NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 4
        nf.maximumIntegerDigits = 4
        nf.minimumFractionDigits = 1
        return nf
    }
    
    var body: some View {
        
        VStack {
            let isSelected:Bool = controller.selectedNode == node
            HStack {
                if let geometry = node.geometry {
                    Image(systemName: "pyramid")
                    Text("\(geometry.sources.last?.vertices.count ?? 0)")
                    Text("Src: \(geometry.sources.count)|\(geometry.elementCount)")
                }
                
                if node.camera != nil {
                    Image(systemName: "camera.viewfinder")
                }
                if node.particleSystems?.isEmpty == false {
                    Image(systemName: "sparkles")
                }
                if node.light != nil {
                    Image(systemName: "lightbulb.fill")
                }
                
                Spacer()
                Text(node.name ?? "< Untitled >")
                    .foregroundColor(isSelected ? .accentColor:.primary)
            }
            .frame(maxWidth:250)
            .onTapGesture {
                controller.selectedNode = node
            }
            
            HStack {
                Text("⌖ \(node.position.toString())")
                Spacer()
                Image(systemName: node.isHidden ? "eye.slash":"eye")
                    .onTapGesture {
                        self.node.isHidden.toggle()
                    }
            }
            .frame(maxWidth:250)
            .onTapGesture {
                controller.selectedNode = node
            }
            
            // Children
            if !node.childNodes.isEmpty {
                HStack {
                    Image(systemName: "arrow.down.forward.circle")
                    Text("● \(node.childNodes.count)")
                    Spacer()
                }
                .frame(maxWidth:250)
                
                ForEach(node.childNodes, id:\.self) { child in
                    SMNodeRow(controller: controller, node: child)
                        .padding(.leading, CGFloat(self.indent(node: child)))
                }
            }
        }
        .background(controller.selectedNode == node ? Color.black.opacity(0.5):.clear)
        
        // Menu Options
        .contextMenu {
            Button("Add Empty") {
                print("Add Node")
                let newNode = SCNNode()
                newNode.name = "Empty Node"
                controller.scene.rootNode.addChildNode(newNode)
            }
            
            Button("Rename") {
                self.nodeRenameStr = node.name ?? "<untitled>"
                isRenamingNode.toggle()
            }
            
            Button("Delete") {
                controller.removeNode(node: node)
            }
            Button("Hide/Unhide") {
                node.isHidden.toggle()
            }
            Button("Pause/Unpause") {
                node.isPaused.toggle()
            }
        }
        
        // Renaming Sheet
        .sheet(isPresented: $isRenamingNode, content: {
            HStack {
                TextField("Rename", text: $nodeRenameStr)
                    .frame(width:80)
                
                Button("Rename") {
                    
                    controller.scene.rootNode.childNodes { pNode, pt in
                        return pNode == node
                    }.first!.name = nodeRenameStr
                    controller.selectedNode = node
                    
                    isRenamingNode.toggle()
                }
            }
            .padding()
        })
    }
    
    func indent(node:SCNNode) -> Int {
        var nextNode:SCNNode? = node
        var indentation:Int = 4
        
        while nextNode != nil {
            indentation += 4
            nextNode = nextNode!.parent
        }
        return indentation
    }
}

struct SMNodeRow_Previews: PreviewProvider {
    static var previews: some View {
        let ctrl = SceneMachineController()
//        let nod = ctrl.scene.rootNode.childNodes.last!
        ForEach(ctrl.scene.rootNode.childNodes, id:\.self) { node in
            SMNodeRow(controller: ctrl, node: node)
        }
    }
        
}
