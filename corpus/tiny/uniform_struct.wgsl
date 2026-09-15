struct Uniforms {
    mvp: mat4x4<f32>,
    color: vec4<f32>,
    scale: f32,
};

@group(0) @binding(0) var<uniform> u: Uniforms;

@vertex
fn vs_main(@location(0) pos: vec3<f32>) -> @builtin(position) vec4<f32> {
    return u.mvp * vec4<f32>(pos * u.scale, 1.0);
}
