library(sf)
library(raster)
library(tidyverse)
library(purrr)
library(rgl)

### pull in all helper functions
walk(list.files("./helpers", full.names = TRUE), source)

### read mesh
uluru_mesh <-
  read_rds("./data/uluru_mesh_12000.rds")

### look at mesh in rgl
rgl.clear()
bg3d("white")
wire3d(
  tmesh3d(
    vertices = t(asHomogeneous(uluru_mesh$P)),
    indices = array(t(uluru_mesh$T))
  )
)
rglwidget()

### prepare mesh for JSON conversion 
### The coordinates for x and y are in metres from a reference point of the
### globe that is very far away and so a have large magnitude. A VR scene is
### typically centred around 0, 0, 0 with units in metres also. So if we do not
### centre the x, y coordinates of our mesh all the vertices will be VERY far
### away from the camera.
summary(uluru_mesh$P)

### write to JSON
mesh_json <- trimesh_to_threejson(vertices = uluru_mesh$P, face_vertices = uluru_mesh$T)
write_lines(mesh_json, "./data/uluru_mesh.json")

### rendering in a frame
### Uluru will initially be rendered at a strange viewpoint and height.
 height_correction <- -1 * (min(uluru_mesh$P[,3]) - mean(uluru_mesh$P[,3]))
