################################################################################

## Prerequisite code

################################################################################

library(devtools)
library(sf)
library(raster)
library(tidyverse)
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
mesh_json <- trimesh_to_threejson(vertices = uluru_bbox_trimesh$P, face_vertices = uluru_bbox_trimesh$T)
write_lines(mesh_json, "./data/uluru_mesh.json")

## render in A-Frame
## use a 1/1000 scale factor because Uluru is really big! 
scale_factor <- 0.001

uluru <- a_asset(id = "uluru",
                 src = "./data/uluru_mesh.json")

aframe_scene <-
  a_scene(.template = "basic",
          .title = "Uluru Mesh",
          .description = "An A-Frame scene of Uluru",
          .children = list(
            a_json_model(src = uluru,
                         material = list(color = '#C88A77'),
                         scale = scale_factor*c(1,1,1),
                         position = c(0,0,-3),
                         rotation = c(0, 0, 0))))
aframe_scene$serve()

## don't forget to:
aframe_scene$stop()

## We need to correct the height based on ground height.
## In this case we'll find ground height from the  highest corner of the bounding box.
ground_height <- 
 max(raster::extract(nt_raster, uluru_bbox_mpoly[[1]][[1]][[1]], nrow = 1))

height_correction <- -1 * (ground_height - mean(uluru_bbox_trimesh$P[,3]))
## We're reversing the correction that would have been applied to the
## ground height by centering.

## Rotated and height corrected render:

scale_factor <- 0.001

uluru <- a_asset(id = "uluru",
                 src = "./data/uluru_mesh.json")

aframe_scene2 <-
  a_scene(.template = "basic",
          .title = "Uluru Mesh",
          .description = "An A-Frame scene of Uluru",
          .children = list(
            a_json_model(src = uluru,
                         material = list(color = '#C88A77'),
                         scale = scale_factor*c(1,1,1),
                         position = c(0,0 + height_correction * scale_factor ,-3),
                         rotation = c(-90, 180, 0))))
aframe_scene2$serve()

## don't forget to:
aframe_scene2$stop()
