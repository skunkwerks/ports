# Static NIF example

A minimal C NIF linked into the emulator at build time, so the finished
executable carries it with no shared `.so` to extract at runtime.

## Build

The tool links NIFs itself when you pass `--native`:

```sh
./elixiraotc build greet.exs --native native-c.json -o greet
./greet
```

`native-c.json` names the C source; the tool compiles it against the SDK and
relinks the emulator. For a C NIF the initialization symbol is
`<STATIC_ERLANG_NIF_LIBNAME>_nif_init`, here `greet_nif_init`.

To drive the linking by hand (for tool development), export the native SDK from
a patched OTP tree first (see the top-level README), then:

```sh
cc -I"$SDK/include" -I"$SDK/include/<target>" -c greet.c -o greet.o
ar rcs greet.a greet.o
elixir "$SDK/link.exs" "$SDK" native.json beam.smp
```

## Files

- `greet.c` — the NIF. `STATIC_ERLANG_NIF_LIBNAME` sets the init symbol, and
  `ERL_NIF_INIT(greet, ...)` exports it.
- `greet.exs` — the Erlang side. It calls `:erlang.load_nif` on a path that
  does not exist; the emulator resolves the NIF from its static table instead.
- `native.json` — a descriptor whose `archive` entry points at a prebuilt
  `greet.a` (consumed by the manual `link.exs` flow).
- `native-c.json` — the same NIF described by its C source, so `elixiraotc
  --native` compiles and links it automatically.

## Rust

`rust_greet/` is a minimal rustler crate. Build and link it with a `crate`
entry:

```json
{
  "schema": 1,
  "nifs": [
    {"crate": "rust_greet", "init": "rust_greet_nif_init"}
  ],
  "link_args": []
}
```

```sh
./elixiraotc build rust_greet.exs --native native-rust.json -o rust_greet
./rust_greet
```

The crate builds a `staticlib` (`crate-type = ["staticlib"]`) and depends on
rustler 0.37+ with the `staticlib` feature, which exports
`<crate>_nif_init` (`rust_greet_nif_init`) instead of the dynamic-only
`nif_init`.
