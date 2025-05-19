from Bio import PDB
from Bio.PDB import PDBParser, PPBuilder
from pathlib import Path
import yaml

with open("config.yaml") as f:
    config = yaml.safe_load(f)

parser = PDBParser(QUIET=True)
ppb = PPBuilder()

pdb_dir = Path(config["paths"]["pdb_dir"])
fasta_out = Path(config["paths"]["fasta_output"])

with open(fasta_out, "w") as fasta:
    for pdb_file in pdb_dir.glob("*.pdb"):
        structure = parser.get_structure(pdb_file.stem, pdb_file)
        for model in structure:
            for chain in model:
                for i, pp in enumerate(ppb.build_peptides(chain)):
                    seq = pp.get_sequence()
                    fasta.write(f">{pdb_file.stem}_{chain.id}_{i}\n{seq}\n")
