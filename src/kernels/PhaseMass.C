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


#include "PhaseMass.h"

template<>
InputParameters validParams<PhaseMass>()
{
  
  InputParameters params = validParams<Kernel>();

  // Coupled variables
  params.addRequiredCoupledVar("vel_x", "x component of the velocity");
  params.addCoupledVar("vel_y", "y component of the velocity"); // only required in 2D and 3D
  params.addCoupledVar("vel_z", "z component of the velocity"); // only required in 3D
  params.addCoupledVar("phase","variable containing the phase");
  return params;
}

PhaseMass::PhaseMass(const std::string & name, InputParameters parameters) :
    Kernel(name, parameters),
    // Coupled variables
    _u_vel(coupledValue("vel_x")),
    _v_vel(_mesh.dimension() >= 2 ? coupledValue("vel_y") : _zero),
    _w_vel(_mesh.dimension() == 3 ? coupledValue("vel_z") : _zero),
    _phase(coupledValue("phase")),

    // Gradients
    _grad_u_vel(coupledGradient("vel_x")),
    _grad_v_vel(_mesh.dimension() >= 2 ? coupledGradient("vel_y") : _grad_zero),
    _grad_w_vel(_mesh.dimension() == 3 ? coupledGradient("wvel_z") : _grad_zero),
    _grad_phase(coupledGradient("phase")),

    // Variable numberings
    _u_vel_var_number(coupled("vel_x")),
    _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("vel_y") : libMesh::invalid_uint),
    _w_vel_var_number(_mesh.dimension() == 3 ? coupled("vel_z") : libMesh::invalid_uint),
    _phase_var_number(coupled("phase"))
{
}

Real
PhaseMass::computeQpResidual()
{
  //Arbitrarily multiplied by -1 to match - grad P, Shouldn't matter...I think. 
  return 0.5 * ( _grad_u_vel[_qp](0) - _grad_u_vel[_qp](0) * _phase[_qp] - _grad_phase[_qp](0) * _u_vel[_qp]
                + _grad_v_vel[_qp](1) - _grad_v_vel[_qp](1) * _phase[_qp] - _grad_phase[_qp](1) * _v_vel[_qp]
                + _grad_w_vel[_qp](2) - _grad_w_vel[_qp](2) * _phase[_qp] - _grad_phase[_qp](2) * _w_vel[_qp]) * _test[_i][_qp];
}

Real
PhaseMass::computeQpJacobian()
{
  //the derivative of the residual wrt p = 0.
  return 0.0;
}
Real
PhaseMass::computeQpOffDiagJacobian(unsigned jvar)
{
/*  if (jvar==_phase_var_number)
    return  -0.5 * _phi[_j][_qp]* Kernel::computeQpResidual();
  else
    return Kernel::computeQpOffDiagJacobian(jvar);
*/
  return 0.0;
}
