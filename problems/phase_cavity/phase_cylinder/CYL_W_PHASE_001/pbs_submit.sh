#!/bin/bash
#PBS -N CYL_W_PHASE_001
#PBS -l select=2:ncpus=8:mpiprocs=8
#PBS -l place=scatter:excl
#PBS -l walltime=5:00:00

#PBS -M micahjohnson1@u.boisetstate.edu

#PBS -q MRI


source /etc/profile.d/modules.sh
module load moose-dev-gcc

cd $PBS_O_WORKDIR

JOB_NUM=${PBS_JOBID%\.*}


export MV2_ENABLE_AFFINITY=0

mpiexec /home/mjohnson/projects/pika/pika-opt -i cylinder_w_phase.i  


