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


[GlobalParams]
  gravity = '0 0 0'
[]

[Mesh]
  type = FileMesh
  file = coldplate1.e
[]

[Preconditioning]
  [Newton_SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  []
[]

[Variables]
 [./velocity]
    order = CONSTANT
   family = MONOMIAL
   block='channel'
  [../]

  [./vel_x]
    order = SECOND
    family = LAGRANGE
    block='channel'
  [../]
  [./vel_y]
    order = SECOND
    family = LAGRANGE
    block='channel'
  [../]
  [./vel_z]
    order = SECOND
    family = LAGRANGE
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

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'wall-channel-outer  wall-channel-inner'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'wall-channel-outer  wall-channel-inner'
    value = 0.0
  [../]
  [./z_no_slip]
    type = DirichletBC
    variable = vel_z
    boundary = 'wall-channel-top  wall-channel-bottom'
    value = 0.0
  [../]
  [./inlet_x]
    type = DirichletBC
    variable = vel_x
    boundary = 'inlet'
    value = 1e-15
  [../]
  [./inlet_y]
    type = DirichletBC
    variable = vel_y
    boundary = 'inlet'
    value = 0.1
  [../]
  [./inlet_z]
    type = DirichletBC
    variable = vel_z
    boundary = 'inlet'
    value = 1e-15
  [../]
  [./inlet_temp]
    type = DirichletBC
    variable =T_channel
    boundary = 'inlet'
    value = 273
  [../]
  [./outlet_p]
    type = DirichletBC
    variable = p
    boundary = outlet
    value = 0.0
  [../]
[]

[Kernels]

  [./mass]
    type = INSADMass
    variable = p
    block = 'channel'
  [../]
  [./mass_pspg]
    type = INSADMassPSPG
    variable = p
    block = 'channel'
  [../]
  [./momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
    block = 'channel'
  [../]
  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
    block = 'channel'
  [../]
  [./momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = p
    integrate_p_by_parts = true
    block = 'channel'
  [../]
  [./momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
    block = 'channel'
  [../]
 [./temperature_advection]
   type = INSADEnergyAdvection
   variable = T_channel
   block = 'channel'
 [../]
  [./temperature_conduction]
    type = ADHeatConduction
    variable = T_channel
    thermal_conductivity = 'k'
  [../]
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
  [./mag]
   type = VectorMagnitudeAux
   variable = velocity
   x = vel_x
   y = vel_y
   z = vel_z
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

  [./const_functor_source]
    type = ADGenericConstantFunctorMaterial
    prop_names ='cp_s k_s'
    prop_values =  '${cp_s} ${k_s}'
    block = 'heat-source'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_factor_levels -ksp_gmres_restart'
  petsc_options_value = 'asm      6                     200'
  line_search = 'none'
  nl_rel_tol = 1e-12
  nl_max_its = 6
  automatic_scaling=true
[]

[Outputs]
  exodus = true
[]
