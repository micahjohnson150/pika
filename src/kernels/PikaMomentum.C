#include "PikaMomentum.h"

template<>
InputParameters validParams<PikaMomentum>()
{
  InputParameters params = validParams<Kernel>();
  params+=validParams<PropertyUserObjectInterface>();

  // Coupled variables
  params.addRequiredCoupledVar("vel_x", "x-velocity");
  params.addCoupledVar("vel_y", "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("vel_z", "z-velocity"); // only required in 3D
  params.addRequiredCoupledVar("p", "pressure");
  params.addRequiredCoupledVar("phase", "variable containing the phase");

  // Required parameters
  params.addRequiredParam<unsigned>("component", "0,1,2 depending on if we are solving the x,y,z component of the momentum equation");

  return params;
}



PikaMomentum::PikaMomentum(const std::string & name, InputParameters parameters) :
  Kernel(name, parameters),
  PropertyUserObjectInterface(name, parameters),

  // Coupled variables
  _u_vel(coupledValue("vel_x")),
  _v_vel(_mesh.dimension() >= 2 ? coupledValue("vel_y") : _zero),
  _w_vel(_mesh.dimension() == 3 ? coupledValue("vel_z") : _zero),
  _p(coupledValue("p")),
  _phase(coupledValue("phase")),

  // Gradients
  _grad_u_vel(coupledGradient("vel_x")),
  _grad_v_vel(_mesh.dimension() >= 2 ? coupledGradient("vel_y") : _grad_zero),
  _grad_w_vel(_mesh.dimension() == 3 ? coupledGradient("vel_z") : _grad_zero),
  _grad_p(coupledGradient("p")),
  _grad_phase(coupledGradient("phase")),

  // Variable numberings
  _u_vel_var_number(coupled("vel_x")),
  _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("vel_y") : libMesh::invalid_uint),
  _w_vel_var_number(_mesh.dimension() == 3 ? coupled("vel_z") : libMesh::invalid_uint),
  _p_var_number(coupled("p")),
  _phase_var_number(coupled("phase")),

  // Required parameters
  _mu(_property_uo.getParam<Real>("dry_air_viscosity")),
  _rho(_property_uo.equilibriumWaterVaporConcentrationAtSaturationAtReferenceTemperature()),
  _gravity(_property_uo.getParam<RealVectorValue>("gravity")),
  _component(getParam<unsigned>("component")),
  _xi(_property_uo.getParam<Real>("temporal_scaling"))

{
}

Real PikaMomentum::Convective()
{
  // The convection part, rho * (u.grad) * u_component * v.
  // Note: _grad_u is the gradient of the _component entry of the velocity vector.
    return  _xi * _rho *
            0.5 *(1.0-_phase[_qp]) * (_u_vel[_qp]*_grad_u[_qp](0) +
             _v_vel[_qp]*_grad_u[_qp](1) +
             _w_vel[_qp]*_grad_u[_qp](2)) * _test[_i][_qp];

}
Real PikaMomentum::Pressure()
{
  // The pressure part, -p (div v)
  return _xi * 0.5 * (1.0-_phase[_qp]) *  _p[_qp] * _grad_test[_i][_qp](_component);
}

Real PikaMomentum::Viscous()
{
  // The component'th row (or col, it's symmetric) of the viscous stress tensor
  RealVectorValue tau_row;
  tau_row(0)= - _grad_phase[_qp](0)* _u[_qp] + _grad_u[_qp](0) * (1.0 - _phase[_qp]);
  tau_row(1)= - _grad_phase[_qp](1)* _u[_qp] + _grad_u[_qp](1) * (1.0 - _phase[_qp]);
  tau_row(2)= - _grad_phase[_qp](2)* _u[_qp] + _grad_u[_qp](2) * (1.0 - _phase[_qp]);

/*  
 tau_row(0)= _grad_u[_qp](0) - _grad_phase[_qp](0)* _u[_qp] + _grad_u[_qp](0) * _phase[_qp];
  tau_row(1)= _grad_u[_qp](1) - _grad_phase[_qp](1)* _u[_qp] + _grad_u[_qp](1) * _phase[_qp];
  tau_row(2)= _grad_u[_qp](2) - _grad_phase[_qp](2)* _u[_qp] + _grad_u[_qp](2) * _phase[_qp];
  */
  return 0.5 * _xi * _mu * (tau_row * _grad_test[_i][_qp]);
}

Real PikaMomentum::computeQpResidual()
{
  //return Convective() +  Pressure() +  Viscous();
  return  Pressure() +  Viscous();
}

Real PikaMomentum::computeQpJacobian()
{/*
  RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  // Convective part
  Real convective_part = _rho * ((U*_grad_phi[_j][_qp]) + _phi[_j][_qp]*_grad_u[_qp](_component)) * _test[_i][_qp];

  // Viscous part, Stokes/Laplacian version
  // Real viscous_part = _mu * (_grad_phi[_j][_qp] * _grad_test[_i][_qp]);

  // Viscous part, full stress tensor.  The extra contribution comes from the "2"
  // on the diagonal of the viscous stress tensor.
  Real viscous_part = _mu * (_grad_phi[_j][_qp]             * _grad_test[_i][_qp] +
                             _grad_phi[_j][_qp](_component) * _grad_test[_i][_qp](_component));

  return 0.5 * (1.0-_phase[_qp]) * _xi * (convective_part + viscous_part);
  */
  return 0.0;
}

Real PikaMomentum::computeQpOffDiagJacobian(unsigned jvar)
{
  /*
  // In Stokes/Laplacian version, off-diag Jacobian entries wrt u,v,w are zero
  if (jvar == _u_vel_var_number)
  {
    Real convective_part = _phi[_j][_qp] * _grad_u[_qp](0) * _test[_i][_qp];
    Real viscous_part = _mu * _grad_phi[_j][_qp](_component) * _grad_test[_i][_qp](0);

    return 0.5 * (1.0-_phase[_qp]) * _xi * (convective_part + viscous_part);
  }

  else if (jvar == _v_vel_var_number)
  {
    Real convective_part = _phi[_j][_qp] * _grad_u[_qp](1) * _test[_i][_qp];
    Real viscous_part = _mu * _grad_phi[_j][_qp](_component) * _grad_test[_i][_qp](1);

    return 0.5 * (1.0-_phase[_qp]) * _xi * (convective_part + viscous_part);
  }

  else if (jvar == _w_vel_var_number)
  {
    Real convective_part = _phi[_j][_qp] * _grad_u[_qp](2) * _test[_i][_qp];
    Real viscous_part = _mu * _grad_phi[_j][_qp](_component) * _grad_test[_i][_qp](2);

    return 0.5 * (1.0-_phase[_qp]) * _xi * (convective_part + viscous_part);
  }

  else if (jvar == _p_var_number)
    return -_xi * _phi[_j][_qp] * _grad_test[_i][_qp](_component);

  else if (jvar == _phase_var_number)
      return -0.5 * _phi[_j][_qp]* PikaMomentum::computeQpResidual();
  else
    return 0.0;
    */
  return 0.0;
}
