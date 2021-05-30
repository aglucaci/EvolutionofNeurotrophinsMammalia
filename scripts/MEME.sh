#!/bin/bash
#PBS -N MEME
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc MEME.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}

HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"
MEME="MEME"
NP=8

echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $MEME --alignment $FASTA --tree $TREE
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $MEME --alignment $FASTA --tree $TREE

exit 0
