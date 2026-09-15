//! Per-shader, per-stage translation benchmarks for naga.
//!
//! Corpus is discovered from NAGA_BENCH_CORPUS (default: ../corpus).
//! Only WGSL files that parse AND validate are benchmarked; failures are
//! reported once at startup so corpus problems are visible.

use std::hint::black_box;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};

/// Parsed + validated module cached per corpus file, plus which writer
/// stages succeeded in a warm-up pass (those that fail are never registered).
struct Prepared {
    module: &'static naga::Module,
    info: &'static naga::valid::ModuleInfo,
    spv_ok: bool,
    hlsl_ok: bool,
    msl_ok: bool,
}

fn corpus_dir() -> PathBuf {
    std::env::var_os("NAGA_BENCH_CORPUS")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("../corpus"))
}

fn collect_wgsl(dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(rd) = std::fs::read_dir(dir) else {
        return;
    };
    for e in rd.flatten() {
        let p = e.path();
        if p.is_dir() {
            collect_wgsl(&p, out);
        } else if p.extension().is_some_and(|x| x == "wgsl") {
            out.push(p);
        }
    }
}

fn validator() -> naga::valid::Validator {
    naga::valid::Validator::new(
        naga::valid::ValidationFlags::all(),
        naga::valid::Capabilities::all(),
    )
}

fn cache() -> &'static Vec<(String, PathBuf, Prepared)> {
    static CACHE: OnceLock<Vec<(String, PathBuf, Prepared)>> = OnceLock::new();
    CACHE.get_or_init(|| {
        let mut files = Vec::new();
        collect_wgsl(&corpus_dir(), &mut files);
        files.sort();
        let mut failed = 0usize;
        let out = files
            .into_iter()
            .filter_map(|p| {
                let name = p
                    .file_stem()
                    .map(|s| s.to_string_lossy().into_owned())
                    .unwrap_or_default();
                let src = std::fs::read_to_string(&p).ok()?;
                let module = match naga::front::wgsl::parse_str(&src) {
                    Ok(m) => m,
                    Err(_) => {
                        failed += 1;
                        eprintln!("[skip] parse failed: {}", p.display());
                        return None;
                    }
                };
                let info = match validator().validate(&module) {
                    Ok(i) => i,
                    Err(e) => {
                        failed += 1;
                        eprintln!("[skip] validate failed: {} ({e})", p.display());
                        return None;
                    }
                };
                let spv_ok =
                    naga::back::spv::write_vec(&module, &info, &naga::back::spv::Options::default(), None)
                        .is_ok();
                let hlsl_opts = naga::back::hlsl::Options::default();
                let hlsl_pipe = naga::back::hlsl::PipelineOptions::default();
                let hlsl_ok = {
                    let mut out = String::new();
                    let mut writer = naga::back::hlsl::Writer::new(&mut out, &hlsl_opts, &hlsl_pipe);
                    writer.write(&module, &info, None).is_ok()
                };
                let msl_opts = naga::back::msl::Options::default();
                let msl_pipe = naga::back::msl::PipelineOptions::default();
                let msl_ok = naga::back::msl::write_string(&module, &info, &msl_opts, &msl_pipe).is_ok();
                for (ok, stage) in [(spv_ok, "spv"), (hlsl_ok, "hlsl"), (msl_ok, "msl")] {
                    if !ok {
                        failed += 1;
                        eprintln!("[skip] {stage} writer failed: {}", p.display());
                    }
                }
                let module: &'static _ = Box::leak(Box::new(module));
                let info: &'static _ = Box::leak(Box::new(info));
                Some((
                    name,
                    p,
                    Prepared {
                        module,
                        info,
                        spv_ok,
                        hlsl_ok,
                        msl_ok,
                    },
                ))
            })
            .collect::<Vec<_>>();
        if failed > 0 {
            eprintln!("[corpus] {failed} file(s) excluded (parse/validate failure)");
        }
        eprintln!("[corpus] {} file(s) benchmarked", out.len());
        out
    })
}

fn bench_translate(c: &mut Criterion) {
    let mut group = c.benchmark_group("naga");
    let corpus = cache();
    let spv_opts = naga::back::spv::Options::default();
    let hlsl_opts = naga::back::hlsl::Options::default();
    let hlsl_pipe = naga::back::hlsl::PipelineOptions::default();
    let msl_opts = naga::back::msl::Options::default();
    let msl_pipe = naga::back::msl::PipelineOptions::default();

    for (name, path, prepared) in corpus.iter() {
        let Prepared {
            module,
            info,
            spv_ok,
            hlsl_ok,
            msl_ok,
        } = *prepared;
        let src = std::fs::read_to_string(path).expect("corpus file readable");
        group.throughput(Throughput::Bytes(src.len() as u64));

        group.bench_function(BenchmarkId::new("parse", name), |b| {
            b.iter(|| naga::front::wgsl::parse_str(black_box(&src)).unwrap())
        });

        group.bench_function(BenchmarkId::new("validate", name), |b| {
            b.iter(|| validator().validate(black_box(module)).unwrap())
        });

        if spv_ok {
            group.bench_function(BenchmarkId::new("spv", name), |b| {
                b.iter(|| {
                    naga::back::spv::write_vec(black_box(module), info, &spv_opts, None).unwrap()
                })
            });
        }

        if hlsl_ok {
            group.bench_function(BenchmarkId::new("hlsl", name), |b| {
                b.iter(|| {
                    let mut out = String::new();
                    let mut writer =
                        naga::back::hlsl::Writer::new(&mut out, &hlsl_opts, &hlsl_pipe);
                    writer.write(black_box(module), info, None).unwrap();
                })
            });
        }

        if msl_ok {
            group.bench_function(BenchmarkId::new("msl", name), |b| {
                b.iter(|| {
                    naga::back::msl::write_string(black_box(module), info, &msl_opts, &msl_pipe)
                        .unwrap()
                })
            });
        }
    }
    group.finish();
}

criterion_group!(benches, bench_translate);

/// criterion_main! runs benches on the main thread (1 MB stack on Windows).
/// Deeply-nested torture shaders overflow recursive parsers, so run on a
/// thread with a large stack instead.
fn main() {
    let worker = std::thread::Builder::new()
        .name("criterion".into())
        .stack_size(1024 * 1024 * 1024)
        .spawn(benches)
        .expect("failed to spawn criterion thread");
    worker.join().expect("criterion thread panicked");
}
