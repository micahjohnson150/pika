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

#ifndef PHASEMASS_H
#define PHASEMASS_H

// MOOSE includes
#include "INSMass.h"

// Pika includes
#include "PropertyUserObjectInterface.h"
#include "CoefficientKernelInterface.h"

//Forward Declarations
class PhaseMass;

template<>
InputParameters validParams<PhaseMass>();

/**
 * A coefficient diffusion Kernel
 *
 * This Kernel allows to a coefficient to be applied to the diffusion term, that
 * coefficient may be either a scalar value or a scalar material property.
 *
 * This Kernel includes the ability to scale and offset the coefficient. The
 * coefficient (material or scalar) is applied as:
 *     (scale * coefficient + offset) * div(coefficient \nabla u)
 *
 * Also, include the ability to toggle the additional temporal scaling parameter (\xi)
 * as defined by Kaempfer and Plapp (2009). This temporal scalling is applied in
 * additions to the coefficient scaling:
 *     xi * (scale * coefficient + offset) * div(coefficient \nabla u)
 */
class PhaseMass :
  public INSMass
{
public:

  /**
   * Class constructor
   */
  PhaseMass(const std::string & name, InputParameters parameters);

protected:

  /**
   * Compute residual
   * Utilizes INSMass::computeQpResidual with phase dependency added

   */
  virtual Real computeQpResidual();

  /**
   * Compute Jacobian
   * Utilizes INSMass::computeQpJacobian with phase dependency added
   */
  virtual Real computeQpJacobian();

 /**
   * Compute off diagonal jacobian
   * Utilizes INSMass::computeQpOffDiagJacobian  with phase dependency added
   */


  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  VariableValue& _phase;
  unsigned _phase_var_number;

};

#endif //PHASEMASS
