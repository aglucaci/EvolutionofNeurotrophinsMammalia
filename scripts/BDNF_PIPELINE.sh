#!/bin/bash

# Updated for 2021 analysis, Comparative evolution of neurotrophins
# v0.03 Is used for clade analysis on Mammalia. In light of new literature.
#@Usage on hpc: bash BDNF_PIPELINE.sh

now=$(date)
echo "## Starting Mammalia pipeline: "$now
echo ""

# User configuration here
#BASEDIR=/home/aglucaci/EvolutionOfNeurotrophins/MAMMALIA/EvolutionOfNeurotrophins
BASEDIR=/home/aglucaci/EvolutionofNeurotrophinsMammalia
cd $BASEDIR
mkdir -p "$BASEDIR"/results

# ######################################################
# Software Requirements -- create separate scripts, requirements.txt
# ######################################################
# HyPhy, installed via conda version 2.5.31
#wget -O macse_v2.05.jar  https://bioweb.supagro.inra.fr/macse/releases/macse_v2.05.jar

HYPHY="/home/aglucaci/hyphy-develop/HYPHYMPI"
PYTHON="/home/aglucaci/anaconda3/bin/python3.7"
IQTREE="/opt/iqtree/iqtree-1.6.6-Linux/bin/iqtree"
JAVA="/usr/bin/java"

# ######################################################
# Custom Scripts
# ######################################################
CODON_SCRIPT="$BASEDIR"/scripts/codons.py
MACSE_SCRIPT="$BASEDIR"/scripts/MACSEv2.sh
IQTREE_SCRIPT="$BASEDIR"/scripts/IQTREE.sh
TN93_SCRIPT="$BASEDIR"/scripts/TN93.sh

# ######################################################
# Get codons
# ######################################################
# Uses protein file and transcript to get the CDS.
# output 'BDNF_codons.fasta' is unaligned.
OUTPUT_CODONS_PY="$BASEDIR"/results/BDNF_codons.fasta
if [ -s $OUTPUT_CODONS_PY ]; then
    echo "# Get codons from transcript + protein fasta -- complete"
else
    #echo "## Step 1  # Get codons from transcript + protein fasta"
    #echo $PYTHON -W ignore $CODON_SCRIPT $BASEDIR/data/refseq_protein.fasta $BASEDIR/data/refseq_transcript.fasta $BASEDIR/analysis/BDNF_codons.fasta > $BASEDIR/scripts/codon.py_errors.txt
    echo $PYTHON -W ignore $CODON_SCRIPT $BASEDIR/data/refseq_protein.fasta $BASEDIR/data/refseq_transcript.fasta $OUTPUT_CODONS_PY
    $PYTHON -W ignore $CODON_SCRIPT $BASEDIR/data/refseq_protein.fasta $BASEDIR/data/refseq_transcript.fasta $OUTPUT_CODONS_PY
	
    sed 's/,//g' -i $OUTPUT_CODONS_PY
    sed 's, mRNA,,g' -i $OUTPUT_CODONS_PY
    sed 's,PREDICTED: ,,g' -i $OUTPUT_CODONS_PY
    sed 's, brain derived neurotrophic factor,,g' -i $OUTPUT_CODONS_PY
    sed 's,(Bdnf),,g' -i $OUTPUT_CODONS_PY
    sed 's,(BDNF),,g' -i $OUTPUT_CODONS_PY
    sed 's,  transcript variant,,g' -i $OUTPUT_CODONS_PY
    sed 's, ,-,g' -i $OUTPUT_CODONS_PY
fi

#exit 0
# ######################################################
# Parse out the Human sequence
# ######################################################
# Manually parse out the Human sequence from the renamed fasta.
# This is now called 'BDNF_Human_Reference.fasta'
#FASTA="/home/aglucaci/EvolutionOfNeurotrophins/analysis/BDNF_codons.fasta"
#FASTA=$BASEDIR"/analysis/BDNF_codons.fasta"
#REF_SEQ=$BASEDIR"/analysis/BDNF_codons_HomoSapiens.fasta"

#if [ -s $REF_SEQ ]; 
#then
#   echo "# Human reference sequence exists"
#else
#   echo $PYTHON $BASEDIR"/scripts/separate_human_sequence.py" $FASTA
#   $PYTHON $BASEDIR"/scripts/separate_human_sequence.py" $FASTA
#fi

# ######################################################
# Rename the fastas sequences
# This makes the file more hyphy compatible
# ######################################################
# Rename fasta file:
#OUTPUT_RENAMED_FASTA=$BASEDIR"/analysis/BDNF_codons_renamed.fasta"
#if [ -s $OUTPUT_RENAMED_FASTA ];     
#then
#   echo "# Fasta already renamed"
#else 
#   #python rename_codon_msa_for_hyphy.py ../analysis/BDNF_codons.fasta ../analysis/BDNF_codons_renamed.fasta
#   #$PYTHON $BASEDIR"/scripts/rename_codon_msa_for_hyphy.py" $BASEDIR"/analysis/BDNF_codons.fasta" $BASEDIR"/analysis/BDNF_codons_renamed.fasta"
#   echo $PYTHON $BASEDIR"/scripts/rename_codon_msa_for_hyphy.py" $FASTA $OUTPUT_CODONS_PY
#   $PYTHON $BASEDIR"/scripts/rename_codon_msa_for_hyphy.py" $FASTA $OUTPUT_CODONS_PY
#fi

# ######################################################
# Multiple sequence alignment (MACSEv2)
# ######################################################
GENE=$BASEDIR"/results/BDNF_codons.fasta"
OUTPUT_CODON_MSA=$GENE"_codon_aln.fas"
mkdir -p $BASEDIR/scripts/STDOUT

if [ -s $OUTPUT_CODON_MSA ];
then
   echo "# Codon MSA with (MACSEv2) already exists"
   jobid_1=0
else
   #echo "qsub -V -l nodes=1:ppn=8 -q epyc -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT $MACSE_SCRIPT -v FASTA=$GENE"
   # qsub -V -l nodes=1:ppn=8 -q epyc $MACSE_SCRIPT -v FASTA=$GENE
   cmd="qsub -V -l nodes=1:ppn=8 -q epyc -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT $MACSE_SCRIPT -v FASTA=$GENE"
   echo $cmd
   jobid_1=$($cmd | cut -d' ' -f3)
fi

# ######################################################
# Tamura-Nei 1993 (TN93) Distance
# ######################################################
GENE=$BASEDIR"/results/BDNF_codons_renamed.fasta"
OUTPUT_TN93=$OUTPUT_CODON_MSA".dst"

if [ -s $OUTPUT_TN93 ];
then
   echo "# TN93 calculation already exists"
else
#   echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=2 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT -q epyc $TN93_SCRIPT -v FASTA=$OUTPUT_CODON_MSA
   cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=2 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT -q epyc $TN93_SCRIPT -v FASTA=$OUTPUT_CODON_MSA"
   echo $cmd
   jobid_2=$($cmd | cut -d' ' -f3)
fi

# ######################################################
# Generate Tree (ML or FastTree)
# ######################################################
# Output from previous step, the codon-aware-msa
INPUT=$OUTPUT_CODON_MSA
#iqtree output
OUTPUT_IQTREE=$INPUT".treefile"
if [ -s $OUTPUT_IQTREE ];
then
   echo "# IQTREE already ran"
else
   echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT
   cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/script/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT"
   # launch command and collect job id
   jobid_3=$($cmd | cut -d' ' -f3)
fi

# RDP
exit 0
