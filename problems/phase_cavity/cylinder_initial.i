[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 90
  ny =30
  xmax = 0.05
  ymax = 0.02
  uniform_refine = 0
  elem_type = QUAD9
[]

[Variables]
  [./phi]
  [../]
[]
[AuxVariables]
  [./phi_aux]
  [../]
[]

[Kernels]
  active = 'phase_diffusion phase_double_well'
  [./phase_diffusion]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
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
    boundary = 'left right top bottom'
    value = -1
  [../]
[]

[Preconditioning]
  active = 'SMP_PJFNK'
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 100
  solve_type = PJFNK
[]

[Adaptivity]
  cycles_per_step = 0
  initial_steps = 6
  initial_marker = phi_marker
  max_h_level = 8
  [./Indicators]
    [./phi_jump]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorFractionMarker
      coarsen = 0.2
      indicator = phi_jump
      refine = 0.8
    [../]
   [./solid_marker]
      type = ValueRangeMarker
      lower_bound = 0.5
      upper_bound = 1.0
      variable = phi
    [../]
   [./combo_marker]
      type = ComboMarker
      markers = 'phi_marker solid_marker'
    [../]


  [../]
[]

[Outputs]
  [./console]
    type = Console
    linear_residuals = true
    nonlinear_residuals = true
  [../]
  [./exodus]
    type = Exodus
    file_base = cylinder_initial
    output_final = true
    interval = 1
  [../]
[]

[ICs]
  [./phase_ic]
    int_width = 1e-5
    x1 = 0.01
    y1 = 0.01
    radius = 0.0025
    outvalue = -1
    variable = phi
    3D_spheres = false
    invalue = 1
    type = SmoothCircleIC
  [../]
[]

[PikaMaterials]
  phase = phi
  temporal_scaling = 1
  temperature = 263
[]

