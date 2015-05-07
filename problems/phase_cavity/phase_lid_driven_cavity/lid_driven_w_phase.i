[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
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
  [./p]
  [../]
  [./phi]
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
  active = 'phi_diffusion y_momentum_time phi_double_well y_no_slip x_no_slip y_momentum mass_conservation x_momentum_time x_momentum'
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
  active = 'lid y_no_slip vapor_phase_wall phase_wall_no_slip'
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
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom left right'
    value = -1
  [../]
  [./phase_wall_no_slip_y]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./lid]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = .95391499
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = bottom
    value = 0
  [../]
  [./phase_wall_no_slip]
    type = DirichletBC
    variable = phi
    boundary = 'bottom left right'
    value = 1
  [../]
[]

[VectorPostprocessors]
  [./v_func_x]
    type = LineValueSampler
    variable = v_y
    num_points = 50
    end_point = '0.0025 0.005 0'
    sort_by = x
    execute_on = custom
    start_point = '0 0.0025 0'
  [../]
  [./u_func_y]
    type = LineValueSampler
    variable = v_x
    num_points = 100
    start_point = '0.0025 0 0'
    end_point = '0.0025 0.005 0'
    sort_by = y
  [../]
[]

[UserObjects]
  [./intial_uo]
    type = SolutionUserObject
    execute_on = initial
    mesh = ../phase_convection/phi_initial_out.e
    timestep = 2
  [../]
[]

[Preconditioning]
  active = 'SMP_PJFNK'
  [./SMP_PJFNK]
    type = SMP
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
  num_steps = 1000
  dt = 0.01
  l_max_its = 50
  solve_type = JFNK
  petsc_options_iname = -pc_type
  petsc_options_value = bjacobi
  l_tol = 1e-04
  nl_rel_tol = 1e-10
  nl_abs_tol = 2e-6
  end_time = 0.5
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
  temperature = 263
  interface_thickness = 1e-05
  temporal_scaling = 1 # 1e-05
[]

[ICs]
  active = 'phi_const'
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

