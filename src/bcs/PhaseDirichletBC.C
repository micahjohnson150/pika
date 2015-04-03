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

#include "PhaseDirichletBC.h"
#include "PropertyUserObject.h"
template<>
InputParameters validParams<PhaseDirichletBC>()
{
  InputParameters params = validParams<DirichletBC>();
  params += validParams<PropertyUserObjectInterface>();
  params.addRequiredCoupledVar("phase_variable", "The variable containing the phase of the continuum (phi)");
  return params;
}

PhaseDirichletBC::PhaseDirichletBC(const std::string & name, InputParameters parameters) :
    DirichletBC(name, parameters),
    PropertyUserObjectInterface(name, parameters),
    _phase(coupledValue("phase_variable"))
{
}

Real
PhaseDirichletBC::computeQpResidual()
{
  return _u[_qp] - _value* ((1.0 - _phase[_qp]) / 2.0);
}
