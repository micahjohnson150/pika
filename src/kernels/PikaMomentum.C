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
  _grad_p(coupledGradient("p")),
  _grad_phase(coupledGradient("phase")),

  // Variable numberings
  _u_vel_var_number(coupled("vel_x")),
  _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("vel_y") : libMesh::invalid_uint),
  _w_vel_var_number(_mesh.dimension() == 3 ? coupled("vel_z") : libMesh::invalid_uint),
  _p_var_number(coupled("p")),
  _phase_var_number(coupled("phase")),

  // constant
  _mu(_property_uo.getParam<Real>("dry_air_viscosity")),
  _rho(_property_uo.getParam<Real>("density_air")),
  _component(getParam<unsigned>("component")),
  _xi(_property_uo.getParam<Real>("temporal_scaling"))

{
}

Real PikaMomentum::Convective()
{
  // The convection part
  // Note: _grad_u is the gradient of the _component entry of the velocity vector.
    RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
    return  _xi * _rho * 0.5 * (1.0 - _phase[_qp]) * U * _grad_u[_qp] * _test[_i][_qp];
}
Real PikaMomentum::Pressure()
{
  // The pressure part
  return -0.5 * _xi * (1.0 - _phase[_qp]) * _p[_qp] *  _grad_test[_i][_qp](_component);
  //return 0.5 * _xi * (1.0 - _phase[_qp]) * _grad_p[_qp](_component) *  _test[_i][_qp];
}

Real PikaMomentum::Viscous()
{
  RealVectorValue tau = -_grad_phase[_qp] * _u[_qp] + (1.0 - _phase[_qp]) * _grad_u[_qp];
  return 0.5 * _xi * _mu * tau * _grad_test[_i][_qp];
}

Real PikaMomentum::computeQpResidual()
{
  return  Convective() + Pressure() +  Viscous();
}

Real PikaMomentum::computeQpJacobian()
{
  Real convective;
  RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  //Jacobian of convective part

  convective = _xi * _rho * 0.5 * (1.0 - _phase[_qp]) * (U * _grad_phi[_j][_qp] +  _phi[_j][_qp] * _grad_u[_qp](_component)) *  _test[_i][_qp];
           
  //Jacobian part of pressure = 0

  //Jacobian of viscous part 
  RealVectorValue tau = -_grad_phase[_qp] * _phi[_j][_qp] + (1.0 - _phase[_qp]) * _grad_phi[_j][_qp];

  Real viscous = 0.5 * _xi * _mu * tau *_grad_test[_i][_qp];

return convective + viscous;
  
}

Real PikaMomentum::computeQpOffDiagJacobian(unsigned jvar)
{
  //Laplacian viscous term is zero for off diags.
  
  // The off Diag Jac for u_vel when u_vel!= _u  in convection part
  if (jvar == _u_vel_var_number || jvar == _v_vel_var_number || jvar == _w_vel_var_number )
  {
    RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
    return  _xi * _rho * 0.5 * (1.0 - _phase[_qp]) * _phi[_j][_qp] * _grad_u[_qp](_component) * _test[_i][_qp];
  }

  // The off Diag Jac for pressure
  else if (jvar == _p_var_number)
  {
    return -_xi * 0.5 * (1.0-_phase[_qp]) *  _phi[_j][_qp] * _grad_test[_i][_qp](_component);
  }

  else if (jvar == _phase_var_number)
  {
    RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
    Real convective =  _xi * _rho * 0.5 * (- _phi[_j][_qp]) * U * _grad_u[_qp] * _test[_i][_qp];
    
    Real pressure = -_xi * 0.5 * (-_phi[_j][_qp]) *  _p[_qp] * _grad_test[_i][_qp](_component);

    RealVectorValue tau = -_grad_phi[_j][_qp] * _u[_qp] + ( - _phi[_j][_qp]) * _grad_u[_qp];
    
    Real viscous =  0.5 * _xi * _mu * (tau * _grad_test[_i][_qp]);
    return convective + pressure + viscous;
  }
  else
    return 0.0;
}
