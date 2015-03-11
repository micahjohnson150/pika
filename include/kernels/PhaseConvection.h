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

#ifndef PHASECONVECTION_H
#define PHASECONVECTION_H

// MOOSE includes
#include "Kernel.h"

// Pika includes
#include "PropertyUserObjectInterface.h"

//Forward Declarations
class PhaseConvection;

template<>
InputParameters validParams<PhaseConvection>();

/**
 * A convection Kernel
 *
 */
class PhaseConvection :
  public Kernel,
  public PropertyUserObjectInterface
{
public:

  /**
   * Class constructor
   */
  PhaseConvection(const std::string & name, InputParameters parameters);

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
  Real _rho;
  Real _xi;

};

#endif //MATDIFFUSION_H
