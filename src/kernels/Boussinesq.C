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

#include "Boussinesq.h"

template<>
InputParameters validParams<Boussinesq>()
{
  InputParameters params = validParams<Kernel>();
  params += validParams<PropertyUserObjectInterface>();

  //Required parameters
  params.addRequiredParam<unsigned>("component", "direction were solving for");

  // Coupled variables
  params.addRequiredCoupledVar("T", "Temperature");
  return params;
}

Boussinesq::Boussinesq(const std::string & name, InputParameters parameters) :
  Kernel(name, parameters),
  PropertyUserObjectInterface(name, parameters),

  // Coupled variables
  _T(coupledValue("T")),

  // Variable numberings
  _T_var_number(coupled("T")),

  // Parameters
  _alpha(_property_uo.getParam<Real>("thermal_expansion")),
  _rho(_property_uo.getParam<Real>("density_air")),
  _gravity(_property_uo.getParam<RealVectorValue>("gravity")),
  _xi(_property_uo.getParam<Real>("temporal_scaling")),
 // _xi(1.0),
  _component(getParam<unsigned>("component"))

{
}

Real Boussinesq::computeQpResidual()
{
  //return  -_xi * _rho * 0.5 * (1.0 - _phase[_qp]) * (1.0 -  _alpha * (_T[_qp] - _T_ref)) * _test[_i][_qp] * _gravity(_component);
  return  -_xi * _rho * 0.5  * (1.0 -  _alpha * (_T[_qp] - _T_ref)) * _test[_i][_qp] * _gravity(_component);
}

Real Boussinesq::computeQpJacobian()
{
 return 0.0;
}

Real Boussinesq::computeQpOffDiagJacobian(unsigned jvar)
{
  if(jvar == _T_var_number)
  { //return  -_xi * _rho * 0.5 * (1.0 - _phase[_qp]) * ( -  _alpha * _phi[_j][_qp]) * _test[_i][_qp] * _gravity(_component);
    return  -_xi * _rho * ( -  _alpha * _phi[_j][_qp]) * _test[_i][_qp] * _gravity(_component);
  }
/*
  else if(jvar == _phase_var_number)
    return  _xi * _rho * 0.5 * (- _phi[_j][_qp]) * (1.0 -  _alpha * (_T[_qp] - _T_ref)) * _test[_i][_qp] * _gravity(_component);
*/
  else 
    return 0.0; 
}
