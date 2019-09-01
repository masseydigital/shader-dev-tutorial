# Unity Shaders

## Unity Shader Introduction

Shaders are written in ShaderLab language (Cg) / High Level Shader Language (HLSL)

They can be broken down into:
(1) Properties
(2) Processing
(3) For inferior GPUs

In the HelloShader shader we have the following properties

(1) Gives you the name of the shader and the material bucket to put it in.
(2) The properties block will allow you to provide input into your shader and how they show up in your inspector, i.e. color 
(3) Subshader block - cg/hlsl that does the computation of your shader
(4) CG Program block 
(5) #pragma block - contains information on the type of shader that you are building, i.e. surface - you are building a surface.  Also contains the function that you are going to use to build the shader and the type of lighting that you intend to use.
(6) The next block is the structure that contains the input information from the model's mesh data. i.e. uv's
(7) Properties that you want available to your function, i.e. the color that you created earlier.
(8) The functions that are being used to develop your output model.  i.e. SurfaceOuput - containing Albedo, Normal, Emission, Specular, Gloss, Alpha.  The output is dependent on the type of lighting that you are using.  Any of these properties can be modified in the function.
(9) Finally you give the shader a Fallback in case the machine is not capable of running the code that you wrote.

## Vector Mathematics Crash Course

Vector: a line that has length and a direction (arrow).  It can be used to represent measurements such as displacement, velocity, and acceleration.  You can think of a vector as a change in location of coordinates, with the values of the vector representing the amounts of coordinate change.  

The magnitude of the vector can be calculated using Pythagoras theorem.

Occassionally it is useful to scale a vector so that it has a unit length, thereby making the length of the Vector 1.  This process is called normalizing, and the resulting vector is called the unit vector.  The equation for finding the unit vector is the original vector over the magnitude.

Vectors also have dot and cross product.  This has a lot of value in graphics calculations.  The dot product can be used to calculate the angle between two vectors, and the cross product can be used to calculate the direction.  

Dot product: (vx * wx) + (vy + wy) (results in a single value)  If the dot product is greater than 0, the vectors are less than 90 degrees apart.  If the dot product is zero, then they are at right angles.  If the dot product is less than 0, then they are more than 90 degrees apart.  

Another way to find the exact angle between two angles is to take the arccosine of the dot product of the two vectors.  Angles in computer graphics are positive for counterclockwise.

The cross product of two vectors results in a new vector.  The resulting vector is perpendicular to both the intial vectors.  It is only defined in 3 dimensions.

v x x = (vywz - vz wy)(1,0,0) + (vzwx - vxwz)(0,1,0) + (vxwy - vywx)(0,0,1)

## Shader Data Types

When we are using ShaderLab script in Unity, we are only writing part of the code that is executed.  The actual shader code runs on a per pixel basis.  When we use ShaderLab we are only defining how we react to a _single_ pixel.

Shaders have their own data types that are optimized.

1) float : Highest precision, 32 bits like a regular C# float.  Used for World positions, texture coordinates, and calculations.
2) half : Half Sized Float, 16 bits - Used for short vectors, directions, and dynamic colour ranges.
3) fixed : Lowest precision, 11 bits - Used for regular colours and simple colour operations.
4) int : Like a regular int - used for counters and array indexes.

Shaders also have _Texture Data Types_

sampler2D : Single texture images, i.e. sampler2D_half (low precision), sampler2D_float (high precision)
sampleCUBE : 6 textures stiched together in a uv unwrapped cube, i.e. samplerCUBE_half (low precision), samplerCUBE_float (high precision)

Shaders have special arrays called Packed Arrays:

| int2 | float2 | half2 | fixed2 |
| int3 | float3 | half3 | fixed3 |
| int4 | float4 | half4 | fixed4 |

values are placed in the array with parenthesis values, i.e. fixed4 clour1 = (0,1,1,0); 

can be accessed by their color or position in the array (r,g,b,a) or (x,y,x,z)

Swizzling is reversing the indices in a different order.
fixed3 colour3;
colour3 = colour1.bgr;

Smearing is filling all positions in the array with the same value.
fixed3 colour3 = 1;

Masking is copying over as many values as you want.
colour1.rg = colour2.gr;

Matrices are used to define the infinite number of values that can be ascertained in a graphic.  ShaderLab has Packed Matrices to deal with this requirement.

float4x4 matrix;

[matrix name].m[row][column]
float myValue = matrix._m00;

**indexes always start at zero**

Chaining always you to specify a chain of values that you want to put into an array.
fixed4 colour = matrix._m00_m01_m02_m03
fixed4 colour = matrix[0];

**RGB is known as an additive color type - containing 3 different lights that you blend together to create different colors, the 4th channel is transparency (alpha)**

Colors in Shader code is between (0,1) where the color picker is between 0 and 255.

## Mesh Construction

The most efficient way to store a mesh is in triangles (also referred to as a polygon).  A polygon consists of (3) (x,y,z) coordinates, and a surface normal.  Each vertex also has it's own normal.  A normal is a vector pointing 90 degrees into an angle.  They are used to determine which side of a polygon to texture and the lighting characteristics when light hits the surface.

A mesh is stored as a series of arrays that make-up the surface
1) Vertex Array : an array of all the points that make up the model
2) Normal Array : makes up all of the normals for the vertices in a model.
3) UV Array : All of the uvs textures in the model.  Defines how a texture is mapped to the polygon.
4) Triangle Array : All of the polygons in the model.  Vertices in a group of 3 where each vertice makes up a tuple for the triangle in the mesh.

UVs : Map a pixel in an image to a pixel in a polygon.  A uv is represented by u,v,w.  The w is used for internal calculations.  (u,v) values fall between (0,1) starting with (0,0) in the lower left.  Uvs belong to each vertex and are implemented in counter clockwise order.  The UVs can be broken down into many parts to satisfy the polygons in the mesh.  All of the UVs should add up to 1 for each axis.  Polygons can have multiple UVs applied to a single mesh.

viewDIR gives you information about the angle that you are viewing a texture from.  An example of this woudl be rim lighting.

worldPos gives you the coordinates of the vertex being processed, and allows you to perform operations on the shader based on the world location.  An example of this would be to show or not show a material based on the physical location in the world.

worldRefl : contains information on how to reflect an image on the surface of the model.  i.e. comes in handy for shiny object with mirror finish.

**You can combine as much of these input properties as you want.  There are many of them included in the Unity api.**

## Shader Properties

Shader properties are how we get values from the inspector into the shader.

Properties can have many different inputs including:
1) Color : Provides a color picker | fixed4
2) Range : Allows you to input a range of values | half
3) 2D : provides a 2D texture.  This also gives you tiling and offset values which tell how many times and where to start the texture | sampler2D
4) CUBE : provides a cube map that you can map (used for sky boxes) | samplerCUBE
5) Float : Allows you to define a float value | float
6) Vector : Allows you to define a 4-value float vector value (x,y,z,w) | float4
7) 3D : Requires a 3D image to be produced with code, but would be used to perform 3D color correction

The tex2D that is used in the surf function in the example is a built-in function that is included with ShaderLab, Cg.  You can find all of the built-in functions on Microsoft or NVIDIAs documentation.  The best way to know how these functions work though is to try them out.

## Lighting
A lighting model is used to calculate the amount of light at a point on a surface.  It takes into account (3) things:
1) The normal of the surface (n)
2) The vector to the viewer of the surface (v)
3) Vector of the light source (s)

Lambert is a light model that determines the brightness of a surface and its relation to the orientation of the light source.  It is the simplest model due to it only taking into account the angle between the source and the normal.  When the angle is very small, the light is near perpendicular to the surface and gives a bright value.  When the angle is greater than 90 degrees, the source will not affect the surface.

Normal Mapping : creating depth with a texture map.  It does this by defining a bunch of normals across a texture.  A normal map is an rgb image where each pixel defines a normal direction used for lighting the pixel.  The less blue, the more flat the pixel.  

Red : 0 to 255 -> X : -1 to 1
Green : 0 to 255 -> Y : -1 to 1 
Blue :  0 to 255 -> Z : -1 to 1

This is also called bump mapping.  Visual effects, but not added geometry - this reduces cost.  Normal mapping is a form of bump mapping.

To make the indents deeper, you can use modify the x and y values.

The world reflection property is used to pick the parts of a cubemap to map to the models emission output.

There are (3) illumination models
1) Flat : Simplest and least computationally intensive model.  Uses one normal to shade each polygon.
2) Gouraud : Interpolation of normal colors across vertexes.
3) Phong : The flat surface is made to look curved by blending the normals across the polygon. This is the default Unity illumination method.

An improvement to the Phong model was made, named the Blinn-Phong (specular reflection) model.  This introduces a halfway vector (h) which reduces the need to calculate the reflection vector.  The halfway vector is the source vector plus the view vector, h = s + v.

Physically-Based Rendering is a rendering model aimed at generating realistic textures.  Physically-based rendering aims to implement:
1) Reflection : Drawing rays from the viewer to the material
2) Diffusion : Examines how color and light are distributed along the surface
3) Translucency and Transparency : How light can move through objects
4) Conservation of Energy : Objects never reflect more light than they receive
5) Metallicity : Considers the interaction of light on shiny surfaces and the highlights on the surface
6) Fresnel Reflectivity : How reflections on a curved surface become stronger on the edges.
7) Microsurface Scattering : Similar to bump mapping.

Vertex vs Pixel Lighting
1) Vertex : Incoming light is calculated at each vertex and then interpolated along the surface.
2) Pixel : Phong-like lighting, light for each pixel is calculated.  This picks up much more accurate specular reflections, but requires more processing.



## Buffers and Queueus
The Frame Buffer is a computer memory structure that holds the color information for each pixel on the screen.

The Z Buffer holds depth information for each pixel.  The size of the Z buffer is the same as the Frame Buffer.  This tells which pixels should get rendered to the screen by comparing the Z length from the camera.  This prevents duplication of writing information to the Frame Buffer more than once.  You can prevent Z Buffer writing in a shader by adding the line, ZWrite Off.

When Unity renders things, it is generally rendered front to back.  Render Queues allow you to change the order that shaders are drawn to the screen.  The default queue is:
1) Background | 1000
2) Geometry | 2000
3) AlphaTest | 2450
4) Transparent | 3000
5) Overlay | 4000

Tags can also be used to control what render queue your shader is in.  You can also perform math on the render queue to control additionally when the shader is drawn.

Another rendering buffer in Unity is the G-Buffer.  It is used to control deferred rendering.  There are two rendering techniques that can be used:
1) Forward Rendering : Geometry -> Vertex Shader -> Geometry Shader -> Fragment Shader Lighting | Frame Buffer
In forward rendering each object follows its own render path.  For each object each light in the environment needs to be calculated.

2) Deferred Rendering : Geometry -> Vertex Shader -> Geometry Shader -> Fragment Shader | G-Buffer -> Lighting | Frame Buffer
Lighting is only calculated once we get to the G-Buffer - therefore they only happen once. Deferred Rendering cannot display transparent objects.

## Dot Product
There are two ways that the dot product can be used to calculate the angle between two vectors
1) ||a|| ||b|| cos (angle)
2) a.x * b.x + a.y * b.y + a.z * b.z

In Cg, the dot product can be calculated using 
```c++
dot(IN.viewDIR, o.Normal);
```

The dot product is a key factor in calculating rim lighting, outlines, and anistropic highlights

When vectors are normalized to their unit vectors, the dot product equals 1.  When they are opposite they are -1, and when they are 0 they are perpendicular.  This also applies to directions of a vector coming into a normal on a polygon.

## Rim Lighting
Coloring around the edges of a model respective to a viewers location (holograms, outlines of planets).

The built-in method saturate will reduce a value to be between 0 and 1.

Logic statements can also be used in shader code.

the _frac_ function gives you the fractional part of a number.  This allows you to divide things by certain amounts and get the remainder - can be used to get odd or even numbers.

Using subsurface shaders does not allow you the ability to perform mesh positional operations since we are only passing world data into the mesh.

## Physically-based Rendering
Unity includes (2) Physially-based shaders
1) Standard - has a metallic channel, quality of the surface
2) Standard (Specular) - has a specular channel, affects the light being cast upon the object

## Passes and Blending
The alpha channel is the 4th color in the rgba color schema and represents how transparent that specific pixel is.  It also allows us to mask textures to make things such as tree leaves using billboards.

A _pass_ executes one round of a shader.  You can run multiple passes within a shader.  Each pass is called a _draw call_.  The more passes you have, however, the more labor intensive your shader will be.

The Blend command takes on a few formats
Blend SrcFactor DestFactor
Where each factor can have multiple different named types.

Blends are used for particle systems to put particles on the screen.  You can many blend shaders in the particle system shaders that unity provides.

Backface culling clears the back side of faces on a 3D object.  The point of doing this is to prevent extra processing from being done.  This becomes a problem with billboards where you need to see both sides, i.e. for trees.  You can implement culling with the Cull keyword in the shader.  i.e. Cull Off turns backface culling off.

The stencil buffer is another mask that allows you to control what pixels make it into the scene from the frame buffer.

## Vertex / Fragment Shaders
The vertex and fragment shaders give you more granular control over the rendering of a model.  i.e. modifying the vertices of a model with a shader.

The Vertex shader gives you control of each vertice in a model where you can change the color or position of the vertex.

The fragment shader provides per pixel coloring and allows access to pixels per world position.

The structure of a vertex/fragment shader looks like the following:
1) Property Block
2) Subshader Block
3) Pass Block
4) Structs for shaders - similar to input struct

**UnityCG.cginc provides more access to shaders.**

The data that you can access with the appdata struct (located in the UnityCG.cginc) is:
1) POSITION
2) TANGENT
3) NORMAL
4) TEXCOORD0
5) TEXCOORD1
6) TEXCOORD2
7) TEXCOORD3
8) COLOR

**A tangent is a vector sitting at 90 degrees to the vertex normal**

The V2F struct ccan contain the following properties for the fragment shader:
1) SV_POSITION
2) NORMAL
3) TEXCOORD0
4) TEXCOORD1
5) TANGENT
6) COLOR

The rendering queue for these shaders goes:
1) struct appdata - this is in *World Space*.
2) struct v2f - this is in *Clipping Space*.
3) Final - this is the projected image.

**Vertex shaders take away all of the background processing done by surface shaders - such as lighting and shading.**

**Vertex shaders generally have to do less work than fragment shaders due to fragment shaders affecting each pixel and vertex shaders only affecting each vertex.**

A wave can be mathematically created using a sin function. The amplitude is the height of the wave, the wavelength is the distance the peak of one wave to the next, and the frequency is the number of waves in a given time.