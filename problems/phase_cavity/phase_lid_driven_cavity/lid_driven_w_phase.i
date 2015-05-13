[Mesh]
  type = FileMesh
  file = phi_initial_out.e-s002
  dim = 2
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

[AuxVariables]
  [./phi_aux]
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
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
    phase = phi_aux
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
    phase = phi_aux
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
    phase = phi_aux
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
    phase = phi_aux
  [../]
  [./y_momentum_time]
    type = PhaseTimeDerivative
    variable = v_y
    phase = phi_aux
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
[]

[AuxKernels]
  [./phi_intializer]
    type = PikaPhaseInitializeAux
    variable = phi_aux
    phase = phi
  [../]
[]

[BCs]
  active = 'lid y_no_slip solid_phase_wall phi_neuman_top'
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
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'bottom left right'
    value = 1
  [../]
  [./phase_wall_no_slip_y]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./lid]
    type = PhaseDirichletBC
    variable = v_x
    boundary = top
    value = .95391499
    phase_variable = phi
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = bottom
    value = 0
  [../]
  [./phi_neuman_top]
    type = NeumannBC
    variable = phi
    boundary = top
  [../]
[]

[VectorPostprocessors]
  [./v_func_x]
    type = LineValueSampler
    variable = v_y
    num_points = 100
    end_point = '0.00501 0.002505 0'
    sort_by = x
    execute_on = timestep_end
    start_point = '-1e-5 0.002505 0'
    outputs = exodus
  [../]
  [./u_func_y]
    type = LineValueSampler
    variable = v_x
    num_points = 100
    start_point = '0.00251 -1e-5 0'
    end_point = '0.00251 0.005 0'
    sort_by = y
    outputs = exodus
  [../]
[]

[UserObjects]
  [./intial_uo]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_out.e-s002
    timestep = 1
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
  num_steps = 5
  dt = 1e-7
  l_max_its = 50
  solve_type = PJFNK
  petsc_options_iname = -ksp_gmres_restart
  petsc_options_value = 300
  l_tol = 1e-02
  nl_rel_tol = 1e-4
  nl_abs_tol = 2e-20
  end_time = 500
  nl_rel_step_tol = 1e-4
  line_search = none
[]

[Outputs]
  csv = true
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
  phase = phi_aux
  temperature = 263
  interface_thickness = 1e-05
  temporal_scaling = 1e-5 # 1e-05
[]

[ICs]
  active = 'phi_ic_func'
  [./phase_ic]
    y2 = 0.02001
    y1 = 0
    inside = -1
    x2 = 0.02
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
  [./phi_const]
    variable = phi
    type = ConstantIC
    value = -1
  [../]
  [./phi_ic_func]
    function = phi_func
    variable = phi
    type = FunctionIC
  [../]
[]

