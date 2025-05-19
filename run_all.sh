#!/bin/bash
set -euo pipefail

# Directories
RAW_DIR="data/raw"
PROCESSED_DIR="data/processed"
MODEL_DIR="model"
RESULTS_DIR="results"

# Create directories if missing
mkdir -p "$RAW_DIR" "$PROCESSED_DIR" "$MODEL_DIR" "$RESULTS_DIR"

echo "Downloading Kunitz sequences from UniProt..."
curl -G "https://rest.uniprot.org/uniprotkb/search" \
  --data-urlencode "query=reviewed:true AND kunitz" \
  --data-urlencode "format=fasta" \
  -o "$RAW_DIR/kunitz.fasta"

SEQ_COUNT=$(grep -c "^>" "$RAW_DIR/kunitz.fasta" || echo 0)
if [ "$SEQ_COUNT" -lt 10 ]; then
  echo "Warning: Only $SEQ_COUNT sequences found. Try to get more sequences for a better model."
fi

echo "Running multiple sequence alignment with mafft (output in CLUSTAL format)..."
mafft --auto --clustalout "$RAW_DIR/kunitz.fasta" > "$MODEL_DIR/kunitz.aln"

echo "Converting alignment from CLUSTAL to Stockholm format with seqmagick..."
seqmagick convert "$MODEL_DIR/kunitz.aln" "$MODEL_DIR/kunitz.sto"

echo "Building HMM model from Stockholm alignment..."
hmmbuild "$MODEL_DIR/kunitz.hmm" "$MODEL_DIR/kunitz.sto"

echo "Running hmmsearch against positive and negative datasets..."
if [ ! -f "$PROCESSED_DIR/positives.fasta" ] || [ ! -f "$PROCESSED_DIR/negatives.fasta" ]; then
  echo "ERROR: Positive and/or negative FASTA files missing in $PROCESSED_DIR"
  exit 1
fi

hmmsearch --tblout "$RESULTS_DIR/hmmsearch_positives.tbl" "$MODEL_DIR/kunitz.hmm" "$PROCESSED_DIR/positives.fasta" > "$RESULTS_DIR/hmmsearch_positives.out"
hmmsearch --tblout "$RESULTS_DIR/hmmsearch_negatives.tbl" "$MODEL_DIR/kunitz.hmm" "$PROCESSED_DIR/negatives.fasta" > "$RESULTS_DIR/hmmsearch_negatives.out"

echo "Validating model with Python script..."
python scripts/validate_model.py \
  --results "$RESULTS_DIR" \
  --positives "$PROCESSED_DIR/positives.fasta" \
  --negatives "$PROCESSED_DIR/negatives.fasta"

echo "Pipeline complete!"

