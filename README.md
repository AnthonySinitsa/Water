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

- Implement lambertian diffuse lighting

- Specular highlights added to give the water that shine
  - Blinn Phong Specular

- Fractional Brownian Motion
  - We start with a wave an amplitude and frequency of 1 and a random direction
  - We sample our wave, add it to a sum, calculate the derivative and add it to a different sum(just like the sum of sines)
  - Unlike before we are now going to multiply the current frequency by a num >1 like 1.18 and multiply current amplitude by a num <1 like 0.82
  - Then on next iteration of the loop, we use new frequency and amplitude for the next wave that has a new random direction
  - We can do this with as many waves we want but the amplitude will eventually reach 0 so adding more waves won't do much