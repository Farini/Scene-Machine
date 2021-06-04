#  About Shaders

## Core Image + Metal Kernels

## Notes + To Do

1. Get a simple Color Noise Image
```
let colorNoise = AppTextures.colorNoiseTexture()
let monocnoise = AppTextures.monocolorNoiseTexture(tSize:TextureSize = .medium, smooth:CGFloat = 0.5)
```

- Decide what to do with "default values"
- Extend some filters, so they can work with others.
- Research strategies to make images tileable
- When does a Filter need to be a `Kernel` vs `ColorKernel`

## Shader Types

### Tiled

1. CheckerMetal:        A Filter that generates a Checkerboard
2. RandomMaze:        A filter that generates random directions of diagonals in tiles, representing a Maze   
3. BricksFilter:            Tiled Filter with Brick Pattern
4. InterlacedTiles:       Laces going over+under other laces. Tiled.
5. TriangledGrid:         Triangles mirrorred and connected. Tiled.
6. CircuitMaker:          Segments (Edges) connecting dots, resembling a circuit. Tiled.
7. CornerHoles
8. ScalingCheckerboard
9. TricapsuleGrid

### Noise

1. VoronoiFilter:                Standart `Voronoi` Shader
2. CausticNoiseMetal:     Caustic (Electric/Cloud) Noise         
3. PlasmaFilter:                A Random Color Warping Shader

### Effects

1. NormalMapFilter:         Makes a Normal Map from an image
2. SwapRGFilter:              A filter that Swaps Red and Green components of an image.
3. BLKTransparent:          Turns a black pixel into a transparent pixel, with a threshold
4. WHITransparent:          Turns a white pixel into a transparent pixel, with a threshold
5. LaplatianFilter:             Standart Laplatian Filter
6. SketchFilter:                 Makes Sketches from outlines in the original image.
7. TileMaker:                    Tiling engine (Blurs the edges to match beginning of tile)

### Great Tutorials
Not necessarily in order of preference.

1. [IQuilezles](https://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm)
2. [IQ Youtube](https://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm)
3. [BigWings](https://www.shadertoy.com/view/ltffzl)
4. [BW YouTube](https://www.youtube.com/channel/UCcAlTqd9zID6aNX3TzwxJXg)

### Important Notes - Modulo Function Metal vs GLSL

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

## Scene Shaders

- [X] GRBA -> Green to Red (and back) pixels 
- [X] Caustic Noise improved
- [X] Black to Transparent
- [X] Hexagons pattern
- [X] Truchet tiling
- [X] Epitrochoidal Waves
- [X] Mercurialize
- [X] Voronoi Noise improved
- [ ] KIFS Fractals: https://www.youtube.com/watch?v=il_Qg9AqQkE&list=RDCMUCcAlTqd9zID6aNX3TzwxJXg&index=6
