#!/bin/bash
set -e  # stop if any command fails

echo "Downloading PDB structures..."
python3 scripts/download_pdbs.py

echo "Extracting sequences..."
python3 scripts/extract_sequences.py

echo "Downloading UniProt Kunitz sequences..."
python3 scripts/get_uniprot_kunitz.py

# Check if input fasta exists for alignment
FASTA_IN="data/processed/kunitz_seqs.fasta"
STO_OUT="model/kunitz.sto"

if [ ! -s "$FASTA_IN" ]; then
  echo "Error: Input fasta $FASTA_IN not found or empty."
  exit 1
fi

echo "Running multiple sequence alignment with MAFFT..."
mafft --auto "$FASTA_IN" > "$STO_OUT"

if [ ! -s "$STO_OUT" ]; then
  echo "Error: Alignment output $STO_OUT is empty."
  exit 1
fi

echo "Building HMM profile..."
hmmbuild model/kunitz.hmm "$STO_OUT"

echo "Running validation script..."
# Adjust these paths and filenames to your validation data as needed
RESULTS="results/hmmsearch_output.txt"
POSITIVES="data/positives.fasta"
NEGATIVES="data/negatives.fasta"

if [ -f "$RESULTS" ] && [ -f "$POSITIVES" ] && [ -f "$NEGATIVES" ]; then
  python3 scripts/validate_model.py -r "$RESULTS" -p "$POSITIVES" -n "$NEGATIVES"
else
  echo "Validation data not found, skipping validate_model.py."
fi

echo "Pipeline finished successfully."
