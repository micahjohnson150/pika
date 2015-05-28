[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
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
[]
[BCs]
  [./lid]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 0.9539149888
  [../]
  [./y_no_slip_top]
    type = DirichletBC
    variable = v_y
    boundary = top
    value = 0.0
  [../]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'left right bottom'
    value = 1
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_out.e-s005
    timestep = 1
  [../]
[]

[VectorPostprocessors]
  [./horizontal]
    type = LineValueSampler
    variable = v_y
    num_points = 100
    end_point = '0.0051 0.0025 0'
    sort_by = x
    execute_on = timestep_end
    start_point = '-1e-4 0.0025 0'
  [../]
  [./vertical]
    type = LineValueSampler
    variable = v_x
    num_points = 100
    start_point = '0.0025 -1e-4 0'
    end_point = '0.0025 0.005 0'
    sort_by = y
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
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100 '
  l_max_its = 100
  nl_max_its = 150
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none

[]
[Adaptivity]
  max_h_level = 3
  initial_steps = 3
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
    file_base = phase_LDC_h_100
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


