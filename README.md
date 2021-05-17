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


## Expected Features

### Noise & Generators
- SpriteKit Noise
- Pedal2DMetal
- Quick Noise

**Common Features** 

- [X] Choose Image Size: 256x256, 512x512, 1024x1024, 2048x2048, 4096x4096
- [X] Zoom in and out of images - Scale 0.2 to 8.0
- [X] Save Image
- [X] Undo Changes

### SpriteKit Noise Maker
Create 6 common types of noises using `SpriteKit`.

- [X] Generate any noise in SpriteKit: Perlin, Voronoi, Ridged, Billow, Checker, Cylinder
- [X] Color Gradients

### Pedal2DMetal
Procedural Image generators with `Metal`

- [X] Organize in Sections
- [X] Noise { Voronoi, Caustic, Waves }
- [X] Overlay { Lens flare, Halo, Sunbeams, Caustic Refraction }
- [X] Tiles { Checkerboard, Hexagons, Truchet, Bricks, Diagonal Lines }

### Image Composition
Mix 2 images, using multiple `CoreImage` techniques

- [X] Basic CIFilters

### Metal Kernel Shaders
Image CIKernels built on Metal programming language.
More about Shaders: [Here](https://github.com/Farini/Scene-Machine/blob/main/Scene%20Machine/Shaders/ShadersReadme.md#about-shaders)

- [X] GRBA -> Green to Red (and back) pixels 
- [X] Caustic Noise improved
- [X] Black to Transparent
- [X] Hexagons pattern
- [X] Truchet tiling
- [X] Epitrochoidal Waves
- [X] Mercurialize
- [ ] KIFS Fractals: https://www.youtube.com/watch?v=il_Qg9AqQkE&list=RDCMUCcAlTqd9zID6aNX3TzwxJXg&index=6
- [ ] Voronoi Noise improved

### SceneKit
Test and export `SceneKit` scenes.

- [X] Show a Geometry's `UVMap`
- [X] Save and export scene `.scn` files
- [X] Background `HDRI` Images
- [X] App Geometries
- [X] Add Geometry from `.dae`, or `.obj` files.
- [X] Export Scenes in `.scn` or `.dae`
- [X] Option to export scenes to `*.scnassets` folder.
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
- [ ] Save Materials

// Remove this
Character: https://www.youtube.com/watch?v=sdE9q_784F0


### App Resources
✅ = Added, ⭕️ = Buiding

**Geometries**
✅ Suzanne, 
✅ Woman, 
✅ Prototype car, 
⭕️ Trees,
⭕️ House

**Textures**
    ✅ Wall,
    ✅ Asphalt,
    ✅ Wood,
    ✅ UVGrid,
    ⭕️ Brushed Metal,
    ⭕️ Dirt,
    ⭕️ Skin

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
- [X] NormalMap shader, to transform images in Normal Maps, or...
- [X] Blender Shortcuts
- [X] Export to `.scnassets` folder.

- [ ] Draw textures on UVMaps
- [ ] Ability to use .txt files that can contain code for fragment/vertex shaders
- [ ] SpriteKit Normal map. `SKTexture.generatingNormalMap()` 
- [ ] 💾 Save Materials Property `SceneMaterial`
- [ ] Improve App Help: http://swiftrien.blogspot.com/2015/06/adding-apple-help-to-os-x-application.html

# 🍎 SceneKit

## SCNGeometry
https://developer.apple.com/documentation/scenekit/scngeometry#1655143

>You can animate a geometry object. The vertex data associated with a geometry is immutable, but SceneKit provides several ways to animate geometry. You can use a SCNMorpher or SCNSkinner object to deform a geometry’s surface, or run animations created in an external 3D authoring tool and loaded from a scene file.

### SCNMorpher
https://developer.apple.com/documentation/scenekit/scnmorpher
An object that manages smooth transitions between a node's base geometry and one or more target geometries.
You control these transitions by associating an **SCNMorpher** object with a node using its morpher property.
The morpher maintains an array of target geometries and a set of weights associated with each.

### SCNSkinner
https://developer.apple.com/documentation/scenekit/scnskinner
An object that manages the relationship between skeletal animations and the nodes and geometries they animate.
Working with an Animation Skeleton:
>convenience init(baseGeometry: SCNGeometry?, 
>bones: [SCNNode], 
>boneInverseBindTransforms: [NSValue]?, 
>boneWeights: SCNGeometrySource, 
>boneIndices: SCNGeometrySource)

Sharing a Skinner Object:
```
let hero = SCNScene(named:"hero").rootNode
let hat = SCNScene(named:"hat").rootNode
hat.skinner.skeleton = hero.skinner.skeleton;
```

### SCNShadable
https://developer.apple.com/documentation/scenekit/scnshadable
Methods for customizing SceneKit's rendering of geometry and materials using Metal or OpenGL shader programs.

1. geometry
2. surface
3. lightingModel
4. fragment

👀 Writing a Shader Modifier Snippet
The code below rotates the position of the object

```
// 1. Custom variable declarations (optional)
// For Metal, a pragma directive and one custom variable on each line:
#pragma arguments
float intensity;
// For OpenGL, a separate uniform declaration for each custom variable
uniform float intensity;

// 2. Custom global functions (optional)
vec2 sincos(float t) { return vec2(sin(t), cos(t)); }

// 3. Pragma directives (optional)
#pragma transparent
#pragma body

// 4. Code snippet
_geometry.position.xy = sincos(u_time);
_geometry.position.z = intensity;
```

### SCNGeometrySource, SCNGeometryElement
Create a custom geometry from vertex data
>init(sources:elements:)

> Sources
>  An array of SCNGeometrySource objects describing vertices in the geometry and their attributes.

>  Elements
>  An array of SCNGeometryElement objects describing how to connect the geometry’s vertices.

**Different Materials in one geometry**
> Sources for the vertex, normal, and color semantics must be unique—if multiple objects in the sources array have the same semantic, SceneKit uses only the first. 
> A geometry may have multiple sources for the texcoord semantic—the order of texture coordinate sources in the sources array > determines the value to use for the mappingChannel property when attaching materials.

See **Configuring Texture Mapping Attributes** for more.
Link: https://developer.apple.com/documentation/scenekit/scnmaterialproperty/1395405-mappingchannel

### SCNGeometrySource
```
typedef struct {
float x, y, z;    // position
float nx, ny, nz; // normal
float s, t;       // texture coordinates
} MyVertex;

MyVertex vertices[VERTEX_COUNT] = { /* ... vertex data ... */ };
NSData *data = [NSData dataWithBytes:vertices length:sizeof(vertices)];
SCNGeometrySource *vertexSource, *normalSource, *tcoordSource;

vertexSource = [SCNGeometrySource geometrySourceWithData:data
semantic:SCNGeometrySourceSemanticVertex
vectorCount:VERTEX_COUNT
floatComponents:YES
componentsPerVector:3 // x, y, z
bytesPerComponent:sizeof(float)
dataOffset:offsetof(MyVertex, x)
dataStride:sizeof(MyVertex)];

normalSource = [SCNGeometrySource geometrySourceWithData:data
semantic:SCNGeometrySourceSemanticNormal
vectorCount:VERTEX_COUNT
floatComponents:YES
componentsPerVector:3 // nx, ny, nz
bytesPerComponent:sizeof(float)
dataOffset:offsetof(MyVertex, nx)
dataStride:sizeof(MyVertex)];

tcoordSource = [SCNGeometrySource geometrySourceWithData:data
semantic:SCNGeometrySourceSemanticTexcoord
vectorCount:VERTEX_COUNT
floatComponents:YES
componentsPerVector:2 // s, t
bytesPerComponent:sizeof(float)
dataOffset:offsetof(MyVertex, s)
dataStride:sizeof(MyVertex)];
```

### SCNGeometryElement
https://developer.apple.com/documentation/scenekit/scngeometryelement

```
convenience init(data: Data?, 
primitiveType: SCNGeometryPrimitiveType, 
primitiveCount: Int, 
bytesPerIndex: Int)
```


### SCNMaterial
https://developer.apple.com/documentation/scenekit/scnmaterial

A set of shading attributes that define the appearance of a geometry's surface when rendered.

Visual Properties for Physically Based Shading
var diffuse: SCNMaterialProperty:               An object that manages the material’s diffuse response to lighting.
var metalness: SCNMaterialProperty:         An object that provides color values to determine how metallic the material’s surface appears.
var roughness: SCNMaterialProperty:         An object that provides color values to determine the apparent smoothness of the surface.

### SCNMaterialProperty
https://developer.apple.com/documentation/scenekit/scnmaterialproperty

>Typically, you associate texture images with materials when creating 3D assets with third-party authoring tools, and the scene files containing those assets reference external image files. 
>For best results when shipping assets in your app bundle, place scene files in a folder with the .scnassets extension, and 
>place image files referenced as textures from those scenes in an Asset Catalog.


## Privacy Policy - Scene Machine

We do not collect, use, save, or have access to any of you personal data recorded in Scene Machine for Mac or iOS.

Individual settings relating to Scene Machine app are not personal and are stored only on your device. You might also be asked to provide access to your photo library, but this is only so you can open your photos in Scene Machine and save them back in your library. We have no access to that information, and therefore we do not process it.

In addition, when saving an image file, some devices might store location data. However, we do not have access to it, and the data is not shared with anyone, so long you choose yourself to share the file.
