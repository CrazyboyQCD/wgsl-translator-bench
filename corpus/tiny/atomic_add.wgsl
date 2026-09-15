@group(0) @binding(0) var<storage, read_write> counter: atomic<i32>;
@group(0) @binding(1) var<storage, read_write> values: array<f32>;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    if (gid.x >= arrayLength(&values)) { return; }
    let old = atomicAdd(&counter, 1);
    values[gid.x] = values[gid.x] + f32(old);
}
