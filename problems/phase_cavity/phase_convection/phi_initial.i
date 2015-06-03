[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
  ymax = .0051
  elem_type = QUAD9
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
  [./solid]
    type = DirichletBC
    variable = phi
    boundary = 'top left bottom right'
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
  l_tol = 1e-4
  l_abs_step_tol = 1e-13
[]
[Adaptivity]
  max_h_level = 3
  initial_steps = 3
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
  print_linear_residuals = true
  print_perf_log = true
  [./out]
    type = Exodus
    file_base = phi_initial_out
    output_final = true
    output_initial = true
  [../]
[]

[ICs]
active = 'phi_full_box_IC'
  [./phi_full_box_IC]
    y2 = 0.005
    y1 = 0
    inside = -1
    x2 = 0.005
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
  [./phi_small_box_IC]
    y2 = 0.005
    y1 = 0
    inside = -1
    x2 = 0.0001
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]

[]

[PikaMaterials]
  temperature = 263.15
  interface_thickness = 1e-5
  phase = phi
  temporal_scaling = 1
[]

