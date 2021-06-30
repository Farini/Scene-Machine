//
//  SMMaterialView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/8/21.
//

import SwiftUI
import SceneKit

struct SMMaterialView: View {
    
    @State var controller:SceneMachineController
    @State var material:SCNMaterial
    
    @State var active:Bool = false
    
    @State var diffuseURL:URL?
    @State var diffuseColor:Color = .white
    @State var diffuseImage:NSImage = NSImage()
    @State var diffuseIntensity:CGFloat = 1
    
    @State var metalnessURL:URL?
    @State var metalnessColor:Color = .white
    @State var metalnessImage:NSImage = NSImage()
    @State var metalnesseIntensity:CGFloat = 1
    
    @State var roughnessURL:URL?
    @State var roughnessColor:Color = .white
    @State var roughnessImage:NSImage = NSImage()
    @State var roughnessIntensity:CGFloat = 1
    @State var roughnessValue:CGFloat = 0.5
    
    @State var occlusionURL:URL?
    @State var occlusionColor:Color = .white
    @State var occlusionImage:NSImage = NSImage()
    @State var occlusionIntensity:CGFloat = 1
    
    @State var emissionURL:URL?
    @State var emissionColor:Color = .white
    @State var emissionImage:NSImage = NSImage()
    @State var emissionIntensity:CGFloat = 1
    
    @State var normalURL:URL?
    @State var normalColor:Color = .white
    @State var normalImage:NSImage = NSImage()
    @State var normalIntensity:CGFloat = 1
    
    var body: some View {
        VStack {
            
            // Header
            Group {
                HStack {
                    Text("Material")
                    Spacer()
                    Text(material.name ?? "untitled")
                }
            }.font(.title3).foregroundColor(.orange)
            
            
            // Diffuse
            Group {
                HStack {
                    Text("Diffuse").font(.headline)
                    Spacer()
                    ColorPicker("", selection: $diffuseColor)
                        .onChange(of: diffuseColor, perform: { value in
                            self.material.diffuse.contents = NSColor(diffuseColor)
                        })
                }
                
                // Contents
                if let img = material.diffuse.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.diffuse.contents = dropImage
                                        self.diffuseURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $diffuseIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.diffuse.wrapS.toString()) | \(material.diffuse.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.diffuse.contents = dropImage
                                        self.diffuseURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
            
            // Metalness
            Group {
                HStack {
                    Text("Metalness").font(.headline)
                    Spacer()
                    ColorPicker("", selection: $metalnessColor)
                        .onChange(of: metalnessColor, perform: { value in
                            self.material.metalness.contents = NSColor(value)
                        })
                }
                // Contents
                if let img = material.metalness.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.metalness.contents = dropImage
                                        self.metalnessURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $metalnesseIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.metalness.wrapS.toString()) | \(material.metalness.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.metalness.contents = dropImage
                                        self.metalnessURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
            // Roughness
            Group {
                HStack {
                    Text("Roughness").font(.headline)
                    Spacer()
                    TextField("Roughness Value", value: $roughnessValue, formatter:NumberFormatter.scnFormat).frame(width:50)
                    ColorPicker("", selection: $roughnessColor)
                        .onChange(of: roughnessColor, perform: { value in
                            self.material.roughness.contents = NSColor(value)
                        })
                }
                // Contents
                if let img = material.roughness.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.roughness.contents = dropImage
                                        self.diffuseURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $roughnessIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.roughness.wrapS.toString()) | \(material.roughness.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.roughness.contents = dropImage
                                        self.roughnessURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
            // Occlusion
            Group {
                HStack {
                    Text("Occlusion").font(.headline)
                    Spacer()
                    ColorPicker("", selection: $occlusionColor)
                        .onChange(of: occlusionColor, perform: { value in
                            self.material.ambientOcclusion.contents = NSColor(value)
                        })
                }
                // Contents
                if let img = material.ambientOcclusion.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.ambientOcclusion.contents = dropImage
                                        self.occlusionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $occlusionIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.ambientOcclusion.wrapS.toString()) | \(material.ambientOcclusion.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.ambientOcclusion.contents = dropImage
                                        self.occlusionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
            // Emission
            Group {
                HStack {
                    Text("Emission").font(.headline)
                    Spacer()
                    ColorPicker("", selection: $emissionColor)
                        .onChange(of: emissionColor, perform: { value in
                            self.material.emission.contents = NSColor(value)
                        })
                }
                // Contents
                if let img = material.emission.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.emission.contents = dropImage
                                        self.emissionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $emissionIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.emission.wrapS.toString()) | \(material.emission.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.emission.contents = dropImage
                                        self.emissionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
            // Normal
            Group {
                HStack {
                    Text("Normal").font(.headline)
                    Spacer()
                }
                // Contents
                if let img = material.normal.contents as? NSImage {
                    Image(nsImage: img)
                        .resizable()
                        .frame(width:200, height:200)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.normal.contents = dropImage
                                        self.normalURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    HStack {
                        Text("Intensity")
                        Spacer(minLength: 20)
                        TextField("Intensity", value: $normalIntensity, formatter:NumberFormatter.scnFormat)
                    }
                    HStack {
                        Text("Wrap S, T")
                        Spacer()
                        Text("\(material.normal.wrapS.toString()) | \(material.normal.wrapT.toString())")
                    }
                    
                } else {
                    Text("[Drop Image]").padding().font(.title3).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.normal.contents = dropImage
                                        self.normalURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
                Divider()
            }
            
        }
        .frame(width:200)
        .padding(.horizontal, 6)
        .onAppear() {
            self.prepareUI()
        }
        .onChange(of: controller.selectedMaterial!) { value in
            self.material = value
            self.prepareUI()
        }
    }
    
    func prepareUI() {
        // Diffuse
        if let difImage = material.diffuse.contents as? NSImage {
            self.diffuseImage = difImage
        } else if let difColor = material.diffuse.contents as? NSColor {
            self.diffuseColor = Color(difColor)
        }
        // Metalness
        if let metalImage = material.metalness.contents as? NSImage {
            self.metalnessImage = metalImage
        } else if let color = material.metalness.contents as? NSColor {
            self.metalnessColor = Color(color)
        }
        // Roughness
        if let image = material.roughness.contents as? NSImage {
            self.roughnessImage = image
        } else if let color = material.roughness.contents as? NSColor {
            self.roughnessColor = Color(color)
        }
        // Emission
        if let image = material.emission.contents as? NSImage {
            self.emissionImage = image
        } else if let color = material.emission.contents as? NSColor {
            self.emissionColor = Color(color)
        }
        // Normal
        if let image = material.normal.contents as? NSImage {
            self.normalImage = image
        } else if let color = material.displacement.contents as? NSColor {
            self.normalColor = Color(color)
        }
    }
}

// MARK: - Previews

struct SMMaterialView_Previews: PreviewProvider {
    static var previews: some View {
        let control = SceneMachineController()
        control.selectedMaterial = MaterialExample().material
        return SMMaterialView(controller:control, material: control.selectedMaterial!)
    }
}
