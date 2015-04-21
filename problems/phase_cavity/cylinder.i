[Mesh]
  type = FileMesh
  file = cylinder_initial.e
  dim = 2
[]

[Variables]
  [./phi]
  [../]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./p]
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
    solution = phi_initial
  [../]
[]

[Kernels]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
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
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
    phase = phi
  [../]
  [./phase_diffusion]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
  [../]
[]

[AuxKernels]
  [./phi_aux_kernel]
    type = PikaPhaseInitializeAux
    variable = phi_aux
    phase = phi
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'top bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./inlet]
    type = DirichletBC
    variable = v_y
    boundary = left
    value = 10
  [../]

[]

[Postprocessors]
[]

[UserObjects]
  [./phi_initial]
    type = SolutionUserObject
    mesh = cylinder_initial.e
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
  type = Steady
  l_max_its = 100
  nl_max_its = 6
  solve_type = PJFNK
  petsc_options_iname = -ksp_gmres_restart
  petsc_options_value = 300
  nl_rel_tol = 1e-9
  line_search = none
[]

[Outputs]
  output_initial = true
  exodus = true
  csv = true
  print_linear_residuals = true
  print_perf_log = true
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
[]

[PikaMaterials]
  temperature = 263
  interface_thickness = 1e-5
  temporal_scaling = 1
  condensation_coefficient = .01
  phase = phi
  gravity = '0 -1 0'
[]

