[Mesh]
  type = FileMesh
  file = lid_driven_initial.e
  uniform_refine = 1
[]

[MeshModifiers]
[]

[Variables]
  active = 'v_x v_y p'
  [./T]
  [../]
  [./u]
  [../]
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

[AuxVariables]
  [./phi_aux]
  [../]
[]

[Functions]
  active = 'phi_func'
  [./T_func]
    type = ParsedFunction
    value = -543*x+267.515
  [../]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = initial_uo
  [../]
[]

[Kernels]
  active = 'v_x_momentum mass_cons v_y_momentum no_slip_x no_slip_y'
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
    scale = 1.0
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
    variable = u
    coefficient = 1.0
    scale = 1.0
  [../]
  [./vapor_diffusion]
    type = PikaDiffusion
    variable = u
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = u
    coefficient = 0.5
    coupled_variable = phi
    use_temporal_scaling = true
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    scale = 1.0
  [../]
  [./phi_transition]
    type = PhaseTransition
    variable = phi
    mob_name = mobility
    chemical_potential = u
    coefficient = 1.0
    lambda = phase_field_coupling_constant
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phi_square_gradient]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
  [../]
  [./mass_cons]
    type = PhaseMass
    variable = p
    p = p
    u = v_x
    v = v_y
    phase = phi_aux
  [../]
  [./Boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    T = T
    phase = phi
  [../]
  [./v_y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
    phase = phi_aux
  [../]
  [./v_x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
    phase = phi_aux
  [../]
  [./v_x_time]
    type = PhaseTimeDerivative
    variable = v_x
    phase = phi
  [../]
  [./v_y_time]
    type = PhaseTimeDerivative
    variable = v_y
    phase = phi
  [../]
  [./vapor_convection]
    type = PhaseConvection
    variable = u
    u = v_x
    v = v_y
    phase = phi
  [../]
  [./heat_convection]
    type = PhaseConvection
    variable = T
    u = v_x
    v = v_y
    phase = phi
  [../]
  [./no_slip_x]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi_aux
    h = .005
  [../]
  [./no_slip_y]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi_aux
    h = .005
  [../]
[]

[AuxKernels]
  [./phi_solution]
    type = SolutionAux
    variable = phi_aux
    from_variable = phi
    solution = initial_uo
    execute_on = timestep_begin
  [../]
[]

[BCs]
  active = 'lid no_slip y_no_slip pressure_pin'
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = left
    value = 267.515
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = right
    value = 264.8
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./lid]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 1
  [../]
  [./no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'bottom left right'
    value = 0
  [../]
  [./phi_neuman]
    type = NeumannBC
    variable = phi
    boundary = 'top bottom left right'
  [../]
[]

[UserObjects]
  [./initial_uo]
    type = SolutionUserObject
    mesh = lid_driven_initial.e
    system_variables = phi
    transformation_order = 'translation scale rotation0'
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Steady
  l_max_its = 150
  nl_max_its = 15
  solve_type = PJFNK
  petsc_options_iname = -ksp_gmres_restart
  petsc_options_value = 300
  nl_rel_tol = 1e-15
  line_search = none
  l_tol = 1e-9
  nl_abs_step_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2
    linear_iteration_ratio = 1
    optimal_iterations = 3
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
  active = ''
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
    variable = u
    type = PikaChemicalPotentialIC
    block = 0
    phase_variable = phi
    temperature = T
  [../]
[]

[PikaMaterials]
  temperature = 263
  interface_thickness = 1e-5
  temporal_scaling = 1 # 1e-6
  condensation_coefficient = .01
  phase = phi_aux
  gravity = '0 -1 0'
[]

