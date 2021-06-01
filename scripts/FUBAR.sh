#!/bin/bash
#PBS -N FEL
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc FUBAR.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}

HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"
FUBAR="FUBAR"
NP=8

echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $FUBAR --alignment $FASTA --tree $TREE --grid 50 --chains 10 --chain-length 10000000 --burn-in 1000000
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $FUBAR --alignment $FASTA --tree $TREE --grid 50 --chains 10 --chain-length 10000000 --burn-in 1000000

exit 0
