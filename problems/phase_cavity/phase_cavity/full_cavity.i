[Mesh]
  type = FileMesh
  file = phi_initial_out.e
  dim = 2
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
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
    order = SECOND
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
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
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
  [./x_momentum_time]
    type = PhaseTimeDerivative
    variable = v_x
    phase = phi
  [../]
  [./y_momentum_time]
    type = PhaseTimeDerivative
    variable = v_y
    phase = phi
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
  [./Heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    use_temporal_scaling = true
    property = latent_heat
    coupled_variable = phi
    scale = -0.5
  [../]
  [./Vapor_time]
    type = PikaTimeDerivative
    variable = x
    coefficient = 1.0
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
  [./y_momentum_boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    T = T
    phase = phi
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
    boundary = left
    value = 1
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = right
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
    timestep = 2
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
  num_steps = 5
  dt = 0.1
  l_max_its = 50
  nl_max_its = 100
  solve_type = JFNK
  petsc_options_iname = -ksp_gmres_restart
  petsc_options_value = ' 50'
  l_tol = 1e-03
  nl_rel_tol = 1e-10
  line_search = none
  nl_abs_tol = 1e-7
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
    nonlinear_residuals = true
    linear_residuals = true
  [../]
  [./exodus]
    file_base = phase_LDC_out
    type = Exodus
    output_on = 'initial failed timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = T
  interface_thickness = 1e-05
  gravity = '0 -9.81 0'
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    function = 7717.38418*x+263.15
    variable = T
    type = FunctionIC
  [../]
  [./x_ic]
    variable = x
    type = PikaChemicalPotentialIC
    phase_variable = phi
    temperature = T
  [../]
[]

