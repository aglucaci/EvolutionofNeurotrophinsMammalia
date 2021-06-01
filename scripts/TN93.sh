#!/bin/bash
#PBS -N TN93

#FASTA=$1
TN93="/home/aglucaci/tn93/tn93"
$TN93 -t 1 -o $FASTA".dst" $FASTA
exit 0
