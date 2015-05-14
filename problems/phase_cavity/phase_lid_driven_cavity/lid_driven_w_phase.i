[Mesh]
  type = FileMesh
  file = phi_initial_out.e
  dim = 2
  uniform_refine =1
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0'
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
[]

[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = initial_uo
  [../]
[]

[Kernels]
  # active = ' x_no_slip y_no_slip phi_diffusion phi_double_well y_momentum mass_conservation x_momentum'
  # active = 'phi_diffusion phi_double_well y_momentum mass_conservation x_momentum'
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
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'left right bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./lid]
    type = PhaseDirichletBC
    variable = v_x
    boundary = top
    value = 0.95391499
    phase_variable = phi
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
  [./phi_neuman_top]
    type = NeumannBC
    variable = phi
    boundary = top
  [../]
  [./solid_phase]
    type = DirichletBC
    variable = phi
    boundary = 'left right bottom'
    value = 1
  [../]
[]

[VectorPostprocessors]
  [./v_func_x]
    # outputs = exodus
    type = LineValueSampler
    variable = v_y
    num_points = 100
    end_point = '0.005 0.0025 0'
    sort_by = x
    execute_on = timestep_end
    start_point = '0 0.0025 0'
  [../]
  [./u_func_y]
    # outputs = exodus
    type = LineValueSampler
    variable = v_x
    num_points = 100
    start_point = '0.0025 0 0'
    end_point = '0.0025 0.005 0'
    sort_by = y
  [../]
[]

[UserObjects]
  [./initial_uo]
    type = SolutionUserObject
    timestep = 2
    mesh = phi_initial_out.e
    system_variables = phi
  [../]
[]

[Preconditioning]
  active = 'SMP_PJFNK'
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
  [./PBP_JFNK]
    type = PBP
    solve_order = 'phi v_x v_y p '
    preconditioner = AMG
    off_diag_row = p
    off_diag_column = 'phi '
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.1
  end_time = 2
  solve_type = PJFNK
  petsc_options_iname = ' -ksp_gmres_restart'
  petsc_options_value = ' 300'
  line_search = none
[]

[Outputs]
  csv = true
  output_final = true
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
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263
  interface_thickness = 1e-05
  temporal_scaling = 1 # 1e-05
[]

[ICs]
  [./phi_IC]
    function = phi_func
    variable = phi
    type = FunctionIC
  [../]
[]
