#  About Shaders

## Core Image + Metal Kernels

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
