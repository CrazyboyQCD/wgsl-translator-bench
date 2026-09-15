@group(0) @binding(0) var<storage, read_write> data: array<f32>;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    var x = data[gid.x];
    var i = 0u;
    loop {
        if (i >= 16u) { break; }
        x = x * 1.0001 + sin(f32(i)) * 0.001;
        i = i + 1u;
    }
    data[gid.x] = x;
}
