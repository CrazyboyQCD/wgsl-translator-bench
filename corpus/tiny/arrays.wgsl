struct Item {
    a: vec4<f32>,
    b: vec4<f32>,
    c: mat3x3<f32>,
};

@group(0) @binding(0) var<storage, read> input: array<Item>;
@group(0) @binding(1) var<storage, read_write> output: array<f32>;

@compute @workgroup_size(32)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let it = input[gid.x];
    output[gid.x] = dot(it.a, it.b) + it.c[0][0] + it.c[2][2];
}
