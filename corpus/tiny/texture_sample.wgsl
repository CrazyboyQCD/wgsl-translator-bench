@group(0) @binding(0) var tex: texture_2d<f32>;
@group(0) @binding(1) var samp: sampler;

@fragment
fn fs_main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let c = textureSample(tex, samp, uv);
    return vec4<f32>(c.rgb * c.a, 1.0);
}
