# interactor-omnigen2-guest

OmniGen2 generation and EditScore scoring as a godot-sandbox guest, written in Lean 4.

## What is here

- `Omnigen2/MulMat.lean`: ggml's `mul_mat` on flat row-major arrays, the first op of the port, with a fixture worked out outside Lean and a control that moves one fixture value.
- `Omnigen2/Guest.lean`: the guest's surface, strings in and strings out. `mul_mat` runs the op against its fixture, `mul_mat flip` runs the control, and any other request is refused by name.
- `Omnigen2Witness.lean`: the same checks on the host, as `lake exe omnigen2_witness`.
- `guest/`: the shim and the CMake file that link the Lean into a riscv64 ELF with `interactor-lean-guest` and `contract-guest-runtime`.
- `project/run.gd` and `tools/test.exs`: the gate in a double-precision Godot with the Sandbox module.

## The surface

    omnigen2_version() -> String      the version of this surface
    omnigen2_ask(request) -> String   the answer to one request, as JSON, or the refusal by name

## Build and run

    lake build omnigen2_witness && lake exe omnigen2_witness
    cmake -S guest -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=<ws>/5-repository/riscv64-sysroot/toolchain.cmake \
      -DGUEST_RUNTIME_ROOT=<ws>/2-contract/guest-runtime \
      -DLEAN_GUEST_DIR=<ws>/3-interactor/lean-guest
    cmake --build build --target omnigen2
    GODOT=<engine binary> elixir tools/test.exs

The build needs clang and lld from the pixi environment of `5-repository/riscv64-sysroot` first on `PATH`, and `ELAN_TOOLCHAIN=leanprover/lean4:v4.34.1`.

## Status

One op, `mul_mat`. The port plan for the rest is in `contract-editscore-mojo`: the Qwen2.5-VL conditioner, the transformer, the VAE, the LoRA merge and the sampler.

## Licence

MIT; see `LICENSE`.
