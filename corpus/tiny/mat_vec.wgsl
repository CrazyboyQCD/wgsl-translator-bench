@group(0) @binding(0) var<uniform> m: mat4x4<f32>;
@group(0) @binding(1) var<uniform> v: vec4<f32>;

@compute @workgroup_size(1)
fn main() {
    var acc = vec4<f32>(0.0);
    for (var i = 0; i < 4; i++) {
        acc = acc + m[i] * v;
    }
}
