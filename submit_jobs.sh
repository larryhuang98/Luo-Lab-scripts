#!/bin/bash

# To tell the system I'm using a shell script
# #$ -S /bin/sh

# The cuda jobs should be sent to the all.q queue
#$ -l hostname=gpu-0-0|gpu-0-1|gpu-0-2|gpu-0-3|gpu-0-4|gpu-0-5|gpu-0-6|gpu-0-7|gpu-0-8|gpu-0-9|gpu-1-0
# Will send email when job ends or aborts
#$ -m ea
#$ -M zhenh7@uci.edu

# Export these environmental variables
#$ -v CUDA_HOME=/usr/local/cuda-11.0/,AMBERHOME=/home/cuda/amber21-cuda11
#$ -v LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64:/home/cuda/amber21-cuda11/lib:/opt/gridengine/lib/linux-x64:/opt/openmpi/lib:/opt/python/lib/
#$ -v PATH=/usr/local/cuda-11.0/bin:/home/cuda/amber21-cuda11/bin:/bin/opt/openmpi/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/bio/ncbi/bin:/opt/bio/mpiblast/bin:/opt/bio/EMBOSS/bin:/opt/bio/clustalw/bin:/opt/bio/tcoffee/bin:/opt/bio/hmmer/bin:/opt/bio/phylip/exe:/opt/bio/mrbayes:/opt/bio/fasta:/opt/bio/glimmer/bin:/opt/bio/glimmer/scripts:/opt/bio/gromacs/bin:/opt/bio/gmap/bin:/opt/bio/tigr/bin:/opt/bio/autodocksuite/bin:/opt/bio/wgs/bin:/opt/eclipse:/opt/ganglia/bin:/opt/ganglia/sbin:/usr/java/latest/bin:/opt/rocks/bin:/opt/rocks/sbin:/opt/condor/bin:/opt/condor/sbin:/opt/gridengine/bin/linux-x64


# The job is located in the current working directory.
#$ -cwd

# Set name of the job. This you will see when you use qstat (Change here)
#$ -N run_larry

pdb_names=("wt.1.wat" "wt.2.wat" "wt.3.wat")

for pdb_name in "${pdb_names[@]}"; do
  qsub -N "run_${pdb_name}" -V -j y -o "run_${pdb_name}.log" -l hostname='gpu-0-[0-9]|gpu-1-[0-2]|gpu-1-[7-9]|gpu-2-[0-3]' ./run_steps.sh ${pdb_name} &
done

wait

