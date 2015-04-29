[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 64
  ny = 64
  xmin = -0.02
  xmax = .02
  ymin = -0.02
  ymax = 0.02
  uniform_refine = 0
  elem_type = QUAD9
[]

[Variables]
  [./p]
  [../]
  [./phi]
  [../]
  [./vx]
    order = SECOND
  [../]
  [./vy]
    order = SECOND
  [../]
[]

[Kernels]
  [./x_momentum]
    type = PikaMomentum
    variable = vx
    vel_y = vy
    vel_x = vx
    component = 0
    p = p
    phase = phi
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = vx
    phase = phi
  [../]
  [./y_momentum]
    type = PikaMomentum
    variable = vy
    vel_y = vy
    vel_x = vx
    component = 1
    p = p
    phase = phi
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = vy
    phase = phi
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = vy
    vel_x = vx
    phase = phi
  [../]
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
[]

[BCs]
  active = 'vapor_phase_wall inlet'
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
  [./inlet]
    type = DirichletBC
    variable = vx
    boundary = left
    value = .119239
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 50
  nl_max_its = 100
  solve_type = JFNK
  l_tol = 1e-06
  nl_rel_tol = 1e-15
[]

[Adaptivity]
  max_h_level = 8
  initial_steps = 5
  marker = combo
  initial_marker = combo
  [./Indicators]
    [./phi_jump]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorFractionMarker
      indicator = phi_jump
      refine = 0.8
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
    file_base = phase_cyl_out
    type = Exodus
    output_on = 'initial failed timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263
  interface_thickness = 1e-05
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
    radius = 0.001
    outvalue = -1
    invalue = 1
  [../]
[]

