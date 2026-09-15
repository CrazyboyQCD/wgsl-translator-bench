@group(0) @binding(0) var<storage, read_write> out: array<f32>;

@compute @workgroup_size(1)
fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    var sum = f32(gid.x);
    sum = sum + 1.0;
    if (sum > 0.0) {
        sum = sum * 0.999 + 0.1;
        if (sum > 0.0) {
            sum = sum * 0.999 + 0.1;
            if (sum > 0.0) {
                sum = sum * 0.999 + 0.1;
                if (sum > 0.0) {
                    sum = sum * 0.999 + 0.1;
                    if (sum > 0.0) {
                        sum = sum * 0.999 + 0.1;
                        if (sum > 0.0) {
                            sum = sum * 0.999 + 0.1;
                            if (sum > 0.0) {
                                sum = sum * 0.999 + 0.1;
                                if (sum > 0.0) {
                                    sum = sum * 0.999 + 0.1;
                                    if (sum > 0.0) {
                                        sum = sum * 0.999 + 0.1;
                                        if (sum > 0.0) {
                                            sum = sum * 0.999 + 0.1;
                                            if (sum > 0.0) {
                                                sum = sum * 0.999 + 0.1;
                                                if (sum > 0.0) {
                                                    sum = sum * 0.999 + 0.1;
                                                    if (sum > 0.0) {
                                                        sum = sum * 0.999 + 0.1;
                                                        if (sum > 0.0) {
                                                            sum = sum * 0.999 + 0.1;
                                                            if (sum > 0.0) {
                                                                sum = sum * 0.999 + 0.1;
                                                                if (sum > 0.0) {
                                                                    sum = sum * 0.999 + 0.1;
                                                                    if (sum > 0.0) {
                                                                        sum = sum * 0.999 + 0.1;
                                                                        if (sum > 0.0) {
                                                                            sum = sum * 0.999 + 0.1;
                                                                            if (sum > 0.0) {
                                                                                sum = sum * 0.999 + 0.1;
                                                                                if (sum > 0.0) {
                                                                                    sum = sum * 0.999 + 0.1;
                                                                                    if (sum > 0.0) {
                                                                                        sum = sum * 0.999 + 0.1;
                                                                                        if (sum > 0.0) {
                                                                                            sum = sum * 0.999 + 0.1;
                                                                                            if (sum > 0.0) {
                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                if (sum > 0.0) {
                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                    if (sum > 0.0) {
                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                        if (sum > 0.0) {
                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                            if (sum > 0.0) {
                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                if (sum > 0.0) {
                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                    if (sum > 0.0) {
                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                        if (sum > 0.0) {
                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                            if (sum > 0.0) {
                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                if (sum > 0.0) {
                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                    if (sum > 0.0) {
                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                        if (sum > 0.0) {
                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                    if (sum > 0.0) {
                                                                                                                                                                                                                                                        sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                        if (sum > 0.0) {
                                                                                                                                                                                                                                                            sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                            if (sum > 0.0) {
                                                                                                                                                                                                                                                                sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                                if (sum > 0.0) {
                                                                                                                                                                                                                                                                    sum = sum * 0.999 + 0.1;
                                                                                                                                                                                                                                                                    sum = sum - 1.0;
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                }
                                                                                                                                                                                                                            }
                                                                                                                                                                                                                        }
                                                                                                                                                                                                                    }
                                                                                                                                                                                                                }
                                                                                                                                                                                                            }
                                                                                                                                                                                                        }
                                                                                                                                                                                                    }
                                                                                                                                                                                                }
                                                                                                                                                                                            }
                                                                                                                                                                                        }
                                                                                                                                                                                    }
                                                                                                                                                                                }
                                                                                                                                                                            }
                                                                                                                                                                        }
                                                                                                                                                                    }
                                                                                                                                                                }
                                                                                                                                                            }
                                                                                                                                                        }
                                                                                                                                                    }
                                                                                                                                                }
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    out[gid.x] = sum;
}
