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
#include "PhaseBoussinesq.h"

template<>
InputParameters validParams<PhaseBoussinesq>()
{
  InputParameters params = validParams<Boussinesq>();
  params.addCoupledVar("phase","variable containing the phase");
  return params;
}

PhaseBoussinesq::PhaseBoussinesq(const std::string & name, InputParameters parameters) :
    Boussinesq(name, parameters),
    _phase(coupledValue("phase")),
    _phase_var_number(coupled("phase"))
{
}

Real
PhaseBoussinesq::computeQpResidual()
{
  return 0.5 * (1.0-_phase[_qp]) * Boussinesq::computeQpResidual();
}

Real
PhaseBoussinesq::computeQpJacobian()
{
    return 0.5 * (1.0-_phase[_qp]) * Boussinesq::computeQpJacobian();
}
Real
PhaseBoussinesq::computeQpOffDiagJacobian(unsigned jvar)
{
  if (jvar==_phase_var_number)
    return  -0.5 * _phi[_j][_qp]* Boussinesq::computeQpResidual();
  else
    return Boussinesq::computeQpOffDiagJacobian(jvar);
}
