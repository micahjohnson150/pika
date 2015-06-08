
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = 0.005
  ymax = 0.005
  elem_type = QUAD9
[]

[Variables]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./v_z]
    order = SECOND
  [../]
  [./p]
  [../]
  [./phi]
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
  [../]
  [./heat_convection]
    type = PikaConvection
    variable = T
    use_temporal_scaling = true
    property = heat_capacity
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

  [./vapor_time]
    type = PikaTimeDerivative
    variable = X
    coefficient = 1.0
    scale = 1.0
  [../]
  [./vapor_convection]
    type = PikaConvection
    variable = X
    use_temporal_scaling = true
    coefficient = 1.0
  [../]
  [./vapor_diffusion]
    type = PikaDiffusion
    variable = X
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = X
    coefficient = 0.5
    coupled_variable = phi
    use_temporal_scaling = true
  [../]


[]
[BCs]
  [./inlet]
    type =PhaseDirichletBC
    variable = v_y
    boundary = bottom
    value = 1.1923937360179E-005
    phase_variable = phi
 
  [../]
  [./x_free_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'left right'
    value = 0
  [../]
  [./pressure]
    type = DirichletBC
    variable = p
    boundary = top
    value = 0
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = top
    value = 267.5
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 265
  [../]

[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial.e-s009
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
  dt = 1
  end_time = 20000
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
  max_h_level = 4
  marker = combo_marker
  initial_steps = 3
  initial_marker = combo_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./u_grad_indicator]
      type = GradientJumpIndicator
      variable = u
    [../]
  [../]
  [./Markers]
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_grad_marker u_grad_marker'
    [../]
    [./u_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 5e-7
      indicator = u_grad_indicator
      refine = 1e-7
    [../]
    [./phi_grad_marker]
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
  interval = 1000
[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-05
  temporal_scaling = 1
  condensation_coefficient = .01
  phase = phi
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
  [./vapor_ic]
    variable = X
    type = PikaChemicalPotentialIC
    block = 0
    phase_variable = phi
    temperature = T
  [../]

[]




