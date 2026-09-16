# Naga vs Tint translation benchmark

- Platform: Windows, in-process timing; naga 30.0.1 (criterion, median),
  tint @ Dawn main (google benchmark, mean over iterations)

## End-to-end (WGSL parse -> target output, same pipeline on both sides)

- naga `e2e_*` = `<target>_full` bench; tint = sum of its
  ParseWGSL + ValidateIR + Generate* benches (all three are
  successive stages of the same pipeline).

| shader | target | naga e2e (us) | tint e2e (us) | naga/tint |
|---|---|---:|---:|---:|
| atan2-const-eval | spv | 16374.2 | 19901.8 | 0.82x |
| atan2-const-eval | hlsl | 15877.1 | 22323.3 | 0.71x |
| atan2-const-eval | msl | 15811.1 | 20669.0 | 0.76x |
| cluster-lights | spv | 419.5 | 1635.2 | 0.26x |
| cluster-lights | hlsl | 424.9 | 1600.3 | 0.27x |
| cluster-lights | msl | 441.1 | 1600.3 | 0.28x |
| metaball-isosurface | spv | 810.3 | 3316.1 | 0.24x |
| metaball-isosurface | hlsl | 807.4 | 3412.2 | 0.24x |
| metaball-isosurface | msl | 833.1 | 3272.6 | 0.25x |
| particles | spv | 550.7 | 3760.0 | 0.15x |
| particles | hlsl | 559.0 | 4415.0 | 0.13x |
| particles | msl | 627.8 | 4298.4 | 0.15x |
| shadow-fragment | spv | 246.2 | 572.0 | 0.43x |
| shadow-fragment | hlsl | 177.4 | 595.2 | 0.30x |
| shadow-fragment | msl | 200.9 | 618.5 | 0.32x |
| skinned-shadowed-pbr-fragment | spv | 1345.0 | 5763.4 | 0.23x |
| skinned-shadowed-pbr-fragment | hlsl | 1355.9 | 5763.4 | 0.24x |
| skinned-shadowed-pbr-fragment | msl | 1397.8 | 5880.0 | 0.24x |
| skinned-shadowed-pbr-vertex | spv | 239.3 | 1223.6 | 0.20x |
| skinned-shadowed-pbr-vertex | hlsl | 248.1 | 1194.6 | 0.21x |
| skinned-shadowed-pbr-vertex | msl | 252.9 | 1166.1 | 0.22x |
| unity_webgpu_0000017e9e2d81a0.vs | spv | 8728.0 | 37908.8 | 0.23x |
| unity_webgpu_0000017e9e2d81a0.vs | hlsl | 8883.7 | 37097.1 | 0.24x |
| unity_webgpu_0000017e9e2d81a0.vs | msl | 9385.3 | 37807.3 | 0.25x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | spv | 5495.8 | 19804.3 | 0.28x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | hlsl | 6247.8 | 18972.8 | 0.33x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | msl | 7272.8 | 19795.1 | 0.37x |
| unity_webgpu_000002778de78280.cs | spv | 592.2 | 2458.2 | 0.24x |
| unity_webgpu_000002778de78280.cs | hlsl | 600.4 | 2458.2 | 0.24x |
| unity_webgpu_000002778de78280.cs | msl | 623.3 | 3336.2 | 0.19x |
| unity_webgpu_000002778de78280.cs.spv | spv | 437.6 | 1749.1 | 0.25x |
| unity_webgpu_000002778de78280.cs.spv | hlsl | 433.5 | 1748.5 | 0.25x |
| unity_webgpu_000002778de78280.cs.spv | msl | 457.5 | 2235.9 | 0.20x |
| unity_webgpu_000002778f740030.fs | spv | 41337.3 | 111293.5 | 0.37x |
| unity_webgpu_000002778f740030.fs | hlsl | 35728.9 | 108813.3 | 0.33x |
| unity_webgpu_000002778f740030.fs | msl | 36637.6 | 113525.6 | 0.32x |
| unity_webgpu_000002778f740030.fs.spv | spv | 21385.5 | 63046.3 | 0.34x |
| unity_webgpu_000002778f740030.fs.spv | hlsl | 22762.2 | 55834.8 | 0.41x |
| unity_webgpu_000002778f740030.fs.spv | msl | 23161.4 | 73863.6 | 0.31x |
| **GEOMEAN** | spv | — | — | **0.28x** |
| **GEOMEAN** | hlsl | — | — | **0.28x** |
| **GEOMEAN** | msl | — | — | **0.27x** |

## Per-stage breakdown (attribution only, stages are not equivalent)

- naga `spv/hlsl/msl` = writer-only; tint `gen_*` = IR lowering + writer
  (parse pre-cached) — the writer rows are NOT the same workload.
- `validate`: naga WGSL validation vs tint IR validation (different layers).

| shader | stage | naga (us) | tint (us) | naga/tint |
|---|---|---:|---:|---:|
| atan2-const-eval | parse | 15712.4 | 10279.6 | 1.53x |
| atan2-const-eval | validate | 214.2 | 941.7 | 0.23x |
| cluster-lights | parse | 274.5 | 645.2 | 0.43x |
| cluster-lights | validate | 20.1 | 118.0 | 0.17x |
| metaball-isosurface | parse | 570.0 | 1180.0 | 0.48x |
| metaball-isosurface | validate | 59.2 | 279.0 | 0.21x |
| particles | parse | 366.1 | 837.1 | 0.44x |
| particles | validate | 32.7 | 196.4 | 0.17x |
| shadow-fragment | parse | 100.3 | 223.2 | 0.45x |
| shadow-fragment | validate | 6.4 | 34.9 | 0.18x |
| skinned-shadowed-pbr-fragment | parse | 1167.5 | 2109.4 | 0.55x |
| skinned-shadowed-pbr-fragment | validate | 85.7 | 505.7 | 0.17x |
| skinned-shadowed-pbr-vertex | parse | 160.2 | 401.1 | 0.40x |
| skinned-shadowed-pbr-vertex | validate | 13.1 | 67.4 | 0.19x |
| unity_webgpu_0000017e9e2d81a0.vs | parse | 10170.9 | 16203.7 | 0.63x |
| unity_webgpu_0000017e9e2d81a0.vs | validate | 351.1 | 3847.9 | 0.09x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | parse | 4184.2 | 6423.6 | 0.65x |
| unity_webgpu_0000017e9e2d81a0.vs.spv | validate | 250.3 | 2269.6 | 0.11x |
| unity_webgpu_000002778de78280.cs | parse | 470.2 | 1057.9 | 0.44x |
| unity_webgpu_000002778de78280.cs | validate | 26.0 | 191.2 | 0.14x |
| unity_webgpu_000002778de78280.cs.spv | parse | 319.8 | 726.1 | 0.44x |
| unity_webgpu_000002778de78280.cs.spv | validate | 21.4 | 151.1 | 0.14x |
| unity_webgpu_000002778f740030.fs | parse | 35274.6 | 39930.6 | 0.88x |
| unity_webgpu_000002778f740030.fs | validate | 793.7 | 13327.2 | 0.06x |
| unity_webgpu_000002778f740030.fs.spv | parse | 19026.4 | 19176.1 | 0.99x |
| unity_webgpu_000002778f740030.fs.spv | validate | 645.3 | 7812.5 | 0.08x |

naga total (all benches median sum): 564.3 ms

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
