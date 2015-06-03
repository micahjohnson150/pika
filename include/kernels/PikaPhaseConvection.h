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

#ifndef PIKAPHASECONVECTION_H
#define PIKAPHASECONVECTION_H

// MOOSE includes
#include "PikaConvection.h"

// Pika includes
#include "PropertyUserObjectInterface.h"
#include "CoefficientKernelInterface.h"

//Forward Declarations
class PikaPhaseConvection;

template<>
InputParameters validParams<PikaPhaseConvection>();

/**
 * A  phase dependent convection Kernel
 * Defined as: 
 *
 *  0.5 (1-\phi) * V \cdot grad_u * \psi
 *
 */
class PikaPhaseConvection :
  public PikaConvection
{
public:

  /**
   * Class constructor
   */
  PikaPhaseConvection(const std::string & name, InputParameters parameters);

protected:

  /**
   * Compute residual
   */
  virtual Real computeQpResidual();

  /**
   * Compute Jacobian
   */
  virtual Real computeQpJacobian();

 /**
   * Compute off diagonal jacobian
   */
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  /// Coupled variables
  VariableValue& _phase;
  
  /// Variable numberings
  unsigned _phase_var_number;
};

#endif //PIKAPHASECONVECTION_H
