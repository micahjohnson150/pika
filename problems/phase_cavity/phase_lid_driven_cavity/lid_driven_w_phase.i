[Mesh]
  type = FileMesh
  file = phi_initial_out.e
  dim = 2
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
  [./x_momentum]
    type = INSMomentum
    variable = v_x
    component = 0
    p = p
    gravity = '0 -9.81 0'
    mu = 1.599e-5
    u = v_x
    rho = 1.341
    v = v_y
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 400
  [../]
  [./y_momentum]
    type = INSMomentum
    variable = v_y
    component = 1
    p = p
    gravity = '0 -9.81 0'
    mu = 1.599e-5
    u = v_x
    rho = 1.341
    v = v_y
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 400
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    p = p
    u = v_x
    v = v_y
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
  [./phi_diffusion]
    type = PikaDiffusion
    variable = phi
    property= interface_thickness_squared
    temporal_scaling = false
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./y_momentum_time]
    type = PikaTimeDerivative
    variable = v_y
    coefficient = 1.341
  [../]
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
  [../]
[]

[BCs]
  [./lid]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 0.95391499
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
    end_point = '0.005 0.00255 0'
    sort_by = x
    start_point = '0 0.00255 0'
  [../]
  [./u_func_y]
    # outputs = exodus
    type = LineValueSampler
    variable = v_x
    num_points = 100
    start_point = '0.0026 0 0'
    end_point = '0.0026 0.005 0'
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
  petsc_options_iname = ' -ksp_gmres_restart'
  petsc_options_value = ' 300'
  line_search = none
  nl_abs_tol = 1e-40
  nl_rel_step_tol = 1e-40
  nl_rel_tol = 1e-1
  l_tol = 1e-04
  nl_abs_step_tol = 1e-40
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    growth_factor = 1.1
  [../]

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
    output_on = 'initial final'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263
  interface_thickness = 1e-04
  temporal_scaling = 1 # 1e-05
[]

[ICs]
  [./phi_IC]
    function = phi_func
    variable = phi
    type = FunctionIC
  [../]
[]

