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

#ifndef PHASETIMEDERIVATIVE_H
#define PHASETIMEDERIVATIVE_H

// MOOSE includes
#include "TimeDerivative.h"

// Pika includes
#include "PropertyUserObjectInterface.h"
#include "CoefficientKernelInterface.h"

//Forward Declarations
class PhaseTimeDerivative;

template<>
InputParameters validParams<PhaseTimeDerivative>();

class PhaseTimeDerivative :
  public TimeDerivative,
  public PropertyUserObjectInterface
{
public:

  /**
   * Class constructor
   */
  PhaseTimeDerivative(const std::string & name, InputParameters parameters);

protected:

  /**
   * Compute residual
   * Utilizes TimeDerivative::computeQpResidual with phase dependency added
   */

  virtual Real computeQpResidual();

  /**
   * Compute Jacobian
   * Utilizes TimeDerivative::computeQpJacobian with phase dependency added
   */
  virtual Real computeQpJacobian();

 /**
   * Compute off diagonal jacobian
   * Utilizes TimeDerivative::computeQpOffDiagJacobian  with phase dependency added
   */


  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  VariableValue& _phase;
  unsigned _phase_var_number;
  Real _rho;

};

#endif //PHASETIMEDERIVATIVE
