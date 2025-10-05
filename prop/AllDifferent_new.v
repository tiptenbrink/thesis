From Coq Require Import Lists.List.
From Coq Require Import Strings.String.
Require Import Arith.

Inductive atomicOp := 
| geq
| leq
| eq
| neq.

Definition var := string.

Definition atomic := var -> atomicOp -> nat.

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

Definition findFixed (fixed : fixedValues) (v: var) (st : state) : fixedValues :=
    match st v with
    | fixed n => n :: fixed
    | _ => fixed
    end.

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

Lemma collapsePreservesSome : forall (A : Type) (l : list (option A)) (n : A),
    In (Some n) l -> In n (collapseOptions l).
Proof.
  intros A l n.
  intros Hin.
  induction l as [| h t IH]. all: simpl in *.
  - unfold In in Hin. contradiction.
  - destruct Hin as [Hh | Ht].
    + rewrite Hh. apply in_eq.
    + apply in_app_iff. right. apply IH. assumption.
Qed.

Lemma mapResultIn : forall (A B : Type) (f : A -> B) (l : list A) (x : A),
    In x l -> In (f x) (map f l).
Proof.
    intros A B f l x.
    intros Hin.
    induction l as [| h t IH]. all: simpl in *.
    - contradiction.
    - destruct Hin as [Hh | Ht].
        + rewrite Hh. apply in_eq.
        + apply in_cons. apply IH. apply Ht.
Qed.

(* Lemma fixedInFindFixed : forall (n : nat) (v : var) (st : state) *)

Fixpoint findFixedTo (vars: list var) (st : state) (fixed : fixedValues) : result :=
    match vars with
    | nil => noConflict
    | v :: vars_r => match st v with
        | fixed n => match (find (fun x => Nat.eqb x n) fixed) with
            | None => findFixedTo vars_r st fixed
            | Some _ => conflict
            end
        | _ => findFixedTo vars_r st fixed
    end
end.

Theorem find_in_list_some : forall (n : nat) (l : list nat),
  In n l ->
  find (fun x => Nat.eqb x n) l = Some n.
Proof.
intros n l Hin.
induction l as [| n' l' IH].
- destruct Hin.
- destruct Hin as [Heq | Hin].
  + assert (n' =? n = true) as Heqb.
    { rewrite Nat.eqb_eq. exact Heq. }
    simpl. rewrite Heqb. rewrite Heq. reflexivity.
  + specialize (IH Hin) as Hfind.
    simpl. destruct (n' =? n) eqn:E.
    * rewrite Nat.eqb_eq in E. rewrite E. reflexivity.
    * exact Hfind.
Qed.

Lemma fixedABC : forall (n : nat) (v : var) (vars : list var) (st : state) (fixedList : fixedValues), In v vars -> In n fixedList -> st v = fixed n -> findFixedTo vars st fixedList = conflict.
Proof.
    intros n v vars st fixedList.
    intros Hinv Hinf Hfix.
    induction vars as [| x vars' IH].
    - destruct Hinv.
    - destruct Hinv.
      + subst x. unfold findFixedTo. rewrite Hfix.
        assert (find (fun x => x =? n) fixedList = Some n) as Hfind.
        { apply find_in_list_some. exact Hinf. }
        rewrite Hfind. reflexivity.
      + specialize (IH H). simpl. induction (st x).
        * exact IH.
        * destruct (find (fun x0 => x0 =? n0) fixedList).
          -- reflexivity.
          -- exact IH.
Qed.

Definition propagate_all_dif (constr: all_different) (st : state) :=
    let fixed := findFixedAll constr st in
    findFixedTo constr st fixed
.

(* If there exists a variable in the state that is fixed to n, propagate_all_diff should report a conflict. *)

(* If there exists two variables in the state that are both fixed to the same n, propagate_all_diff should report a conflict. *)

Definition propagate_all_diff2 (constr: all_different) (st : state) :=
    match constr with
    | nil => noConflict
    | v :: constr_r => let fixed := findFixedAll (remove string_dec v constr) st in
        findFixedTo constr st fixed 
    end
.

Definition propagate_one (v : var) (other : list var) (st : state) : bool :=
    match (st v) with
    | fixed n => existsb (fun n' => Nat.eqb n' n) (findFixedAll other st)
    | _ => false
    end.

Fixpoint propagate_all_diff_iter (vars : list var) (constr: all_different) (st : state) :=
    match vars with
    | nil => noConflict
    | v :: vars_r => if (propagate_one v (remove string_dec v constr) st) then conflict else propagate_all_diff_iter vars_r constr st
    end
.

Definition propagate_all_diff3 (constr: all_different) (st : state) :=
    propagate_all_diff_iter constr constr st
.

(* Lemma next_conflict : forall (v : var) (constr : all_different) (st : state),
    propagate_all_diff2 (v :: constr) st = conflict -> propagate_all_diff2 constr st = conflict \/ propagate_all_diff2 (v :: nil) st = conflict.
Proof.
    intros v constr st.
    intros H.
    unfold propagate_all_diff2 in H. 



    destruct (findFixedTo constr st (findFixedAll (remove string_dec v constr) st)).
    - left. reflexivity.
    - right. reflexivity. *)

Compute (propagate_all_dif ("x"%string :: nil) (fun x => fixed 3)).

(* If there exists a variable in the state that is fixed to n, propagate_all_diff should report a conflict. *)

(* If there exists two variables in the state that are both fixed to the same n, propagate_all_diff should report a conflict. *)

Lemma varInConstraintFixedInFixedAll : forall (n : nat) (x : string) (c : all_different) (st : state), In x c -> st x = fixed n -> In n (findFixedAll c st).
Proof.
    intros n x c st.
    intros Hin Hfix.
    unfold findFixedAll.
    unfold findFixedOptions.
    apply collapsePreservesSome.
    specialize (mapResultIn var (option nat) (fun v => mapFixed v st) c x) as H. apply H in Hin. unfold mapFixed in Hin. rewrite Hfix in Hin. apply Hin.
Qed.

Lemma two_fixed : forall (n : nat) (x y : string) (constr : all_different) (st : state),
    In x constr -> In y constr -> x <> y -> st x = fixed n -> st y = fixed n -> propagate_all_diff2 constr st = conflict.
Proof.
    intros n x y c st.
    intros Hx Hy Hneq Hfx Hfy.

    induction c as [| v c IH].
    - destruct Hx.
    - destruct (propagate_all_diff2 (v :: nil) st) eqn:C.
      + 
    
    
    destruct (String.eqb v y) eqn:Hvy.
      + unfold propagate_all_diff2.
        assert (v = y) as Hvy_eq.
        { apply String.eqb_eq. exact Hvy. }
        remember (v :: c) as l.
        subst v.
            
            

        specialize (varInConstraintFixedInFixedAll n x (remove string_dec y l) st) as H.
        specialize (in_in_remove string_dec l Hneq Hx) as Hremove.
        specialize (H Hremove Hfx) as H.
        specialize (fixedABC n y l st (findFixedAll (remove string_dec y l) st) Hy H Hfy) as HH. 
        
        exact HH. 
      + unfold propagate_all_diff2.
        remember (v :: c) as l.
Qed.
