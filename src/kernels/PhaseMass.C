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
#include "PhaseMass.h"

template<>
InputParameters validParams<PhaseMass>()
{
  InputParameters params = validParams<INSMass>();
  params.addCoupledVar("phase","variable containing the phase");
  return params;
}

PhaseMass::PhaseMass(const std::string & name, InputParameters parameters) :
    INSMass(name, parameters),
    _phase(coupledValue("phase")),
    _phase_var_number(coupled("phase"))
{
}

Real
PhaseMass::computeQpResidual()
{
  return 0.5 * (1.0-_phase[_qp]) * INSMass::computeQpResidual();
}

Real
PhaseMass::computeQpJacobian()
{
    return 0.5 * (1.0-_phase[_qp]) * INSMass::computeQpJacobian();
}
Real
PhaseMass::computeQpOffDiagJacobian(unsigned jvar)
{
  if (jvar==_phase_var_number)
    return  -0.5 * _phi[_j][_qp]* INSMass::computeQpResidual();
  else
    return INSMass::computeQpOffDiagJacobian(jvar);
}
