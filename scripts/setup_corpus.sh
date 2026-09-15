#!/usr/bin/env bash
# Assemble the shared corpus: official Tint benchmark shaders (from a Dawn
# checkout) + locally generated tiny/torture layers.
#
# Env:
#   DAWN_DIR   existing Dawn checkout to reuse (default: external/dawn)
#   DAWN_REF   ref to shallow-clone when no checkout exists (default: main)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DAWN_DIR="${DAWN_DIR:-external/dawn}"
DAWN_REF="${DAWN_REF:-main}"

if [ ! -d "$DAWN_DIR/.git" ]; then
  git clone --depth 1 --branch "$DAWN_REF" https://github.com/google/dawn "$DAWN_DIR"
fi
DAWN_COMMIT=$(git -C "$DAWN_DIR" rev-parse HEAD)
mkdir -p results corpus/official
echo "dawn commit: $DAWN_COMMIT"
echo "$DAWN_COMMIT" > results/dawn-commit.txt
cp "$DAWN_DIR"/test/tint/benchmark/*.wgsl corpus/official/
cp "$DAWN_DIR"/third_party/benchmark_shaders/*/*.wgsl corpus/official/ 2>/dev/null || true

# keep the tint in-tree corpus in sync so tint_benchmark sees the same set
# (its shader list is embedded at build time via a generated header)
cp corpus/official/*.wgsl corpus/tiny/*.wgsl corpus/torture/*.wgsl \
   "$DAWN_DIR/test/tint/benchmark/" 2>/dev/null || true

n_total=$(find corpus -name '*.wgsl' | wc -l)
echo "corpus assembled: $n_total wgsl files"
