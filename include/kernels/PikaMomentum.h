#ifndef PIKAMOMENTUM_H
#define PIKAMOMENTUM_H

#include "Kernel.h"
#include "PropertyUserObjectInterface.h"

// Forward Declarations
class PikaMomentum;

template<>
InputParameters validParams<PikaMomentum>();

/**
 * This class computes the momentum equation for a multiphase continuous domain
 * which best correspond to the Newtonian, incompressible form of the Navier-Stokes momentum
 * equation. The Kernel is highly coupled with the phase-field variable \phi.
 * Where \phi=1 (solid typically ice for Pika) and phi=-1 (vapor in Pika) 
 * to compute flow only in the one side of the phase. This is accomplished by adding 
 * (1-\phi/2) to every term.
 */
class PikaMomentum : public Kernel,
                     public PropertyUserObjectInterface
{
public:
  PikaMomentum(const std::string & name, InputParameters parameters);

  virtual ~PikaMomentum(){}

protected:
  /**
   * Calculates the Convective acceleration portion of the equation
   * \rho * 0.5 * (1-\phi) * (\vec{v} \cdot \nabla u) \psi
   * where u is the velocity component selected
   */
  virtual Real Convective();

  /**
   * Calculates the pressure term
   * 0.5 *(1- \phi) *  p * \nabla \psi 
   * where \psi is the test function
   */
  virtual Real Pressure();

  /**
   * Calculates the viscous term of the momentum equation.
   * -\mu * \nabla^{2}(0.5*( 1-\phi) * u) \psi
   *  Using the divergence theorem becomes:
   *  -\mu * \nabla (0.5*( 1-\phi) * u) \nabla \psi
   *  Using the product rule becomes:
   *  \mu * 0.5 ( - \nabla \phi * u + \nabla u * (1- \phi)) \cdot \nabla \psi
   */
  virtual Real Viscous();
  /**
   * Computes the Residual for the momentum portion of the navier stokes equations
   * by calling convective()+pressure()+viscous()
   */
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  /**
   *  All Coupled variables
   */
  VariableValue& _u_vel;
  VariableValue& _v_vel;
  VariableValue& _w_vel;
  VariableValue& _p;
  VariableValue& _phase;

  /** 
   * Gradients
   */
  VariableGradient& _grad_p;
  VariableGradient& _grad_phase;

  /**
   * Variable numberings for identifying which part of the jacobian to compute
   */
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;
  unsigned _p_var_number;
  unsigned _phase_var_number;

/** 
 * Constant Values required for computations.
 * Note rho is not entered but taken from the user object value store/set in Pika Material dry air density.
 */
  Real _mu;
  Real _rho;

  unsigned _component;
  Real _xi;
};

#endif // PIKAMOMENTUM_H
