#!/bin/bash
#PBS -N BUSTEDS
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc BUSTEDS.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}


HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"

# Batch file is actually BUSTED.bf, but pass in srv boolean
BUSTEDS="BUSTED"
NP=8


echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $BUSTEDS --srv Yes --alignment $FASTA --tree $TREE --output $FASTA".BUSTEDS.json"
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $BUSTEDS --srv Yes --alignment $FASTA --tree $TREE --output $FASTA".BUSTEDS.json"

exit 0
