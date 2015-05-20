[Mesh]
  type = FileMesh
  file = phi_initial.e
  dim = 2
  uniform_refine = 0
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
    h = 100
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
    h = 100
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = vy
    vel_x = vx
    phase = phi
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
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    use_temporal_scaling = false
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
  [./y_no_slip]
    type = DirichletBC
    variable = vy
    boundary = 'top'
    value = 0
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom left right'
    value = -1
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
    timestep = 1
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
  dt = 0.001
  l_max_its = 100
  end_time = 1
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
    file_base = phase_cyl_out
    type = Exodus
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263
  interface_thickness = 1e-04
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

