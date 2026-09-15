#!/usr/bin/env bash
# Build standalone Tint CLI + tint_benchmark (Release) from a Dawn checkout.
#
# Env:
#   DAWN_DIR   Dawn checkout to build (default: external/dawn)
#   BUILD_DIR  cmake build dir relative to DAWN_DIR (default: out)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DAWN_DIR="${DAWN_DIR:-$ROOT/external/dawn}"
cd "$DAWN_DIR"

# --- tool discovery (works on Git Bash/Windows and Linux CI) ---
if command -v ninja >/dev/null 2>&1; then
  NINJA=$(command -v ninja)
elif [ -x 'D:/Ninja/ninja.exe' ]; then
  NINJA='D:/Ninja/ninja.exe'
else
  echo "error: ninja not found" >&2; exit 1
fi

if command -v clang-cl >/dev/null 2>&1; then
  CC=clang-cl; CXX=clang-cl
elif [ -x 'D:/LLVM/bin/clang-cl.exe' ]; then
  CC='D:/LLVM/bin/clang-cl.exe'; CXX='D:/LLVM/bin/clang-cl.exe'
elif command -v clang >/dev/null 2>&1; then
  CC=clang; CXX=clang++
else
  echo "error: no clang found" >&2; exit 1
fi
echo "ninja: $NINJA / CC=$CC"

# third-party deps (abseil, google-benchmark, ...) are fetched once and cached
if [ ! -d third_party/abseil-cpp ]; then
  python tools/fetch_dawn_dependencies.py
fi

cmake -B out -G Ninja -DCMAKE_MAKE_PROGRAM="$NINJA" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS= \
  -DTINT_BUILD_CMD_TOOLS=ON \
  -DTINT_BUILD_BENCHMARKS=ON \
  -DTINT_BUILD_TESTS=OFF \
  -DTINT_BUILD_GLSL_VALIDATOR=OFF \
  -DTINT_BUILD_SPV_WRITER=ON \
  -DTINT_BUILD_MSL_WRITER=ON \
  -DTINT_BUILD_SPV_READER=ON \
  -DDAWN_BUILD_SAMPLES=OFF \
  -DDAWN_BUILD_NODE_BINDINGS=OFF \
  -DDAWN_ENABLE_D3D12=OFF \
  -DDAWN_ENABLE_VULKAN=OFF \
  -DDAWN_ENABLE_OPENGLES=OFF \
  -DDAWN_ENABLE_NULL=OFF \
  -DDAWN_SUPPORTS_GLFW_FOR_WINDOWING=OFF

cmake --build out --target tint tint_benchmark
echo BUILD_DONE
