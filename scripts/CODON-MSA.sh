#!/bin/bash

# variable FASTA is passed in, the unaligned codons fasta

PREMSA=/home/aglucaci/hyphy-analyses/codon-msa/pre-msa.bf
POSTMSA=/home/aglucaci/hyphy-analyses/codon-msa/post-msa.bf
MAFFT=/usr/local/bin/mafft
HYPHYMPI=/home/aglucaci/hyphy-develop/HYPHYMPI
RES=/home/aglucaci/hyphy-develop/res
NP=8

function align_gene {
    GENE=$1
    tag="_CODON_AWARE_ALN.fasta"

    if [ -s $GENE$tag ];
    then
       echo "Alignment Exists at: "$GENE$tag       
       return 1
    fi

    if [ ! -s $GENE"_protein.fas" ]; 
    then
        echo "mpirun -np $NP $HYPHYMPI LIBPATH=$RES $PREMSA --input $GENE"
        mpirun -np $NP $HYPHYMPI LIBPATH=$RES $PREMSA --input $GENE
    fi
 
    if [ ! -s $GENE"_protein.msa" ];
    then
        echo "$MAFFT --auto $GENE"_protein.fas" > $GENE"_protein.msa""
        $MAFFT --auto $GENE"_protein.fas" > $GENE"_protein.msa"
    fi

    echo "mpirun -np $NP $HYPHYMPI LIBPATH=$RES $POSTMSA --protein-msa "$GENE"_protein.msa --nucleotide-sequences "$GENE"_nuc.fas --output $GENE$tag --duplicates "$GENE$tag"_duplicates.json"
    mpirun -np $NP $HYPHYMPI LIBPATH=$RES $POSTMSA --protein-msa "$GENE"_protein.msa --nucleotide-sequences "$GENE"_nuc.fas --output $GENE$tag --duplicates "$GENE$tag"_duplicates.json

}


align_gene $FASTA

exit 0