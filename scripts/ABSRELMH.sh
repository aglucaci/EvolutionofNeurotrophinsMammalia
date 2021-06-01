#!/bin/bash
#PBS -N ABSREL
#PBS -l walltime=999:00:00
#@ Usage: qsub -V -l nodes=1:ppn=8 -q epyc ABSRELMH.sh -v FASTA={CODON_AWARE_MSA},TREE={TREE_NEWICK}


HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
RES="/home/aglucaci/hyphy-develop/res"
ABSREL="ABSREL"
NP=8


echo mpirun --np $NP $HYPHYMPI LIBPATH=$RES $ABSREL --alignment $FASTA --tree $TREE --multiple-hits Double+Triple --output "$FASTA".ABSRELMH.json
mpirun --np $NP $HYPHYMPI LIBPATH=$RES $ABSREL --alignment $FASTA --tree $TREE --multiple-hits Double+Triple --output "$FASTA".ABSRELMH.json

exit 0
