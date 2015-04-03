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
//  params.addParam<Real>("coefficient",1e5,"This value enforces the no slip condition by being very large, caution: instability can occur if too large.");
//  params.addParam<Real>("rho",1,"fluid density");
  params.addParam<Real>("mu",1,"dyanamic viscosity");

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
  _mu(getParam<Real>("h"))

{
}

Real PhaseNoSlipForcing::computeQpResidual()
{
  return  _mu * 0.25 * (1.0 - (_phase[_qp] *  _phase[_qp])) * _h * _u[_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpJacobian()
{

 //return -0.5 * (1.0-_phase[_qp])* _rho * _alpha * _phi[_j][_qp] * _test[_i][_qp] * _gravity(_component);
  return _mu * 0.25 * (1.0 - _phase[_qp] *  _phase[_qp]) * _h * _phi[_j][_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpOffDiagJacobian(unsigned jvar)
{
  if(jvar == _phase_var_number)
    return - _mu * 0.5 *  _phase[_qp] * _h * _u[_qp] / _w_2[_qp];
  else
    return 0.0; 
}
