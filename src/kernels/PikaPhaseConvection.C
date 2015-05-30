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

#include "PikaPhaseConvection.h"

template<>
InputParameters validParams<PikaPhaseConvection>()
{
  InputParameters params = validParams<PikaConvection>();
  // Coupled variables
  params.addRequiredCoupledVar("phase","variable containing the phase of the medium");

  return params;
}

PikaPhaseConvection::PikaPhaseConvection(const std::string & name, InputParameters parameters) :
    PikaConvection(name, parameters),
    // Coupled variables
    _phase(coupledValue("phase")),

    // Variable numberings
    _phase_var_number(coupled("phase"))

{
}
Real
PikaPhaseConvection::computeQpResidual()
{
  return  0.5 * (1.0 - _phase[_qp]) * PikaConvection::computeQpResidual();
}

Real
PikaPhaseConvection::computeQpJacobian()
{
  return  0.5 * (1.0 - _phase[_qp]) * PikaConvection::computeQpJacobian();
}

Real
PikaPhaseConvection::computeQpOffDiagJacobian(unsigned jvar)
{
  // The off Diag Jacobian for u_vel 
  if (jvar == _phase_var_number)
    return  -0.5 * _phi[_j][_qp] * PikaConvection::computeQpResidual();

  else 
    return  0.5 *(1.0 - _phase[_qp]) * PikaConvection::computeQpOffDiagJacobian(jvar);
}
