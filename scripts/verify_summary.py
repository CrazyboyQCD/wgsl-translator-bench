import csv
import collections

p = r"d:/FrontEnd/test/test/g/shader/results/verify.tsv"
rows = list(csv.DictReader(open(p, encoding="utf-8"), delimiter="\t"))
rows = [r for r in rows if r.get("shader")]
cnt = collections.Counter((r["engine"], r["ok"]) for r in rows)
print(dict(cnt))
print("--- FAIL detail ---")
for r in rows:
    if r["ok"] == "FAIL":
        print(f'{r["engine"]:5} {r["target"]:5} {r["shader"]:40} {r["bytes_or_error"][:70]}')
