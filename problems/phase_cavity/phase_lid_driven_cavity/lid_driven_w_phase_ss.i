[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 8
  xmin = -1e-5
  xmax = .02001
  ymin = -1e-5
  ymax = 0.02
  uniform_refine = 3
  elem_type = QUAD9
[]

[MeshModifiers]
  type = AddExtraNodeset
  new_boundary = 99
  tolerance = 1e-4
  coord = '0.01 0.01'
[]

