From Coq Require Import Lists.List.
From Coq Require Import Strings.String.
Require Import Arith.

Definition var := string.

Definition all_different := list var.

Inductive domain := 
| int : list nat -> nat -> nat -> domain
| fixed : nat -> domain.
(* We want to go through it pairwise *)

(* Holes, min, max *)

(* Suppose we have inference: y = 3 -> not x = 3; this is the clause not y = 3 or not x = 3 *)
(* We must then show that y = 3 and x = 3 leads to a conflict *)

Inductive result :=
| conflict
| noConflict.

(* Definition detect_conflict_all_diff_pairwise (constr: all_different) (st : list atomic)  *)


Definition state := var -> domain.


(* For every variable, find out if it is fixed, then, make sure any other variable is not fixed *)

Definition fixedValuesOption := list (option nat).

Definition fixedValues := list nat.

Definition mapFixed (v: var) (st : state) : option nat :=
    match st v with
    | fixed n => Some n
    | _ => None
    end.

Definition findFixedOptions (constr: all_different) (st : state) : fixedValuesOption :=
    map (fun v => mapFixed v st) constr.

Definition collapseOptions { A : Type} (l : list (option A)) : list A :=
    flat_map (fun x => match x with
    | Some n => n :: nil
    | None => nil
    end) l.

Definition findFixedAll (constr: all_different) (st : state) : fixedValues :=
    collapseOptions (findFixedOptions constr st).

Lemma collapsePreservesSome : forall (l : list (option nat)) (n : nat),
    In (Some n) l <-> In n (collapseOptions l).
Proof.
  intros l n.
  induction l as [| nOpt l IH].
  - simpl. reflexivity.
  - split.
    + intros Hin. destruct Hin as [Hasomen | Hninl].
      * rewrite Hasomen. simpl. apply in_eq.
      * apply in_app_iff. right. apply IH. exact Hninl.
    + intros Hin. simpl. destruct nOpt as [n' | ] eqn:Haopt.
      * destruct (n =? n') eqn:Hnn'.
        {
         rewrite Nat.eqb_eq in Hnn'. subst n'. left. reflexivity. 
        }
        {
         simpl in Hin. destruct Hin as [Heq | Hinl].
         - rewrite Nat.eqb_neq in Hnn'. rewrite Heq in Hnn'. contradiction.
         - right. rewrite IH. exact Hinl.
        }
      * simpl in Hin. right. rewrite IH. exact Hin.
Qed.

Definition propagate_one (v : var) (c : all_different) (st : state) : bool :=
    match (st v) with
    | fixed n => existsb (fun n' => Nat.eqb n' n) (findFixedAll (remove string_dec v c) st)
    | _ => false
    end.

Fixpoint propagate_all_diff_iter (vars : list var) (constr: all_different) (st : state) :=
    match vars with
    | nil => noConflict
    | v :: vars_r => if (propagate_one v constr st) then conflict else propagate_all_diff_iter vars_r constr st
    end
.

Lemma propagate_all_one_prop_bi : forall (vars: list var) (c : all_different) (st : state),
    propagate_all_diff_iter vars c st = conflict <-> exists v, In v vars /\ propagate_one v c st = true.
Proof.
  intros vars c st.
  induction vars as [| v vars' IH].
  - split. 
    + intros Hconfl. simpl in Hconfl. inversion Hconfl.
    + intros Hex. destruct Hex as [v [Hin Hprop]]. destruct Hin.
  - split. 
    + intros Hconfl. simpl in Hconfl. destruct (propagate_one v c st) eqn:Hprop.
      * exists v. split. apply in_eq. exact Hprop.
      * apply IH in Hconfl. destruct Hconfl as [v' [Hin Hprop']].
      exists v'. split. apply in_cons. exact Hin. exact Hprop'.
    + intros Hex. destruct Hex as [v' [Hin Hprop]]. destruct Hin.
      * simpl. rewrite H. rewrite Hprop. reflexivity.
      * simpl. destruct (propagate_one v c st) eqn:Hprop'.
        { reflexivity. }
        { apply IH. exists v'. split. 
          - exact H.
          - exact Hprop. 
        }
Qed.

Definition propagate_all_diff (constr: all_different) (st : state) :=
    propagate_all_diff_iter constr constr st
.

Compute (propagate_all_dif ("x"%string :: nil) (fun x => fixed 3)).

Definition AllDifferent (c : all_different) (st : state) : Prop :=
  forall (x y : var) (n m : nat),
    In x c -> In y c -> x <> y -> st x = fixed n -> st y = fixed m -> n <> m
.

Lemma propagate_one_two_fixed_rev : forall (v : var) (c : all_different) (st : state),
    (exists (x : var) (n m : nat), In x c /\ x <> v /\ st v = fixed n /\ st x = fixed m /\ n = m) -> propagate_one v c st = true.
Proof.
  intros v c st.
  intros Hex. destruct Hex as [x [n [m [Hxinc [Hxneqv [Hfvn [Hfxm Hnm]]]]]]].
  unfold propagate_one. rewrite Hfvn. apply existsb_exists. exists m. split.
  - unfold findFixedAll. rewrite <- collapsePreservesSome. unfold findFixedOptions.
    apply in_map_iff. exists x. split.
    + unfold mapFixed. rewrite Hfxm. reflexivity.
    + apply in_in_remove.
      * exact Hxneqv.
      * exact Hxinc.
  - rewrite Nat.eqb_eq. symmetry. exact Hnm.
Qed.

Theorem all_diff_prop_correct : forall (c : all_different) (st : state),
  ~ AllDifferent c st -> propagate_all_diff c st = conflict.
Proof.
  intros c st.
  intros Hdiff. unfold AllDifferent in Hdiff. unfold not in Hdiff.
    destruct (propagate_all_diff c st) eqn:Hconf. reflexivity.
    destruct Hdiff.
    intros x y n m Hxinc Hyinc Hneq Hfxn Hfym Hnism.
    enough (propagate_all_diff c st = conflict).
    { rewrite H in Hconf. inversion Hconf. }
    unfold propagate_all_diff. apply propagate_all_one_prop_bi.
    exists y. split. exact Hyinc.
    apply propagate_one_two_fixed_rev.
    exists x. exists m. exists n.
    split. exact Hxinc.
    split. exact Hneq.
    split. exact Hfym.
    split. exact Hfxn.
    symmetry. exact Hnism.
Qed.

Definition all_diff_with_conflict (c : all_different) (st : state) (var_1 : var) (var_2 : var) : result :=
  if (var_1 =? var_2)%string
    then noConflict
    else
      match (st var_1, st var_2) with
      | (fixed n, fixed m) => if n =? m then conflict else noConflict
      | _ => noConflict
      end
.

Theorem with_conflict_sound : forall (c : all_different) (st : state) (var_1 : var) (var_2 : var),
 (* Move the in check to the with_conflict and not equal *)
  In var_1 c -> In var_2 c -> all_diff_with_conflict c st var_1 var_2 = conflict -> ~ AllDifferent c st.
Proof.
  intros c st var_1 var_2.
  intros Hin1 Hin2 Hconfl.
  unfold all_diff_with_conflict in Hconfl.
  destruct (var_1 =? var_2)%string eqn:Hnotsame. inversion Hconfl.
  destruct (st var_1) as [| n] eqn:Hst1. inversion Hconfl.
  destruct (st var_2) as [| m] eqn:Hst2. inversion Hconfl.
  unfold not. intros Halldiff.
  unfold AllDifferent in Halldiff.
  rewrite String.eqb_neq in Hnotsame.
  destruct (n =? m) eqn:Hnm.
  - specialize (Halldiff var_1 var_2 n m Hin1 Hin2 Hnotsame Hst1 Hst2).
    rewrite Nat.eqb_eq in Hnm. rewrite Hnm in Halldiff. contradiction.
  - inversion Hconfl.
Qed.
  
  

