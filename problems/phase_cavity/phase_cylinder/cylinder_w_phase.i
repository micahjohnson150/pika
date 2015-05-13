[Mesh]
  type = FileMesh
  file = phi_initial.e
  dim = 2
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

[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = intial_uo
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
  [./x_momentum_time]
    type = PhaseTimeDerivative
    variable = vx
    phase = phi
  [../]
  [./y_momentum_time]
    type = PhaseTimeDerivative
    variable = vy
    phase = phi
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
    value = .047696
  [../]
[]

[UserObjects]
  [./intial_uo]
    type = SolutionUserObject
    timestep = 2
    mesh = phi_initial.e
    system_variables = phi
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
  dt = .1
  num_steps = 10
  l_max_its = 50
  nl_max_its = 100
  solve_type = PJFNK
  l_tol = 1e-02
  nl_rel_tol = 1e-3
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
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
[]

