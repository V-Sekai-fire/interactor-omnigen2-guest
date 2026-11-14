-- The gate of the op on the host: the op matches its fixture and the control does not.
-- SPDX-License-Identifier: MIT
import Omnigen2.Guest

def main : IO UInt32 := do
  let clean := Omnigen2.askJson "mul_mat"
  let control := Omnigen2.askJson "mul_mat flip"
  let refused := Omnigen2.askJson "conv2d"
  IO.println clean
  IO.println control
  IO.println refused
  let ok := clean.endsWith "\"match\":true}" && control.endsWith "\"match\":false}" &&
    refused == "{\"refused\":\"unknown_op\"}"
  IO.println (if ok then "RESULT: PASS" else "RESULT: FAIL")
  return (if ok then 0 else 1)
