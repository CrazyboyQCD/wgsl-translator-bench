#!/usr/bin/env bash
# Run both benchmark suites and dump JSON results into results/.
set -e
ROOT='d:/FrontEnd/test/test/g/shader'
cd "$ROOT"
CORPUS="$ROOT/corpus"
CORPUS="$CORPUS" bash -c 'echo corpus: $(find "$NAGA_BENCH_CORPUS" -name "*.wgsl" | wc -l) files'

# --- naga (criterion, per-file per-stage benches) ---
cd "$ROOT/naga-bench"
NAGA_BENCH_CORPUS="$CORPUS" cargo bench --bench translate -- \
  --warm-up-time 1 --measurement-time 3 --noplot
# criterion results live in naga-bench/target/criterion

# --- tint (google benchmark, official corpus + our corpus dir) ---
cd "$ROOT"
TINT_BIN="$ROOT/scripts/external/dawn/out/tint_benchmark"
"$TINT_BIN" --benchmark_format=json --benchmark_out="$ROOT/results/tint.json" \
  --benchmark_min_time=1x
echo "results written to $ROOT/results"
