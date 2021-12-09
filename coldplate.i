# Fluid properties
mu = 1e-3     # Pa*s
rho = 998.2    #kg/m3
cp = 4128      #j/kg-k
k = 0.6     #w/m-k
alpha =0.0018    # Thermal expansion

# Solid-plate   properties
cp_p = 871    #j/kg-k
rho_p = 2719      #kg/m3
k_p = 202.4        #w/m-k

# Solid-source   properties
cp_s = 330    #j/kg-k
rho_s = 5320      #kg/m3
k_s = 54        #w/m-k

# Operating conditions
v_inlet = 0.1
T_inlet = 273        #k
heat_source = 2.6e8              # W/m^3
p_outlet = 1e-6

# Numerical scheme
advected_interp_method='average'
velocity_interp_method='rc'

[Mesh]
  type = FileMesh
  file = coldplate1.e
[]

[Problem]
  fv_bcs_integrity_check = true
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 1e-6
    cell_gradient_caching = false
  []

  [v]
    type = INSFVVelocityVariable
    initial_condition = ${v_inlet}
    cell_gradient_caching = false
  []

  [w]
    type = INSFVVelocityVariable
    initial_condition = 1e-6
    cell_gradient_caching = false
  []

  [pressure]
    type = INSFVPressureVariable
    cell_gradient_caching = false
  []

  [T_channel]
    type = INSFVEnergyVariable
    block = 'channel'
    initial_condition = 273
  []

  [T_plate]
    type = MooseVariableFVReal
    initial_condition = 273
    block = 'plate'
  []

  [T_heat]
    type = MooseVariableFVReal
    initial_condition = 273
    block = 'heat-source'
  []
[]

[Kernels]
  # heatconduction kernel for each block's variable
  [source_conduction]
    type = ADHeatConduction
    variable = T_heat
    block = 'heat-source'
  []

  [plate_conduction]
    type = ADHeatConduction
    variable = T_plate
    block = 'plate'
  []

 [fluid_conduction]
    type = ADHeatConduction
    variable = T_channel
    block = 'channel'
 []

  # Source for the block
  [source_0]
    type = HeatSource
    variable = T_heat
    value = 2.6e8                   # W/m^3
    block =  'heat-source'
  []

   [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    vel = ${velocity}
    pressure = pressure
    u = u
    v = v
   w = w
    mu = ${mu}
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
   w = w
    mu = ${mu}
    rho = ${rho}
     []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = u
    mu = ${mu}
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
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
    w = w
    mu = ${mu}
    rho = ${rho}
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = v
    mu = ${mu}
   []

  [v_pressure]
    type = PINSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
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
    w = w
    mu = ${mu}
    rho = ${rho}
  []

  [w_viscosity]
    type = INSFVMomentumDiffusion
    variable = w
    mu = ${mu}
   []

  [w_pressure]
    type = PINSFVMomentumPressure
    variable = w
    momentum_component = 'z'
    pressure = pressure
  []

[energy_advection]
    type = INSFVEnergyAdvection
    variable = T_channel
    vel = 'velocity'
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    pressure = pressure
    u = u
    v = v
    w=w
    mu = ${mu}
    rho = ${rho}
  []

  [energy_diffusion]
    type = INSFVEnergyAnisotropicDiffusion
    kappa = 'kappa'
    variable = T_channel
    block='channel'
  []

 [plate_energy_diffusion]
    type = FVDiffusion
    coeff = ${k_p}
    variable = T_plate
     block = 'plate'
  []

  [source_energy_diffusion]
    type = FVDiffusion
    coeff = ${k_s}
    variable = T_heat
    diffusivity = conductivity
    block = 'heat-source'
  []
[]

[InterfaceKernels]
  [source_to_plate]
    type = SideSetHeatTransferKernel
    variable = T_heat
    neighbor_var = T_plate
    boundary = 'interface-heat-wrt-source'
  []

  [fluid_to_plate]
    type = ConjugateHeatTransfer
    variable = T_channel
    T_fluid = T_channel
    neighbor_var = 'T_plate'
    boundary = 'interface-wrt-fluid'
    htc = 'alpha'
  []
 []

[AuxVariables]
  [T]
  []
[]

[AuxKernels]
  [T_channel]
    type = NormalizationAux
    variable = T
    source_variable = T_channel
    block = 'channel'
  []

  [T_plate]
    type = NormalizationAux
    variable = T
    source_variable = T_plate
    block = 'plate'
  []

  [T_heat]
    type = NormalizationAux
    variable = T
    source_variable = T_heat
    block = 'heat-source'
  []
 []

[FVBCs]
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = u
    function = ${u_inlet}
  []

  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = v
    function =${v_inlet}
  []

  [inlet-w]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = w
    function = ${w_inlet}
  []
  [inlet-T]
    type = FVNeumannBC
    variable =T_channel
    value = ${fparse v_inlet * rho * cp * T_inlet}
    boundary = 'inlet'
  []

  [no-slip-u]
    type = INSFVNoSlipWallBC
    boundary = 'interface-channel'
    variable = u
    function = 0
  []

  [no-slip-v]
    type = INSFVNoSlipWallBC
    boundary = 'interface-channel'
    variable = v
    function = 0
  []

  [no-slip-w]
    type = INSFVNoSlipWallBC
    boundary = 'interface-channel'
    variable = w
    function = 0
  []

  [outlet-p]
    type = INSFVOutletPressureBC
    boundary = 'outlet'
    variable = pressure
    function = ${p_outlet}
  []
[]

[Materials]
  [./plate]
    type = ADHeatConductionMaterial
    thermal_conductivity = 202.4    # W/m k
    specific_heat = 4128    # J/kg k
    block = 'plate'
  [../]

  [./fluid]
    type = ADHeatConductionMaterial
    thermal_conductivity = .6  # W/m k
    specific_heat = 871    # J/kg K
    block = 'channel'
  [../]

  [./alpha]
    type = ADGenericConstantMaterial
    prop_names = 'alpha'
    prop_values = '0.0018'
    block = 'channel'
  [../]

  [./const_functor_source]
    type = ADGenericConstantFunctorMaterial
    prop_names ='cp_s k_s'
    prop_values =  '${cp_s} ${k_s}'
    block = 'heat-source'
  [../]

  [./ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    w = 'w'
    rho = ${rho}
    block='channel'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling=true
[]

# Some basic Postprocessors to examine the solution
[Postprocessors]
  [inlet-p]
    type = SideAverageValue
    variable = pressure
    boundary = 'inlet'
  []

  [outlet-v]
    type = SideAverageValue
    variable = v
    boundary = 'outlet'
  []

  [outlet-temp]
    type = SideAverageValue
    variable =T_channel
    boundary = 'outlet'
  []

  [plate-temp]
    type = ElementAverageValue
    variable = T_plate
  []
[]

[Outputs]
  exodus = true
  csv = false
[]
pressure = 'pressure'
    temperature = 'T_channel'
    rho = ${rho}
    block='channel'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling=true
[]

# Some basic Postprocessors to examine the solution
[Postprocessors]
  [inlet-p]
    type = SideAverageValue
    variable = pressure
    boundary = 'inlet'
  []

  [outlet-v]
    type = SideAverageValue
    variable = v
    boundary = 'outlet'
  []

  [outlet-temp]
    type = SideAverageValue
    variable =T_channel
    boundary = 'outlet'
  []

  [plate-temp]
    type = ElementAverageValue
    variable = T_plate
  []
[]

[Outputs]
  exodus = true
  csv = false
[]
