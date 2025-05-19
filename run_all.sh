#!/bin/bash
set -e

echo "==> Setting up directories"
mkdir -p data/raw data/processed results model

echo "==> Downloading Kunitz sequences from UniProt"
# You may replace this with actual curl/wget or manual download
cp data/raw/kunitz.fasta data/processed/kunitz.fasta

echo "==> Performing Multiple Sequence Alignment with MAFFT"
mafft data/processed/kunitz.fasta > model/kunitz_aligned.fasta

echo "==> Converting aligned FASTA to Stockholm format"
# Assumes you have seqret (from EMBOSS) installed
seqret -sequence model/kunitz_aligned.fasta -outseq model/kunitz.sto -osformat2 stockholm

echo "==> Building HMM model with hmmbuild"
hmmbuild model/kunitz.hmm model/kunitz.sto

echo "==> Running hmmsearch"
hmmsearch --tblout results/hmmsearch_output.tbl model/kunitz.hmm data/processed/kunitz.fasta > results/hmmsearch_output.txt

echo "==> Validating HMM model"
python scripts/validate_model.py \
  --results results/hmmsearch_output.tbl \
  --positives data/processed/positives.fasta \
  --negatives data/processed/negatives.fasta

echo "==> Pipeline complete"


