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

#ifndef PHASEFORCING_H
#define PHASEFORCING_H

//MOOSE include
#include "Kernel.h"

//Pika Includs
#include "PropertyUserObjectInterface.h"
#include "CoefficientKernelInterface.h"
//Forward Declarations
class PhaseForcing;

template<>
InputParameters validParams<PhaseForcing>();

/**
 * PhaseForcing is a replacement for PhaseTransition kernel from the Phase field module
 * so that the Off Diagonals could be calculated.
 * The equation is the driving term on the phase-field equation represented by 
 * \lambda( u - u_eq) *( 1-\phi^2)^2 
 * where u is the chemical potential variable which has been substituted here for s to avoid confusion with 
 * the variable being solved.
 */

class PhaseForcing :
  public Kernel,
  public PropertyUserObjectInterface,
  public CoefficientKernelInterface
{
public:
  PhaseForcing(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

private:
  /**
   * Chemical potential variable representing available water vapor 
   * represented as u in the original documentation by Kaempfer and Plapp
   */
  VariableValue & _s;

  MaterialProperty<Real> & _s_eq;

  unsigned _s_var_number;

};
#endif // PHASEFORCING_H
