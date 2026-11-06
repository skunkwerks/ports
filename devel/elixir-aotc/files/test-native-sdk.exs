# Integration test against a real patched OTP build and exported SDK.
ExUnit.start()

defmodule NativeSDKTest do
  use ExUnit.Case

  @tag :tmp_dir
  test "relocatable SDK links a NIF without a shared library", %{tmp_dir: dir} do
    otp = System.fetch_env!("OTP") |> Path.expand()
    sdk = System.fetch_env!("NATIVE_SDK") |> Path.expand()
    root = __DIR__
    relocated = Path.join(dir, "relocated sdk")
    File.cp_r!(sdk, relocated)
    fixture = Path.join(root, "test/native_sdk")
    object = Path.join(dir, "probe.o")
    archive = Path.join(dir, "probe.a")
    [sizes] = Path.wildcard("#{otp}/erts/include/*/erl_int_sizes_config.h")

    run!("cc", [
      "-I#{otp}/erts/emulator/beam",
      "-I#{otp}/erts/include",
      "-I#{Path.dirname(sizes)}",
      "-c",
      "#{fixture}/probe.c",
      "-o",
      object
    ])

    run!("ar", ["rcs", archive, object])
    run!("#{otp}/bin/erlc", ["-o", dir, "#{fixture}/static_probe.erl"])
    descriptor = Path.join(dir, "native.json")

    File.write!(
      descriptor,
      JSON.encode!(%{
        "schema" => 1,
        "nifs" => [%{"archive" => archive, "init" => "static_probe_nif_init"}],
        "link_args" => []
      })
    )

    executable = Path.join(dir, "beam.smp")
    run!("elixir", ["#{relocated}/link.exs", relocated, descriptor, executable])

    # Helper programs such as inet_gethost, which kernel starts at boot on Linux,
    # live in the target-specific directory of an OTP build tree.
    [erlaotc] = Path.wildcard("#{otp}/bin/*/erlaotc")
    bindir = Path.dirname(erlaotc)

    {log, status} =
      System.cmd(
        executable,
        [
          "--",
          "-root",
          otp,
          "-bindir",
          bindir,
          "-progname",
          "erl",
          "-home",
          dir,
          "-boot",
          "#{otp}/bin/start_clean",
          "-noshell",
          "-pa",
          dir,
          "-s",
          "static_probe",
          "main"
        ],
        stderr_to_stdout: true
      )

    assert status == 0, log
    assert log =~ "static nif: 42"

    # Also exercise the patched primary archive loader and AOT recording.
    # A plain Erlang boot alone cannot catch stale preloaded init/loader BEAMs.
    release = Path.join(dir, "release")
    releases = Path.join(release, "releases/1")
    File.mkdir_p!(releases)

    apps =
      for app <- ~w(kernel stdlib) do
        {:ok, [{:application, name, properties}]} =
          :file.consult(String.to_charlist("#{otp}/lib/#{app}/ebin/#{app}.app"))

        destination = Path.join(release, "lib/#{app}-#{properties[:vsn]}/ebin")
        File.mkdir_p!(Path.dirname(destination))
        File.cp_r!("#{otp}/lib/#{app}/ebin", destination)
        {name, properties[:vsn]}
      end

    probe = Path.join(release, "lib/static_probe-1/ebin")
    File.mkdir_p!(probe)
    File.cp!("#{dir}/static_probe.beam", "#{probe}/static_probe.beam")
    manifest = JSON.decode!(File.read!("#{sdk}/sdk.json"))
    rel = {:release, {~c"static-nif", ~c"1"}, {:erts, String.to_charlist(manifest["erts"])}, apps}
    File.write!("#{releases}/start.rel", :io_lib.format(~c"~tp.~n", [rel]))
    paths = Path.wildcard("#{release}/lib/*/ebin") |> Enum.map(&String.to_charlist/1)

    assert {:ok, _, []} =
             :systools.make_script(
               String.to_charlist("#{releases}/start"),
               [{:path, paths}, :silent, :no_warn_sasl]
             )

    File.write!("#{release}/releases/start_erl.data", "#{manifest["erts"]} 1\n")
    bundled = Path.join(dir, "bundled")

    {log, status} =
      System.cmd(
        erlaotc,
        [
          "-o",
          bundled,
          release,
          "-noshell",
          "-pa",
          "$ROOT/lib/static_probe-1/ebin",
          "-s",
          "static_probe",
          "main"
        ],
        env: [{"BINDIR", dir}],
        stderr_to_stdout: true
      )

    assert status == 0, log

    runtime = Path.join(dir, "empty-runtime")
    File.mkdir!(runtime)
    File.cp!(bundled, "#{runtime}/probe")
    File.chmod!("#{runtime}/probe", 0o755)

    assert {"static nif: 42\n", 0} =
             System.cmd("#{runtime}/probe", [], cd: runtime, stderr_to_stdout: true)

    assert File.ls!(runtime) == ["probe"]

    # Corruption fails before replacing a previously working emulator.
    previous = File.read!(executable)
    File.write!("#{relocated}/driver_tab.i", "corrupt")

    {log, status} =
      System.cmd(
        "elixir",
        ["#{relocated}/link.exs", relocated, descriptor, executable],
        stderr_to_stdout: true
      )

    assert status != 0
    assert log =~ "SDK digest mismatch"
    assert File.read!(executable) == previous
  end

  defp run!(program, args) do
    {log, status} = System.cmd(program, args, stderr_to_stdout: true)
    assert status == 0, log
  end
end
