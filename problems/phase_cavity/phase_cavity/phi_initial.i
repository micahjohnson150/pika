[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = .005
  ymax = .005
  elem_type = QUAD9
  uniform_refine = 3
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
  active = 'phase_diffusion phase_double_well'
  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
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
    boundary = left
    value = 1
  [../]
  [./vapor]
    type = DirichletBC
    variable = phi
    boundary = right
    value = -1
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '50 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-12
  l_tol = 1e-4
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 3
  [../]
[]

[Outputs]
  output_initial = true
  print_linear_residuals = true
  print_perf_log = true
  [./out]
    output_final = true
    type = Exodus
    file_base = phi_initial_out
  [../]
[]

[ICs]
  [./phase_ic]
    y2 = 0.0051
    y1 = 0
    inside = 1
    x2 = 0.0025
    outside = -1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
[]

[PikaMaterials]
  temperature = 263.15
  interface_thickness = 1e-4
  phase = phi
  temporal_scaling = 1
[]

