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

#include "PhaseForcing.h"

template<>
InputParameters validParams<PhaseForcing>()
{
  InputParameters params = validParams<Kernel>();
  params += validParams<PropertyUserObjectInterface>();
  params += validParams<CoefficientKernelInterface>();

  params.addRequiredCoupledVar("chemical_potential", "The chemical potential variable to couple");
  params.addParam<std::string>("equilibrium_chemical_potential", "equilibrium_chemical_potential", "The name of the material property containing the equilibrium concentration");

  return params;
}

PhaseForcing::PhaseForcing(const std::string & name, InputParameters parameters) :
    Kernel(name, parameters),
    PropertyUserObjectInterface(name,parameters),
    CoefficientKernelInterface(name,parameters),

    _s(coupledValue("chemical_potential")),
    _s_eq(getMaterialProperty<Real>(getParam<std::string>("equilibrium_chemical_potential"))),
    //Numbering
    _s_var_number(coupled("chemical_potential"))

{
  if (useMaterial())
        setMaterialPropertyPointer(&getMaterialProperty<Real>(getParam<std::string>("property")));
}

Real
PhaseForcing::computeQpResidual()
{
  return - coefficient(_qp) * (_s[_qp] - _s_eq[_qp]) * (1.0 - _u[_qp]*_u[_qp])*(1.0 - _u[_qp]*_u[_qp]) * _test[_i][_qp];
}

Real
PhaseForcing::computeQpJacobian()
{
  return - coefficient(_qp) * (_s[_qp] - _s_eq[_qp]) * (4.0*_u[_qp] * _u[_qp] * _u[_qp] - 4.0 * _u[_qp]) * _phi[_j][_qp] * _test[_i][_qp];
}

Real
PhaseForcing::computeQpOffDiagJacobian(unsigned jvar)
{
  if (jvar == _s_var_number )
    return - coefficient(_qp) * _phi[_j][_qp] * (1.0 - _u[_qp]*_u[_qp])*(1.0 - _u[_qp]*_u[_qp]) * _test[_i][_qp];

else 
  return 0.0;

}
