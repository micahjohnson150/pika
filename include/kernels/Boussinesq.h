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

#ifndef PHASEBOUSSINESQ_H
#define PHASEBOUSSINESQ_H

//Moose Includes
#include "Kernel.h"

//Pika Includes
#include "PropertyUserObjectInterface.h"

// Forward Declarations
class Boussinesq;

template<>
InputParameters validParams<Boussinesq>();

/**
 * Computes a one sided, phase dependent buoyancy based
 * forcing term for the Navier Stokes Equations in PikaMomentum
 */
class Boussinesq : 
    public Kernel,
    public PropertyUserObjectInterface
{
public:
  Boussinesq(const std::string & name, InputParameters parameters);

  virtual ~Boussinesq(){}

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
  Real _xi;
  unsigned _component;
};
#endif // PHASEBOUSSINESQ_H
