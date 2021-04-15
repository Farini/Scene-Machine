//
//  DragDropView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import Foundation

import SwiftUI
import SpriteKit

struct DragDropView: View {
    
    let img1url = SKTexture.init(noiseWithSmoothness: 0.25, size: CGSize(width: 512, height: 512), grayscale: true).cgImage()
    let img2url = SKTexture.init(noiseWithSmoothness: 0.85, size: CGSize(width: 512, height: 512), grayscale: true).cgImage()
    let img3url = SKTexture.init(noiseWithSmoothness: 0.15, size: CGSize(width: 512, height: 512), grayscale: true).cgImage()
    let img4url = SKTexture.init(noiseWithSmoothness: 0.55, size: CGSize(width: 512, height: 512), grayscale: true).cgImage()
//    let mmm = "/Users/farini/Desktop/ModuleBake4.png"

    var body: some View {
        HStack {
            VStack {
                DragableImage(url: img1url)
                
                DragableImage(url: img3url)
            }
            
            VStack {
                DragableImage(url: img2url)
                
                DragableImage(url: img4url)
            }
            
//            DroppableArea()
        }.padding(40)
    }
    
    struct DragableImage: View {
        let url: CGImage
        
        var body: some View {
            Image(nsImage: NSImage(cgImage: url, size: NSSize(width: 256, height: 256)))
                .resizable()
//                .frame(width: 150, height: 150)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .padding(2)
//                .overlay(Circle().strokeBorder(Color.black.opacity(0.1)))
                .shadow(radius: 3)
                .padding(4)
//                .onDrag { return NSItemProvider(object: self.url as! NSItemProviderWriting) }
        }
    }
    
    struct DroppableArea: View {
        @State private var imageUrls: [Int: CGImage] = [:]
        @State private var active = 0
        
        var body: some View {
            let dropDelegate = MyDropDelegate(imageUrls: $imageUrls, active: $active)
            
            return VStack {
                HStack {
                    GridCell(active: self.active == 1, url: imageUrls[1])
                    
                    GridCell(active: self.active == 3, url: imageUrls[3])
                }
                
                HStack {
                    GridCell(active: self.active == 2, url: imageUrls[2])
                    
                    GridCell(active: self.active == 4, url: imageUrls[4])
                }
                
            }
            .background(Rectangle().fill(Color.gray))
            .frame(width: 300, height: 300)
            .onDrop(of: ["public.file-url"], delegate: dropDelegate)
            
        }
    }
    
    struct GridCell: View {
        let active: Bool
        let url: CGImage?
        
        var body: some View {
            guard let cgImag = url else { fatalError() }
            
            let img = Image(nsImage: NSImage(cgImage: cgImag, size: NSSize(width: 256, height: 256)))
                
                
                .resizable()
                .frame(width: 150, height: 150)
            
            return Rectangle()
                .fill(self.active ? Color.green : Color.clear)
                .frame(width: 150, height: 150)
                .overlay(img)
        }
    }
    
    struct MyDropDelegate: DropDelegate {
        @Binding var imageUrls: [Int: CGImage]
        @Binding var active: Int
        
        func validateDrop(info: DropInfo) -> Bool {
            return info.hasItemsConforming(to: [.image])
        }
        
        func dropEntered(info: DropInfo) {
            NSSound(named: "Morse")?.play()
        }
        
        func performDrop(info: DropInfo) -> Bool {
            NSSound(named: "Submarine")?.play()
            
            let gridPosition = getGridPosition(location: info.location)
            self.active = gridPosition
            
//            let items: [NSItemProvider] = info.itemProviders(for: [.image])
//            guard let item: NSItemProvider = items.first else {
//                print("unable")
//                return false
//            }
//            guard item.canLoadObject(ofClass: NSImage) else {
//                print("unable")
//                return false
//            }
            
//            item.loadObject(ofClass: NSImage.self) { (reading, error) in
//                guard let image: NSImage = reading as? NSImage else { return }
//                DispatchQueue.main.async {
//
//                }
//            }
            
            
            if let item = info.itemProviders(for: [.image]).first {
                item.loadItem(forTypeIdentifier: "image", options: nil) { (urlData, error) in
                    DispatchQueue.main.async {
                        if let image = urlData as? NSImage {
                            self.imageUrls[gridPosition] = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
                        }else{
                            print("Did not let image")
                        }
                    }
                    
                }
//                item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
//                    DispatchQueue.main.async {
//                        if let urlData = urlData as? Data {
//                            self.imageUrls[gridPosition] = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
//                        }
//                    }
//                }
                
                return true
                
            } else {
                return false
            }
            
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            self.active = getGridPosition(location: info.location)
            
            return nil
        }
        
        func dropExited(info: DropInfo) {
            self.active = 0
        }
        
        func getGridPosition(location: CGPoint) -> Int {
            if location.x > 150 && location.y > 150 {
                return 4
            } else if location.x > 150 && location.y < 150 {
                return 3
            } else if location.x < 150 && location.y > 150 {
                return 2
            } else if location.x < 150 && location.y < 150 {
                return 1
            } else {
                return 0
            }
        }
    }
}

struct DragDrop_Previews: PreviewProvider {
    static var previews: some View {
        DragDropView()
    }
}
