# Download PDBs from list
import os, requests, yaml
from pathlib import Path

with open("config.yaml") as f:
    config = yaml.safe_load(f)

pdb_ids = open(config["paths"]["pdb_ids"]).read().splitlines()
pdb_dir = Path(config["paths"]["pdb_dir"])
pdb_dir.mkdir(parents=True, exist_ok=True)

for pdb_id in pdb_ids:
    url = f"https://files.rcsb.org/download/{pdb_id.upper()}.pdb"
    out_path = pdb_dir / f"{pdb_id.lower()}.pdb"
    if not out_path.exists():
        r = requests.get(url)
        with open(out_path, "w") as f:
            f.write(r.text)
        print(f"Downloaded {pdb_id}")
