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

#ifndef PIKAMOMENTUM_H
#define PIKAMOMENTUM_H

// MOOSE includes
#include "INSMomentum.h"

//Forward Declarations
class PikaMomentum;

template<>
InputParameters validParams<PikaMomentum>();

/**
 */
class PikaMomentum :
  public INSMomentum,
{
public:

  /**
   * Class constructor
   */
  PikaMomentum(const std::string & name, InputParameters parameters);

protected:

  /**
   * Compute residual
   * Utilizes INSMomentum::computeQpResidual with applied coefficients and scaling
   */
  virtual Real computeQpResidual();

  /**
   * Compute residual
   * Utilizes INSMomentum::computeQpJacobian with applied coefficients and scaling
   */
  virtual Real computeQpJacobian();
  const VariableValue & _phi;

};

#endif //PIKAMOMENTUM_H
