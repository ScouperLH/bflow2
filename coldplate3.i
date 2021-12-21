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

[GlobalParams]
  gravity = '0 0 0'
[]

[Mesh]
  type = FileMesh
  file = coldplate1.e
[]

[Variables]
 [./velocity]
    family = LAGRANGE_VEC
    block='channel'
  [../]

  [./p]
    order = FIRST
    family = LAGRANGE
    block='channel'
  [../]
  [T_channel]
    initial_condition = 273
    scaling = 1e-4
    block='channel'
  []

  [T_plate]
    initial_condition = 273
    scaling = 1e-4
    block='plate'
  []
  [T_source]
    initial_condition = 273
    scaling = 1e-4
    block='heat-source'
  []
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1e-15
    z_value = 1e-15
    variable = velocity
  []
[]

[Kernels]
  [./mass]
    type = INSADMass
    variable = p
  [../]
  [./mass_pspg]
    type = INSADMassPSPG
    variable = p
  [../]
  [./momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  [../]
  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  [../]
  [./momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = p
    integrate_p_by_parts = true
  [../]
  [./momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  [../]
 [./temperature_advection]
   type = INSADEnergyAdvection
   variable = T_channel
 [../]
  [./temperature_conduction]
    type = ADHeatConduction
    variable = T_channel
    thermal_conductivity = 'k'
  [../]

  [temperature_source]
    type = INSADEnergySource
    variable = T_channel
    source_variable = u
  []

  [temperature_supg]
    type = INSADEnergySUPG
    variable = T_channel
    velocity = velocity
  []

  [source_conduction]
    type = ADHeatConduction
    variable = T_source
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
    value = 2.6e8                   # W/m^3
    variable = T_source
    block =  'heat-source'
  []
[]


[BCs]
  [./no_slip]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = 'wall-channel-outer  wall-channel-inner wall-channel-top  wall-channel-bottom'
  [../]

  [./inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = 'inlet'
    function_y = 0.1   #m/s     y方向上0.1m/s
  [../]

#不确定是否需要设置此温度入口
  [./inlet_temp]
    type = DirichletBC
    variable =T_channel
    boundary = 'inlet'
    value = 273
  [../]
  [./outlet_p]
    type = DirichletBC
    variable = p
    boundary = 'outlet'
    value = 0.0
  [../]
[]


[InterfaceKernels]
  [source_to_plate]
    type = SideSetHeatTransferKernel
    variable = T_source
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
  [u]
    initial_condition = 273
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

  [T_source]
    type = NormalizationAux
    variable = T
    source_variable = T_source
    block = 'heat-source'
  []
[]

[Materials]
  [./const_fluid]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu cp k'
    prop_values = '${rho} ${mu}  ${cp}  ${k}'
    block = 'channel'
  [../]
  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = T_channel
    block='channel'
  []

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

  [./source]
    type = ADHeatConductionMaterial
    thermal_conductivity = 54    # W/m k
    specific_heat = 330    # J/kg k
    block = 'heat-source'
  [../]

  [gap_mat]
    type = SideSetHeatTransferMaterial
    boundary = 'interface-heat-wrt-source'
    conductivity = 54
    gap_length = 1e-15
    Tbulk = 600
    h_primary = 3000
    h_neighbor = 3000
    emissivity_primary = 1
    emissivity_neighbor = 1
  []
[]

[Preconditioning]
  [Newton_SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  []
[]

[Executioner]
  type = Steady
  nl_rel_tol = 1e-12
  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -ksp_gmres_restart'
  petsc_options_value = 'bjacobi  lu           NONZERO                   200'
  automatic_scaling=true
[]

[Outputs]
  exodus = true
[]
