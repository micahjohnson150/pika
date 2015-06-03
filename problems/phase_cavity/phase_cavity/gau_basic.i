[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmax = 0.005
  ymax = 0.005
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
    tolerance = 1e-4
  [../]
[]

[Variables]
  [./phi]
  [../]
  [./T]
  [../]
  [./X]
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

[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = uo_initial
  [../]
[]

[Kernels]
#Phase Kernels
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
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
  [./phi_transition]
    type = PhaseForcing
    variable = phi
    chemical_potential = X
    property= phase_field_coupling_constant
    use_temporal_scaling = false
  [../]
#Temperature Kernels
  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
  [../]
  [./heat_convection]
    type = PikaConvection
    vel_x = v_x
    vel_y = v_y
    variable = T
    property = heat_capacity
    use_temporal_scaling = true
  [../]
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    use_temporal_scaling = true
    property = latent_heat
    coupled_variable = phi
    scale = -0.5
  [../]
#Chemical Potential Kernels
  [./vapor_time]
    type = PikaTimeDerivative
    variable = X
    coefficient =1.0
  [../]
 [./vapor_convection]
   type = PikaConvection
   vel_x = v_x
   vel_y = v_y
   variable = X
   coefficient = 1.0
   use_temporal_scaling = true
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
    use_temporal_scaling = true
    coupled_variable = phi
    coefficient = 1
    scale = 0.5
  [../]
#Momentum Kernels
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
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
    variable = v_y
    component = 1
    T = T
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    u = v_y
    v = v_x
    p = p
  [../]

[]

[BCs]
  [./pressure_pin]
    type = DirichletBC
    boundary = 99
    variable = p
    value = 0
  [../]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'left '
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'left '
    value = 0
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = right
    value = 264.65
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = left
    value = 264.15
  [../]
  [./phi_vapor]
    type = DirichletBC
    variable = phi
    boundary = left
    value = -1
  [../]
  [./phi_ice]
    type = DirichletBC
    variable = phi
    boundary = right
    value = 1
  [../]

[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = gau_initial_out.e-s004
    timestep = 1
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = false
  [../]
[]

[Executioner]
  type = Transient
  dt = 1
  dtmax = 100
  dtmin = 0.001
  end_time = 10000
  solve_type = PJFNK
  petsc_options_iname = ' -ksp_gmres_restart '
  petsc_options_value = ' 100 '
  l_max_its = 100
  nl_max_its = 1000
  nl_rel_tol = 1e-05
  l_tol = 1e-05
  line_search = none
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 1
    percent_change = 0.1
  [../]
[]

[Adaptivity]
  max_h_level = 3
  marker = combo_marker
  initial_steps = 3
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./X_grad_indicator]
      type = GradientJumpIndicator
      variable = X
    [../]
  [../]
  [./Markers]
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_grad_marker X_grad_marker '
    [../]
    [./X_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = X_grad_indicator
      refine = 1e-5
    [../]
    [./phi_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = gau_cavity_out
    type = Exodus
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = T
  interface_thickness = 1e-05
  gravity = '0 -9.81 0'
  temporal_scaling = 1e-4
  condensation_coefficient = 0.01
[]

[ICs]
active = 'phase_ic T_ic'
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    function = 100*x+264.15
    variable = T
    type = FunctionIC
  [../]
  [./X_ic]
    variable = X
    type = PikaChemicalPotentialIC
    phase_variable = phi
    temperature = T
  [../]
[]

