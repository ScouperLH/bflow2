mu = 0.1
rho = 1
k = .01
cp = 1
vel = 'velocity'
velocity_interp_method = 'rc'
advected_interp_method = 'average'

[Mesh]
  type = FileMesh #Read in mesh from file
  file = channel.e
[]

[Problem]
  fv_bcs_integrity_check = true
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 1
    cache_cell_gradients = false
  []
  [v]
    type = INSFVVelocityVariable
    initial_condition = 1
    cache_cell_gradients = false
  []
  [w]
    type = INSFVVelocityVariable
    initial_condition = 1
    cache_cell_gradients = false
  []
  [T]
    type = INSFVEnergyVariable
    cache_cell_gradients = false
  []
  [pressure]
    type = INSFVPressureVariable
    cache_cell_gradients = false
  []
  [lambda]
    family = SCALAR
    order = FIRST
  []
[]

[ICs]
  [T]
    type = ConstantIC
    variable = T
    value = 300
  []
[]


[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    vel = 'velocity'
    pressure = pressure
    u = u
    v = v
    w= w
    mu = ${mu}
    rho = ${rho}
  []
  [mean_zero_pressure]
    type = FVScalarLagrangeMultiplier
    variable = pressure
    lambda = lambda
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = 'u'
    rho = ${rho}
 []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    advected_quantity = 'rhou'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    w=w
    mu = ${mu}
    rho = ${rho}
  []
  [u_viscosity]
    type = FVDiffusion
    variable = u
    coeff = ${mu}
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = v
    rho = ${rho}
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    advected_quantity = 'rhov'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    w=w
    mu = ${mu}
    rho = ${rho}
  []
  [v_viscosity]
    type = FVDiffusion
    variable = v
    coeff = ${mu}
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
  []

  [w_time]
    type = INSFVMomentumTimeDerivative
    variable = w
    rho = ${rho}
  []
 [w_advection]
    type = INSFVMomentumAdvection
    variable = w
    advected_quantity = 'rhow'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    w=w
    mu = ${mu}
    rho = ${rho}
  []
  [w_viscosity]
    type = FVDiffusion
    variable = w
    coeff = ${mu}
  []
  [w_pressure]
    type = INSFVMomentumPressure
    variable = w
    momentum_component = 'z'
    pressure = pressure
  []

  [temp_time]
    type = INSFVEnergyTimeDerivative
    variable = T
    rho = ${rho}
    cp_name = 'cp'
  []
  [temp_conduction]
    type = FVDiffusion
    coeff = 'k'
    variable = T
  []
  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    vel = ${vel}
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    pressure = pressure
    u = u
    v = v
    w= w
    mu = ${mu}
    rho = ${rho}
  []
[]

[FVBCs]
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = u
    function = '0'
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = v
    function = '1'
  []
 [inlet-w]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = w
    function = '0'
  []

  [walls-u]
    type = INSFVNoSlipWallBC
    boundary = 'walltop wallbtm wallin wallout'
    variable = u
    function = 0
  []
  [walls-v]
    type = INSFVNoSlipWallBC
    boundary = 'walltop wallbtm wallin wallout'
    variable = v
    function = 0
  []
  [walls-w]
    type = INSFVNoSlipWallBC
    boundary = 'walltop wallbtm wallin wallout'
    variable = w
    function = 0
  []
  [T_hot]
    type = FVDirichletBC
    variable = T
    boundary = 'walltop'
    value = 310
  []

  [T_cold]
    type = FVDirichletBC
    variable = T
    boundary = 'wallbtm'
    value = 300
  []

  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'outlet'
    variable = pressure
    function = '0'
  []
[]

[Materials]
  [functor_constants]
    type = ADGenericConstantFunctorMaterial
    prop_names = 'cp k'
    prop_values = '${cp} ${k}'
  []
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    w = 'w'
    pressure = 'pressure'
    temperature = 'T'
    rho = ${rho}
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  num_steps = 20
  dt = .5
  dtmin = .5
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      200                ilu           NONZERO'
  line_search = 'none'
  nl_abs_tol = 1e-10
  nl_max_its = 50
  l_max_its = 200
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true # prints a performance report to the terminal
[]
