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


#include "PhaseConvection.h"

template<>
InputParameters validParams<PhaseConvection>()
{
  InputParameters params = validParams<Kernel>();


  params.addRequiredCoupledVar("phase","variable containing the phase");
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", "z-velocity"); // only required in 3D

  return params;
}

PhaseConvection::PhaseConvection(const std::string & name, InputParameters parameters) :
    Kernel(name, parameters),
    PropertyUserObjectInterface(name,parameters),
    // Coupled variables
    _u_vel(coupledValue("u")),
    _v_vel(_mesh.dimension() >= 2 ? coupledValue("v") : _zero),
    _w_vel(_mesh.dimension() == 3 ? coupledValue("w") : _zero),

    // Variable numberings
    _u_vel_var_number(coupled("u")),
    _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("v") : libMesh::invalid_uint),
    _w_vel_var_number(_mesh.dimension() == 3 ? coupled("w") : libMesh::invalid_uint),

    _phase(coupledValue("phase")),
    _phase_var_number(coupled("phase")),
    _xi(_property_uo.temporalScale())
{
}

Real
PhaseConvection::computeQpResidual()
{

  return 0.5 * (1.0-_phase[_qp]) * _xi * 
     (_u_vel[_qp]*_grad_u[_qp](0) +
     _v_vel[_qp]*_grad_u[_qp](1) +
     _w_vel[_qp]*_grad_u[_qp](2)) * _test[_i][_qp];
}

Real
PhaseConvection::computeQpJacobian()
{
    RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
    return 0.5 * (1.0-_phase[_qp]) * _xi * U * _grad_phi[_j][_qp];
}
Real
PhaseConvection::computeQpOffDiagJacobian(unsigned jvar)
{
  RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  if (jvar==_phase_var_number)
    return  -_xi * 0.5 * _phi[_j][_qp] * U * _grad_u[_qp];

  else if (jvar == _u_vel_var_number)
   { return  -_xi * 0.5 * _phase[_qp] * ( _phi[_j][_qp] * _grad_u[_qp](0) +
             _v_vel[_qp] * _grad_u[_qp](1) +
             _w_vel[_qp] * _grad_u[_qp](2));
   }

  else if (jvar == _v_vel_var_number)
   { return  -_xi * 0.5 * _phase[_qp] * ( _u_vel[_qp] * _grad_u[_qp](0) +
             _phi[_j][_qp] * _grad_u[_qp](1) +
             _w_vel[_qp] * _grad_u[_qp](2));
   }

  else if (jvar == _w_vel_var_number)
   { return  -_xi * 0.5 * _phase[_qp] * ( _u_vel[_qp] * _grad_u[_qp](0) +
             _v_vel[_qp] * _grad_u[_qp](1) +
             _phi[_j][_qp] * _grad_u[_qp](2));
   }
  else
    return 0;
}
