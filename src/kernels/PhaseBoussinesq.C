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
  InputParameters params = validParams<Kernel>();
  params += validParams<PropertyUserObjectInterface>();

  //Required parameters
  params.addRequiredParam<unsigned>("component", "direction were solving for");

  // Coupled variables
  params.addRequiredCoupledVar("T", "Temperature");
  params.addRequiredCoupledVar("phase","variable containing the phase");

=======
  return params;
}

PhaseBoussinesq::PhaseBoussinesq(const std::string & name, InputParameters parameters) :
  Kernel(name, parameters),
  PropertyUserObjectInterface(name, parameters),

  // Coupled variables
  _T(coupledValue("T")),
  _phase(coupledValue("phase")),

  // Variable numberings
  _T_var_number(coupled("T")),
  _phase_var_number(coupled("phase")),

  // Parameters
  _alpha(_property_uo.getParam<Real>("thermal_expansion")),
  _rho(_property_uo.getParam<Real>("density_air")),
  _gravity(_property_uo.getParam<RealVectorValue>("gravity")),
  _component(getParam<unsigned>("component"))

{
}

Real PhaseBoussinesq::computeQpResidual()
{
  return -0.5 * (1.0-_phase[_qp])* _rho * (1.0 -  _alpha * (_T[_qp] - _T_ref) * _test[_i][_qp] * _gravity(_component));
}

Real PhaseBoussinesq::computeQpJacobian()
{

 return 0.0 ;
}

Real PhaseBoussinesq::computeQpOffDiagJacobian(unsigned jvar)
{
  if(jvar == _T_var_number)
    return -0.5 * (1.0-_phase[_qp])* _rho * (1.0 -  _alpha * _phi[_j][_qp] * _test[_i][_qp] * _gravity(_component));
  else if(jvar == _phase_var_number)
    return -0.5 * _phi[_j][_qp]* _rho * (1.0 -  _alpha * (_T[_qp]-_T_ref) * _test[_i][_qp] * _gravity(_component));
  else 
    return 0.0; 
}
