[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
  ymax = .005
  uniform_refine = 3
  elem_type = QUAD9
[]

[Variables]
  [./phi]
  [../]
[]

[AuxVariables]
  [./u]
  [../]
  [./phi_aux]
  [../]
[]

[Kernels]
  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
  [./phase_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
[]

[AuxKernels]
  [./phi_aux]
    type = PikaPhaseInitializeAux
    variable = phi_aux
    phase = phi
  [../]
[]

[BCs]
  active = 'solid phi_neuman_top'
  [./solid]
    type = DirichletBC
    variable = phi
    boundary = 'left bottom right'
    value = 1
  [../]
  [./vapor]
    type = DirichletBC
    variable = phi
    boundary = top
    value = -1
  [../]
  [./phi_neuman_top]
    type = NeumannBC
    variable = phi
    boundary = top
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  nl_max_its = 20
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '300 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-12
  l_tol = 1e-4
  l_abs_step_tol = 1e-13
  end_time = 7200
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 3
  [../]
[]

[Outputs]
  output_initial = true
  print_linear_residuals = true
  print_perf_log = true
  output_final = true
  [./out]
    output_final = true
    type = Exodus
    file_base = phi_initial_out
    output_on = 'final initial'
  [../]
[]

[ICs]
  active = 'phi_box_IC'
  [./phase_ic]
    y2 = 0.005011
    y1 = 0
    inside = -1
    x2 = 0.005
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
  [./phi_box_IC]
    y2 = 0.006
    y1 = 0
    inside = -1
    x2 = 0.005
    outside = 1
    variable = phi
    x1 = 0
    type = BoundingBoxIC
  [../]
[]

[PikaMaterials]
  temperature = 263.15
  interface_thickness = 1e-5
  phase = phi
  temporal_scaling = 1
[]

