#!/bin/bash
#PBS -N FitMultiModel
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc BUSTEDSMH.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}

HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"
BUSTEDSMH=/home/aglucaci/hyphy-analyses/BUSTED-MH/BUSTED-MH.bf
NP=8

echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $BUSTEDSMH --alignment $FASTA --tree $TREE --output $FASTA".BUSTEDSMH.json"
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $BUSTEDSMH --alignment $FASTA --tree $TREE --output $FASTA".BUSTEDSMH.json"

exit 0
