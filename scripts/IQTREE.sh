#!/bin/bash
#PBS -N IQTREE

# FASTA variable is passed to the bash script via qsub -v
IQTREE="/opt/iqtree/iqtree-1.6.6-Linux/bin/iqtree"
NP=16

#echo $IQTREE -v -s $FASTA -st CODON -nt AUTO -m GTR+I+G -nt $NP
#$IQTREE -v -s $FASTA -st CODON -nt AUTO -m GTR+I+G -nt $NP
OUTPUT_IQTREE="$FASTA".treefile
echo "# Checking for $OUTPUT_IQTREE"

if [ ! -s $OUTPUT_IQTREE ]; 
then
   echo $IQTREE -s $FASTA -nt $NP -alrt 1000 -bb 1000
   $IQTREE -s $FASTA -nt $NP -alrt 1000 -bb 1000
fi

exit 0
