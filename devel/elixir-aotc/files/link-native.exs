# This file is copied into each SDK, so it must remain standalone.
defmodule LinkNative do
  def run([sdk, descriptor, output]) do
    sdk = Path.expand(sdk)
    output = Path.expand(output)
    manifest = sdk |> Path.join("sdk.json") |> File.read!() |> JSON.decode!()
    %{"schema" => 1, "files" => files} = manifest
    native = descriptor |> File.read!() |> JSON.decode!()
    %{"schema" => 1, "nifs" => nifs, "link_args" => native_args} = native

    for {path, expected} <- files do
      if Path.type(path) != :relative or ".." in Path.split(path),
        do: raise("unsafe SDK path: #{path}")

      unless digest(Path.join(sdk, path)) == expected, do: raise("SDK digest mismatch: #{path}")
    end

    for "$SDK/" <> path <- manifest["link_args"] do
      unless Map.has_key?(files, path), do: raise("SDK does not inventory #{path}")
    end

    unless Map.has_key?(files, "driver_tab.i"),
      do: raise("SDK does not inventory driver_tab.i")

    symbols = Enum.map(nifs, &Map.fetch!(&1, "init"))

    unless symbols != [] and Enum.uniq(symbols) == symbols and
             Enum.all?(symbols, &Regex.match?(~r/\A[A-Za-z_][A-Za-z0-9_]*\z/, &1)) do
      raise "NIF initialization symbols must be nonempty, unique C identifiers"
    end

    archives =
      Enum.map(nifs, fn %{"archive" => archive} ->
        archive = Path.expand(archive, Path.dirname(Path.expand(descriptor)))
        unless File.regular?(archive), do: raise("missing static NIF archive: #{archive}")
        archive
      end)

    File.mkdir_p!(Path.dirname(output))
    workspace = output <> ".link-" <> Base.encode16(:crypto.strong_rand_bytes(12))
    File.mkdir!(workspace)

    try do
      driver = Path.join(workspace, "driver_tab.i")
      object = Path.join(workspace, "driver_tab.o")

      source =
        sdk
        |> Path.join("driver_tab.i")
        |> File.read!()
        |> String.split("\n")
        |> Enum.flat_map(fn line ->
          if String.contains?(line, "ELIXIRAOTC_NIF_INIT") do
            Enum.map(symbols, &String.replace(line, "ELIXIRAOTC_NIF_INIT", &1))
          else
            [line]
          end
        end)
        |> Enum.join("\n")

      unless source =~ hd(symbols), do: raise("SDK is missing its NIF registration template")
      File.write!(driver, source)
      command!("cc", ["-c", driver, "-o", object])

      args =
        Enum.flat_map(manifest["link_args"], fn
          "$DRIVER" -> [object]
          "$NATIVE" -> archives ++ native_args
          "$SDK/" <> path -> [Path.join(sdk, path)]
          arg -> [arg]
        end)

      staged = Path.join(workspace, "beam.smp")
      command!(manifest["linker"], ["-o", staged | args])
      File.rename!(staged, output)
      IO.puts("Linked #{output}")
    after
      File.rm_rf!(workspace)
    end
  end

  def run(_), do: raise("usage: elixir SDK/link.exs SDK NATIVE_JSON OUTPUT")
  defp digest(path), do: :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

  defp command!(program, args) do
    {_, status} =
      System.cmd(program, args, into: IO.stream(:stdio, :line), stderr_to_stdout: true)

    if status != 0, do: raise("#{program} exited with #{status}")
  end
end

LinkNative.run(System.argv())
