#!/bin/bash
#PBS -N CONV_W_PHASE_001
#PBS -l select=2:ncpus=15:mpiprocs=15
#PBS -l place=scatter:excl
#PBS -l walltime=10:00:00

#PBS -M micahjohnson1@u.boisetstate.edu

#PBS -q MRI


source /etc/profile.d/modules.sh
module load moose-dev-gcc

cd $PBS_O_WORKDIR

JOB_NUM=${PBS_JOBID%\.*}


export MV2_ENABLE_AFFINITY=0

mpiexec /home/mjohnson/projects/pika/pika-opt -i convection_w_phase.i  


