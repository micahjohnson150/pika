[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 5
  ny = 5
  nz = 5
  xmin= 0.003
  ymin = 0.003
  zmin = 0.003
  xmax = 0.004
  ymax = 0.004
  zmax = 0.0032
  elem_type = TET10
[]
[Variables]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./v_z]
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
    solution = uo_initial
  [../]
[]
[Kernels]
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
    use_temporal_scaling = false
  [../]

  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_z = v_z
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
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
    coefficient = 1.341
    use_temporal_scaling = false
  [../]


  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_z = v_z
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 100

  [../]

  [./z_momentum_time]
    type = PikaTimeDerivative
    variable = v_z
    coefficient = 1.341
    use_temporal_scaling = false
  [../]


  [./z_momentum]
    type = PikaMomentum
    variable = v_z
    vel_z = v_z
    vel_y = v_y
    vel_x = v_x
    component = 2
    p = p
  [../]
  [./z_no_slip]
    type = PhaseNoSlipForcing
    variable = v_z
    phase = phi
    h = 100
  [../]

  [./mass_conservation]
    type = INSMass
    variable = p
    v = v_y
    u = v_x
    w = v_z
    p = p
  [../]
  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    use_temporal_scaling = false
  [../]

  [./phase_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
[]
[BCs]
  [./inlet]
    type = DirichletBC
    variable = v_y
    boundary = front
    value = 1.1923937360179E-005
 
  [../]
  [./x_free_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'left right'
    value = 0
  [../]
  [./y_free_slip]
    type = DirichletBC
    variable = v_z
    boundary = 'top bottom'
    value = 0
  [../]

  [./pressure]
    type = DirichletBC
    variable = p
    boundary = back
    value = 0
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial.e-s016
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
  dt = 0.001
  end_time = 0.005
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100 '
  l_max_its = 100
  nl_max_its = 150
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none

[]
[Adaptivity]
  max_h_level = 4
  initial_steps = 4
  steps = 0
  marker = phi_marker
  initial_marker = phi_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
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
    file_base = phase_LDC_h_100
    type = Exodus
    output_final = true
    output_initial = true
  [../]
  [./csv]
    file_base = snow_3d
    type = CSV
  [../]
[]
[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-05
  temporal_scaling = 1
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
[]


