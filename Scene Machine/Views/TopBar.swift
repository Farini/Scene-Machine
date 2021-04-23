//
//  TopBar.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        HStack {
//            Button("try me!"){
//                print("trying...")
//            }
//            Button("Other"){
//                print("cheating...")
//            }
            Spacer()
            Text("Experiements with Noise, Image Effects, Shaders and SceneKit")
                .foregroundColor(.orange)
            Spacer()
        }
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
    }
}
