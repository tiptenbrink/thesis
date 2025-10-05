(** * Maps: Total and Partial Maps *)

(* This file is taken exactly from the Maps.v module from Logical Foundations:
https://softwarefoundations.cis.upenn.edu/lf-current/Maps.html
All unnecessary imports, definitions and lemmas have been removed. *)

Require Export Coq.Strings.String.

Definition total_map (A : Type) := string -> A.

Definition t_empty {A : Type} (v : A) : total_map A :=
  (fun _ => v).

Definition t_update {A : Type} (m : total_map A)
                    (x : string) (v : A) :=
  fun x' => if String.eqb x x' then v else m x'.


Notation "'_' '!->' v" := (t_empty v)
  (at level 100, right associativity).


Notation "x '!->' v ';' m" := (t_update m x v)
                              (at level 100, v at next level, right associativity).


Lemma t_update_eq : forall (A : Type) (m : total_map A) x v,
  (x !-> v ; m) x = v.
Proof.
  intros A m x v. unfold t_update.
  rewrite String.eqb_refl. reflexivity.
Qed.


Theorem t_update_neq : forall (A : Type) (m : total_map A) x1 x2 v,
  x1 <> x2 ->
  (x1 !-> v ; m) x2 = m x2.
Proof.
  intros A m x1 x2 v.
  intros H. unfold t_update.
  apply String.eqb_neq in H.
  rewrite H. reflexivity.
Qed.