# A NIF compiled into the emulator as a static library, so the executable
# carries it with no shared .so to extract at runtime.
defmodule Greet do
  # The path does not exist: dispatch is resolved from the emulator's static
  # NIF table, not from a shared library on disk.
  @on_load :load_nif
  def load_nif, do: :erlang.load_nif('/does/not/exist/greet', 0)

  def greet(_name), do: :erlang.nif_error(:not_loaded)
end

IO.puts(Greet.greet("elixiraotc"))
