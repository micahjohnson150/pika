#ifndef PIKAMOMENTUM_H
#define PIKAMOMENTUM_H

#include "Kernel.h"
#include "PropertyUserObjectInterface.h"

// Forward Declarations
class PikaMomentum;

template<>
InputParameters validParams<PikaMomentum>();

/**
 * This class computes momentum equation residual and Jacobian
 * contributions for the incompressible Navier-Stokes momentum
 * equation.
 */
class PikaMomentum : public Kernel,
                     public PropertyUserObjectInterface
{
public:
  PikaMomentum(const std::string & name, InputParameters parameters);

  virtual ~PikaMomentum(){}

protected:
  virtual Real Convective();
  virtual Real Pressure();
  virtual Real Viscous();
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  // Coupled variables
  VariableValue& _u_vel;
  VariableValue& _v_vel;
  VariableValue& _w_vel;
  VariableValue& _p;
  VariableValue& _phase;

  // Gradients
  VariableGradient& _grad_u_vel;
  VariableGradient& _grad_v_vel;
  VariableGradient& _grad_w_vel;
  VariableGradient& _grad_phase;

  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;
  unsigned _p_var_number;
  unsigned _phase_var_number;

  Real _mu;
  Real _rho;
  RealVectorValue _gravity;

  // Parameters
  unsigned _component;
  Real _xi;
};


#endif // PIKAMOMENTUM_H
