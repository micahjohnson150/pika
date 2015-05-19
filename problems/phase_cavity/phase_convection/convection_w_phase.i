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
    phase = phi
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
    phase = phi
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
  [./x_momentum_boussinesq]
    type = PhaseBoussinesq
    variable = v_x
    component = 0
    T = T
    phase = phi
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
  [../]
  [./phase_time]
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
    timestep = 2
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
  l_max_its = 100
  end_time = 0.2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_gmres_restart'
  petsc_options_value = ' hypre boomeramg 300'
  line_search = none
  nl_abs_tol = 1e-40
  nl_rel_step_tol = 1e-40
  nl_rel_tol = 1e-1
  l_tol = 1e-04
  nl_abs_step_tol = 1e-40
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phase_LDC_out
    type = Exodus
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-04
  gravity = '0 -9.81 0'
  temporal_scaling = 1
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

