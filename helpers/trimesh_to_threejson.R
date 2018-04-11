trimesh_to_threejson <- function(vertices, faces,
                                 colours, vertex_colours,
                                 normals, vertex_normals) {

 ## format from: https://github.com/mrdoob/three.js/wiki/JSON-Model-format-3
 json_template <- '{
    "metadata": { "formatVersion" : 3 },

    "materials": [ {"DbgColor": 15597568,
      "DbgIndex": 1,
      "DbgName": "land",
      "blending": "NormalBlending",
      "colorDiffuse": [1, 1, 1],
      "colorSpecular": [1, 1, 1],
      "depthTest": true,
      "depthWrite": true,
      "shading": "Phong",
      "specularCoef": 0.0,
      "transparency": 1.0,
      "transparent": false,
      "vertexColors": 2}],
    "vertices": [ ${vertices} ],
    "normals":  [ ${normals} ],
    "colors":   [ ${colors} ],
    "uvs":      [ ${uvs} ],
    "faces": [
      ${faces}
      ]}'

  ## calculate face definition byte
  face_def <-
    0 +                                   # use triangular faces
    2^1 +                                 # use material for face
    (!missing(vertex_colours) * 2^7) +    # use face vertex colours
    (!misssing(vertex_normals) * 2^5)     # use face vertex normals

  threejs_json_data <-
    new.env()

  ## vertices
  if (!is.matrix(vertices) | (ncol(vertices != 3))){
    stop("vertices is not a 3 column matrix")
  }
  threejs_json_data$vertices <-
    vertices %>%
    as_data_frame() %>%
    transpose() %>%
    map( ~paste0(., collapse = ',')) %>%
    paste0( ., collapse = ', ')

  ## colours
  if (missing(colours)){
    colours <- ""
  }
  if (!is.character(colours)){
    stop("colours is not a character vector")
  }
  threejs_json_data$colours <-
    colours %>%
    paste0(., collapse=", ")

  ## normals
  if (missing(normals)){
    normals <- ""
  }
  else {
    if (!is.matrix(normals) | ncol(normals != ) ){
      stop("normals is not a 3 column matrix")
    }
  }

  ## bind cols of faces, vertex_colours, and vertex_normals
  ## work by row pasting a face definition

}
