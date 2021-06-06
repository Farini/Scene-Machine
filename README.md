# 🎬 Scene Machine
<p>
<img src="https://img.shields.io/badge/platforms-macOS_11.2_-orange.svg" alt="SwiftUI" />
<img src="https://img.shields.io/badge/Swift-5.1-orange.svg" alt="Swift 5.0" />
<img src="https://img.shields.io/github/followers/Farini?label=Follow" alt="Farini followers" />
</p>

Scene Machine is a tool for app developers and graphic designers that makes procedural generation of textures and Scene Materials easy. 

Textures can be generated as stand-alone images or tiles, and in standard sizes (256x256, 512x512, 1024x1024, 2048x2048 and 4096x4096). Image effects may also be applied to textures.

Scene Materials can be generated, stored and retrieved for other scenes. You may paint materials with Apple Pencil

Scene Machine supports import and export of .obj, .dae and .scn files for easy interchange with Blender. You may draw a shape, and convert to a Geometry.

![Alt text](https://user-images.githubusercontent.com/5069713/115817657-40738a80-a3c9-11eb-8f5c-9c586c1ff0af.png)


## Features

### Noise & Generators

- [X] Choose Image Size: 256x256, 512x512, 1024x1024, 2048x2048, 4096x4096
- [X] Zoom in and out of images - Scale 0.2 to 8.0
- [X] Save Image
- [X] Undo Changes

### SpriteKit Noise
Create common types of noises using `SpriteKit`.

- [X] Generate any noise in SpriteKit: Perlin, Voronoi, Ridged, Billow, Checker, Cylinder
- [X] Color Gradients - Adds step colors to the otherwise black and white noise.

### Pedal2DMetal
Procedural Image generators with `Metal`

- [X] Noise { Voronoi, Caustic, Waves }
- [X] Overlay { Lens flare, Halo, Sunbeams, Caustic Refraction }
- [X] Tiles { Checkerboard, Hexagons, Truchet, Bricks, Diagonal Lines, Interlaced }

### Image Composition
Mix 2 images, using multiple `CoreImage` techniques

### Metal Kernel Shaders
Image CIKernels built on Metal programming language.
More about: [Shaders](https://github.com/Farini/Scene-Machine/blob/main/Scene%20Machine/Shaders/ShadersReadme.md#about-shaders)

### Scene Machine
Test and export `SceneKit` scenes.

- [X] Show a Geometry's `UVMap`
- [X] Save and export scene `.scn`, and `.dae` files or `*.scnassets` folder.
- [X] Background `HDRI` Images
- [X] App Geometries
- [X] Add Geometry from `.dae`, `.scn` and `.obj` files.
- [ ] Have some sample code + shaders written in `Metal`  - `SCNProgram`
- [ ] Test animated characters - Bones(in blender) vs SCNSkinner(Swift)

![Alt text](https://user-images.githubusercontent.com/5069713/115817718-6731c100-a3c9-11eb-8f38-03e8f4298bc7.png)

### Scene Materials
Create SceneKit Materials - `SCNMaterial`

- [X] Material Model for Persistency
- [X] SceneMaterial, and SubMaterialData: Codable -> Persist `SCNMaterial`
- [X] Material Editor (may need improvements)
- [X] UVMap
- [X] Save UVMap Image
- [X] Save Materials
- [X] Allow use of **Apple Pencil** to draw images.
    
### Model
See this apps's model readme: [Here](https://github.com/Farini/Scene-Machine/blob/main/Scene%20Machine/Model/ModelReadme.md#scene-machine-data-model)

> App Resources can be found on the readme file above, or on the `AppConstants.swift` file.


## To-Do list

- [X] Several `CI Filters` for texture generation
- [X] Save Images generated
- [X] Basic Textures
- [X] Texture - filters and save
- [X] Materials persistency in data `SceneMaterial` object
- [X] Better interface - Noise, Scene, Material
- [X] Main menu routing to main interfaces
- [X] SpriteKit noise textures (all)
- [X] ImageFX -> Undo
- [X] Save and export Scenes `.scn` for your project
- [X] Fix bug with SpriteKit Noise
- [X] Export UVMap
- [X] Fix Zoom issues on Pedal2DMetal
- [X] Cleanup SceneMachineController
- [X] Remove CIGenerators from Pedal2DMetal
- [X] Under UVMap (ZStack), add image of the UV (if any)

*New Features v 1.1*
- [X] Export .dae format
- [X] App Textures
- [X] Terrain Editor - Displace intensity
- [X] Add SCNShape to SceneMachine
- [X] Better Voronoi
- [X] Plasma Generator

### New Features v 1.2
- [X] NormalMap shader, to transform images in Normal Maps
- [X] Blender Shortcuts
- [X] Export to `.scnassets` folder.
- [X] Draw textures on UVMaps
- [X] Use Apple Pencil
- [X] 💾 Save Materials Property `SceneMaterial`

### New Features v 1.3
- [X] At least 5 New Generators
- [X] Better Drawing
- [X] Scene Explorer
- [X] Interface Improvements
- [X] Write Shader Snippets on SceneMachine

- [ ] Improve App Help: http://swiftrien.blogspot.com/2015/06/adding-apple-help-to-os-x-application.html


## Privacy Policy - Scene Machine

We do not collect, use, save, or have access to any of you personal data recorded in Scene Machine for Mac or iOS.

Individual settings relating to Scene Machine app are not personal and are stored only on your device. You might also be asked to provide access to your photo library, but this is only so you can open your photos in Scene Machine and save them back in your library. We have no access to that information, and therefore we do not process it.

In addition, when saving an image file, some devices might store location data. However, we do not have access to it, and the data is not shared with anyone, so long you choose yourself to share the file.
