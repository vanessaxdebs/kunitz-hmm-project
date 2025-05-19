#!/bin/bash
set -e

echo "Step 1: Download PDB files"
python3 scripts/download_pdbs.py

echo "Step 2: Extract sequences from PDB files"
python3 scripts/extract_sequences.py

echo "Step 3: Download UniProt Kunitz sequences"
python3 scripts/get_uniprot_kunitz.py

echo "Step 4: Prepare alignment (run MAFFT)"
mkdir -p model
mafft --auto data/raw/uniprot_kunitz.fasta > model/kunitz.sto

echo "Step 5: Build HMM profile"
hmmbuild model/kunitz.hmm model/kunitz.sto

echo "Step 6: Run hmmsearch on PDB sequences"
mkdir -p results
hmmsearch --tblout results/hmmsearch_output.tbl model/kunitz.hmm data/processed/kunitz_seqs.fasta

echo "Step 7: Validate model"
python3 scripts/validate_model.py \
  -r results/hmmsearch_output.tbl \
  -p data/processed/positives.fasta \
  -n data/processed/negatives.fasta

