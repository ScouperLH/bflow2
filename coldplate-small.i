#input file for test

# Fluid properties
mu = 1000    # Pa*s
rho = 998.2    #kg/m3
cp = 4128      #j/kg-k
k = 0.6     #w/m-k
alpha =0.0018    # Thermal expansion

[Mesh]
  type = FileMesh
  file =smaller.e
[]

[Variables]
 [./velocity]
    family = LAGRANGE_VEC
    block='channel'
  #  scaling = 1e7
  [../]

  [./p]
    order = FIRST
    family = LAGRANGE
    block='channel'
    #scaling = 1e13
  [../]
  [T_channel]
    initial_condition = 293
    #scaling = 1e8
    block='channel'
  []

  [T_plate]
    initial_condition = 293
    #scaling = 1e7
    block='plate'
  []
  [T_source]
    initial_condition = 293
  #  scaling = 1e-8
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
    boundary = 'wall-channel-left  wall-channel-right wall-channel-top  wall-channel-bottom'
  [../]

  [./inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = 'inlet'
    function_y = 0.1   #m/s     y方向上0.1m/s
  [../]

  [./inlet_temp]
    type = DirichletBC
    variable =T_channel
    boundary = 'inlet'
    value = 293
  [../]
  [./temp_source_wall]
  type = ConvectiveFluxFunction # (Robin BC)
  variable = T_source
  boundary = 'wall-source-top wall-source-left wall-source-right wall-source-front wall-source-back'
  coefficient = 1e3 # W/K/m^2
  T_infinity = 273.0
[../]

[./temp_wall]
  type = ConvectiveFluxFunction # (Robin BC)
  variable = T_plate
  boundary = 'wall-top1 wall-top2 wall-left wall-right wall-front wall-back wall-bottom'
  coefficient = 1e3 # W/K/m^2
  T_infinity = 273.0
[../]

  [./outlet_p]
    type = DirichletBC
    variable = p
    boundary = 'outlet'
    value = 0.0
  [../]
  
  #this outlet need to be modify,now I'm finding suitable outlet.
  [./outlet_temp]
    type = DirichletBC
    variable = T_channel
    boundary ='outlet'
    value = 273
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
    boundary = 'wall-channel-left wall-channel-right wall-channel-top wall-channel-bottom'
    htc = 'alpha'
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
    gap_length = 0.0001
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
    petsc_options_iname = '-pc_type'
    petsc_options_value = ' svd'
   petsc_options = '-pc_svd_monitor'
    solve_type = 'NEWTON'
  []
[]

[Debug]
  show_var_residual_norms = true
  show_var_residual=' p T_channel T_plate T_source'
[]

[Executioner]
    type = Steady
    nl_rel_tol = 1e-14
    nl_max_its = 1000
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -ksp_gmres_restart'
    petsc_options_value = 'bjacobi  lu           NONZERO                   300'
   automatic_scaling=true
   line_search = none
[]

[Outputs]
  exodus = true
[]

