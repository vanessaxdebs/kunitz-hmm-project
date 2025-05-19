#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

echo " Starting Kunitz HMM pipeline..."

# Directories
RAW_DIR="data/raw"
PROC_DIR="data/processed"
MODEL_DIR="model"
RESULTS_DIR="results"
SCRIPTS_DIR="scripts"

# Files
UNIPROT_FASTA="$RAW_DIR/uniprot_kunitz.fasta"
POSITIVES="$PROC_DIR/positives.fasta"
NEGATIVES="$PROC_DIR/negatives.fasta"
MSA_FILE="$MODEL_DIR/kunitz.msa"
HMM_FILE="$MODEL_DIR/kunitz.hmm"
HMMSEARCH_OUTPUT="$RESULTS_DIR/hmmsearch_output.tbl"

# Step 1: Prepare Data
echo "Step 1: Preparing data..."
python3 $SCRIPTS_DIR/prepare_data.py --input "$UNIPROT_FASTA" --output-dir "$PROC_DIR"

# Step 2: Build MSA
echo " Step 2: Building multiple sequence alignment..."
python3 $SCRIPTS_DIR/build_msa.py --input "$POSITIVES" --output "$MSA_FILE"

# Step 3: Build HMM
echo " Step 3: Building HMM profile..."
python3 $SCRIPTS_DIR/build_hmm.py --msa "$MSA_FILE" --output "$HMM_FILE"

# Step 4: Run HMM search
echo " Step 4: Running HMM search..."
python3 $SCRIPTS_DIR/run_hmmsearch.py --hmm "$HMM_FILE" --seqs "$POSITIVES" --output "$HMMSEARCH_OUTPUT"

# Step 5: Validate model
echo " Step 5: Validating model..."
python3 $SCRIPTS_DIR/validate_model.py --hmm "$HMM_FILE" --positives "$POSITIVES" --negatives "$NEGATIVES"

echo " Pipeline complete. All steps finished successfully."
