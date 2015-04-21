[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 4
  ny = 4
  xmax = 0.01
  ymax = 0.01
  elem_type = QUAD9
[]

[Variables]
  [./phi]
  [../]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./p]
  [../]
[]

[Kernels]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
  [../]
  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
    phase = phi
  [../]
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
    phase = phi
  [../]
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
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'top bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./inlet]
    type = DirichletBC
    variable = v_x
    boundary = left
    value = 159.9
  [../]
  [./vapor_walls]
    type = DirichletBC
    variable = phi
    boundary = 'left right top bottom'
    value = -1
  [../]
[]

[Postprocessors]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 100
  nl_max_its = 1000
  solve_type = PJFNK
  petsc_options_iname = -ksp_gmres_restart
  petsc_options_value = 50
  nl_rel_tol = 1e-9
  line_search = none
[]

[Adaptivity]
  max_h_level = 10
  initial_steps = 6
  initial_marker = unform
  marker = combo
  steps = 2
  [./Indicators]
    [./phi_jump]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./v_x_jump]
      type = GradientJumpIndicator
      variable = v_x
    [../]
    [./v_y_jump]
      type = GradientJumpIndicator
      variable = v_y
    [../]
    [./pressure_jump]
      type = GradientJumpIndicator
      variable = p
    [../]
  [../]
  [./Markers]
    active = 'phi_marker v_y_marker combo p_marker v_x_marker unform'
    [./phi_marker]
      type = ErrorFractionMarker
      indicator = phi_jump
      refine = 0.8
    [../]
    [./p_marker]
      type = ErrorFractionMarker
      indicator = pressure_jump
      refine = 0.8
    [../]
    [./v_x_marker]
      type = ErrorFractionMarker
      indicator = v_x_jump
      refine = 0.8
    [../]
    [./v_y_marker]
      type = ErrorFractionMarker
      indicator = phi_jump
      refine = 0.8
    [../]
    [./combo]
      type = ComboMarker
      markers = 'p_marker v_x_marker v_y_marker phi_marker'
    [../]
    [./center_line]
      type = BoxMarker
      bottom_left = '0.004 0.004 0'
      top_right = '0.01 0.006 0.0'
      inside = REFINE
      outside = DO_NOTHING
    [../]
    [./unform]
      type = UniformMarker
      mark = REFINE
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  exodus = true
  csv = true
  print_linear_residuals = true
  print_perf_log = true
[]

[ICs]
  [./phase_ic]
    int_width = 1e-5
    x1 = 0.005
    y1 = 0.005
    radius = 0.0005
    outvalue = -1
    variable = phi
    3D_spheres = false
    invalue = 1
    type = SmoothCircleIC
  [../]
[]

[PikaMaterials]
  temperature = 263
  interface_thickness = 1e-5
  temporal_scaling = 1
  condensation_coefficient = .01
  phase = phi
  gravity = '0 -1 0'
[]

