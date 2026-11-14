# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
# Runs build/omnigen2.elf in a double-precision Godot with the Sandbox module and judges by its
# RESULT lines. The verdict is the lines, not the exit code.
#   GODOT=<engine binary> elixir tools/test.exs
defmodule Test do
  @lines [
    "RESULT: vmcall omnigen2_version == omnigen2-guest 0.0.1",
    "RESULT: vmcall omnigen2_ask(mul_mat) matches the fixture",
    "RESULT: vmcall omnigen2_ask(mul_mat flip) is refused, the control holds",
    "RESULT: vmcall omnigen2_ask(conv2d) is refused by name"
  ]

  def main do
    File.cd!(Path.expand("..", __DIR__))
    godot = System.get_env("GODOT") || fail("set GODOT")
    File.cp!("build/omnigen2", "project/omnigen2.elf")
    System.cmd(godot, ["--path", "project", "--import", "--quit-after", "5"], stderr_to_stdout: true)

    {out, _} =
      System.cmd(godot, ["--path", "project", "--script", "run.gd", "--quit-after", "300"],
        stderr_to_stdout: true
      )

    IO.puts(out)
    missing = for l <- @lines, not String.contains?(out, l), do: l
    if out =~ "RESULT: FAIL" or missing != [], do: fail("missing: #{inspect(missing)}")
    IO.puts("RESULT: PASS")
  end

  defp fail(msg) do
    IO.puts("RESULT: FAIL #{msg}")
    System.halt(1)
  end
end

Test.main()
