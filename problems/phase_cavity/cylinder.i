[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 8
  xmin = -1e-5
  xmax = .020
  ymin = -1e-5
  ymax = 0.04
  uniform_refine = 3
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pressure pin]
    type = AddExtraNodeset
    new_boundary = 99
    tolerance = 1e-4
    coord = '0.01 0.01'
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
  [./vapor_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'top bottom left right'
    value = -1
  [../]
  [./inlet]
    type = DirichletBC
    variable = v_x
    boundary = left
    value = 50
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
  temperature = 263
  interface_thickness = 1e-05
  temporal_scaling = 1 # 1e-05
[]

[ICs]
  [./phase_ic]
    y1 = 0.01
    x1 = 0.01
    radius = 0.0025
    invalue = 1
    outvalue = -1
    variable = phi
    int_width = 1e-5
    type = SmoothCircleIC
  [../]
[]

