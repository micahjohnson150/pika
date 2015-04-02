#include "PhaseNoSlipForcing.h"

template<>
InputParameters validParams<PhaseNoSlipForcing>()
{
  InputParameters params = validParams<Kernel>();
//  params += validParams<PropertyUserObjectInterface>();

  // Coupled variables
  params.addRequiredCoupledVar("phase","variable containing the phase");

  //Coefficients
  params.addParam<Real>("coefficient",1e5,"This value enforces the no slip condition by being very large, caution: instability can occur if too large.");
  params.addParam<Real>("rho",1,"fluid density");

  return params;
}

PhaseNoSlipForcing::PhaseNoSlipForcing(const std::string & name, InputParameters parameters) :
  Kernel(name, parameters),
 // PropertyUserObjectInterface(name, parameters),

  // Coupled variables
  _phase(coupledValue("phase")),

  // Variable numberings
  _phase_var_number(coupled("phase")),

  // Parameters
  _a(getParam<Real>("coefficient")),
  _rho(getParam<Real>("rho"))
  //_rho(_property_uo.equilibriumWaterVaporConcentrationAtSaturationAtReferenceTemperature())

{
}

Real PhaseNoSlipForcing::computeQpResidual()
{
  return _rho * 0.5*(1.0 + _phase[_qp]) * _a * _u[_qp];
}

Real PhaseNoSlipForcing::computeQpJacobian()
{

 //return -0.5 * (1.0-_phase[_qp])* _rho * _alpha * _phi[_j][_qp] * _test[_i][_qp] * _gravity(_component);
  return 0.0 ;
}

Real PhaseNoSlipForcing::computeQpOffDiagJacobian(unsigned jvar)
{
/* if(jvar == _T_var_number)
    return -0.5 * (1.0-_phase[_qp])* _rho * (1.0 -  _alpha * _phi[_j][_qp] * _test[_i][_qp] * _gravity(_component));
  else if(jvar == _phase_var_number)
    return -0.5 * _phi[_j][_qp]* _rho * (1.0 -  _alpha * (_T[_qp]-_T_ref) * _test[_i][_qp] * _gravity(_component));
  else */
    return 0.0; 
}
