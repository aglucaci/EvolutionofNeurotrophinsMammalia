#!/bin/bash
#PBS -N MACSEv2

JAVA="/usr/bin/java"
MACSE=/home/aglucaci/EvolutionofNeurotrophinsMammalia/scripts/macse_v2.05.jar

echo $JAVA -jar $MACSE -prog alignSequences -seq $FASTA -out_NT $FASTA"_codon_macse.fas" -out_AA $FASTA"_AA_macse.fas"
$JAVA -jar $MACSE -prog alignSequences -seq $FASTA -out_NT $FASTA"_codon_aln.fas" -out_AA $FASTA"_AA_macse.fas"

exit 0
