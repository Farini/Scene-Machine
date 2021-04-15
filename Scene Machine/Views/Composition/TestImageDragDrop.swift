//
//  TestImageDragDrop.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import SwiftUI

struct TestImageDragDrop: View {
    
    @State var image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "image")
    @State private var dragOver = false
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text("Test Drag drop")
                .font(.largeTitle)
                .padding()
            
            Image(nsImage: image ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 256, idealWidth: 256, minHeight: 256, idealHeight: 256, alignment: .center)
                .padding(.all)
                .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                        if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                            let image = NSImage(contentsOf: url)
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                    })
                    return true
                }
                .onDrag {
                    let data = self.image?.tiffRepresentation
                    let provider = NSItemProvider(item: data as NSSecureCoding?, typeIdentifier: kUTTypeTIFF as String)
                    provider.previewImageHandler = { (handler, _, _) -> Void in
                        handler?(data as NSSecureCoding?, nil)
                    }
                    return provider
                }
                .border(dragOver ? Color.red : Color.clear)
            
            Spacer()
                
        }
        .frame(minWidth: 256, idealWidth: 300, minHeight: 256, idealHeight: 400, alignment: .center)
        
        
    }
}

struct TestImageDragDrop_Previews: PreviewProvider {
    static var previews: some View {
        TestImageDragDrop()
    }
}
