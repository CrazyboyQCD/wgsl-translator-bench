#!/usr/bin/env bash
# Correctness pass: translate every corpus WGSL with both CLIs, record success/size.
# Output: results/verify.tsv  (shader, engine, target, ok, bytes_or_error)
#
# Env:
#   DAWN_DIR   Dawn checkout containing out/tint (default: external/dawn)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p results/out

DAWN_DIR="${DAWN_DIR:-$ROOT/external/dawn}"
NAGA_BIN="${NAGA_BIN:-$(command -v naga || true)}"
[ -n "$NAGA_BIN" ] || NAGA_BIN="$HOME/.cargo/bin/naga"
TINT_SYSROOT="$DAWN_DIR/out"
TINT_BIN="${TINT_BIN:-$TINT_SYSROOT/tint}"
[ -x "$TINT_BIN" ] || TINT_BIN="$TINT_SYSROOT/tint.exe"
echo "naga: $NAGA_BIN"
echo "tint: $TINT_BIN"

TSV=results/verify.tsv
printf 'shader\tengine\ttarget\tok\tbytes_or_error\n' > "$TSV"

record() { # shader engine target status detail
  printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" >> "$TSV"
}

# naga <input> <output>  (format inferred from output extension)
run_naga() {
  local f="$1" target="$2"
  local base="results/out/$(basename "$f" .wgsl).naga.$target"
  if err=$("$NAGA_BIN" "$f" "$base" 2>&1); then
    record "$(basename "$f" .wgsl)" naga "$target" OK "$(stat -c%s "$base")"
  else
    record "$(basename "$f" .wgsl)" naga "$target" FAIL "$(echo "$err" | tr '\n\t' '  ' | head -c 120)"
  fi
}

# tint <input> --format <fmt> -o <name>
run_tint() {
  local f="$1" target="$2" fmt="$3"
  local base="results/out/$(basename "$f" .wgsl).tint.$target"
  if err=$("$TINT_BIN" "$f" --format "$fmt" -o "$base" 2>&1); then
    record "$(basename "$f" .wgsl)" tint "$target" OK "$(stat -c%s "$base")"
  else
    record "$(basename "$f" .wgsl)" tint "$target" FAIL "$(echo "$err" | tr '\n\t' '  ' | head -c 120)"
  fi
}

find corpus -name '*.wgsl' | sort | while read -r f; do
  for target in spv hlsl msl; do
    run_naga "$f" "$target"
    run_tint "$f" "$target" "${target/spv/spirv}"
  done
done

echo "--- summary ---"
awk -F'\t' 'NR>1 && $1!="shader" {ok[$2"_"$4]++} END {for(k in ok) print k, ok[k]}' "$TSV"
awk -F'\t' 'NR>1 && $4=="FAIL" && $1!="shader" {print "FAIL: "$2" "$3" "$1" :: "substr($5,1,80)}' "$TSV" | sort -u | head -20
