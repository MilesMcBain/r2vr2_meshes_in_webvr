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

### centre mesh x,y
uluru_mesh$P[,1] <- scale(uluru_mesh$P[,1], center = TRUE, scale = FALSE)
uluru_mesh$P[,2] <- scale(uluru_mesh$P[,2], center = TRUE, scale = FALSE)

## start indicies from 0
## Our uluru_mesh$T is set up to index uluru_mesh$P. In R the indicies start
## from 1, but in the threejs JSON they need to start from 0. It's a simple
## transform:
uluru_mesh$T <- uluru_mesh$T-1

### write to JSON
mesh_json <- trimesh_to_threejson(vertices = uluru_mesh$P, face_vertices = uluru_mesh$T)
write_lines(mesh_json, "./data/uluru_mesh.json")
