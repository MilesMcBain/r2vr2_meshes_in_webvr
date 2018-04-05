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


### load template
threejs_json_template <-
  read_lines("./helpers/threejs_json_template.txt") %>%
  paste0(collapse = "\n")

threejs_json_data <-
  new.env()

threejs_json_data$vertices <-
  uluru_mesh$P %>%
  as_data_frame() %>%
  transpose() %>%
  map( ~paste0(., collapse = ',')) %>%
  paste0( ., collapse = ', ') %>% head() 

