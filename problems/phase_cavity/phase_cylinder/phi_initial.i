[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 75
  xmin = -.05
  xmax = 0.1
  ymin = -0.1
  ymax = 0.1
  elem_type = QUAD9
[]

[Variables]
  [./phi]
  [../]
[]

[Kernels]
  [./phi_diffusion]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
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
  active = 'vapor_phase_wall'
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = top
    value = 0
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom left right'
    value = -1
  [../]
  [./phase_wall_no_slip_x]
    type = DirichletBC
    variable = v_x
    boundary = bottom
    value = 0
  [../]
  [./phase_wall_no_slip_y]
    type = DirichletBC
    variable = v_y
    boundary = bottom
    value = 0
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = right
    value = 0
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
  max_h_level = 9
  initial_steps =9
  initial_marker = phi_marker
  cycles_per_step = 0
  [./Indicators]
    [./phi_jump]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    active = 'phi_marker'
    [./phi_marker]
      type = ErrorFractionMarker
      indicator = phi_jump
      refine = 0.8
      coarsen = 0.2
    [../]
    [./box_marker]
      type = BoxMarker
      bottom_left = '0 -0.001 0'
      top_right = '0.01 0.001 0'
      inside = REFINE
      outside = DONT_MARK
    [../]
    [./combo]
      type = ComboMarker
      markers = 'box_marker phi_marker'
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
    output_on = 'initial failed timestep_end'
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

