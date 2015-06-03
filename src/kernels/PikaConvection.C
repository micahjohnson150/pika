/**********************************************************************************/
/*                  Pika: Phase field snow micro-structure model                  */
/*                                                                                */
/*                     (C) 2014 Battelle Energy Alliance, LLC                     */
/*                              ALL RIGHTS RESERVED                               */
/*                                                                                */
/*                   Prepared by Battelle Energy Alliance, LLC                    */
/*                      Under Contract No. DE-AC07-05ID14517                      */
/*                      With the U. S. Department of Energy                       */
/**********************************************************************************/

#include "PikaConvection.h"

template<>
InputParameters validParams<PikaConvection>()
{
  InputParameters params = validParams<Kernel>();
  params += validParams<PropertyUserObjectInterface>();
  params += validParams<CoefficientKernelInterface>();


  params.addRequiredCoupledVar("vel_x", "x-velocity");
  params.addCoupledVar("vel_y", "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("vel_w", "z-velocity"); // only required in 3D

  return params;
}

PikaConvection::PikaConvection(const std::string & name, InputParameters parameters) :
    Kernel(name, parameters),
    PropertyUserObjectInterface(name,parameters),
    CoefficientKernelInterface(name,parameters),
    // Coupled variables
    _u_vel(coupledValue("vel_x")),
    _v_vel(_mesh.dimension() >= 2 ? coupledValue("vel_y") : _zero),
    _w_vel(_mesh.dimension() == 3 ? coupledValue("vel_w") : _zero),

    // Variable numberings
    _u_vel_var_number(coupled("vel_x")),
    _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("vel_y") : libMesh::invalid_uint),
    _w_vel_var_number(_mesh.dimension() == 3 ? coupled("vel_z") : libMesh::invalid_uint)
{
 // The getMaterialProperty method cannot be replicated in interface
  if (useMaterial())
    setMaterialPropertyPointer(&getMaterialProperty<Real>(getParam<std::string>("property")));
}

Real
PikaConvection::computeQpResidual()
{
  return  coefficient(_qp) * ( _u_vel[_qp] * _grad_u[_qp](0) +  _v_vel[_qp] * _grad_u[_qp](1) +  _w_vel[_qp] * _grad_u[_qp](2)) * _test[_i][_qp];
}

Real
PikaConvection::computeQpJacobian()
{
  return  coefficient(_qp) * ( _u_vel[_qp] * _grad_phi[_j][_qp](0) +  _v_vel[_qp] * _grad_phi[_j][_qp](1) +  _w_vel[_qp] * _grad_phi[_j][_qp](2)) * _test[_i][_qp];
}
Real
PikaConvection::computeQpOffDiagJacobian(unsigned jvar)
{
  // The off Diag Jacobian for u_vel 
  if (jvar == _u_vel_var_number)
   return   coefficient(_qp) * _phi[_j][_qp] * _grad_u[_qp](0) * _test[_i][_qp];

  // The off Diag Jacobian for v_vel 
  else if (jvar == _v_vel_var_number)
   return   coefficient(_qp) *  _phi[_j][_qp] * _grad_u[_qp](1) * _test[_i][_qp];

  // The off Diag Jacobian for w_vel 
  else if (jvar == _w_vel_var_number)
   return   coefficient(_qp) * _phi[_j][_qp] * _grad_u[_qp](2) * _test[_i][_qp];

  else 
    return 0.0;
}
