
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 70
  ny = 70
  xmax = 0.005
  ymax = 0.005
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    coord = '0 0'
    new_boundary = 99
  [../]
[]

[Variables]
  [./phi]
  [../] 
  [./T]
  [../] 
  [./X]
  [../] 

[]

[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = uo_initial
  [../]
  [./T_func]
    type = ParsedFunction
    value = 500*x+260.5
  [../]
[]

[Kernels]

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
  [./phase_transition]
    type = PhaseForcing
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
    chemical_potential = X
  [../]

  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
    scale = 1.0
    use_temporal_scaling = false
  [../]
#  [./heat_convection]
#    type = PikaConvection
#    variable = T
#    use_temporal_scaling = true
#    property = heat_capacity
#    vel_x = v_x
#    vel_y = v_y
#  [../]

  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    property = latent_heat
    scale = -0.5
    use_temporal_scaling = true
    coupled_variable = phi
  [../]

  [./vapor_time]
    type = PikaTimeDerivative
    variable = X
    coefficient = 1.0
    scale = 1.0
    use_temporal_scaling = false
  [../]
  [./vapor_diffusion]
    type = PikaDiffusion
    variable = X
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = X
    coefficient = 0.5
    coupled_variable = phi
    use_temporal_scaling = true
  [../]

[]
[BCs]
  [./Periodic]
    [./periodic_phi]
      variable = phi
      auto_direction = ' y'
    [../]
    [./periodic_X]
      variable = X
      auto_direction = ' y'
    [../]
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = right
    value = 263
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = left
    value = 260.5
  [../]
  [./X_BC]
    type = PikaChemicalPotentialBC
    variable = X
    boundary = 'left right'
    phase_variable = phi
    temperature = T
  [../]

[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_small_out.e-s009
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
  dt = 1
  end_time = 86400
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '300'
  l_max_its = 100
  nl_max_its = 550
  nl_rel_tol = 1e-06
  l_tol = 1e-06
  line_search = none
  scheme = 'crank-nicolson'

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.1
    percent_change = 0.1
  [../]
[]

[Adaptivity]
  max_h_level = 4
  marker = phi_marker
  initial_steps = 4
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
      coarsen = 1e-4
      indicator = phi_grad_indicator
      refine = 1e-3
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  output_final = true
  exodus = true
  interval = 1000
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
#
#  output_nonlinears = true
#  output_initial = true
 # exodus = true
 # csv = true
 # print_linear_residuals = true
 # print_perf_log = true

[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-05
  temporal_scaling = 1e-4
  condensation_coefficient = .01
  phase = phi
#Slope of 30 degrees
  gravity = '4.905 -8.49571 0'
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./temperature_ic]
    variable = T
    type = FunctionIC
    function = T_func
  [../]
  [./vapor_ic]
    variable = X
    type = PikaChemicalPotentialIC
    block = 0
    phase_variable = phi
    temperature = T
  [../]

[]
