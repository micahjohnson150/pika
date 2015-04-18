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

#ifndef PIKACONVECTION_H
#define PIKACONVECTION_H

// MOOSE includes
#include "Kernel.h"

// Pika includes
#include "PropertyUserObjectInterface.h"
#include "CoefficientKernelInterface.h"

//Forward Declarations
class PikaConvection;

template<>
InputParameters validParams<PikaConvection>();

/**
 * A  phase dependent convection Kernel
 * Defined as: 
 *
 * 0.5 * (1 - phi) * grad_u * test
 *
 */
class PikaConvection :
  public Kernel,
  public PropertyUserObjectInterface,
  public CoefficientKernelInterface
{
public:

  /**
   * Class constructor
   */
  PikaConvection(const std::string & name, InputParameters parameters);

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

  // Coupled variables
  VariableValue& _u_vel;
  VariableValue& _v_vel;
  VariableValue& _w_vel;
  
  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;

  VariableValue& _phase;
  unsigned _phase_var_number;

};

#endif //PIKACONVECTION_H
