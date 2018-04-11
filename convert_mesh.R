library(sf)
library(raster)
library(tidyverse)
library(rgl)
source("./helpers/sf_to_trimesh.R")
 
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
