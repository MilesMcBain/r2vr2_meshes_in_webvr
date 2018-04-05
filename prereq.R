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

### Check in rgl
library(rgl)
rgl.clear()
bg3d("white")
wire3d(
  tmesh3d(
    vertices = t(asHomogeneous(uluru_bbox_trimesh$P)),
    indices = array(t(uluru_bbox_trimesh$T))
  )
)
rglwidget()

### Write R Object
write_rds(uluru_bbox_trimesh, "./data/uluru_mesh_12000.rds")

