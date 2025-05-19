#!/bin/bash

# Download PDB structures
python3 scripts/download_pdbs.py

# Extract sequences
python3 scripts/extract_sequences.py

# Download UniProt entries with PF00014
python3 scripts/get_uniprot_kunitz.py

# Align sequences manually (CLI command, not a script)
# e.g., mafft --auto data/processed/kunitz_seqs.fasta > model/kunitz.sto

# Build HMM
hmmbuild model/kunitz.hmm model/kunitz.sto

# Validate model (TBD)
python3 scripts/validate_model.py
