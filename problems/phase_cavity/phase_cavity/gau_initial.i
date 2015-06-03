[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = .005
  ymax = .005
  elem_type = QUAD9
  uniform_refine = 0
[]

[Variables]
  [./phi]
  [../]
[]

[AuxVariables]
  [./u]
  [../]
  [./phi_aux]
  [../]
[]

[Kernels]
  [./phase_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
[]

[AuxKernels]
  [./phi_aux]
    type = PikaPhaseInitializeAux
    variable = phi_aux
    phase = phi
  [../]
[]

[BCs]
  [./vapor]
    type = DirichletBC
    variable = phi
    boundary = left
    value = -1
  [../]
  [./solid]
    type = DirichletBC
    variable = phi
    boundary = right
    value = 1
  [../]
[]

[Executioner]
  type = Steady
  nl_max_its = 20
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '50 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-12
  l_tol = 1e-7
  l_abs_step_tol = 1e-20
[]

[Adaptivity]
  max_h_level = 4
  initial_steps = 4
  steps = 5
  marker = phi_marker
  initial_marker = phi_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  [./out]
    output_final = true
    type = Exodus
    file_base = gau_initial_out
  [../]
[]

[ICs]
  [./phase_ic]
    y2 = 0.005
    y1 = 0
    inside = 1
    x2 = 0.005
    outside = -1
    variable = phi
    x1 = 1e-5
    type = BoundingBoxIC
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-05
  gravity = '0 -9.81 0'
  temporal_scaling = 1
  #ice
  conductivity_ice = 0.02
  density_ice = 1.341
  heat_capacity_ice = 1400
  #vapor
  dry_air_viscosity = 3.98e-7
  thermal_expansion = 0.0036
  #misc
  latent_heat = 6.57e2
[]
