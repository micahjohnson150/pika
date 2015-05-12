[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-5
  ymin = -1e-5
  xmax = .00501
  ymax = .00501
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
    boundary = 'left top bottom right'
    value = 1
  [../]
  [./vapor]
    type = DirichletBC
    variable = phi
    boundary = top
    value = -1
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  nl_max_its = 20
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '50 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-12
  l_tol = 1e-4
  l_abs_step_tol = 1e-13
  end_time = 7200
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 3
  [../]
[]

[Adaptivity]
  max_h_level = 3
  initial_steps = 3
  marker = phi_marker
  initial_marker = phi_marker
  steps = 4
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen = 0.5
      indicator = phi_grad_indicator
      refine = 0.5
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  print_linear_residuals = true
  print_perf_log = true
  output_final = true
  [./out]
    output_final = true
    type = Exodus
    file_base = phi_initial_out
    output_on = 'final initial'
  [../]
[]

[ICs]
  active = 'phase_ic'
  [./phase_ic]
    y2 = 0.005011
    y1 = 0
    inside = -1
    x2 = 0.005
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
  [./phi_const_IC]
    variable = phi
    type = ConstantIC
    value = -1
  [../]
[]

[PikaMaterials]
  temperature = 263.15
  interface_thickness = 1e-5
  phase = phi
  temporal_scaling = 1
[]

