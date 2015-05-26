[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
  ymax = .0051
  elem_type = QUAD9
  uniform_refine = 3
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
  [./x_momentum]
    type = PikaMomentum
    variable = v_x
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
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
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
  [./y_momentum_boussinesq]
    type = Boussinesq
    phase = phi
    T = T
    variable = v_y
    component = 1
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    v = v_y
    u = v_x
    p = p
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
    mesh = phi_initial_out.e-s004
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
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = ' -ksp_gmres_restart '
  petsc_options_value = '100 '
  nl_max_its = 50
  l_max_its = 100
  nl_rel_tol = 1e-07
  l_tol = 1e-07
  line_search = none
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phase_conv_out
    type = Exodus
    output_final = true
    output_initial = true
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-05
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

