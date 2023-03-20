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
export CUDA_HOME=/usr/local/cuda-11.0
export AMBERHOME=/home/cuda/amber21-cuda11
export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64:/home/cuda/amber21-cuda11/lib:/opt/gridengine/lib/linux-x64:/opt/openmpi/lib:/opt/python/lib/
export PATH=/usr/local/cuda-11.0/bin:/home/cuda/amber21-cuda11/bin:/bin/opt/openmpi/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/bio/ncbi/bin:/opt/bio/mpiblast/bin:/opt/bio/EMBOSS/bin:/opt/bio/clustalw/bin:/opt/bio/tcoffee/bin:/opt/bio/hmmer/bin:/opt/bio/phylip/exe:/opt/bio/mrbayes:/opt/bio/fasta:/opt/bio/glimmer/bin:/opt/bio/glimmer/scripts:/opt/bio/gromacs/bin:/opt/bio/gmap/bin:/opt/bio/tigr/bin:/opt/bio/autodocksuite/bin:/opt/bio/wgs/bin:/opt/eclipse:/opt/ganglia/bin:/opt/ganglia/sbin:/usr/java/latest/bin:/opt/rocks/bin:/opt/rocks/sbin:/opt/condor/bin:/opt/condor/sbin:/opt/gridengine/bin/linux-x64

pdb_name=$1
cwrk=$(pwd)
echo $cwrk
job=run_larry_${pdb_name}_$$
wrk=/state/partition1/$job

if [ -d $wrk ]; then
   rm -rf $wrk
fi
mkdir $wrk

cp -a $cwrk/* $wrk
cd $wrk

pmemd=/home/cuda/amber21-cuda11/bin/pmemd.cuda_SPFP

echo "AMBERHOME = $AMBERHOME"
echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"
echo "HOSTNAME = $HOSTNAME"

echo "${pdb_name} job"

# Min1 step
echo "Min1 step begin!"
# Your Min1 step code here
${pmemd} \
	-O \
	-i 01_min.in \
	-p ${pdb_name}.prmtop \
	-c ${pdb_name}.inpcrd \
	-ref ${pdb_name}.inpcrd \
	-o ${pdb_name}_Min1.out \
	-r ${pdb_name}_Min1.rst
echo "Min1 step done!"

# Min2 step
echo "Min2 step begin!"
# Your Min2 step code here
${pmemd} \
        -O \
        -i 02_min.in \
        -p ${pdb_name}.prmtop \
        -c ${pdb_name}_Min1.rst \
        -o ${pdb_name}_Min2.out \
        -r ${pdb_name}_Min2.rst

echo "Min2 step done!"

# Heat step
echo "Heat step begin!"
# Your Heat step code here
${pmemd} \
        -O \
        -i 03_heat.in \
        -p ${pdb_name}.prmtop \
        -c ${pdb_name}_Min2.rst \
        -ref ${pdb_name}_Min2.rst \
        -o ${pdb_name}_Heat.out \
        -r ${pdb_name}_Heat.rst \
        -x ${pdb_name}_Heat.nc 

echo "Heat step done!"

# Equil step
echo "Equil step begin!"
# Your Equil step code here
${pmemd} \
        -O \
        -i 04_equil.in \
        -p ${pdb_name}.prmtop \
        -c ${pdb_name}_Heat.rst \
        -ref ${pdb_name}_Heat.rst \
        -o ${pdb_name}_Equil.out \
        -r ${pdb_name}_Equil.rst \
        -x ${pdb_name}_Equil.nc

echo "Equil step done!"

# Prod step
echo "Prod step begin!"
# Your Prod step code here
${pmemd} \
        -O \
        -i 05_prod.in \
        -p ${pdb_name}.prmtop \
        -c ${pdb_name}_Equil.rst \
        -o ${pdb_name}_Prod1.out \
        -r ${pdb_name}_Prod1.ncrst \
        -x ${pdb_name}_Prod1.nc 

echo "Prod step done!"

cp -a ${pdb_name}_* $cwrk
if [ -d $wrk ]; then
   rm -rf $wrk
fi

