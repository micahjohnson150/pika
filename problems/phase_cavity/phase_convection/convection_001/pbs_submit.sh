#!/bin/bash
#PBS -N convection_001
#PBS -l select=3:ncpus=8:mpiprocs=8
#PBS -l place=scatter:excl
#PBS -l walltime=100:00:00

#PBS -M micahjohnson1@u.boisestate.edu

#PBS -q MRI


module load openmpi/gcc/64/1.6.5
module load moose/gcc/64/3.0.1
module load pbspro

cd $PBS_O_WORKDIR

JOB_NUM=${PBS_JOBID%\.*}


export MV2_ENABLE_AFFINITY=0

mpirun /home/mjohnson/projects/pika/pika-opt -i convection_w_phase.i  


