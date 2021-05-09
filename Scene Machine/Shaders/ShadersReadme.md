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
