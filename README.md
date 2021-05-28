# 🎬 Scene Machine
<p>
<img src="https://img.shields.io/badge/platforms-macOS_11.2_-orange.svg" alt="SwiftUI" />
<img src="https://img.shields.io/badge/Swift-5.1-orange.svg" alt="Swift 5.0" />
<img src="https://img.shields.io/github/followers/Farini?label=Follow" alt="Farini followers" />
</p>

**Textures**

Scene Machine is a tool for App Developers and Graphic Designers. This app makes the generation of procedural textures extremely easy. Besides procedural and noise textures, there is a collection of tiled & tileable textures that can be generated with Scene Machine. These images are called textures because of the standart texture sizes the app can generate: 256x256, 512x512, 1024x1024, 2048x2048 and 4096x4096 (measures in pixels).

Some textures such as Asphalt, Wood, Wallpaper, and a UVGrid also comes in the app library. - These come with their respective counterparts in Diffuse, Normal, Roughness and Ambient Occlusion counterparts. Another type of texture generated in Scene Machine is the Overlay type of textures (Lens flare, Halo, Sunbeam, and Caustic refraction).

**Effects**

Scene Machine comes with quite a few image effects. Blur, Color, Distort and Stylize. Each one of these types of effects offers at least 6 variations of itself.
Besides the effects that can be used, it is also possible to mix images. When textures are more complex, one may need to mix two, or more images using options like Color burn, Color dodge, Darken, Divide and Screen modes.

**SceneKit**

Import and export scenes in .dae and .scn formats. 

Scene Machine lets you play around with scene materials. The app can be used to preview materials before finally importing scenes into your project. It allows you to go back and forth between Scene Machine (to see if your scene is looking okay in .scn format) and Blender. This is a good way to work on details of a scene before adding it to your project.

Although SpriteKit offers ways to generate noise textures, the options are limited. In Blender, for example, there are many options, and graphics operations that can be performed to generate a texture. Scene Machine seeks to bring that type of graphic settings, essential for building great 3D scenes. Furthermore, a few pre-made geometries and backgrounds were added, to expand the users options when building scenes.

The objective of this app is to create a more user-friendly way to build a `.scn` file, or to facilitate the conversion of `.dae` files into `.scn` while maintaining high-quality meshes, with their textures. Besides these scenes, if your interest is in generating patterns and effects, this app can be very useful as well.

![Alt text](https://user-images.githubusercontent.com/5069713/115817657-40738a80-a3c9-11eb-8f5c-9c586c1ff0af.png)


## Features

### Noise & Generators
- SpriteKit Noise
- Pedal2DMetal
- Quick Noise

- [X] Choose Image Size: 256x256, 512x512, 1024x1024, 2048x2048, 4096x4096
- [X] Zoom in and out of images - Scale 0.2 to 8.0
- [X] Save Image
- [X] Undo Changes

### SpriteKit Noise Maker
Create common types of noises using `SpriteKit`.

- [X] Generate any noise in SpriteKit: Perlin, Voronoi, Ridged, Billow, Checker, Cylinder
- [X] Color Gradients - Adds step colors to the otherwise black and white noise.

### Pedal2DMetal
Procedural Image generators with `Metal`

- [X] Noise { Voronoi, Caustic, Waves }
- [X] Overlay { Lens flare, Halo, Sunbeams, Caustic Refraction }
- [X] Tiles { Checkerboard, Hexagons, Truchet, Bricks, Diagonal Lines }

### Image Composition
Mix 2 images, using multiple `CoreImage` techniques

### Metal Kernel Shaders
Image CIKernels built on Metal programming language.
More about Shaders: [Here](https://github.com/Farini/Scene-Machine/blob/main/Scene%20Machine/Shaders/ShadersReadme.md#about-shaders)

### SceneKit
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
- [X] Ambient Occlusion
- [X] Save UVMap Image
- [X] Save Materials
    
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

### New Features v 1.1
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

- [ ] Ability to use .txt files that can contain code for fragment/vertex shaders
- [ ] Improve App Help: http://swiftrien.blogspot.com/2015/06/adding-apple-help-to-os-x-application.html


## Privacy Policy - Scene Machine

We do not collect, use, save, or have access to any of you personal data recorded in Scene Machine for Mac or iOS.

Individual settings relating to Scene Machine app are not personal and are stored only on your device. You might also be asked to provide access to your photo library, but this is only so you can open your photos in Scene Machine and save them back in your library. We have no access to that information, and therefore we do not process it.

In addition, when saving an image file, some devices might store location data. However, we do not have access to it, and the data is not shared with anyone, so long you choose yourself to share the file.
