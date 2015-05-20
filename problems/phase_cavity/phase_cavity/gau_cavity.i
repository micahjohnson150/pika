[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmax = 0.05
  ymax = 0.05
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
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
  [./x]
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
    type = PhaseTimeDerivative
    variable = v_x
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
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 100
  [../]
  [./y_momentum_time]
    type = PhaseTimeDerivative
    variable = v_y
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
    h = 100
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
  [../]
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
    type = PhaseTransition
    variable = phi
    mob_name = mobility
    chemical_potential = x
    coefficient = 1.0
    lambda = phase_field_coupling_constant
  [../]

  [./Heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
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
  [./Heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    use_temporal_scaling = true
    property = latent_heat
    coupled_variable = phi
    scale = -0.5
  [../]
  [./Vapor_time]
    type = PikaTimeDerivative
    variable = x
    coefficient = 1.0
  [../]
  [./Vapor_convection]
    type = PikaConvection
    variable = x
    vel_x = v_x
    use_temporal_scaling = true
    phase = phi
    coefficient = 1.0
    vel_y = v_y
  [../]
  [./Vapor_diffusion]
    type = PikaDiffusion
    variable = x
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./Vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = x
    use_temporal_scaling = true
    coupled_variable = phi
    coefficient = 1
    scale = 0.5
  [../]
  [./y_momentum_boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    T = T
    phase = phi
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = 'top left right bottom'
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = right
    value = 1
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = left
    value = -1
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
    boundary = left
    value =263.361547752
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = right
    value = 263.15
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = gau_initial_out.e
    timestep = 2
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
  l_max_its = 100
  end_time = 1
  solve_type = PJFNK
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_hypre_type  -ksp_gmres_restart'
  petsc_options_value = ' hypre boomeramg 300'
  line_search = none
  nl_abs_tol = 1e-40
  nl_rel_step_tol = 1e-40
  nl_rel_tol = 1e-1
  l_tol = 1e-04
  nl_abs_step_tol = 1e-40
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 1.1
  [../]
[]
[Adaptivity]
  max_h_level = 5
  initial_steps = 4
  marker = combo_marker
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
    [./vapor_marker]
      type = ValueRangeMarker
      lower_bound = -1
      upper_bound = 0
      variable = phi
    [../]
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_marker vapor_marker'
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
    file_base = gau_cavity_out
    type = Exodus
    output_on = 'initial timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = T
  interface_thickness = 1e-04
  gravity = '0 -9.81 0'
  temporal_scaling = 1e-4
  #ice 
  conductivity_ice = 0.02
  density_ice = 1.341
  heat_capacity_ice = 1400
  #vapor 
  dry_air_viscosity = 3.98e-7
  thermal_expansion = 0.0036
  #misc
  latent_heat = 6.57e2

[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    function = -4.2309550392*x+263.361547752
    variable = T
    type = FunctionIC
  [../]
  [./x_ic]
    variable = x
    type = PikaChemicalPotentialIC
    phase_variable = phi
    temperature = T
  [../]
[]

