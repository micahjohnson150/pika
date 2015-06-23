
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = 0.005
  ymax = 0.005
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    coord = '0 0'
    new_boundary = 99
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
  [./T_func]
    type = ParsedFunction
    value = 500*y+260.5
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
  [./x_boussinesq]
    type = Boussinesq
    variable = v_x
    T = T
    component = 0
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 100
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
  [./y_boussinesq]
    type = Boussinesq
    variable = v_y
    T = T
    component = 1
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 100
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
    scale = 1.0
    use_temporal_scaling = false
  [../]
  [./heat_convection]
    type = PikaConvection
    variable = T
    use_temporal_scaling = true
    property = heat_capacity
    vel_x = v_x
    vel_y = v_y
  [../]
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    property = latent_heat
    scale = -0.5
    use_temporal_scaling = true
    coupled_variable = phi
  [../]

[]
[BCs]
  [./Periodic]
    [./periodic_v_x]
      variable = v_x
      auto_direction = 'x y'
    [../]
    [./periodic_v_y]
      variable = v_y
      auto_direction = 'x y'
    [../]
    [./periodic_phi]
      variable = phi
      auto_direction = ' y'
    [../]
    [./periodic_T]
      variable = T
      auto_direction = 'x'
    [../]
  [../]
  [./pressure]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 263
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = top
    value = 260.5
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_small_out.e-s009
    timestep = 1
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
  end_time = 0.1
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100'
  l_max_its = 100
  nl_max_its = 550
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none
  scheme = 'crank-nicolson'
[]

[Adaptivity]
  max_h_level = 5
  marker = phi_marker
  initial_steps = 5
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
      coarsen = 1e-4
      indicator = phi_grad_indicator
      refine = 1e-3
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  output_final = true
  exodus = true
  interval = 1
 output_nonlinears = true
 output_initial = true
 #exodus = true
 #csv = true
 #print_linear_residuals = true
 #print_perf_log = true

[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-05
  temporal_scaling = 1
  condensation_coefficient = .01
  phase = phi
#Slope of 30 degrees
#  gravity = '4.905 -8.49571 0'
   gravity = '0 -9.81 0'

[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./temperature_ic]
    variable = T
    type = FunctionIC
    function = T_func
  [../]
[]
