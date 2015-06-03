[Mesh]
  type = GeneratedMesh
  dim = 2
  nx =50
  ny = 50
  xmin = 0
  ymin = 0
  xmax = .005
  ymax = .0050
  elem_type = QUAD9
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
#  [./X]
#    order = SECOND
#  [../]
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

  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
    use_temporal_scaling = false
  [../]

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

  [./y_momentum_time]
    type = PikaTimeDerivative
    variable = v_y
    coefficient = 1.341
    use_temporal_scaling = false
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
  [./mass_conservation]
    type = INSMass
    variable = p
    v = v_y
    u = v_x
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
#  [./vapor_convection] 
#    type = PikaPhaseConvection 
#    coefficient = 1.0 
#    use_temporal_scaling = true 
#    variable = X 
#    vel_x = v_x 
#    vel_y = v_y 
#    phase = phi
#  [../] 
#  [./vapor_diffusion] 
#    type = PikaDiffusion 
#    property = diffusion_coefficient 
#    use_temporal_scaling = true 
#    variable = X 
#  [../]
  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
    use_temporal_scaling = false
  [../]

  [./heat_convection]
    type = PikaPhaseConvection
    property = heat_capacity
    use_temporal_scaling = false
    variable = T
    vel_x = v_x
    vel_y = v_y
    phase = phi
  [../]

  [./heat_diffusion]
    type = PikaDiffusion
    property = conductivity
    use_temporal_scaling = true
    variable = T
  [../]


[]
[BCs]
  [./inlet]
    type = PhaseDirichletBC
    variable = v_x
    boundary = right
    phase_variable = phi
    value = -1.1923937360179E-005
  [../]
  [./y_no_slip_top]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom'
    value = 0.0
  [../]
 [./pressure_out]
   type = DirichletBC
   variable = p
   boundary = left
   value = 0
 [../]
# [./X_bc]
#   type = PikaChemicalPotentialBC
#   variable = X
#   boundary = 'bottom top'
#   phase_variable = phi
#   temperature = T
# [../]
 [./T_hot]
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 263.65
 [../]
# [./T_cold]
#    type = DirichletBC
#    variable = T
#    boundary = 'left'
#    value = 263.15
# [../]



[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_out.e-s005
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
  nl_rel_tol = 1e-06
  l_tol = 1e-08
  line_search = none
  scheme = 'crank-nicolson'

[]
[Adaptivity]
  max_h_level = 5
  initial_steps = 5
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
    file_base = phase_cylinder_h_100
    type = CSV
  [../]
[]


[PikaMaterials]
  phase = phi
  temperature = T
  interface_thickness = 1e-5
  temporal_scaling = 1e-4
[]

[ICs]
active = 'phase_ic T_ic'
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    variable = T
    type = FunctionIC
    function = 100*x+263.15
  [../]
  [./T_const_ic]
    variable = T
    type = ConstantIC
    value = 263.15
  [../]

  [./X_ic]
    variable = X
    type = PikaChemicalPotentialIC
    phase_variable = phi
    temperature  = T
  [../]

[]
