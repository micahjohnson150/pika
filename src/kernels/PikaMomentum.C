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

  // Gradients
  _grad_p(coupledGradient("p")),

  // Variable numberings
  _u_vel_var_number(coupled("vel_x")),
  _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("vel_y") : libMesh::invalid_uint),
  _w_vel_var_number(_mesh.dimension() == 3 ? coupled("vel_z") : libMesh::invalid_uint),
  _p_var_number(coupled("p")),

  // constant
  _mu(_property_uo.getParam<Real>("dry_air_viscosity")),
  _rho(_property_uo.getParam<Real>("density_air")),
  _component(getParam<unsigned>("component")),
  _xi(_property_uo.getParam<Real>("temporal_scaling"))
 // _xi(1.0)

{
}

Real PikaMomentum::Convective()
{
  // The convection part
  // Note: _grad_u is the gradient of the _component entry of the velocity vector.
   return  _xi * _rho * (_u_vel[_qp] * _grad_u[_qp](0) + _v_vel[_qp] * _grad_u[_qp](1) + _w_vel[_qp] * _grad_u[_qp](2)) * _test[_i][_qp];
}
Real PikaMomentum::Pressure()
{
  // The pressure part
  return - _xi  * _p[_qp] *  _grad_test[_i][_qp](_component);
}

Real PikaMomentum::Viscous()
{
  return  _xi * _mu * _grad_u[_qp] * _grad_test[_i][_qp];
}

Real PikaMomentum::computeQpResidual()
{
  return  Convective() + Pressure() +  Viscous();
}

Real PikaMomentum::computeQpJacobian()
{
  //Jacobian of convective part (considering product rule)
    return  _xi * _rho * (_u_vel[_qp] * _grad_phi[_j][_qp](0) + _v_vel[_qp] * _grad_phi[_j][_qp](1) + _w_vel[_qp] * _grad_phi[_j][_qp](2) 
        + _phi[_j][_qp] * _grad_u[_qp](_component)) * _test[_i][_qp]
  //Jacobian part of pressure = 0
  //Jacobian of viscous part 
   + _xi * _mu *_grad_phi[_j][_qp] * _grad_test[_i][_qp];
  
}

Real PikaMomentum::computeQpOffDiagJacobian(unsigned jvar)
{
  //Laplacian viscous term is zero for off diags.
  
  // The off Diag Jac for u_vel when u_vel!= _u  in convection part
  if (jvar == _u_vel_var_number || jvar == _v_vel_var_number || jvar == _w_vel_var_number )
  {
    return  _xi * _rho * _phi[_j][_qp] * _grad_u[_qp](_component) * _test[_i][_qp];
  }

  // The off Diag Jac for pressure
  else if (jvar == _p_var_number)
  {
    return -_xi *  _phi[_j][_qp] * _grad_test[_i][_qp](_component);
  }

  else
    return 0.0;
}
