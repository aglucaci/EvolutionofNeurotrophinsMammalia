#!/bin/bash

# Updated for Mammalia -- analysis
# Create hyphy-specific analysis in order to automate this.
# @Usage: bash BDNF_PIPELINE_Recombinants.sh

now=$(date)
echo "## Starting pipeline: "$now
echo ""

# Config file this.
BASEDIR=/home/aglucaci/EvolutionofNeurotrophinsMammalia

# ######################################################
# Software Requirements
# ######################################################
HYPHYMPI="/home/aglucaci/hyphy-develop/HYPHYMPI"
PYTHON="/home/aglucaci/anaconda3/bin/python3.7"

# ######################################################
# Custom Scripts
# ######################################################

IQTREE_SCRIPT=$BASEDIR"/scripts/IQTREE.sh"
TN93_SCRIPT=$BASEDIR"/scripts/TN93.sh"
FEL_SCRIPT=$BASEDIR"/scripts/FEL.sh"
MEME_SCRIPT=$BASEDIR"/scripts/MEME.sh"
BUSTEDS_SCRIPT=$BASEDIR"/scripts/BUSTEDS.sh"
ABSREL_SCRIPT=$BASEDIR"/scripts/ABSREL.sh"
SLAC_SCRIPT=$BASEDIR"/scripts/SLAC.sh"
PRIME_SCRIPT=$BASEDIR"/scripts/PRIME.sh"
BGM_SCRIPT=$BASEDIR"/scripts/BGM.sh"
FMM_SCRIPT=$BASEDIR"/scripts/FMM.sh"

DATA_DIR=$BASEDIR"/results/RDP"

# #####################################################
# Make a tree
# #####################################################

for INPUT in $DATA_DIR/*.fasta; do
  echo "# Processing: "$INPUT
  #iqtree output
  OUTPUT_IQTREE=$INPUT".treefile"

#  if [ -s $OUTPUT_IQTREE ];
#  then
#     echo "# IQTREE already ran"
#  else
#     echo qsub -V -l nodes=1:ppn=16 -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT
#     cmd="qsub -V -l nodes=1:ppn=16 -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT"
#     # launch command and collect job id
#     jobid_1=$($cmd | cut -d' ' -f3)
#  fi   
   echo qsub -V -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT
   cmd="qsub -V -l nodes=1:ppn=16 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $IQTREE_SCRIPT -v FASTA=$INPUT"
   jobid_1=$($cmd | cut -d' ' -f3)
done

#exit 0

# Run Selection Analyses
echo "# Performing selection analyses"
for INPUT in $DATA_DIR/*.fasta; do
    OUTPUT_CODON_MSA=$INPUT
    OUTPUT_IQTREE=$INPUT".treefile"
    
    echo "# Input alignment: "$OUTPUT_CODON_MSA
    echo "# Input phylogenetic tree: "$OUTPUT_IQTREE

    echo "# Cleaning dots for underscores"
    sed 's,.,_,g' -i $OUTPUT_CODON_MSA
    sed 's,.,_,g' -i $OUTPUT_IQTREE
    echo ""

    # FEL
    OUTPUT_FEL=$OUTPUT_CODON_MSA".FEL.json"
    if [ -s $OUTPUT_FEL ];
    then
       echo "# FEL output already exists"
    else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FEL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FEL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_5=$($cmd | cut -d' ' -f3)
    fi

    # MEME
    OUTPUT_MEME=$OUTPUT_CODON_MSA".MEME.json"

    if [ -s $OUTPUT_MEME ];
    then
        echo "# MEME output already exists"
    else
        echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $MEME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
        cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $MEME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
        jobid_6=$($cmd | cut -d' ' -f3)
    fi

   # BUSTEDS
   OUTPUT_BUSTEDS=$OUTPUT_CODON_MSA".BUSTEDS.json"
   if [ -s $OUTPUT_BUSTEDS ];
   then
       echo "# BUSTEDS output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BUSTEDS_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BUSTEDS_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_7=$($cmd | cut -d' ' -f3)
   fi

   # ABSREL ##
   OUTPUT_ABSREL=$OUTPUT_CODON_MSA".ABSREL.json"
   if [ -s $OUTPUT_ABSREL ];
   then
       echo "# ABSREL output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $ABSREL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $ABSREL_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_8=$($cmd | cut -d' ' -f3)
   fi

   # SLAC ##
   OUTPUT_SLAC=$OUTPUT_CODON_MSA".SLAC.json"
   if [ -s $OUTPUT_SLAC ];
   then
       echo "# SLAC output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $SLAC_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $SLAC_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_9=$($cmd | cut -d' ' -f3)
   fi

   # PRIME ##
   OUTPUT_PRIME=$OUTPUT_CODON_MSA".PRIME.json"
   if [ -s $OUTPUT_PRIME ];
   then
       echo "# PRIME output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $PRIME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $PRIME_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_10=$($cmd | cut -d' ' -f3)
   fi

   # BGM ##
   OUTPUT_BGM=$OUTPUT_CODON_MSA".BGM.json"
   if [ -s $OUTPUT_BGM ];
   then
       echo "# BGM output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BGM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $BGM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_11=$($cmd | cut -d' ' -f3)
   fi

   # FMM ##
   OUTPUT_FMM=$OUTPUT_CODON_MSA".FMM.json"
   if [ -s $OUTPUT_FMM ];
   then
       echo "# FMM output already exists"
   else
       echo qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FMM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE
       cmd="qsub -V -W depend=afterok:$jobid_1 -l nodes=1:ppn=8 -o $BASEDIR/scripts/STDOUT -e $BASEDIR/scripts/STDOUT -q epyc $FMM_SCRIPT -v FASTA=$OUTPUT_CODON_MSA,TREE=$OUTPUT_IQTREE"
       jobid_11=$($cmd | cut -d' ' -f3)
   fi

   # FUBAR, aBSREL-MH, BUSTEDS-MH

   # Annotate the tree
   # RELAX
   # CFEL
done
exit 0

