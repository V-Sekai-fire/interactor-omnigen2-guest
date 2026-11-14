-- The surface of omnigen2.elf. Strings in, strings out, as the persona's guest does.
-- SPDX-License-Identifier: MIT
import Omnigen2.MulMat

namespace Omnigen2

/-- The answer to one request: `mul_mat` runs the op against its fixture, `mul_mat flip` runs the
control, which must not match. -/
def askJson (request : String) : String :=
  let flip := request.trimAscii.toString == "mul_mat flip"
  if request.trimAscii.toString == "mul_mat" || flip then
    "{\"op\":\"mul_mat\",\"flip\":" ++ toString flip ++ ",\"match\":" ++ toString (agrees flip) ++ "}"
  else
    "{\"refused\":\"unknown_op\"}"

end Omnigen2

@[export omnigen2_version_text]
def omnigen2VersionText (_request : String) : String := "omnigen2-guest 0.0.1"

@[export omnigen2_ask_json]
def omnigen2AskJson (request : String) : String := Omnigen2.askJson request
