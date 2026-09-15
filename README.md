# naga vs tint — WGSL translation benchmark

In-process, per-shader, per-stage comparison of the two WebGPU shader
translators:

- **naga** (wgpu) — `naga-bench/` (Rust + criterion): `parse`, `validate`,
  `spv`, `hlsl`, `msl` benches run per corpus file.
- **tint** (Dawn) — official `tint_benchmark` (Google Benchmark): `ParseWGSL`,
  `ValidateIR`, `GenerateSPIRV`, `GenerateHLSL`, `GenerateMSL`, `GenerateWGSL`.

Both sides consume the **same corpus**: Tint's official benchmark shaders +
tiny feature shaders + torture tests (see `corpus/`).

## Interpretation caveats

- `spv/hlsl/msl` (naga) are writer-only. `gen_*` (tint) include the
  AST→IR lowering pass before the writer; parse is pre-cached.
- `validate` compares naga WGSL validation vs tint IR validation —
  different layers, indicative only.
- `parse` on each side includes whatever semantic/IR construction is
  internal to that compiler (naga parses straight to its IR).
- Windows note: the naga CLI can **crash with stack overflow** on extreme
  shaders (1 MB main-thread stack) where tint rejects them gracefully.
  The in-process benches use a 1 GB stack thread to measure real cost.

## Run locally (Windows Git Bash / Linux)

```bash
# 1. corpus (clones Dawn under external/dawn) + torture generation
bash scripts/setup_corpus.sh
python scripts/gen_corpus.py

# 2. build tint (ninja + clang or clang-cl)
bash scripts/build_tint.sh

# 3. benches
cd naga-bench && NAGA_BENCH_CORPUS=../corpus cargo bench --bench translate -- \
  --warm-up-time 1 --measurement-time 2 --noplot && cd ..
(cd external/dawn && ./out/tint_benchmark \
  --benchmark_filter='WGSL/|SPIRV/|HLSL/|MSL/|ValidateIR/' \
  --benchmark_min_time=0.3s --benchmark_format=json \
  --benchmark_out=../../results/tint.json)

# 4. correctness matrix + merged report
bash scripts/verify.sh
python scripts/collect.py   # -> results/report.md
```

On Windows point `DAWN_DIR` to your existing checkout if you have one, e.g.
`DAWN_DIR=scripts/external/dawn` (ninja/clang-cl are auto-discovered in
`D:/Ninja` and `D:/LLVM/bin` as fallbacks).

## CI

`bench` workflow (`workflow_dispatch`, ubuntu-latest):

1. assembles the corpus from `dawn_ref` (default `main`),
2. runs both in-process benchmark suites,
3. runs the CLI correctness matrix,
4. publishes the merged table to the run's **Step Summary** and uploads
   `bench-results` artifact (`report.md`, CSVs, raw JSON).

Environment knobs: `DAWN_DIR`, `DAWN_REF`, `NAGA_BENCH_CORPUS`.
