[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny =16 
  xmin = -1e-5
  xmax = .02001
  ymin = -1e-5
  ymax = 0.02
  uniform_refine = 4
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
  [../]
  [./mass_conservation]
    type = PhaseMass
    variable = p
    vel_y = v_y
    vel_x = v_x
    phase = phi
  [../]
  [./phi_diffusion]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
[]

[BCs]
  active = 'lid y_no_slip vapor_phase_wall solid_phase_wall'
  [./x_no_slip]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v_y
    boundary = top
    value = 0
  [../]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'bottom left right'
    value = 1
  [../]
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = top
    value = -1
  [../]
  [./phase_wall_no_slip_x]
    type = DirichletBC
    variable = v_x
    boundary = bottom
    value = 0
  [../]
  [./phase_wall_no_slip_y]
    type = DirichletBC
    variable = v_y
    boundary = bottom
    value = 0
  [../]
  [./lid]
    type = DirichletBC
    variable = v_x
    boundary = top
    value = 1491.58
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
  [../]
[]

[VectorPostprocessors]
  [./vertical]
    type = LineValueSampler
    variable = v_x
    num_points = 200
    start_point = '0.01 -1e-5 0'
    end_point = '0.01 0.02 0'
    sort_by = y
  [../]
  [./horizontal]
    type = LineValueSampler
    variable = v_y
    num_points = 200
    start_point = '-1e-5 0.01 0'
    end_point = '0.02001 0.01 0'
    sort_by = x
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
  l_max_its = 50
  nl_max_its = 40
  solve_type = PJFNK
  l_tol = 1e-07
  nl_rel_tol = 1e-15
  petsc_options_iname = '-ksp_gmres_restart'
  petsc_options_value = '20'
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phase_LDC_out
    type = Exodus
    output_on = 'initial failed timestep_end'
  [../]
[]

[PikaMaterials]
  phase = phi
  temperature = 263
  interface_thickness = 1e-05
  temporal_scaling = 1 # 1e-05
[]

[ICs]
  active = 'phase_ic'
  [./phase_ic]
    y2 = 0.02001
    y1 = 0
    inside = -1
    x2 = 0.02
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
[]

