# Op census: Qwen2.5-VL vision tower and LLM, against ggml-rd

Source: leejet/stable-diffusion.cpp b9d7176, `src/model/te/llm.hpp` (vision tower lines 1001-1450). ggml-rd: contract-ggml-rd at 94b6be4, `guest/ggml-rd/ops`.
This is a static triage. The authoritative check builds the graph and runs every node through `supports_op`.

OmniGen2 has no entry in stable-diffusion.cpp (grep for "omnigen" finds nothing). EditScore7B-v1.1 is a LoRA on Qwen2.5-VL-7B and only scores; generation needs the separate OmniGen2 weights (3B MLLM, DiT, Flux VAE).

## Vision tower ops

| Op | ggml-rd |
|---|---|
| reshape, view, get_rows, add, concat, slice | registered |
| conv_3d patch embed (`Conv3d`, or two Conv2d when split) | registered (CONV_3D, CONV_2D) |
| LayerNorm / RMSNorm | registered (NORM, RMS_NORM) |
| mul_mat (qkv, proj, MLP) | registered, f32/f16/bf16 only |
| gelu_erf | registered |
| attention with window mask | FLASH_ATTN_EXT registered |
| swiglu_split (VisionMLP) | GAP: only GLU sub-op GEGLU_ERF is registered |
| 2D rotary embedding (`Rope::apply_rope`, `rope_ext`) | GAP: ROPE accepts only NEOX, f32, no frequency factors |

## LLM ops beyond the vision tower

| Op | ggml-rd |
|---|---|
| rope_multi MROPE (Qwen2.5-VL) | GAP: refused by `ops/rope.cpp` |
| swiglu, swiglu_split | GAP |
| silu, sigmoid, softplus, step | silu, sigmoid, step registered; softplus not checked |
| rms_norm, soft_max, scale, repeat, cont, cpy | registered |

## Gaps to close first

1. ROPE modes MROPE and VISION, and the f16/bf16 inputs if the model needs them.
2. GLU sub-op SWIGLU (and swiglu_split).
3. Quantized GGUF weights need new kernels; start with BF16.
