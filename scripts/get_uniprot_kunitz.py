import requests
query = "domain:PF00014 AND reviewed:yes AND database:(type:pdb)"
url = f"https://rest.uniprot.org/uniprotkb/search?query={query}&format=fasta"
r = requests.get(url)
with open("data/raw/uniprot_kunitz.fasta", "w") as f:
    f.write(r.text)
print("Downloaded Kunitz sequences from UniProt")
