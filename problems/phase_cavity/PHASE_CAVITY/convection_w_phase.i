[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 8
  xmin = -1e-5
  xmax = .02001
  ymin = -1e-5
  ymax = 0.02001
  uniform_refine = 5
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pressure]
    type = AddExtraNodeset
    new_boundary = 99
    tolerance = 1e-04
    coord = '1e-5 1e-5'
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
    order = SECOND
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
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_convection]
    type = PikaConvection
    property = heat_capacity
    phase = phi
    vel_x = v_x
    vel_y = v_y
    variable = T
  [../]
  [./v_x_boussinesq]
    type = PhaseBoussinesq
    component = 0
    T = T
    phase = phi
    variable = v_x
  [../]
  [./v_y_boussinesq]
    type = PhaseBoussinesq
    component = 1
    T = T
    phase = phi
    variable = v_y
  [../]
[]

[BCs]
  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom left right'
    value = 1
  [../]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = left
    value = 1
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = right
    value = 0
  [../]
  [./pressure]
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
  l_max_its = 500
  nl_max_its = 40
  solve_type = PJFNK
  l_tol = 1e-06
  nl_rel_tol = 1e-15
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
  temperature = T
  interface_thickness = 1e-05
  temporal_scaling = 1 # 1e-05
  gravity = '0 -1 0'
[]

[ICs]
  [./phase_ic]
    y2 = 0.02
    y1 = 0
    inside = -1
    x2 = 0.02
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
[]

