# Water

### First sum of sines waves
![1](images/water1.gif)
### Lambertian diffuse lighting
![2](images/water2.gif)
 
## Steps Taken

- Render simple plane

- Give plane many vertices

- Displace the vertices according to the sum of sines

- Use the vertex shader to displace the vertices
  - position
  - uvs
  - normals
  - tangents
  - vertex colors
  - vertex lighting

- Have the vertex shader calculate the sum of sines for each vertex position then send it off to the rest of the render pipeline
