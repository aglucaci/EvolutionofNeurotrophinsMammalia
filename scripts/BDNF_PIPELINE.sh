#!/bin/bash
# Updated for 2021 analysis, Comparative evolution of neurotrophins
# v0.03 Is used for clade analysis on Mammalia. In light of new literature.
#@Usage on hpc: bash BDNF_PIPELINE.sh

now=$(date)
echo "## Starting Mammalia pipeline: "$now
echo ""

# User configuration here
BASEDIR=/home/aglucaci/EvolutionofNeurotrophinsMammalia
cd $BASEDIR
mkdir -p "$BASEDIR"/results
mkdir -p $BASEDIR/scripts/STDOUT

# ######################################################
# Software Requirements -- create separate scripts, requirements.txt
# ######################################################
HYPHY="/home/aglucaci/hyphy-develop/HYPHYMPI"
PYTHON="/home/aglucaci/anaconda3/bin/python3.7"
IQTREE="/opt/iqtree/iqtree-1.6.6-Linux/bin/iqtree"
JAVA="/usr/bin/java"

# ######################################################
# Custom Scripts
# ######################################################
CODON_SCRIPT="$BASEDIR"/scripts/codons.py
IQTREE_SCRIPT="$BASEDIR"/scripts/IQTREE.sh
TN93_SCRIPT="$BASEDIR"/scripts/TN93.sh
CODON_MSA_SCRIPT="$BASEDIR"/scripts/CODON-MSA.sh

# ######################################################
# Get codons
# ######################################################
# Uses protein file and transcript to get the CDS.
# output 'BDNF_Codons.fasta' is unaligned.
OUTPUT_CODONS_PY="$BASEDIR"/results/BDNF_Codons.fa
if [ -s $OUTPUT_CODONS_PY ]; then
    echo "# Get codons from transcript + protein fasta -- complete"
else
    echo $PYTHON -W ignore $CODON_SCRIPT $BASEDIR/data/refseq_protein.fasta $BASEDIR/data/refseq_transcript.fasta $OUTPUT_CODONS_PY > $BASEDIR/results/codons.txt
    $PYTHON -W ignore $CODON_SCRIPT $BASEDIR/data/refseq_protein.fasta $BASEDIR/data/refseq_transcript.fasta $OUTPUT_CODONS_PY > $BASEDIR/results/codons.txt
fi

# ######################################################
# Multiple sequence alignment (codon-msa)
# ######################################################
GENE=$OUTPUT_CODONS_PY
OUTPUT_CODON_MSA=$GENE"_CODON_AWARE_ALN.fasta"
jobid_1=0

#if [ -s $OUTPUT_CODON_MSA ];
#then
#   echo "# codon-msa exists"
#else
#   cmd="qsub -V -l nodes=1:ppn=8 -q epyc -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT $CODON_MSA_SCRIPT -v FASTA=$GENE"
#   echo $cmd
#   jobid_1=$($cmd | cut -d' ' -f3)
#fi

cmd="qsub -V -l nodes=1:ppn=8 -q epyc -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT $CODON_MSA_SCRIPT -v FASTA=$GENE"
echo $cmd
jobid_1=$($cmd | cut -d' ' -f3)

# ######################################################
# Tamura-Nei 1993 (TN93) Distance
# ######################################################
#GENE=$BASEDIR"/results/BDNF_codons_renamed.fasta"
GENE=$OUTPUT_CODON_MSA
OUTPUT_TN93=$OUTPUT_CODON_MSA".dst"

if [ -s $OUTPUT_TN93 ];
then
   echo "# TN93 calculation already exists"
else
   cmd="qsub -V -l nodes=1:ppn=2 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $TN93_SCRIPT -v FASTA=$OUTPUT_CODON_MSA"
   echo $cmd
   jobid_2=$($cmd | cut -d' ' -f3)

   #if qstat -s $jobid_1; then
   #    cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=2 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $TN93_SCRIPT -v FASTA=$OUTPUT_CODON_MSA"
   #    echo $cmd
   #    jobid_2=$($cmd | cut -d' ' -f3)
   #else
   #    echo ""
   #    cmd="qsub -V -l nodes=1:ppn=2 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $TN93_SCRIPT -v FASTA=$OUTPUT_CODON_MSA"
   #    echo $cmd
   #    jobid_2=$($cmd | cut -d' ' -f3)
   #fi
fi

# ######################################################
# Generate Tree (ML or FastTree)
# ######################################################
# Output from previous step, the codon-aware-msa
INPUT=$OUTPUT_CODON_MSA
#iqtree output
OUTPUT_IQTREE=$INPUT".treefile"

#if [ -s $OUTPUT_IQTREE ];
#then
#   echo "# IQTREE already ran"
#else
#   cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT"
#   echo $cmd
#   # launch command and collect job id
#   jobid_3=$($cmd | cut -d' ' -f3)
#fi

cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT"
echo $cmd
# launch command and collect job id
jobid_3=$($cmd | cut -d' ' -f3)


# ######################################################
# Run Selection Analyses
# ######################################################
FEL_SCRIPT=$BASEDIR"/scripts/FEL.sh"
MEME_SCRIPT=$BASEDIR"/scripts/MEME.sh"
BUSTEDS_SCRIPT=$BASEDIR"/scripts/BUSTEDS.sh"
ABSREL_SCRIPT=$BASEDIR"/scripts/ABSREL.sh"
SLAC_SCRIPT=$BASEDIR"/scripts/SLAC.sh"
PRIME_SCRIPT=$BASEDIR"/scripts/PRIME.sh"
BGM_SCRIPT=$BASEDIR"/scripts/BGM.sh"
FMM_SCRIPT=$BASEDIR"/scripts/FMM.sh"

DATA_DIR=$BASEDIR"/results"

echo "# Performing selection analyses"

for INPUT in $DATA_DIR/*.fasta; do
    OUTPUT_CODON_MSA=$INPUT
    OUTPUT_IQTREE=$INPUT".treefile"
    echo "# Input alignment: "$OUTPUT_CODON_MSA
    echo "# Input phylogenetic tree: "$OUTPUT_IQTREE

    # FEL
    OUTPUT_FEL=$OUTPUT_CODON_MSA".FEL.json"
    if [ -s $OUTPUT_FEL ];
    then
       echo "# FEL output already exists"
    else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FEL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_5=$($cmd | cut -d' ' -f3)
    fi

    # MEME
    OUTPUT_MEME=$OUTPUT_CODON_MSA".MEME.json"
    if [ -s $OUTPUT_MEME ];
    then
        echo "# MEME output already exists"
    else
        cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $MEME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
        echo $cmd
        jobid_6=$($cmd | cut -d' ' -f3)
    fi

   # BUSTEDS
   OUTPUT_BUSTEDS=$OUTPUT_CODON_MSA".BUSTEDS.json"
   if [ -s $OUTPUT_BUSTEDS ];
   then
       echo "# BUSTEDS output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BUSTEDS_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_7=$($cmd | cut -d' ' -f3)
   fi

   # ABSREL ##
   OUTPUT_ABSREL=$OUTPUT_CODON_MSA".ABSREL.json"
   if [ -s $OUTPUT_ABSREL ];
   then
       echo "# ABSREL output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $ABSREL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_8=$($cmd | cut -d' ' -f3)
   fi

   # SLAC ##
   OUTPUT_SLAC=$OUTPUT_CODON_MSA".SLAC.json"
   if [ -s $OUTPUT_SLAC ];
   then
       echo "# SLAC output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $SLAC_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_9=$($cmd | cut -d' ' -f3)
   fi

   # PRIME ##
   OUTPUT_PRIME=$OUTPUT_CODON_MSA".PRIME.json"
   if [ -s $OUTPUT_PRIME ];
   then
       echo "# PRIME output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $PRIME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_10=$($cmd | cut -d' ' -f3)
   fi

   # BGM ##
   OUTPUT_BGM=$OUTPUT_CODON_MSA".BGM.json"
   if [ -s $OUTPUT_BGM ];
   then
       echo "# BGM output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BGM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_11=$($cmd | cut -d' ' -f3)
   fi

   # FMM ##
   OUTPUT_FMM=$OUTPUT_CODON_MSA".FMM.json"
   if [ -s $OUTPUT_FMM ];
   then
       echo "# FMM output already exists"
   else
       cmd="qsub -V -W depend=afterok:$jobid_3 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FMM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       echo $cmd
       jobid_11=$($cmd | cut -d' ' -f3)
   fi

   # FUBAR, aBSREL-MH, BUSTEDS-MH

   # Annotate the tree
   # RELAX
   # CFEL
done


exit 0
