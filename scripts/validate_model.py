import argparse
from collections import defaultdict

def parse_args():
    parser = argparse.ArgumentParser(description="Validate HMM predictions")
    parser.add_argument("-r", "--results", required=True, help="HMMER hmmsearch output file")
    parser.add_argument("-p", "--positives", required=True, help="FASTA file with known positive IDs")
    parser.add_argument("-n", "--negatives", required=True, help="FASTA file with known negative IDs")
    parser.add_argument("-e", "--evalue", type=float, default=1e-5, help="E-value threshold")
    return parser.parse_args()

def parse_fasta_ids(fasta_file):
    return set(line.strip().lstrip(">") for line in open(fasta_file) if line.startswith(">"))

def parse_hmmsearch_tblout(tbl_file, evalue_threshold):
    hits = set()
    with open(tbl_file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) > 4:
                target_id = parts[0]
                evalue = float(parts[4])
                if evalue <= evalue_threshold:
                    hits.add(target_id)
    return hits

def evaluate(hits, positives, negatives):
    TP = len(hits & positives)
    FP = len(hits & negatives)
    FN = len(positives - hits)
    TN = len(negatives - hits)

    print(f"\nConfusion Matrix:\nTP={TP}, FP={FP}, FN={FN}, TN={TN}")

    accuracy = (TP + TN) / (TP + FP + FN + TN)
    precision = TP / (TP + FP) if (TP + FP) else 0
    recall = TP / (TP + FN) if (TP + FN) else 0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0

    print(f"\nMetrics:")
    print(f"Accuracy:  {accuracy:.3f}")
    print(f"Precision: {precision:.3f}")
    print(f"Recall:    {recall:.3f}")
    print(f"F1 Score:  {f1:.3f}")

def main():
    args = parse_args()
    positives = parse_fasta_ids(args.positives)
    negatives = parse_fasta_ids(args.negatives)
    hits = parse_hmmsearch_tblout(args.results, args.evalue)
    evaluate(hits, positives, negatives)

if __name__ == "__main__":
    main()

