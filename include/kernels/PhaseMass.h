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
#include "Kernel.h"

//Forward Declarations
class PhaseMass;

template<>
InputParameters validParams<PhaseMass>();

/**
 * div[ ((1-phase) / 2.0 ) * vec{v} ]
 *
 * Incompressible mass conservation for one sided momentum equations 
 */
class PhaseMass :
  public Kernel
{
public:

  /**
   * Class constructor
   */
  PhaseMass(const std::string & name, InputParameters parameters);

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
  //Coupled Variables
  VariableValue& _u_vel;
  VariableValue& _v_vel;
  VariableValue& _w_vel;
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
  unsigned _phase_var_number;

};

#endif //PHASEMASS
