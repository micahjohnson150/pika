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


// MOOSE includes
#include "PhaseTimeDerivative.h"

template<>
InputParameters validParams<PhaseTimeDerivative>()
{
  InputParameters params = validParams<TimeDerivative>();
  params +=validParams<PropertyUserObjectInterface>();
  params.addCoupledVar("phase","variable containing the phase");
  return params;
}

PhaseTimeDerivative::PhaseTimeDerivative(const std::string & name, InputParameters parameters) :
    TimeDerivative(name, parameters),
    PropertyUserObjectInterface(name, parameters),
    _phase(coupledValue("phase")),
    _phase_var_number(coupled("phase")),
    _rho(_property_uo.equilibriumWaterVaporConcentrationAtSaturationAtReferenceTemperature())

{
}

Real
PhaseTimeDerivative::computeQpResidual()
{
  //return 0.5 * (1.0-_phase[_qp]) * _rho *  TimeDerivative::computeQpResidual();
  return _rho *  TimeDerivative::computeQpResidual();
}

Real
PhaseTimeDerivative::computeQpJacobian()
{
    //return 0.5 * (1.0-_phase[_qp]) * _rho * TimeDerivative::computeQpJacobian();
    return _rho * TimeDerivative::computeQpJacobian();
}
Real
PhaseTimeDerivative::computeQpOffDiagJacobian(unsigned jvar)
{
/*  if (jvar==_phase_var_number)
    return  -0.5 * _phi[_j][_qp]* _rho *  TimeDerivative::computeQpResidual();
  else
    return   0.5 * (1.0-_phase[_qp]) *  _rho * TimeDerivative::computeQpOffDiagJacobian(jvar);
    */
    return   _rho * TimeDerivative::computeQpOffDiagJacobian(jvar);
}
