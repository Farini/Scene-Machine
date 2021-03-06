//
//  HelpMainView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/3/21.
//

import SwiftUI

struct HelpMainView: View {
    
    enum HelpSection {
        case Base
        case Noise
        case ImageFX
        case Scenes
        case Pencil
    }
    
    @State var selection:HelpSection? = .Base
    
    var body: some View {
        NavigationView {
            
            List(selection:$selection) {
                
                NavigationLink(
                    destination: HelpFrontView(),
                    tag: HelpSection.Base,
                    selection: $selection) {
                    Label("Start", systemImage: "heart")
                }
                .tag(HelpSection.Base)
                
                NavigationLink(
                    destination: HelpNoiseView(),
                    tag: HelpSection.Noise,
                    selection: $selection) {
                    Label("Noise & Generators", systemImage: "heart")
                }
                .tag(HelpSection.Noise)
                
                NavigationLink(
                    destination: HelpImagesView(),
                    tag: HelpSection.ImageFX,
                    selection: $selection) {
                    Label("Images & Special Effects", systemImage: "heart")
                }
                .tag(HelpSection.ImageFX)
                
                NavigationLink(
                    destination: HelpSceneView(),
                    tag: HelpSection.Scenes,
                    selection: $selection) {
                    Label("Scenes", systemImage: "heart")
                }
                .tag(HelpSection.Scenes)
                
                Divider()
                
                NavigationLink(
                    destination: HelpPencilKitView(),
                    tag: HelpSection.Pencil,
                    selection: $selection) {
                    Label("Pencil Kit", systemImage: "pencil")
                }
                .tag(HelpSection.Pencil)
            }
            .frame(minWidth: 100, maxWidth: 200, alignment: .center)
        }
    }
}

struct HelpFrontView:View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                Text("Help - Start").font(.title).foregroundColor(.accentColor)
                Text("Scene Machine is composed of three main parts.")
                
                Text("Noise & Generators")
                    .foregroundColor(.blue).font(.title2).padding(6)
                Text("Generates Noises and Patterns. Some of them can be really useful for UVMaps").foregroundColor(.gray)
                
                Text("Images & Effects")
                    .foregroundColor(.blue).font(.title2).padding(6)
                Text("Mix images, or apply filters to images.").foregroundColor(.gray)
                
                Text("Scenes")
                    .foregroundColor(.blue).font(.title2).padding(6)
                Text("Import, and create Scenes. Inspect geometries, check and export UVMaps from geometries, and export '.scn' files.").foregroundColor(.gray)
                
//                Text("There are three views that make images from noise sources.")
//
//                Group {
//                    Text("Quick Noise").font(.title3).padding(6).foregroundColor(.blue)
//
//                    Text("Makes a basic perlin noise, considering only one variable: Smoothness. You may also choose the size of the image generated by going through the options of 'sizes'")
//                }
//
//                Group {
//                    Text("SpriteKit Noise").font(.title3).padding(6).foregroundColor(.blue)
//
//                    Text("SpriteKit offers a few great ways to make noise, and Scene Machine uses it as a tool to create great textures.")
//                }
                
            }
            .padding(8)
            .frame(minWidth: 200, maxWidth: 750, minHeight: 300, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        }
    }
}

struct HelpNoiseView:View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                Group {
                    Text("Noise").font(.title).foregroundColor(.accentColor)
                    Text("There are 3 noise, or pattern generators.")
                }
                .padding(6)
                
                Group {
                    Text("Quick Noise").font(.title3).foregroundColor(.blue)
                    
                    Text("Makes a basic perlin noise, considering only one variable: Smoothness. You may also choose the size of the image generated by going through the options of 'sizes'")
                }
                .padding(6)
                
                Group {
                    Text("SpriteKit Noise").font(.title3).foregroundColor(.blue)
                    
                    Text("SpriteKit offers a few great ways to make noise, and Scene Machine uses it as a tool to create great textures.")
                }
                .padding(6)
                
                Group {
                    Text("Pedal 2D Metal").font(.title3).foregroundColor(.blue)
                    
                    Text("Most of the generators there were created in Metal programming language. Some examples were extracted from the GLSL language, on Shadertoy (www.shadertoy.com) - Big Kudos for 'The art of code' - a great youtube channel that offers amazing tutorials on GLSL.")
                    
                    Text("Here you will find a few types of image, such as Noise, Tiles, Overlay and Other types of generators. The best way to approach it, if you are learning, is to try and experiment with all of them, to see which one, or even a group of shaders that fit your needs")
                }
                .padding(6)
            }
            
        }
        
    }
}

struct HelpImagesView:View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                Group {
                    Text("Image FX").font(.title).foregroundColor(.accentColor)
                    Text("There are two types of effects. Compose and Image FX")
                }
                .padding(6)
                
                Group {
                    Text("Compose").font(.title3).foregroundColor(.blue)
                    
                    Text("Mix two images using many Core Image color filters. Includes Blendmode, BurnBlendMode, DodgeBlendMode, DarkenBlendMode, ScreenBlendMode, and more. You may use the 'Background' and 'Foreground' buttons, or simply drag an image from finder into the images. The button 'Mix Image' will apply the effect, and 'Flip Order' will swap the background and foreground images.")
                }
                .padding(6)
                
                Group {
                    Text("Image FX").font(.title3).foregroundColor(.blue)
                    
                    Text("There are many effects created by this app. They are divided in 'Blur', 'Color', 'Stylize' and 'Distort'. Experimenting with them is highly recommended.")
                }
                .padding(6)
            }
        }
        
    }
}

struct HelpSceneView:View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                Group {
                    Text("Scenes").font(.title).foregroundColor(.accentColor)
                    Text("There are two types of scenes. Terrain Editor and SceneMachine")
                }
                .padding(6)
                
                Group {
                    Text("Terrain Editor").font(.title3).foregroundColor(.blue)
                    
                    Text("This was made specially for those who like to create procedural terrains. Simply drag a black and white image to the 'Displacement' area to create the height of the terrain, and drop a colored image to 'Diffuse' area, to give the terrain some color. Those images can easily be generated at the Noise & Generators >> SpriteKit noise.")
                }
                .padding(6)
                
                Group {
                    Text("Scene Machine").font(.title3).foregroundColor(.blue)
                    
                    Text("Some features are still being worked on, but Scene Machine allows you to import geometries from other scenes with the following extensions: .dae, .obj, .scn")
                    
                    Text("It is also possible to generate an image from the UVMap, to paint over in another application, while looking at the UVMap. Some geometries were included with the app, and can easily be added using the '+ Geometry' button, on the top area of the window.")
                    
                }
                .padding(6)
                
                Group {
                    Text("Saving a Scene").font(.title3).foregroundColor(.blue)
                    
                    Text("Scene files can be saved in '.dae', or '.scn' formats.")
                    
                    Text("In addition, it is possible to export a scene to a '.scnassets' folder. This is convenient when the objective is to have a large scene, with many characters. They can be organized into a folder. The images are also exported to the same folder. That way, the references (URL) to the material images, for example, will continue to work.")
                    
                }
                .padding(6)
            }
        }
    }
}

struct HelpMainView_Previews: PreviewProvider {
    static var previews: some View {
        HelpMainView()
    }
}
