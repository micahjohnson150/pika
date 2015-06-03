[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = 0.005
  ymax = 0.005
  elem_type = QUAD9
  unform_refine = 3
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
    tolerance = 1e-4
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
  [./x]
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

  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
    phase = phi
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 100
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
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 100
  [../]
  [./y_momentum_boussinesq]
    type = Boussinesq
    variable = v_y
    component = 1
    T = T
    phase = phi
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    u = v_y
    v = v_x
    p = p
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
  [./phi_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phi_transition]
    type = PhaseTransition
    variable = phi
    mob_name = mobility
    chemical_potential = x
    coefficient = 1.0
    lambda = phase_field_coupling_constant
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
  [./Heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    use_temporal_scaling = true
    property = latent_heat
    coupled_variable = phi
    scale = -0.5
  [../]
  [./Vapor_convection]
    type = PikaConvection
    variable = x
    vel_x = v_x
    use_temporal_scaling = true
    phase = phi
    coefficient = 1.0
    vel_y = v_y
  [../]
  [./Vapor_diffusion]
    type = PikaDiffusion
    variable = x
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./Vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = x
    use_temporal_scaling = true
    coupled_variable = phi
    coefficient = 1
    scale = 0.5
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'top left right bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = right
    value = 1
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = left
    value = -1
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
    boundary = left
    value = 474.6977519584
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = right
    value = 263.15
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = gau_initial_out.e-s003
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
  time_steps = 1
  solve_type = PJFNK
  petsc_options_iname = ' -ksp_gmres_restart '
  petsc_options_value = ' 100 '
  l_max_its = 100
  nl_max_its = 100
  nl_rel_tol = 1e-05
  l_tol = 1e-05
  line_search = none
[]

[Adaptivity]
  max_h_level = 4
  marker = combo_marker
  initial_steps = 4
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./x_grad_indicator]
      type = GradientJumpIndicator
      variable = x
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
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_grad_marker x_grad_marker v_x_marker v_y_marker'
    [../]
    [./x_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-10
      indicator = x_grad_indicator
      refine = 1e-8
    [../]
    [./phi_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
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
  [../]
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = gau_cavity_out
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
  #vapor 
  dry_air_viscosity = 3.98e-7
  thermal_expansion = 0.0036
  #misc
  latent_heat = 6.57e2
[]

[ICs]
active = 'phase_ic x_ic T_const'
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    function = -42309.5503916823*x+474.6977519584
    variable = T
    type = FunctionIC
  [../]
  [./T_const]
    variable = T
    type = ConstantIC
    value = 263.15
  [../]

  [./x_ic]
    variable = x
    type = PikaChemicalPotentialIC
    phase_variable = phi
    temperature = T
  [../]
[]

