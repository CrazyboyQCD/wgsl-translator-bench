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
| atan2-const-eval | parse | 18134.5 | 10279.6 | 1.76x |
| atan2-const-eval | validate | 236.8 | 941.7 | 0.25x |
| cluster-lights | parse | 290.3 | 645.2 | 0.45x |
| cluster-lights | validate | 21.9 | 118.0 | 0.19x |
| metaball-isosurface | parse | 801.9 | 1180.0 | 0.68x |
| metaball-isosurface | validate | 73.5 | 279.0 | 0.26x |
| particles | parse | 389.7 | 837.1 | 0.47x |
| particles | validate | 37.0 | 196.4 | 0.19x |
| shadow-fragment | parse | 109.8 | 223.2 | 0.49x |
| shadow-fragment | validate | 6.9 | 34.9 | 0.20x |
| skinned-shadowed-pbr-fragment | parse | 1576.2 | 2109.4 | 0.75x |
| skinned-shadowed-pbr-fragment | validate | 133.4 | 505.7 | 0.26x |
| skinned-shadowed-pbr-vertex | parse | 178.7 | 401.1 | 0.45x |
| skinned-shadowed-pbr-vertex | validate | 15.0 | 67.4 | 0.22x |
| unity_webgpu_0000017e9e2d81a0.vs | parse | 8192.6 | 16203.7 | 0.51x |
| unity_webgpu_0000017e9e2d81a0.vs | validate | 326.9 | 3847.9 | 0.08x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | parse | 5436.9 | 6423.6 | 0.85x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | validate | 311.6 | 2269.6 | 0.14x |
| unity_webgpu_000002778de78280.cs | parse | 634.0 | 1057.9 | 0.60x |
| unity_webgpu_000002778de78280.cs | validate | 32.9 | 191.2 | 0.17x |
| unity_webgpu_000002778de78280.cs.spv | parse | 395.7 | 726.1 | 0.54x |
| unity_webgpu_000002778de78280.cs.spv | validate | 34.0 | 151.1 | 0.23x |
| unity_webgpu_000002778f740030.fs | parse | 32362.5 | 39930.6 | 0.81x |
| unity_webgpu_000002778f740030.fs | validate | 1080.6 | 13327.2 | 0.08x |
| unity_webgpu_000002778f740030.fs.spv | parse | 29192.5 | 19176.1 | 1.52x |
| unity_webgpu_000002778f740030.fs.spv | validate | 901.7 | 7812.5 | 0.12x |

naga total (all benches median sum): 173.1 ms

## Correctness (CLI translation, per shader x target)

| shader | naga spv/hlsl/msl | tint spv/hlsl/msl | note |
|---|---|---|---|
|      | X/X/X | X/X/X |  |
|       | X/X/X | X/X/X |  |
|      let x = f299(f298( | X/X/X | X/X/X |  |
|      out[gid.x] = src[gid.x] * 1 | X/X/X | X/X/X |  |
| arrays | OK/OK/OK | OK/OK/OK |  |
| atan2-const-eval | OK/OK/OK | OK/OK/OK |  |
| atomic_add | OK/OK/OK | OK/OK/OK |  |
| branches | OK/OK/OK | OK/OK/OK |  |
| cluster-lights | OK/OK/OK | OK/OK/OK |  |
| empty_compute | OK/OK/OK | OK/OK/OK |  |
| loop_accum | OK/OK/OK | OK/OK/OK |  |
| mat_vec | OK/OK/OK | OK/OK/OK |  |
| metaball-isosurface | OK/OK/OK | OK/OK/OK |  |
| particles | OK/OK/OK | X/X/X | Emitting to a file but the module has multiple entry points. |
| shadow-fragment | OK/OK/OK | OK/OK/OK |  |
| skinned-shadowed-pbr-fragment | OK/OK/OK | OK/OK/OK |  |
| skinned-shadowed-pbr-vertex | OK/OK/OK | OK/OK/OK |  |
| texture_sample | OK/OK/OK | OK/OK/OK |  |
| torture-big-array | OK/OK/OK | OK/OK/OK |  |
| torture-big-expr | X/X/X | X/X/X |  thread 'main' (11060) has overflowed its stack  |
| torture-deep-nest | OK/OK/OK | X/X/X | corpus/torture/torture-deep-nest.wgsl:132:261 error: stateme |
| torture-many-bindings | OK/OK/OK | OK/OK/OK |  |
| torture-many-functions | X/X/X | X/X/X | Could not parse WGSL: error: internal WGSL front end error   |
| uniform_struct | OK/OK/OK | OK/OK/OK |  |
| uniformity-analysis-pointer-parameters | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_0000017E9E2D81A0.vs | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_0000017E9E2D81A0.vs.spv | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_000002778DE78280.cs | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_000002778DE78280.cs.spv | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_000002778F740030.fs | OK/OK/OK | OK/OK/OK |  |
| unity_webgpu_000002778F740030.fs.spv | OK/OK/OK | OK/OK/OK |  |
