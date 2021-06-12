//
//  SettingsFormView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/12/21.
//

import SwiftUI

struct SettingsFormView: View {
    
    @State var displayTopDownView:Bool = UserDefaults.standard.bool(forKey: "displayTopDownView")
    
    var body: some View {
        VStack {
            Text("Scene Machine").font(.title2).foregroundColor(.orange)
            Divider()
            Toggle(isOn: $displayTopDownView, label: {
                Label("Top Down View", systemImage: "square.2.stack.3d.top.fill")
            })
            Divider()
            HStack {
                Button("Save") {
                    
                }
                Button("Cancel") {
                    
                }
            }
        }
        .frame(maxWidth: 350)
        .padding()
    }
}

struct SettingsFormView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormView()
    }
}
