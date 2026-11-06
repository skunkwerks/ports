# Run with Elixir 1.20+ after building the patched OTP tree.
defmodule ExportNativeSDK do
  def run([otp, output]) do
    otp = Path.expand(otp)
    output = Path.expand(output)
    emulator = Path.join(otp, "erts/emulator")
    [makefile] = Path.wildcard(Path.join(emulator, "*-*/Makefile"))
    target = makefile |> Path.dirname() |> Path.basename()
    source = Path.join([emulator, target, "opt", "jit", "driver_tab.c"])
    File.mkdir!(output)

    try do
      template =
        source
        |> File.read!()
        |> String.replace(
          "ErtsStaticNif erts_static_nif_tab[] =\n{",
          """
          void *ELIXIRAOTC_NIF_INIT(void);
          ErtsStaticNif erts_static_nif_tab[] =
          {
              {&ELIXIRAOTC_NIF_INIT, 1, THE_NON_VALUE, NULL},
          """
          |> String.trim_trailing()
        )

      unless template =~ "ELIXIRAOTC_NIF_INIT", do: raise("unrecognized OTP static NIF table")
      File.write!(Path.join(output, "driver_tab.c"), template)

      command!(
        make_command(),
        [
          "--no-print-directory",
          "-f",
          makefile,
          "-f",
          Path.join(__DIR__, "native-sdk.mk"),
          "TYPE=opt",
          "FLAVOR=jit",
          "TARGET=#{target}",
          "SDK_DIR=#{output}",
          "SDK_SOURCE=#{output}/driver_tab.c",
          "export-native-sdk"
        ],
        cd: emulator,
        env: [{"ERL_TOP", otp}]
      )

      [linker | args] =
        output
        |> Path.join("link.argv")
        |> File.read!()
        |> String.split(<<0>>, trim: true)

      library_paths =
        for "-L" <> path <- args, do: Path.expand(path, emulator)

      File.mkdir!(Path.join(output, "files"))

      args =
        Enum.flat_map(args, fn arg ->
          cond do
            String.starts_with?(arg, "-L") ->
              []

            arg == "NATIVE_INPUTS" ->
              ["$NATIVE"]

            Path.basename(arg) == "driver_tab.o" ->
              ["$DRIVER"]

            String.starts_with?(arg, "-l") ->
              name = String.replace_prefix(arg, "-l", "")

              case Enum.find(library_paths, &File.regular?(Path.join(&1, "lib#{name}.a"))) do
                nil -> [arg]
                dir -> [copy!(Path.join(dir, "lib#{name}.a"), output)]
              end

            Path.extname(arg) in [".o", ".a"] ->
              [copy!(Path.expand(arg, emulator), output)]

            true ->
              [arg]
          end
        end)

      unless "$DRIVER" in args, do: raise("OTP link did not contain driver_tab.o")
      File.cp!(Path.join(__DIR__, "link-native.exs"), Path.join(output, "link.exs"))
      File.rm!(Path.join(output, "driver_tab.c"))
      File.rm!(Path.join(output, "link.argv"))

      version_header = File.read!(Path.join([emulator, target, "erl_version.h"]))
      [_, version] = Regex.run(~r/#define ERLANG_VERSION "([^"]+)"/, version_header)

      # Record.extract_lib and Erlang's preprocessor need real include files at
      # build time. They are not present in the bootstrap's embedded archive.
      for appfile <- Path.wildcard(Path.join(otp, "lib/*/ebin/*.app")) do
        {:ok, [{:application, app, properties}]} = :file.consult(String.to_charlist(appfile))
        include = Path.join([Path.dirname(Path.dirname(appfile)), "include"])

        if File.dir?(include) do
          destination =
            Path.join([output, "include", "#{app}-#{properties[:vsn]}", "include"])

          File.mkdir_p!(Path.dirname(destination))
          File.cp_r!(include, destination)
        end
      end

      # erl_nif.h -> erl_drv_nif.h includes the per-target generated
      # erl_int_sizes_config.h, which the app include loop above does not pick
      # up. Ship the erts include tree so NIFs compile against the SDK alone.
      for erts_include <- File.ls!(Path.join(otp, "erts/include")) do
        src = Path.join([otp, "erts/include", erts_include])
        dst = Path.join(output, "include")

        if File.dir?(src) do
          File.cp_r!(src, Path.join(dst, erts_include))
        else
          File.cp!(src, Path.join(dst, erts_include))
        end
      end

      # The NIF API declarations live under erts/emulator/beam/, not
      # erts/include/. Copy the handful a NIF author #includes so compiling
      # against the SDK does not need the OTP build tree.
      for nif_header <- ~w(erl_nif.h erl_drv_nif.h erl_driver.h erl_nif_api_funcs.h) do
        File.cp!(
          Path.join([otp, "erts/emulator/beam", nif_header]),
          Path.join([output, "include", nif_header])
        )
      end

      # erl_drv_nif.h does a flat `#include "erl_int_sizes_config.h"`, so the
      # generated per-target header must also sit directly in include/ for a
      # NIF to compile with a single -I flag (no target subdir lookup).
      case Path.wildcard(Path.join(otp, "erts/include/*/erl_int_sizes_config.h")) do
        [config | _] -> File.cp!(config, Path.join(output, "include/erl_int_sizes_config.h"))
        [] -> raise("no generated erl_int_sizes_config.h under erts/include")
      end

      files =
        for file <- Path.wildcard(Path.join(output, "**/*")), File.regular?(file), into: %{} do
          {Path.relative_to(file, output), digest(file)}
        end

      manifest = %{
        "schema" => 1,
        "target" => target,
        "erts" => version,
        "linker" => Path.basename(linker),
        "link_args" => args,
        "files" => files
      }

      File.write!(Path.join(output, "sdk.json"), JSON.encode!(manifest) <> "\n")
      IO.puts("Exported native SDK to #{output}")
    rescue
      error ->
        File.rm_rf!(output)
        reraise error, __STACKTRACE__
    end
  end

  def run(_), do: raise("usage: elixir scripts/export-native-sdk.exs OTP_BUILD NEW_SDK_DIRECTORY")

  # OTP is GNU-make only. On FreeBSD the program is `gmake`; elsewhere it is
  # `make`.
  defp make_command, do: System.find_executable("gmake") || "make"

  defp copy!(source, output) do
    name = "files/#{digest(source)}-#{Path.basename(source)}"
    File.cp!(source, Path.join(output, name))
    "$SDK/" <> name
  end

  defp digest(path), do: :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

  defp command!(program, args, opts) do
    {_, status} =
      System.cmd(program, args, opts ++ [into: IO.stream(:stdio, :line), stderr_to_stdout: true])

    if status != 0, do: raise("#{program} exited with #{status}")
  end
end

ExportNativeSDK.run(System.argv())
