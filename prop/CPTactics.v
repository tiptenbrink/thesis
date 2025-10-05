From Coq Require Strings.String.
From Coq Require Arith.PeanoNat.
From Coq Require ZArith.BinInt.

Ltac destruct_eqb x y :=
  let H := fresh "H" in
  lazymatch type of x with
  | nat => destruct (Nat.eqb x y) eqn:H; [rewrite PeanoNat.Nat.eqb_eq in H; subst | rewrite PeanoNat.Nat.eqb_neq in H]
  | BinInt.Z => destruct (BinInt.Z.eqb x y) eqn:H; [rewrite BinInt.Z.eqb_eq in H; subst | rewrite BinInt.Z.eqb_neq in H]
  | String.string => destruct (String.eqb x y) eqn:H; [rewrite String.eqb_eq in H; subst | rewrite String.eqb_neq in H]
  | _ => fail "Unsupported type for destruct_eqb"
  end; try congruence.  