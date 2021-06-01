#!/bin/bash

HYPHYMP="/home/aglucaci/hyphy-develop/HYPHYMP"
RES="/home/aglucaci/hyphy-develop/res"

TREE="../results/BDNF_Codons.fa_CODON_AWARE_ALN.fasta.treefile"
TREE_LABELLED="$TREE".labelled

#cp -rf $TREE $TREE_LABELLED

# Batch file
ANNOTATE=/home/aglucaci/hyphy-analyses/LabelTrees/label-tree.bf

sleep 1

for FILE in posthocs/*.txt; do
   #echo $FILE

   #basename "$FILE"
   f="$(basename -- $FILE)"
   #echo $f

   LABEL=${f%.txt}
   #echo ${LABEL##*/}

   echo ''

   # Once for a tree with all of the labels
   if [ -s $TREE_LABELLED ]; 
   then
   #Do this
       echo $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE_LABELLED --list $FILE --output $TREE_LABELLED --label $LABEL
       $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE_LABELLED --list $FILE --output $TREE_LABELLED --label $LABEL
   else  
       echo $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE --list $FILE --output $TREE_LABELLED --label $LABEL
       $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE --list $FILE --output $TREE_LABELLED --label $LABEL
       break
   fi
   #sleep 1
   #break

   # Second time for a tree with JUST that label.. e.g., Primates tree, Gilres tree etc etc
   if [ ! -s "$TREE_LABELLED".$LABEL ]; then 
       echo $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE --list $FILE --output "$TREE_LABELLED".$LABEL --label $LABEL
       $HYPHYMP LIBPATH=$RES $ANNOTATE --tree $TREE --list $FILE --output "$TREE_LABELLED".$LABEL --label $LABEL
   fi
done

exit 0