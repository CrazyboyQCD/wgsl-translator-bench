import csv

rows = list(csv.DictReader(open("tmp/bench-results/verify.tsv", encoding="utf-8"), delimiter="\t"))
seen = set()
for r in rows:
    if r["ok"] == "FAIL" and (r["shader"], r["engine"], r["target"]) not in seen:
        seen.add((r["shader"], r["engine"], r["target"]))
        print(f'{r["engine"]:5} {r["target"]:4} {r["shader"]:32} :: {r["bytes_or_error"][:100]}')
