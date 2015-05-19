[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 300  
  ny = 200
  xmin = -.05
  xmax = 0.1
  ymin = 0
  ymax = 0.05
  elem_type = QUAD9
[]

[Variables]
  [./phi]
  [../]
[]

[Kernels]
  [./phi_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    temporal_scaling = false
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
[]

[BCs]
  [./vapor_phase_walls]
    type = DirichletBC
    variable = phi
    boundary =' top left right'
    value = -1
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
  [../]
[]

[Executioner]
  type = Transient
  l_max_its = 50
  nl_max_its = 100
  solve_type = PJFNK
  petsc_options_iname = -pc_type
  petsc_options_value = hypre
  l_tol = 1e-03
  nl_rel_tol = 1e-15
  nl_abs_tol = 1e-9
  end_time = 3600
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
  [../]
[]
[Adaptivity]
  max_h_level = 5
  initial_steps = 5
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
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phi_initial
    type = Exodus
    output_on = 'final'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-04
  temporal_scaling = 1 # 1e-05
  gravity = '0 -9.81 0'
[]

[ICs]
  [./phase_ic]
    y1 = 0
    variable = phi
    x1 = 0
    type = SmoothCircleIC
    int_width = 1e-5
    radius = 0.0025
    outvalue = -1
    invalue = 1
    3D_spheres = false
  [../]
[]

