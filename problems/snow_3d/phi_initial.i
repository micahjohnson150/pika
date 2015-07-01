[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 5
  ny = 5
  nz = 2
  xmin= 0.003
  ymin = 0.003
  zmin = 0.003
  xmax = 0.004
  ymax = 0.004
  zmax = 0.0031
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

[Functions]
  [./image]
    type = ImageFunction
    file_base =~/data/snow_images/0930/0930_rr_rec_tra_bin__Tra
    file_suffix = png
    threshold = 180
    lower_value = 1
    upper_value = -1
    dimensions = '0.005 0.005 0.006'
    file_range = '1303 1659'
     
  [../]
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

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  dt = 10
  end_time = 1000
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '300 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 5e-14
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    growth_factor = 1.5
  [../]
[]

[Adaptivity]
  max_h_level = 6
  marker = phi_grad_marker
  initial_steps = 6
  initial_marker = phi_grad_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
  [../]
[]



[Postprocessors]
  [./num_elems]
    type = NumElems
  [../]
[]

[Outputs]
  output_initial = true
  console = true
  print_linear_residuals = true
  print_perf_log = true
  [./exodus]
    output_final = true
    file_base = phi_initial
    type = Exodus
  [../]
[]

[ICs]
  [./phase_ic]
    type = FunctionIC
    function = image
    variable = phi
  [../]
[]

[PikaMaterials]
  temperature = 263.15
  interface_thickness = 1e-5
  phase = phi
  temporal_scaling = 1e-04
[]
