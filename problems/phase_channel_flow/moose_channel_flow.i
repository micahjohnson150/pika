[Mesh]
  type = GeneratedMesh
  dim = 2
  ymax = .005
  nx = 16
  ny = 4
  xmax = .02
  ymin = 3e-5
  uniform_refine = 3
  elem_type = QUAD9
[]

[Variables]
  # x-velocity
  # y-velocity
  # Temperature
  # Pressure
  [./u]
    order = SECOND
    family = LAGRANGE
    [./InitialCondition]
      type = ConstantIC
      value = 0.0
    [../]
  [../]
  [./v]
    order = SECOND
    family = LAGRANGE
    [./InitialCondition]
      type = ConstantIC
      value = 0.0
    [../]
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = ConstantIC
      value = 0 # This number is arbitrary for NS...
    [../]
  [../]
[]

[Kernels]
  active = 'x_momentum_space mass y_momentum_space'
  [./mass]
    type = INSMass
    variable = p
    u = u
    v = v
    p = p
  [../]
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = u
  [../]
  [./x_momentum_space]
    type = INSMomentum
    variable = u
    u = u
    v = v
    p = p
    rho = 1.341
    mu = 1.599e-05
    component = 0
    gravity = '0 -1 0 '
  [../]
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = v
  [../]
  [./y_momentum_space]
    type = INSMomentum
    variable = v
    u = u
    v = v
    p = p
    rho = 1.341
    mu = 1.599e-05
    component = 1
    gravity = '0 -1 0 '
  [../]
[]

[BCs]
  active = 'x_no_slip inlet y_no_slip'
  [./x_no_slip]
    type = DirichletBC
    variable = u
    boundary = 'bottom top'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = v
    boundary = 'top bottom left right'
    value = 0.0
  [../]
  [./inlet]
    # boundary = '2'
    type = DirichletBC
    variable = u
    boundary = left
    value = 1
  [../]
  [./pressure_out]
    type = DirichletBC
    variable = p
    boundary = right
    value = 0
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    # Preconditioned JFNK (default)
    type = SMP
    full = true
    solve_type = PJFNK
  [../]
[]

[Executioner]
  # Basic GMRES/linesearch options only
  # MOOSE does not correctly read these options!! Always run with actual command line arguments if
  # you want to guarantee you are getting pilut!  Also, even though there are pilut defaults,
  # i'm not sure that petsc actually passes them through, so always specify them!.
  # 
  # PILUT options:
  # -pc_type hypre -pc_hypre_type pilut -pc_hypre_pilut_factorrowsize 20 -pc_hypre_pilut_tol 1.e-4
  # 
  # PETSc ILU options (parallel):
  # -sub_pc_type ilu -sub_pc_factor_levels 2
  # 
  # ASM options (to be used in conjunction with ILU sub_pc)
  # -pc_type asm -pc_asm_overlap 2
  type = Steady
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '300                '
  line_search = none
  nl_rel_tol = 1e-9
  l_tol = 1e-6
  l_max_its = 200
[]

[Outputs]
  file_base = flat_plate_out
  output_initial = true
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
[]

