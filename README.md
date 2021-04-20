# 🎬 Scene Machine
Scene Machine is a tool for SceneKit, with a few additional features for SpriteKit. The objective is to provide an easy way to generate textures and 3D geometries to facilitate the creation of SceneKit scenes, allowing creators to speed up their process, and achieve better results.

Although SpriteKit offers ways to generate noise textures, the options are limited. In Blender, for example, there are many more options, and graphics operations that can be performed to generate a texture. Plus, those patterns can be generated and placed in an UV map.

### Noise Interface
The Noise Interface (From the Menu Noise) should generate different types of noises.
The SpriteKit Noise generates `SpriteKit`s default noise generators
The Noise Maker generates other types of noises that SpriteKit can't generate, such as the CausticNoise, and Lens flare

Properties
    
    - Image Size
    - Type, and noise properties
    - Colors Array
    
![image](https://drive.google.com/uc?export=view&id=1wEuXcVkOmv2KEQ-dtnwprrbh7oqcBdLU)

## Expected Features

### Image Composition + Noise

- [X] SpriteKit noise generation
- [X] CIFilter with Kernels
- [X] Save CIImage
- [X] Save SKNoise image
- [ ] SpriteKit shaders
- [ ] Mix Images
- [ ] Test new Metal shader: makeBlackTransparent >> With that ugly SpriteKit image (black background)

### Scene Materials
- [X] Material Model for Persistency
- [ ] Enable the use of  `TrimSheets`
- [ ] Basic Materials library (Wood, bricks, asphalt, plastic, metals, dirt, etc.)
- [ ] Save Materials
- [ ] Material Editor

### SceneKit

- [ ] Have more sample geometries than the ones provided by SceneKit
- [ ] Save and export scene `.scn` files >> https://developer.apple.com/documentation/scenekit/scnscene/1523577-write
- [ ] Automatically "beautify" `.dae` files made in blender - Adjust lighting, colors, etc.
- [ ] Have some sample code + shaders written in `Metal`  - `SCNProgram`
- [ ] Test animated characters - Bones(in blender) vs SCNSkinner(Swift)

## To-Do list

- [X] Several `CI Filters` for texture generation
- [X] Save Images generated
- [X] Basic Textures
- [X] Texture - filters and save
- [X] Materials persistency in data `SceneMaterial` object
- [X] Better interface - Noise, Scene, Material
- [X] Main menu routing to main interfaces
- [X] SpriteKit noise textures (all)

- [ ] Save Materials Property `SceneMaterial`
- [ ] Fix bug with SpriteKit Noise
- [ ] SCNProgram -> Shaders

- [ ] AppDelegate, or SwiftUI? See `Fruta` app for latter.
- [ ] Blender made textures
- [ ] Save and export Scenes `.scn` for your project
- [ ] 2/4 Basic Scenes
    - [X] Monkey
    - [X] Terrain
    - [ ] Woman
    - [ ] StreetView


### Important Notes - Modulo Funtion Metal vs GLSL

GLSL mod() can be expanded to:

> return x - y * floor(x/y)

Metal fmod() can be expanded to:

> x – y * trunc(x/y)

`GLSL's` mod function is this for `Metal`
```
float mod(float x, float y) {
    return x - y * floor(x / y);
}
```

`Metal` **fmod** function is equivalent to
```
float fmod(float x, float y) {
    return x - y * trunc(x / y);
}
```


### Scene Ideas

1. Forest
2. Terrain
3. Beach
4. Maze
5. House in the forest

### Animatable Ideas

1. Car, or Rover
2. Monkey
3. Person

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

> sources
>>  An array of SCNGeometrySource objects describing vertices in the geometry and their attributes.
> elements
>>  An array of SCNGeometryElement objects describing how to connect the geometry’s vertices.

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


