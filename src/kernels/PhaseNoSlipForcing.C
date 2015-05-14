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

  //Coupled Gradients
  _grad_phase(coupledGradient("phase")),

  // Variable numberings
  _phase_var_number(coupled("phase")),

  // Parameters
  _h(getParam<Real>("h")),
  _w_2(getMaterialProperty<Real>("interface_thickness_squared")),
  _xi(_property_uo.getParam<Real>("temporal_scaling")),
  _mu(_property_uo.getParam<Real>("dry_air_viscosity"))

{
}

Real PhaseNoSlipForcing::computeQpResidual()
{
    return _mu * _xi * 0.25 *_h * (1.0 - _phase[_qp] * _phase[_qp] ) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpJacobian()
{

    return _mu * _xi* 0.25 *_h * (1.0 - _phase[_qp] * _phase[_qp] ) * _phi[_j][_qp] * _test[_i][_qp] / _w_2[_qp];
}

Real PhaseNoSlipForcing::computeQpOffDiagJacobian(unsigned jvar)
{
  if(jvar == _phase_var_number)
  {
    return _mu * _xi* 0.25 *_h * _phi[_j][_qp] *  ( -2.0*_phase[_qp] ) * _u[_qp] * _test[_i][_qp] / _w_2[_qp];
  }

  else
    return 0.0; 
}
