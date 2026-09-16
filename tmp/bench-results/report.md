# Naga vs Tint translation benchmark

- Platform: Windows, in-process timing; naga 30.0.1 (criterion, median),
  tint @ Dawn main (google benchmark, mean over iterations)
- `spv/hlsl/msl` = naga writer-only; `gen_*` = tint Generate* benches
  (includes AST->IR lowering before the writer; parse is pre-cached)
- `parse` on both sides includes semantic/IR construction internal to each
  compiler; `validate` compares naga WGSL validation vs tint IR validation
  (different layers - indicative only)

| shader | stage | naga (us) | tint (us) | naga/tint |
|---|---|---:|---:|---:|
| atan2-const-eval | parse | 18397.5 | 9258.3 | 1.99x |
| atan2-const-eval | validate | 255.2 | 706.2 | 0.36x |
| cluster-lights | parse | 315.2 | 589.2 | 0.54x |
| cluster-lights | validate | 23.7 | 118.6 | 0.20x |
| metaball-isosurface | parse | 659.5 | 1154.4 | 0.57x |
| metaball-isosurface | validate | 66.5 | 256.0 | 0.26x |
| particles | parse | 406.6 | 862.1 | 0.47x |
| particles | validate | 37.5 | 197.3 | 0.19x |
| shadow-fragment | parse | 108.3 | 230.8 | 0.47x |
| shadow-fragment | validate | 7.1 | 38.5 | 0.19x |
| skinned-shadowed-pbr-fragment | parse | 1121.4 | 2105.4 | 0.53x |
| skinned-shadowed-pbr-fragment | validate | 93.1 | 495.2 | 0.19x |
| skinned-shadowed-pbr-vertex | parse | 175.8 | 398.9 | 0.44x |
| skinned-shadowed-pbr-vertex | validate | 13.9 | 71.9 | 0.19x |

naga total (all benches median sum): 174.7 ms

## Correctness (CLI translation, per shader x target)

| shader | naga spv/hlsl/msl | tint spv/hlsl/msl | note |
|---|---|---|---|
| arrays | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| atan2-const-eval | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| atomic_add | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| branches | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| cluster-lights | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| empty_compute | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| loop_accum | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| mat_vec | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| metaball-isosurface | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| particles | X/X/X | X/X/X | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| shadow-fragment | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| skinned-shadowed-pbr-fragment | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| skinned-shadowed-pbr-vertex | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| texture_sample | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| torture-big-array | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| torture-big-expr | X/X/X | X/X/X | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| torture-deep-nest | X/X/X | X/X/X | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| torture-many-bindings | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| torture-many-functions | X/X/X | X/X/X | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| uniform_struct | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| uniformity-analysis-pointer-parameters | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_0000017E9E2D81A0.vs | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_0000017E9E2D81A0.vs.spv | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_000002778DE78280.cs | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_000002778DE78280.cs.spv | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_000002778F740030.fs | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
| unity_webgpu_000002778F740030.fs.spv | X/X/X | OK/X/OK | scripts/verify.sh: line 32: /home/runner/.cargo/bin/naga: No |
run at 2026-09-16 02:05 UTC on ubuntu-latest
dawn: 4aefbf1ef607cc4e7396f054d52f8b1af4f6d6c3
