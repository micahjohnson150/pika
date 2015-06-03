#!/bin/bash
#PBS -N <JOB_NAME>
#PBS -l select=<CHUNKS>:ncpus=<NCPUS_PER_CHUNK>:mpiprocs=<MPI_PROCS_PER_CHUNK>
#PBS -l place=<PLACE>
#PBS -l walltime=<WALLTIME>
<NOTIFICATIONS>
<NOTIFY_ADDRESS>
<SOFT_LINK1>
<QUEUE>
<COMBINE_STREAMS>

module load openmpi/gcc/64/1.6.5
module load moose/gcc/64/3.0.1
module load pbspro

cd $PBS_O_WORKDIR

JOB_NUM=${PBS_JOBID%\.*}
<SOFT_LINK2>

export MV2_ENABLE_AFFINITY=0

mpirun <MOOSE_APPLICATION> -i <INPUT_FILE> <THREADS> <CLI_ARGS>

<SOFT_LINK3>
