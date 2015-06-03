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

#ifndef PHASENOSLIPBC_H
#define PHASENOSLIP_H

// MOOSE includes
#include "NodalBC.h"

//Forward Declarations
class PhaseNoSlipBC;

template<>
InputParameters validParams<PhaseNoSlipBC>();

/**
 * No slip condition for the entire domain
 *   velocity = 0 when phi= 1
 */
class PhaseNoSlipBC :
  public NodalBC
{
public:
  PhaseNoSlipBC(const std::string & name, InputParameters parameters);
  virtual ~PhaseNoSlipBC(){};

protected:

  /**
   * Computes the No slip as a function of the phase boundary condition
   */
  virtual Real computeQpResidual();

private:


  /// Coupled phase-field variable
  VariableValue & _phase;

  /// Coupled velocity variables
  VariableValue & _u_vel;

  VariableValue & _v_vel;

  VariableValue & _w_vel;
};

#endif // PHASENOSLIPBC_H
