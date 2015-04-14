#include "PhaseNoSlipForcing.h"

template<>
InputParameters validParams<PhaseNoSlipForcing>()
{
  InputParameters params = validParams<Kernel>();
  params += validParams<PropertyUserObjectInterface>();

  // Coupled variables
  params.addRequiredCoupledVar("phase","variable containing the phase");

  //Coefficients
  params.addParam<Real>("h",2.757,"This value helps enforce the no slip condition, caution: instability can occur if too large.");

  return params;
}

PhaseNoSlipForcing::PhaseNoSlipForcing(const std::string & name, InputParameters parameters) :
  Kernel(name, parameters),
  PropertyUserObjectInterface(name, parameters),

  // Coupled variables
  _phase(coupledValue("phase")),

  // Variable numberings
  _phase_var_number(coupled("phase")),

  // Parameters
  //_a(getParam<Real>("coefficient")),
  _h(getParam<Real>("h")),
//  _rho(getParam<Real>("rho"))
  _w_2(getMaterialProperty<Real>("interface_thickness_squared")),
  _mu(_property_uo.getParam<Real>("dry_air_viscosity"))

{
}

Real PhaseNoSlipForcing::computeQpResidual()
{
    //return _mu * 0.125 *_h * (1.0 + _phase[_qp] - _phase[_qp] * _phase[_qp] - _phase[_qp] * _phase[_qp] * _phase[_qp]) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];
  //return _mu * 0.125 *_h * std::pow(1.0 - _phase[_qp]*_phase[_qp],2.0) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];
    return -_mu * 0.125 *_h * std::pow(1.0 + _phase[_qp],2.0) * (1.0 - _phase[_qp]) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpJacobian()
{
  return 0.0;
//  return _mu * 0.125 *_h * (1.0 + _phase[_qp] - _phase[_qp] * _phase[_qp] - _phase[_qp] * _phase[_qp] * _phase[_qp]) * _phi[_j][_qp] * _test[_i][_qp] / _w_2[_qp];
//  return _mu * 0.125 *_h * std::pow(1.0 - _phase[_qp]*_phase[_qp],2.0) * _phi[_j][_qp] * _test[_i][_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpOffDiagJacobian(unsigned jvar)
{
/*  if(jvar == _phase_var_number)
    return _mu * 0.125 *_h * (1.0 + _phi[_j][_qp] - 2.0 * _phase[_qp] - 3.0 *  _phase[_qp] * _phase[_qp]) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];

  else */
    return 0.0; 
}
