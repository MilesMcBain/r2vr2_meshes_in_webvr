################################################################################

## Prerequisite code

################################################################################

library(devtools)
library(sf)
library(raster)
library(tidyverse)
library(purrr)
source("./helpers/sf_to_trimesh.R")

### Make a tight bounding box.
### coords come from a google map: https://drive.google.com/open?id=1Ak26Hyx1R-f2QjPCTK0rQLye5xcHyE8n&usp=sharing

uluru_bbox <-
  st_bbox(c(xmin = 131.02084,
            xmax = 131.0535,
            ymin = -25.35461,
            ymax = -25.33568),
          crs = st_crs("+proj=longlat +ellps=WGS84"))

### Convert to a MULTIPOLYGON
uluru_bbox_mpoly <-
  uluru_bbox %>%
    st_as_sfc() %>%
    st_multipolygon() %>%
    st_geometry()

st_crs(uluru_bbox_mpoly) <- st_crs(uluru_bbox)

### Read in raster
nt_raster <- raster("./data/ELVIS_CLIP.tif")

### Homogenise bbox and raster CRS
uluru_bbox_mpoly <-
  st_transform(uluru_bbox_mpoly, crs = crs(nt_raster)@projargs)

### Plot cropped raster for sanity check
nt_raster %>%
  crop(st_bbox(uluru_bbox_mpoly)[c("xmin","xmax","ymin","ymax")]) %>%
  plot() ## looks good!

### Triangulate bbox
uluru_bbox_trimesh <-
  sf_to_trimesh(uluru_bbox_mpoly, 12000) # a few more than last example for finer mesh.

### Add elevation to trimesh
ul_extent_elev <-
  raster::extract(nt_raster, uluru_bbox_trimesh$P[,1:2])
uluru_bbox_trimesh$P <-
  cbind(uluru_bbox_trimesh$P, ul_extent_elev)

### Optional: Check in rgl
## library(rgl)
## rgl.clear()
## bg3d("white")
## wire3d(
##   tmesh3d(
##     vertices = t(asHomogeneous(uluru_bbox_trimesh$P)),
##     indices = array(t(uluru_bbox_trimesh$T))
##   )
## )
## rglwidget()


################################################################################

## Uluru Mesh to VR

################################################################################

## install r2vr using devtools
install_github('milesmcbain/r2vr')
library(r2vr)

## load JSON conversion helper function
source("./helpers/trimesh_to_threejson.R")

## After prerequisite code, our mesh is now in uluru_bbox_trimesh.

## write to JSON
mesh_json <- trimesh_to_threejson(vertices = uluru_mesh$P, face_vertices = uluru_mesh$T)
write_lines(mesh_json, "./data/uluru_mesh.json")

## render in A-Frame
aframe_scene <-
  a_scene(template = "empty",
          title = "Uluru Mesh",
          description = "An A-Frame scene of Uluru",
          chilren = list(a_json_model())

          )


## rendering in a frame
## Uluru will initially be rendered at a strange viewpoint and height.
height_correction <- -1 * (min(uluru_mesh$P[,3]) - mean(uluru_mesh$P[,3]))

## still a bit off because of the lowest point dips slightly below the
## surrounding ground. Correct based on ground height.
## find ground height from the edge? 
ground_height <- 
 max(raster::extract(nt_raster, uluru_bbox_mpoly[[1]][[1]][[1]], nrow = 1))

height_correction <- -1 * (ground_height - mean(uluru_mesh$P[,3]))
## This is pretty close to correct. The ground is not perfectly flat. It's slightly tilted.

## Viewing from R
## TODO setup minimal R2VR package


## Vertex normals

