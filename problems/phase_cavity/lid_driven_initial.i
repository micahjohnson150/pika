[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 3
  ny = 3
  xmax = .007
  ymax = 0.006
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
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
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
  [./phi_neuman]
    type = ImplicitNeumannBC
    variable = phi
    boundary = 'top bottom left right '
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '50 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-15
  l_tol = 1e-8
  end_time = 500
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 3
  [../]
[]

[Adaptivity]
  max_h_level = 5
  initial_steps = 3
  marker = phi_marker
  initial_marker = phi_marker
  steps = 3
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen = 1
      indicator = phi_grad_indicator
      refine = 1e-4
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  print_linear_residuals = true
  print_perf_log = true
  [./out]
    output_final = true
    type = Exodus
    file_base = lid_driven_initial
    additional_output_on = final
  [../]
[]

[ICs]
  [./phase_ic]
    x1 = 0.001
    y1 = 0.001
    variable = phi
    type = BoundingBoxIC
    y2 = 0.0061
    inside = -1
    x2 = 0.006
    outside = 1
  [../]
[]

[PikaMaterials]
  temperature = 258.2
  interface_thickness = 1e-5
  phase = phi
  temporal_scaling = 1e-04
[]

