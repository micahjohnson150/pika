[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 500
  ny = 500
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
  ymax = .0051
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
    tolerance = 1e-04
  [../]
[]

[Variables]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./p]
  [../]
  [./phi]
  [../]
  [./T]
  [../]
[]

[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = uo_initial
  [../]
[]

[Kernels]
#active = 'x_momentum_time x_momentum x_no_slip x_momentum_boussinesq y_momentum_time y_momentum y_no_slip y_momentum_boussinesq mass_conservation Heat_convection Heat_diffusion phase_time phase_diffusion phase_double_well'
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    phase = phi
    coefficient = 1.341
  [../]
  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 100
  [../]
  [./x_momentum_boussinesq]
    type = PhaseBoussinesq
    variable = v_x
    component = 0
    T = T
    phase = phi
  [../]
  [./y_momentum_time]
    type = PikaTimeDerivative
    variable = v_y
    phase = phi
    coefficient = 1.341
  [../]
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 100
  [../]
  [./y_momentum_boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    T = T
    phase = phi
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    v = v_y
    u = v_x
    p = p
  [../]
  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
  [./phase_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./Heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
  [../]
  [./Heat_convection]
    type = PikaConvection
    variable = T
    vel_x = v_x
    use_temporal_scaling = true
    phase = phi
    property = heat_capacity
    vel_y = v_y
  [../]
  [./Heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
[]

[BCs]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'left right top bottom'
    value = 1
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = right
    value = 301.736921
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = left
    value = 263.15
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_out.e
    timestep = 1
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.001
  end_time = 0.05
  solve_type = PJFNK
  petsc_options_iname = ' -pc_type -ksp_gmres_restart'
  petsc_options_value = 'hypre 300'
  l_max_its = 100
  nl_abs_tol = 1e-40
  nl_rel_step_tol = 1e-40
  nl_rel_tol = 1e-5
  l_tol = 1e-5
  nl_abs_step_tol = 1e-40
[]

[Adaptivity]
  max_h_level = 4
  initial_steps = 4
  marker = combo_marker
  initial_marker = phi_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./v_x_grad_indicator]
      type = GradientJumpIndicator
      variable = v_x
    [../]
    [./v_y_grad_indicator]
      type = GradientJumpIndicator
      variable = v_y
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen =1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
    [./v_x_marker]
      type = ErrorToleranceMarker
      coarsen =1e-7
      indicator = v_x_grad_indicator
      refine = 1e-5
    [../]
    [./v_y_marker]
      type = ErrorToleranceMarker
      coarsen =1e-7
      indicator = v_y_grad_indicator
      refine = 1e-5
    [../]
    [./combo_marker]
      type = ComboMarker
      markers = ' v_x_marker v_y_marker phi_marker'
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
    file_base = phase_conv_out
    type = Exodus
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = T
  interface_thickness = 1e-05
  gravity = '0 -9.81 0'
  temporal_scaling = 1
  #ice
  conductivity_ice = 0.02
  density_ice = 1.341
  heat_capacity_ice = 1400
[]

[ICs]
  [./T_ic]
    function = 7717.38418*x+263.15
    variable = T
    type = FunctionIC
  [../]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
[]

