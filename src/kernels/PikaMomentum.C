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
#include "PikaMomentum.h"

template<>
InputParameters validParams<PikaMomentum>()
{
  InputParameters params = validParams<INSMomentum>();
  params.addRequiredCoupledVariable("phase","Phase of medium");
  return params;
}

PikaMomentum::PikaMomentum(const std::string & name, InputParameters parameters) :
    INSMomentum(name, parameters),
    _phi(coupled("phase"))
{
}

Real
PikaMomentum::computeQpResidual()
{
  return 0.5*(1.0-_phi[_qp])*INSMomentum::computeQpResidual();
}
Real
PikaMomentum::computeQpJacobian()
{
  return 0.5*(1.0-_phi[_qp])*INSMomentum::computeQpJacobian();
}
