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

#ifndef PHASEDIRICHLET
#define PHASEDIRICHLET

// MOOSE includes
#include "DirichletBC.h"

// PIKA includes
#include "PropertyUserObjectInterface.h"

//Forward Declarations
class PhaseDirichletBC;

template<>
InputParameters validParams<PhaseDirichletBC>();

/**
 * Phase dependent boundary conditions
 *   u - value (1 - phi)/2
 */
class PhaseDirichletBC :
  public DirichletBC,
  public PropertyUserObjectInterface
{
public:
  PhaseDirichletBC(const std::string & name, InputParameters parameters);
  virtual ~PhaseDirichletBC(){};

protected:

  /**
   * Computes the dirichlet boundary condition for phi = -1
   */
  virtual Real computeQpResidual();

private:

  /// Coupled phase-field variable
  VariableValue & _phase;
};

#endif // PHASEDIRICHLET
