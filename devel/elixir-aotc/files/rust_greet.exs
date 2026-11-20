# A Rustler NIF compiled as a staticlib and linked into the emulator, so the
# executable carries it with no shared .so to extract at runtime. rustler 0.37+
# exports <crate>_nif_init when built with the "staticlib" feature.
defmodule RustGreet do
  # The path does not exist: dispatch is resolved from the emulator's static
  # NIF table, not from a shared library on disk.
  @on_load :load_nif
  def load_nif, do: :erlang.load_nif('/does/not/exist/rust_greet', 0)

  def greet(_name), do: :erlang.nif_error(:not_loaded)
end

IO.puts(RustGreet.greet("elixiraotc"))
