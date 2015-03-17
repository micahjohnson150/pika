#ifndef PHASEBOUSSINESQ_H
#define PHASEBOUSSINESQ_H

//Moose Includes
#include "Kernel.h"

//Pika Includes
#include "PropertyUserObjectInterface.h"

// Forward Declarations
class PhaseBoussinesq;

template<>
InputParameters validParams<PhaseBoussinesq>();

/**
 * Computes a one sided, phase dependent buoyancy based
 * forcing term for the Navier Stokes Equations in PikaMomentum
 */
class PhaseBoussinesq : 
    public Kernel,
    public PropertyUserObjectInterface
{
public:
  PhaseBoussinesq(const std::string & name, InputParameters parameters);

  virtual ~PhaseBoussinesq(){}

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  // Coupled variables
  VariableValue& _T;
  VariableValue& _phase;
  unsigned _T_var_number;
  unsigned _phase_var_number;

  Real _T_ref;
  Real _alpha;
  Real _rho;
  RealVectorValue _gravity;
  unsigned _component;
};
#endif // PHASEBOUSSINESQ_H
