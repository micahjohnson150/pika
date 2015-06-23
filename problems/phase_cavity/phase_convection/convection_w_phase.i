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
#  [./phi_func]
#    type = SolutionFunction
#    from_variable = phi
#    solution = uo_initial
#  [../]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = uo_restart
  [../]
  [./p_func]
    type = SolutionFunction
    from_variable = p
    solution = uo_restart
  [../]
  [./T_func]
    type = SolutionFunction
    from_variable = T
    solution = uo_restart
  [../]
  [./v_x_func]
    type = SolutionFunction
    from_variable = v_x
    solution = uo_restart
  [../]
  [./v_y_func]
    type = SolutionFunction
    from_variable = v_y
    solution = uo_restart
  [../]
[]
[Kernels]
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
    use_temporal_scaling = false
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
  [./x_boussinesq]
    type = Boussinesq
    component = 0
    variable = v_x
    T = T
 [../]

  [./y_momentum_time]
    type = PikaTimeDerivative
    variable = v_y
    coefficient = 1.341
    use_temporal_scaling = false
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
  [./y_boussinesq]
    type = Boussinesq
    component = 1
    variable = v_y
    T = T
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
    use_temporal_scaling = false
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

  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
    use_temporal_scaling = false
  [../]
  [./heat_convection]
    type = PikaConvection
    property = heat_capacity
    use_temporal_scaling = false
    variable = T
    vel_x = v_x
    vel_y = v_y
  [../]
  [./heat_diffusion]
    type = PikaDiffusion
    property = conductivity
    use_temporal_scaling = true
    variable = T
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
    value = 301.7369208944
 [../]
 [./T_cold]
    type = DirichletBC
    variable = T
    boundary = left
    value = 263.15
 [../]
[]

[UserObjects]
#  [./uo_initial]
#    type = SolutionUserObject
#    execute_on = initial
#    mesh = phi_initial_out.e-s002
#    timestep = 1
#  [../]
  [./uo_restart]
    type = SolutionUserObject
    execute_on = initial
    mesh = ../ra_1000_002/phase_convection_out.e
    timestep = 10
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  start_time = 0.1
  end_time = 0.15
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100 '
  l_max_its = 100
  nl_max_its = 150
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none

[]
[Adaptivity]
  max_h_level = 5
  initial_steps = 5
  steps = 0
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
    output_linear = false
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phase_convection_out
    type = Exodus
    output_final = true
    output_initial = true
  [../]
  [./csv]
    file_base = phase_conv
    type = CSV
  [../]
[]


[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-05
  temporal_scaling = 1
  gravity = '0 -9.81 0'
[]

[ICs]
#  [./phase_ic]
#    variable = phi
#    type = FunctionIC
#    function = phi_func
#  [../]
#  [./T_ic]
#    variable = T
#    type = FunctionIC
#    function =7717.3841788774*x+263.15
#  [../]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./p_ic]
    variable = p
    type = FunctionIC
    function = p_func
  [../]
  [./T_ic]
    variable = T
    type = FunctionIC
    function = T_func
  [../]
  [./v_x_ic]
    variable = v_x
    type = FunctionIC
    function = v_x_func
  [../]
  [./v_y_ic]
    variable = v_y
    type = FunctionIC
    function = v_y_func
  [../]
[]


