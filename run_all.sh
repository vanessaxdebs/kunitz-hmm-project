#!/bin/bash
set -euo pipefail

# Paths
RAW_FASTA="data/raw/kunitz.fasta"
ALIGNMENT="model/kunitz.sto"
HMM_MODEL="model/kunitz.hmm"
RESULTS="results/hmmsearch_output.tbl"
POSITIVES="data/processed/positives.fasta"
NEGATIVES="data/processed/negatives.fasta"

echo "Downloading reviewed UniProt sequences with Kunitz domain (InterPro IPR002223)..."
curl -G "https://rest.uniprot.org/uniprotkb/search" \
  --data-urlencode "query=reviewed:true AND database_interpro:IPR002223" \
  --data-urlencode "format=fasta" \
  -o $RAW_FASTA

# Check how many sequences downloaded
NUM_SEQ=$(grep -c "^>" $RAW_FASTA || true)
echo "Number of sequences downloaded: $NUM_SEQ"

if [[ $NUM_SEQ -lt 5 ]]; then
  echo "Warning: Less than 5 sequences downloaded, you might want more diverse sequences for a good HMM."
fi

echo "Running multiple sequence alignment with MAFFT..."
mafft --auto $RAW_FASTA > $ALIGNMENT

echo "Building HMM from alignment..."
hmmbuild $HMM_MODEL $ALIGNMENT

echo "Searching positives and negatives with hmmsearch..."
# Search positives
hmmsearch --tblout results/pos_hmmsearch.tbl $HMM_MODEL $POSITIVES > /dev/null
# Search negatives
hmmsearch --tblout results/neg_hmmsearch.tbl $HMM_MODEL $NEGATIVES > /dev/null

# Combine results for validation script
cat results/pos_hmmsearch.tbl results/neg_hmmsearch.tbl > $RESULTS

echo "Validating model..."
python scripts/validate_model.py \
  --results $RESULTS \
  --positives $POSITIVES \
  --negatives $NEGATIVES

echo "All done!"


