import Lake
open Lake DSL

package omnigen2

lean_lib Omnigen2 where
  roots := #[`Omnigen2.Guest]
  globs := #[.submodules `Omnigen2]

lean_exe omnigen2_witness where
  root := `Omnigen2Witness
