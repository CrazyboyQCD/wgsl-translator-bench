@group(0) @binding(0) var<storage, read_write> out: array<vec4<f32>>;

fn classify(v: vec4<f32>) -> u32 {
    if (v.x > 0.5) { return 1u; }
    else if (v.y > 0.5) { return 2u; }
    else if (v.z > 0.5) { return 3u; }
    return 0u;
}

@compute @workgroup_size(16)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    var v = out[gid.x];
    switch classify(v) {
        case 1u: { v = vec4<f32>(1.0, 0.0, 0.0, 1.0); }
        case 2u: { v = vec4<f32>(0.0, 1.0, 0.0, 1.0); }
        case 3u: { v = vec4<f32>(0.0, 0.0, 1.0, 1.0); }
        default: { v = abs(v); }
    }
    out[gid.x] = v;
}
