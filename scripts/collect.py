#!/usr/bin/env python3
"""Merge criterion (naga) + google-benchmark (tint) results into a comparison table.

Inputs:
  naga-bench/target/criterion/naga/<stage>/<shader>/new/estimates.json
  results/tint.json (google benchmark --benchmark_format=json)

Outputs:
  results/naga.csv, results/tint.csv, results/report.md
"""
import csv
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CRIT = os.path.join(ROOT, "naga-bench", "target", "criterion", "naga")
TINT_JSON = os.path.join(ROOT, "results", "tint.json")
OUT = os.path.join(ROOT, "results")


def load_naga():
    """criterion: median point estimate in ns per (shader, stage)."""
    rows = []
    if not os.path.isdir(CRIT):
        print(f"[warn] missing {CRIT}")
        return rows
    for stage in sorted(os.listdir(CRIT)):
        stage_dir = os.path.join(CRIT, stage)
        if not os.path.isdir(stage_dir):
            continue
        for shader in sorted(os.listdir(stage_dir)):
            est = os.path.join(stage_dir, shader, "new", "estimates.json")
            if not os.path.isfile(est):
                continue
            with open(est) as f:
                data = json.load(f)
            med = data["median"]["point_estimate"]  # ns
            ci = data.get("confidence_interval") or data["median"].get("confidence_interval") or {}
            lo = ci.get("lower_bound", med)
            hi = ci.get("upper_bound", med)
            rows.append({"shader": shader, "stage": stage, "median_us": med / 1e3,
                         "lo_us": lo / 1e3, "hi_us": hi / 1e3})
    return rows


def load_tint():
    """google benchmark: median cpu_time per (shader, stage-guess)."""
    if not os.path.isfile(TINT_JSON):
        print(f"[warn] missing {TINT_JSON}")
        return []
    with open(TINT_JSON) as f:
        data = json.load(f)
    rows = []
    for b in data.get("benchmarks", []):
        # repetitions=1 -> no aggregate entries; the iteration entry itself is
        # the mean over `iterations` runs, so use it directly.
        if b.get("run_type") != "iteration":
            continue
        name = b["name"]
        unit = b.get("time_unit", "ns")
        mult = {"ns": 1.0, "us": 1e3, "ms": 1e6, "s": 1e9}.get(unit, 1.0)
        rows.append({"name": name, "cpu_us": b["cpu_time"] * mult / 1e3,
                     "real_us": b["real_time"] * mult / 1e3})
    return rows


STAGE_PATTERNS = [
    ("parse", re.compile(r"parse|wgsl.?reader|reader", re.I)),
    ("validate", re.compile(r"valid", re.I)),
    ("spv", re.compile(r"spv|spirv(?!.*asm)", re.I)),
    ("hlsl", re.compile(r"hlsl", re.I)),
    ("msl", re.compile(r"msl", re.I)),
    ("glsl", re.compile(r"glsl", re.I)),
    ("wgsl", re.compile(r"wgsl.?writer|writer.*wgsl", re.I)),
]


STAGE_MAP = {
    "ParseWGSL": "parse",
    "ValidateIR": "validate",
    "GenerateSPIRV": "gen_spv",
    "GenerateHLSL": "gen_hlsl",
    "GenerateMSL": "gen_msl",
    "GenerateWGSL": "gen_wgsl",
}


def tint_stage(name):
    fam = name.split("/")[0]
    if fam in STAGE_MAP:
        return STAGE_MAP[fam]
    for stage, pat in STAGE_PATTERNS:
        if pat.search(name):
            return stage
    return "other"


def shader_of(name, corpus_names):
    """Find corpus shader stem mentioned in the bench name.

    Returns the corpus name with its on-disk casing (naga keeps the original
    file-stem case while tint lowercases bench names, so matching is done
    case-insensitively but the merged key stays consistent with naga rows).
    """
    low = name.lower()
    best = None
    for c in corpus_names:
        cl = c.lower()
        if cl in low and (best is None or len(cl) > len(best)):
            best = c
    return best


def main():
    naga = load_naga()
    tint = load_tint()
    print(f"naga rows: {len(naga)}, tint rows: {len(tint)}")

    os.makedirs(OUT, exist_ok=True)

    with open(os.path.join(OUT, "naga.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["shader", "stage", "median_us", "lo_us", "hi_us"])
        w.writeheader()
        w.writerows(naga)

    # normalize tint rows
    corpus_names = sorted({r["shader"] for r in naga})
    tint_rows = []
    for r in tint:
        stage = tint_stage(r["name"])
        shader = shader_of(r["name"], corpus_names) or r["name"]
        tint_rows.append({"shader": shader, "stage": stage, "median_us": r["cpu_us"], "bench": r["name"]})
    with open(os.path.join(OUT, "tint.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["shader", "stage", "median_us", "bench"])
        w.writeheader()
        w.writerows(tint_rows)

    # merge on (shader, stage)
    tint_map = {(r["shader"], r["stage"]): r["median_us"] for r in tint_rows}
    naga_map = {(r["shader"], r["stage"]): r["median_us"] for r in naga}
    shaders = sorted({r["shader"] for r in naga} & {r["shader"] for r in tint_rows})

    # --- end-to-end view (the fair comparison) ---
    # naga e2e   = <tgt>_full bench        (parse + validate + write, one shot)
    # tint e2e   = ParseWGSL + ValidateIR + Generate*   (sum of its stages)
    lines = [
        "# Naga vs Tint translation benchmark",
        "",
        "- Platform: Windows, in-process timing; naga 30.0.1 (criterion, median),",
        "  tint @ Dawn main (google benchmark, mean over iterations)",
        "",
        "## End-to-end (WGSL parse -> target output, same pipeline on both sides)",
        "",
        "- naga `e2e_*` = `<target>_full` bench; tint = sum of its",
        "  ParseWGSL + ValidateIR + Generate* benches (all three are",
        "  successive stages of the same pipeline).",
        "",
        "| shader | target | naga e2e (us) | tint e2e (us) | naga/tint |",
        "|---|---|---:|---:|---:|",
    ]
    e2e_ratios = {"spv": [], "hlsl": [], "msl": []}
    for s in shaders:
        for tgt in ("spv", "hlsl", "msl"):
            n = naga_map.get((s, f"{tgt}_full"))
            t = tint_map.get((s, "parse"))
            v = tint_map.get((s, "validate"))
            g = tint_map.get((s, f"gen_{tgt}"))
            if n is None or t is None or v is None or g is None:
                continue
            e2e = t + v + g
            e2e_ratios[tgt].append(n / e2e)
            lines.append(f"| {s} | {tgt} | {n:.1f} | {e2e:.1f} | {n / e2e:.2f}x |")
    for tgt, ratios in e2e_ratios.items():
        if ratios:
            geo = (__import__("math").prod(ratios)) ** (1 / len(ratios))
            lines.append(f"| **GEOMEAN** | {tgt} | — | — | **{geo:.2f}x** |")

    # --- per-stage breakdown (attribution view; NOT apples-to-apples) ---
    lines += [
        "",
        "## Per-stage breakdown (attribution only, stages are not equivalent)",
        "",
        "- naga `spv/hlsl/msl` = writer-only; tint `gen_*` = IR lowering + writer",
        "  (parse pre-cached) — the writer rows are NOT the same workload.",
        "- `validate`: naga WGSL validation vs tint IR validation (different layers).",
        "",
        "| shader | stage | naga (us) | tint (us) | naga/tint |",
        "|---|---|---:|---:|---:|",
    ]
    for s in shaders:
        for st in ("parse", "validate", "spv", "gen_spv", "hlsl", "gen_hlsl", "msl", "gen_msl"):
            n = naga_map.get((s, st))
            t = tint_map.get((s, st))
            if n is None or t is None:
                continue
            lines.append(f"| {s} | {st} | {n:.1f} | {t:.1f} | {n / t:.2f}x |")
    # totals
    tot_n = sum(r["median_us"] for r in naga)
    lines += ["", f"naga total (all benches median sum): {tot_n/1e3:.1f} ms", ""]

    # correctness matrix
    tsv = os.path.join(OUT, "verify.tsv")
    if os.path.isfile(tsv):
        seen = set()
        lines += ["## Correctness (CLI translation, per shader x target)", "",
                  "| shader | naga spv/hlsl/msl | tint spv/hlsl/msl | note |",
                  "|---|---|---|---|"]
        with open(tsv, encoding="utf-8") as f:
            rd = csv.DictReader(f, delimiter="\t")
            grid = {}
            notes = {}
            for r in rd:
                if not r.get("shader"):
                    continue
                key = (r["shader"], r["engine"])
                grid.setdefault(key, {})[r["target"]] = r["ok"]
                if r["ok"] == "FAIL":
                    notes.setdefault((r["shader"], r["engine"]),
                                     r["bytes_or_error"][:60])
        def cell(sh, eng):
            marks = []
            for t in ("spv", "hlsl", "msl"):
                ok = grid.get((sh, eng), {}).get(t, "-")
                marks.append("OK" if ok == "OK" else "X")
            return "/".join(marks)
        for sh in sorted({k[0] for k in grid}):
            n_fail = "X" in cell(sh, "naga")
            t_fail = "X" in cell(sh, "tint")
            note = ""
            if n_fail:
                note = notes.get((sh, "naga"), "")
            elif t_fail:
                note = notes.get((sh, "tint"), "")
            lines.append(f"| {sh} | {cell(sh, 'naga')} | {cell(sh, 'tint')} | {note} |")
    with open(os.path.join(OUT, "report.md"), "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"wrote {os.path.join(OUT, 'report.md')}")


if __name__ == "__main__":
    sys.exit(main())
