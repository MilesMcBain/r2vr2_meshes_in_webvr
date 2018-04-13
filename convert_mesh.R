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
mesh_json <- trimesh_to_threejson(vertices = uluru_mesh$P, face_vertices = uluru_mesh$T)

write_lines(mesh_json, "./data/uluru_mesh.json")
