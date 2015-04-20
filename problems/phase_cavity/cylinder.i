[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 21
  ny = 7
  xmax = 0.05
  ymax = 0.02
  uniform_refine = 1
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

[AuxVariables]
  [./phi_aux]
  [../]
[]

[Functions]
  [./phase_func]
    type = SolutionFunction
    from_variable = phi
    solution = initial_uo
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
  [./inlet]
    type = DirichletBC
    variable = v_x
    boundary = left
    value = 1
  [../]
  [./vapor]
    type = DirichletBC
    variable = phi
    boundary = 'left right top bottom'
    value = -1
  [../]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'top bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'left top right bottom'
    value = 0
  [../]
[]

[Preconditioning]
  active = 'SMP_PJFNK'
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
  [./PBD]
    type = PBP
    solve_order = 'phi p v_x v_y'
    preconditioner = 'LU LU'
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 100
  solve_type = PJFNK
[]

[Adaptivity]
  cycles_per_step = 0
  initial_steps = 5
  initial_marker = phi_marker
  max_h_level = 8
  [./Indicators]
    [./phi_jump]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorFractionMarker
      coarsen = 0.2
      indicator = phi_jump
      refine = 0.8
    [../]
  [../]
[]

[Outputs]
  [./console]
    type = Console
    linear_residuals = true
    nonlinear_residuals = true
  [../]
  [./exodus]
    type = Exodus
    file_base = cylinder
    output_on = 'TIMESTEP_END initial'
  [../]
[]

[ICs]
  [./phase_ic]
    type = FunctionIC
    function = phase_func
    variable = phi
  [../]
[]

[PikaMaterials]
  phase = phi
  temporal_scaling = 1
  temperature = 263
[]

[UserObjects]
  [./initial_uo]
    type = SolutionUserObject
    mesh = cylinder_initial.e-s001
  [../]
[]
