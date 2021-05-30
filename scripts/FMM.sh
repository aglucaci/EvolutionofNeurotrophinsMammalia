#!/bin/bash
#PBS -N FitMultiModel
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc FMM.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}

HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"
FMM="/home/aglucaci/hyphy-analyses/FitMultiModel/FitMultiModel.bf"
NP=8

echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $FMM --alignment $FASTA --tree $TREE --output $FASTA".FMM.json"
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $FMM --alignment $FASTA --tree $TREE --output $FASTA".FMM.json"

exit 0
