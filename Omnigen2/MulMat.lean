-- ggml's mul_mat on flat row-major arrays, the first op of the OmniGen2 and EditScore port.
-- SPDX-License-Identifier: MIT

namespace Omnigen2

/-- The sum of `a[ao + t] * b[bo + t]` for `t` from 0 up to the fuel, added onto `acc`. -/
def dotAux (a b : FloatArray) (ao bo : Nat) : Nat → Nat → Float → Float
  | 0, _, acc => acc
  | fuel + 1, t, acc => dotAux a b ao bo fuel (t + 1) (acc + a.get! (ao + t) * b.get! (bo + t))

/-- `a` holds `m` rows of `k`, `b` holds `n` rows of `k`, and the result holds `n` rows of `m`. -/
def mulMat (a b : FloatArray) (k m n : Nat) : FloatArray := Id.run do
  let mut dst := FloatArray.empty
  for j in [0:n] do
    for i in [0:m] do
      dst := dst.push (dotAux a b (i * k) (j * k) k 0 0.0)
  return dst

def K : Nat := 4
def M : Nat := 3
def N : Nat := 2

def fixtureA : FloatArray :=
  FloatArray.mk ((Array.range (K * M)).map fun i => Float.ofNat (i + 1))

def fixtureB : FloatArray :=
  FloatArray.mk ((Array.range (K * N)).map fun i => Float.ofInt ((Int.ofNat i) - 4))

/-- Worked out outside this file with numpy: `B @ A.T` for the two inputs above. -/
def fixtureDst : FloatArray :=
  FloatArray.mk #[-20.0, -60.0, -100.0, 20.0, 44.0, 68.0]

/-- True when `mulMat` gives the fixture. With `flip` one value of the fixture is moved first, so
the answer must be false: that is the control. -/
def agrees (flip : Bool) : Bool :=
  let got := mulMat fixtureA fixtureB K M N
  let want := if flip then fixtureDst.set! 0 (fixtureDst.get! 0 + 1.0) else fixtureDst
  got.size == want.size && (List.range got.size).all fun i => got.get! i == want.get! i

end Omnigen2
