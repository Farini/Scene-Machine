#  Scene Machine Data Model

The objective of this folder is to persist data created in the app.

For now, objects are related to:

- MaterialModel (needs rename)
- Drawing

Some challenges here includes:

- Persisting Color. See: `ColorData` object.
- `CGLineJoin` conforms to  `Codable`
- `CGLineCap` conforms to `Codable`

## Assets Included with the app
Assets included with the app are located in `AppConstants.swift`

### Geometries
✅ Suzanne
✅ Woman
✅ Prototype car
✅ Trees
✅ Liberty Lady
✅ Post + Lamp
✅ Egg Tree
✅ Square tree/lamp
⭕️ House

### HDRI Images
✅ Lava1
✅ Lava2
✅ SMB1
✅ SMB2
✅ SMB3
✅ NightSky
✅ CityNight

# Drawing Model
## DrawingLayer
```
var id:UUID
var name:String?

var colorData:ColorData
var lineWidth:CGFloat

var lineJoin:CGLineJoin?     // (Int): miter(0), round(1), bevel(2)
var lineCap:CGLineCap?       // (Int): butt(0), round(1), square(2)

var tool:DrawingTool

var pencilStrokes:[PencilStroke] = []
var penPoints:[PenPoint] = []
var shapeInfo:[ShapeInfo] = []

var isVisible:Bool = true
var sublayers:[DrawingLayer] = []
```

## PencilStroke
```
var points: [CGPoint] = [CGPoint]()
```

## PenPoint
```
/// The standart identifier for SwiftUI Views
var id:UUID

/// The (main) point of this object
var point:CGPoint

/// Optional control point, if object s curve
var control1:CGPoint?

/// Optional control point, if object is curve
var control2:CGPoint?

/// Informs if this point is a curve. Defaults to false.
var isCurve:Bool
```

# Material Model

## SCNMaterial
## SceneMaterial
## SubMaterialData

# Geometries

## Collada .dae file specs
[Khronos.org](https://www.khronos.org/files/collada_spec_1_5.pdf)

## Wavefront .obj file specs
[File Specification Wikipedia](https://en.wikipedia.org/wiki/Wavefront_.obj_file)
[FileFormat.info](https://www.fileformat.info/format/wavefrontobj/egff.htm)
[MTL Format](https://people.math.sc.edu/Burkardt/data/mtl/mtl.html)

# 🍎 SceneKit
You use geometry sources together with SCNGeometryElement objects to define custom SCNGeometry objects or to inspect the data that composes an existing geometry.

### GeometryElement
SCNGeometryElement object, containing an array of indices identifying vertices in the geometry sources and describing the drawing primitive that SceneKit uses to connect the vertices when rendering the geometry.

### GeometrySource
SCNGeometrySource objects containing vertex data. Each geometry source defines an attribute, or semantic, of the vertices it describes. You must provide at least one geometry source, using the vertex semantic, to create a custom geometry; typically you also provide geometry sources for surface normals and texture coordinates.

### Extensions
The texture coordinates of a `SCNGeometry` can be obtained by getting the geometry's `SCNGeometrySource` and getting the var `uv`. It will return the **UV coordinates** of that geometry.
To discover what materials goes into what faces of a geometry, see `SCNGeometryElement` extension, `getVertices()`

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


## SceneMachine View - ToDo

1. Scene Options - Data that should be passed between View & Controller and SAVED for continuation.

- [X] Panel (Node options)
- [ ] PIP Scene (is displaying)
- [ ] SCNInteractionMode + SCNCameraController info
- [ ] PointOfView
- [ ] Autosave?
- [ ] Display node count/stats
- [ ] Scene name
- [ ] Rendering Mode?

