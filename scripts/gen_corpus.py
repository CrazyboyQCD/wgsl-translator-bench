#!/usr/bin/env python3
"""Generate compiler torture-test WGSL into corpus/torture/."""
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "corpus", "torture")


def deep_nest(levels=64):
    """Deeply nested control flow."""
    body = "    sum = sum + 1.0;\n"
    for i in range(levels):
        ind = "    " * (i + 1)
        body += f"{ind}if (sum > 0.0) {{\n{ind}    sum = sum * 0.999 + 0.1;\n"
    body += "    " * (levels + 1) + "sum = sum - 1.0;\n"
    for i in range(levels):
        ind = "    " * (levels - i)
        body += f"{ind}}}\n"
    return f"""@group(0) @binding(0) var<storage, read_write> out: array<f32>;

@compute @workgroup_size(1)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {{
    var sum = f32(gid.x);
{body}    out[gid.x] = sum;
}}
"""


def many_functions(count=300):
    """Long call chain: main -> f0 -> f1 -> ... -> fN."""
    decls = []
    for i in range(count):
        decls.append(f"fn f{i}(x: f32) -> f32 {{ return x * 1.0001 + f32({i}) ; }}")
    chain = "f0("
    chain += ")" .join([]) # placeholder, built below
    calls = "f0"
    inner = "x"
    for i in range(1, count):
        inner = f"f{i}({inner})"
    return (
        "\n".join(decls)
        + f"""

@compute @workgroup_size(1)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {{
    let x = {inner}(f32(gid.x));
}}
"""
    )


def big_array(n=4096):
    vals = ", ".join(f"{(i * 37 % 251) / 251:.4f}" for i in range(n))
    return f"""const W: array<f32, {n}> = array<f32, {n}>({vals});

@group(0) @binding(0) var<storage, read_write> out: array<f32>;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {{
    var acc = 0.0;
    let base = gid.x * {n}u;
    for (var i = 0u; i < {n}u; i++) {{
        acc = acc + W[i];
    }}
    out[gid.x] = acc;
}}
"""


def many_bindings(n=32):
    bindings = []
    uses = []
    for i in range(n):
        bindings.append(f"@group(0) @binding({i}) var<storage, read> b{i}: array<vec4<f32>>;")
        uses.append(f"    acc = acc + b{i}[gid.x].x + b{i}[gid.x].y;")
    return "\n".join(bindings) + """

@group(0) @binding(255) var<storage, read_write> out: array<f32>;

@compute @workgroup_size(32)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    var acc = 0.0;
""" + "\n".join(uses) + """
    out[gid.x] = acc;
}
"""


def big_expr(n=2000):
    """Single huge expression chain."""
    terms = " + ".join(f"src[gid.x] * {i + 1}.0" for i in range(n))
    return f"""@group(0) @binding(0) var<storage, read> src: array<f32>;
@group(0) @binding(1) var<storage, read_write> out: array<f32>;

@compute @workgroup_size(1)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {{
    out[gid.x] = {terms};
}}
"""


GENS = {
    "torture-deep-nest.wgsl": deep_nest(),
    "torture-many-functions.wgsl": many_functions(),
    "torture-big-array.wgsl": big_array(),
    "torture-many-bindings.wgsl": many_bindings(),
    "torture-big-expr.wgsl": big_expr(),
}

os.makedirs(OUT, exist_ok=True)
for name, content in GENS.items():
    path = os.path.join(OUT, name)
    with open(path, "w", newline="\n") as f:
        f.write(content)
    print(f"wrote {path} ({len(content)} bytes)")
