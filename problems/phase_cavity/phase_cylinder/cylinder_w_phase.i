[Mesh]
  type = GeneratedMesh
  xmin = -0.01
  xmax = 0.05
  ymin = 0
  ymax =0.01
  dim = 2
  nx = 200
  ny = 500
  elem_type = QUAD9
[]

[Variables]
  [./p]
  [../]
  [./phi]
  [../]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
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
    h = 100
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
    h = 100
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
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
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
  [../]
  [./y_momentum_time]
    type = PikaTimeDerivative
    variable = v_y
    coefficient = 1.341
  [../]
[]

[BCs]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top'
    value = 0
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top left right'
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
    variable = v_x
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
  timesteps = 2
  solve_type = PJFNK
  petsc_options_iname = ' -ksp_gmres_restart'
  petsc_options_value = ' 300'
  l_max_its = 100
  nl_abs_tol = 1e-40
  nl_rel_step_tol = 1e-40
  nl_rel_tol = 1e-5
  l_tol = 1e-5
  nl_abs_step_tol = 1e-40
[]
[Adaptivity]
  max_h_level = 5
  initial_steps =5
  marker = combo_marker
  initial_marker = phi_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./v_x_grad_indicator]
      type = GradientJumpIndicator
      variable = v_x
    [../]
    [./v_y_grad_indicator]
      type = GradientJumpIndicator
      variable = v_y
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen =1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
    [./v_x_marker]
      type = ErrorToleranceMarker
      coarsen =0.5
      indicator = v_x_grad_indicator
      refine = 0.5
    [../]
    [./v_y_marker]
      type = ErrorToleranceMarker
      coarsen =0.5
      indicator = v_y_grad_indicator
      refine = 0.5
    [../]
    [./combo_marker]
      type = ComboMarker
      markers = ' v_x_marker v_y_marker phi_marker'
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

