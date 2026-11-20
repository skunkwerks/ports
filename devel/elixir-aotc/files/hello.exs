# Dependency-free example. This runs fully offline: no Mix.install/2, so the
# resulting executable needs no Hex fetch at run time. Demonstrates the AOT
# emulator spawning a task, passing a message, and debugging both sides.
pid = self()

Task.async(fn ->
  dbg(self())
  send(pid, {:hi, self()})
end)

receive do
  message ->
    dbg(message)
end
