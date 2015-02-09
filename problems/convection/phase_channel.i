[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 16
  xmax = 0.01
  ymax = 0.01
  uniform_refine = 2
  elem_type = QUAD9
[]

[Variables]
  [./T]
    order = SECOND
  [../]
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
  active = 'X-momentum y_momentum temp_space COM phi_diffusion double_well'
  [./X-momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    gravity = '0 -1 0'
    mu = 1
    p = p
    rho = 1
    phase = phi
  [../]
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    gravity = '0 -1 0'
    mu = 1
    p = p
    rho = 1
    phase = phi
  [../]
  [./temp_space]
    type = INSTemperature
    variable = T
    k = 1
    u = v_x
    rho = 1
    v = v_y
    cp = 1
  [../]
  [./COM]
    type = INSMass
    variable = p
    p = p
    u = v_x
    v = v_y
  [../]
  [./phi_diffusion]
    type = ACInterface
    variable = phi
    mob_name = mob
    kappa_name = w
  [../]
  [./double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mob
  [../]
  [./boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    gravity = '0 -1 0'
    beta = 1
    T = T
    rho = 1
    phase = phi
    T_ref = 0
  [../]
[]

[AuxKernels]
[]

[BCs]
  [./phi_walls]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom'
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
  [./inlet]
    type = DirichletBC
    variable = v_x
    boundary = left
    value = 1
  [../]
  [./outlet_pressure]
    type = DirichletBC
    variable = p
    boundary = right
    value = 0
  [../]
[]

[Materials]
  [./phase_field_props]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'w mob'
    prop_values = '1e-10 1'
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 200
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  [./console]
    type = Console
    output_linear = true
  [../]
  [./exodus]
    file_base = phase_channel
    type = Exodus
  [../]
[]

[ICs]
  [./phi_ic]
    variable = phi
    type = ConstantIC
    value = -1
  [../]
[]

[PikaMaterials]
  phase = phi
  temporal_scaling = 1e-5 # 1e-05
  temperature = T
[]

