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

Lemma propagate_all_one_prop : forall (vars: list var) (c : all_different) (st : state),
    propagate_all_diff_iter vars c st = conflict -> exists v, In v vars /\ propagate_one v c st = true.
Proof.
  intros vars c st. intros Hconfl.
  induction vars as [| v vars' IH].
  - simpl in Hconfl. inversion Hconfl.
  - simpl in Hconfl. destruct (propagate_one v c st) eqn:Hprop.
    + exists v. split. apply in_eq. exact Hprop.
    + apply IH in Hconfl. destruct Hconfl as [v' [Hin Hprop']].
      exists v'. split. apply in_cons. exact Hin. exact Hprop'.
Qed.

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

Lemma propagate_forall : forall (v : var) (vars : list var ) (c : all_different) (st : state),
    In v vars /\ propagate_one v c st = true -> propagate_all_diff_iter vars c st = conflict.
Proof.
  intros v vars c st. specialize (propagate_all_one_prop_bi vars c st) as H.
  - intros [Hin Hprop]. rewrite H. exists v. split.
    + exact Hin.
    + exact Hprop.
Qed.

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

Lemma varInConstraintFixedInFixedAll : forall (n : nat) (x : string) (vars : list var) (st : state), In x vars -> st x = fixed n -> In n (findFixedAll vars st).
Proof.
    intros n x vars st.
    intros Hin Hfix.
    unfold findFixedAll.
    unfold findFixedOptions.
    apply collapsePreservesSome.
    specialize (in_map (fun v => mapFixed v st) vars x) as H. apply H in Hin. unfold mapFixed in Hin. rewrite Hfix in Hin. apply Hin.
Qed.

(* Lemma more_var_also_conflict : forall (o : var) (c : all_different) (st : state),
  propagate_all_diff3 c st = conflict -> propagate_all_diff3 (o :: c) st = conflict.
Proof.
    intros o c st. intros Hconfl.
    unfold propagate_all_diff3 in *. simpl.
    destruct (propagate_one o _ st).
    { reflexivity. }
    specialize (propagate_all_one_prop c c st Hconfl) as Hprop.
    destruct Hprop as [v [Hin Hprop']].
    induction c as [| x c' IH].
    - destruct Hin.
    - simpl.

    unfold propagate_all_diff_iter in *. simpl in *.
    reflexivity *)

Lemma oneConflict : forall (v : var) (c : all_different) (st : state),
    In v c -> propagate_one v c st = true -> propagate_all_diff3 c st = conflict.
Proof.
  intros v c st.
  intros Hin Hprop.
  unfold propagate_all_diff3. 
  specialize (propagate_forall v c c st) as H.
  apply H. split.
  - exact Hin.
  - exact Hprop.
Qed.

Lemma two_fixed : forall (n : nat) (x y : string) (constr : all_different) (st : state),
    In x constr -> In y constr -> x <> y -> st x = fixed n -> st y = fixed n -> propagate_all_diff3 constr st = conflict.
Proof.
    intros n x y c st.
    intros Hx Hy Hneq Hfx Hfy.
    specialize (oneConflict y c st) as H.
    apply H.
    - exact Hy.
    - unfold propagate_one. rewrite Hfy. apply existsb_exists. exists n. split.
      + apply varInConstraintFixedInFixedAll with (x := x).
        * apply in_in_remove.
          { exact Hneq. }
          { exact Hx. }
        * exact Hfx.
      + apply Nat.eqb_refl.

    (* unfold propagate_all_diff3.


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
        remember (v :: c) as l. *)
Qed.

(* The below theorem should indicate that if most one of the variables in the constraint is fixed, then propagate_all_diff3 should not return a conflict. *)

Definition is_not_fixed (st : state) (v : var) : Prop :=
  match (st v) with
  | fixed _ => False 
  | _ => True
  end.

Lemma is_not_fixed_not_fixed : forall (st : state) (v : var) (n: nat),
    is_not_fixed st v -> st v <> fixed n.
Proof.
  intros st v n.
  intros Hnotfixed Hfixed.
  unfold is_not_fixed in Hnotfixed.
  rewrite Hfixed in Hnotfixed.
  contradiction.
Qed.

Inductive Propagate_noconflict (st : state) (c : all_different) : list var -> Prop :=
  | Propagate_noconflict_nil : Propagate_noconflict st c nil
  | Propagate_noconflict_cons (v : var) (vars : list var) (H : propagate_one v c st = false) (H' : Propagate_noconflict st c vars) : Propagate_noconflict st c (v :: vars)
  .

Lemma Propagate_noconflict_is_prop_noconflict : forall (st : state) (c : all_different) (vars : list var),
    Propagate_noconflict st c vars <-> propagate_all_diff_iter vars c st = noConflict.
Proof.
  intros st c vars.
  induction vars as [| v vars' IH].
  - simpl. split.
    + intros H. reflexivity.
    + intros H. apply Propagate_noconflict_nil.
  - split.
    + intros H. inversion H. simpl. rewrite H1. rewrite <- IH.
      exact H'.
    + intros H. apply Propagate_noconflict_cons.
      * simpl in H. destruct (propagate_one v c st) eqn:Hprop.
        { inversion H. }
        { reflexivity. }
      * apply IH. simpl in H. destruct (propagate_one v c st) eqn:Hprop.
        { inversion H. }
        { exact H. }
Qed.

Lemma findFixedWithNotFixed : forall (v : var) (vars : list var) (st : state),
    is_not_fixed st v -> findFixedAll vars st = findFixedAll (v :: vars) st.
Proof.
  intros v vars st.
  intros Hnotfixed.
  unfold findFixedAll.
  assert (mapFixed v st = None) as Hnone.
  { unfold mapFixed. destruct (st v) eqn:Hst.
    - reflexivity.
    - specialize (is_not_fixed_not_fixed st v n Hnotfixed) as Hnotfixed'. rewrite Hst in Hnotfixed'. contradiction.
  }
  unfold findFixedOptions. simpl. rewrite Hnone. simpl. reflexivity.
Qed.

(* Lemma mapResultIn : forall (A B : Type) (f : A -> B) (l : list A) (x : A),
    In x l -> In (f x) (map f l).
Proof. *)

Lemma propagate_one_larger : forall (v : var) (x : var) (vars : list var) (st : state),
    propagate_one v vars st = true -> propagate_one v (x :: vars) st = true.
Proof.
  intros v x vars st.
  intros Hprop.
  unfold propagate_one in *. destruct (st v) eqn:Hst.
  - inversion Hprop.
  - apply existsb_exists in Hprop. destruct Hprop as [n' [Hin Heq]].
    apply existsb_exists. exists n. split.
    + rewrite Nat.eqb_eq in Heq. subst n'.
      simpl. destruct (string_dec v x) eqn:Hvx.
      * exact Hin.
      * unfold findFixedAll in *.  
        rewrite <- collapsePreservesSome in *.
        unfold findFixedOptions in *.
        apply in_map_iff in Hin as Hexin.
        destruct Hexin as [xFix [Hxfixfix Hinremv]].
        apply in_map_iff. exists xFix. split.
        { exact Hxfixfix. }
        { apply in_cons. exact Hinremv. }
    + rewrite Nat.eqb_eq. reflexivity.
Qed.

Lemma propagate_extra : forall (vars : list var) (c : all_different) (x : var) (st : state),
    propagate_all_diff_iter vars c st = noConflict -> is_not_fixed st x ->
    propagate_all_diff_iter vars (x :: c) st = noConflict.
Proof.
  intros vars c x st.
  intros Hnoconf Hnotfixed.
  induction vars as [| v vars IH].
  - simpl in Hnoconf. inversion Hnoconf. reflexivity.
  - simpl. destruct (propagate_one v (x :: c) st) eqn:Hprop.
    + specialize (propagate_forall v (v :: vars) c st) as Hprops.
      symmetry. rewrite <- Hnoconf.
      apply Hprops. split.
      * apply in_eq.
      * unfold propagate_one in *.
        specialize (is_not_fixed_not_fixed st x) as Hxfixnotn.
        simpl in Hprop. destruct (string_dec v x) eqn:Hvx.
        {
          subst x. destruct (st v) eqn:Hvst.
          - inversion Hprop.
          - specialize (Hxfixnotn n Hnotfixed). contradiction.
        }
        {
          specialize (findFixedWithNotFixed x (remove string_dec v
c) st Hnotfixed) as Hnotfind. rewrite Hnotfind. exact Hprop. 
        }
    + apply IH. simpl in Hnoconf. destruct (propagate_one v c st) eqn:Hpropc.
      * inversion Hnoconf.
      * exact Hnoconf.
Qed.
        (* subst v.
        
      
      destruct (st v) eqn:Hst.
        { inversion Hprop. }
        { 
          apply existsb_exists.
          apply existsb_exists in Hprop.
          destruct Hprop as [n' [Hin Heq]].
          exists n'. split.
          - 
          - exact Heq.
        }
    
    unfold propagate_one in Hprop. destruct (st v) eqn:Hst.
      * inversion Hprop. 
      * specialize (is_not_fixed_not_fixed st x n Hnotfixe) as Hnotfixed'.
      existsb_exists in Hprop. destruct Hprop as [n [Hin Heq]].
        apply in_in_remove in Hin. destruct Hin as [Hin Hneq].
        specialize (is_not_fixed_not_fixed st x n) as Hnotfixed'.
        specialize (Hnotfixed' Hnotfixed). contradiction.
      * reflexivity. 
    + apply IH. inversion Hnoconf. exact H1. *)

(* This is sort of a base case *)
Theorem none_no_conflict : forall (c : all_different) (st : state),
    Forall (is_not_fixed st) c -> Propagate_noconflict st c c.
Proof.
  intros c st.
  intros Hnotfixed.
  induction c as [| v c' IH].
  - apply Propagate_noconflict_nil.
  - apply Forall_inv in Hnotfixed as Hvnotfixed.
    specialize (is_not_fixed_not_fixed st v) as Hvnotfixed'.
    apply Propagate_noconflict_cons.
    + unfold propagate_one. destruct (st v) eqn:Hst.
      * reflexivity.
      * specialize (Hvnotfixed' n Hvnotfixed). contradiction.
    + apply Forall_inv_tail in Hnotfixed. specialize (IH Hnotfixed). rewrite Propagate_noconflict_is_prop_noconflict in *. apply propagate_extra.
      * exact IH.
      * exact Hvnotfixed.
    
    (* rewrite Propagate_noconflict_is_prop_noconflict. unfold propagate_all_diff_iter.
    apply IH in Hnotfixed'.
    apply Propagate_noconflict_cons.
    + simpl. destruct (st v) eqn:Hst.
      * contradiction.
      * reflexivity.
    + exact Hnotfixed'.

  intros c st.
  intros H.
  induction c as [| v c' IH].
  - reflexivity.
  - simpl. destruct (propagate_one v (v :: c') st) eqn:Hprop.
    + admit.
    + exact IH.
  
   inversion H as [H1 H2]. destruct (propagate_one v c' st) eqn:Hprop.
    + apply IH. apply Forall_inv in H2. exact H2.
    + reflexivity. *)
Qed.

Definition AllDifferent (c : all_different) (st : state) : Prop :=
  forall (x y : var) (n m : nat),
    In x c -> In y c -> x <> y -> st x = fixed n -> st y = fixed m -> n <> m
.

Lemma n_in_find_fixed_exists_x : forall (n : nat) (v : var) (vars : list var) (st : state),
    In n (findFixedAll (remove string_dec v vars) st) -> exists x, In x vars /\ x <> v /\ st x = fixed n.
Proof.
  intros n v vars st.
  intros Hin. unfold findFixedAll in Hin. rewrite <- collapsePreservesSome in Hin. unfold findFixedOptions in Hin.
  apply in_map_iff in Hin. destruct Hin as [x [Hfx Hxin]].
  exists x. split.
  + apply in_remove in Hxin. destruct Hxin as [Hxin _]. exact Hxin.
  + split.
    * apply in_remove in Hxin. destruct Hxin as [_ Hneq]. exact Hneq.
    * unfold mapFixed in Hfx. destruct (st x) eqn:Hstx.
      { inversion Hfx. }
      { inversion Hfx. reflexivity. }
Qed.

Lemma propagate_one_two_fixed : forall (v : var) (c : all_different) (st : state),
    propagate_one v c st = true -> exists (x : var) (n m : nat), In x c /\ x <> v /\ st v = fixed n /\ st x = fixed m /\ n = m.
Proof.
  intros v c st.
  intros Hprop.
  unfold propagate_one in Hprop.
  destruct (st v) as [ | n ] eqn:Hst.
  - inversion Hprop.
  - apply existsb_exists in Hprop. destruct Hprop as [m [Hin Heq]]. apply n_in_find_fixed_exists_x in Hin.
    destruct Hin as [x [Hxinc [Hxneqv Hfxm]]].
    exists x. exists n. exists m. 
    split. exact Hxinc.
    split. exact Hxneqv.
    split. reflexivity.
    split. exact Hfxm.
    rewrite Nat.eqb_eq in Heq. symmetry. exact Heq.  
Qed.

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
  propagate_all_diff3 c st = conflict <-> ~ AllDifferent c st.
Proof.
  intros c st.
  split.
  - intros Hconf. unfold propagate_all_diff3 in Hconf.
    apply propagate_all_one_prop_bi in Hconf.
    destruct Hconf as [v [Hin Hprop]].
    unfold AllDifferent. intros Hdiff.
    apply propagate_one_two_fixed in Hprop. destruct Hprop as [x [n [m [Hxinc [Hxneqv [Hfvn [Hfxm Hnm]]]]]]].
    specialize (Hdiff x v m n Hxinc Hin Hxneqv Hfxm Hfvn).
    rewrite Hnm in Hdiff. contradiction.
  - intros Hdiff. unfold AllDifferent in Hdiff. unfold not in Hdiff.
    destruct (propagate_all_diff3 c st) eqn:Hconf. reflexivity.
    destruct Hdiff.
    intros x y n m Hxinc Hyinc Hneq Hfxn Hfym Hnism.
    enough (propagate_all_diff3 c st = conflict).
    { rewrite H in Hconf. inversion Hconf. }
    unfold propagate_all_diff3. apply propagate_all_one_prop_bi.
    exists y. split. exact Hyinc.
    apply propagate_one_two_fixed_rev.
    exists x. exists m. exists n.
    split. exact Hxinc.
    split. exact Hneq.
    split. exact Hfym.
    split. exact Hfxn.
    symmetry. exact Hnism.
Qed.

Theorem neg_propagate_confl : forall (c : all_different) (st : state),
  propagate_all_diff3 c st = noConflict <-> ~ propagate_all_diff3 c st = conflict.
Proof.
  intros c st.
  split.
  - intros Hnoconf. unfold not. intros Hconf. rewrite Hconf in Hnoconf. inversion Hnoconf.
  - intros Hnoconf. unfold not in Hnoconf. destruct (propagate_all_diff3 c st) eqn:Hprop.
    + assert (conflict = conflict). reflexivity.
      specialize (Hnoconf H). contradiction.
    + reflexivity.
Qed.

(* Theorem result_neg : forall (r : result),
  r = conflict <-> ~ r = noConflict.
Proof.
  intros r.
  split.
  - intros Hconf. unfold not. intros Hnoconf. rewrite Hconf in Hnoconf. inversion Hnoconf.
  - intros Hnoconf. unfold not in Hnoconf. destruct r eqn:Hr.
    + reflexivity.
    + specialize (Hnoconf eq_refl). contradiction.
Qed. *)

Definition negate_result (r : result) : result :=
  match r with
  | conflict => noConflict
  | noConflict => conflict
  end.

(* Theorem negate_negate_result : forall (r : result),
  negate_result (negate_result r) = r.
Proof.
  intros r.
  destruct r eqn:Hr.
  - reflexivity.
  - reflexivity.
Qed. *)

Theorem negate_negate_result_not : forall (r : result) (o : result),
  r = o <-> ~ (r = negate_result o).
Proof.

  intros r o.
    destruct r.
  - destruct o.
    + simpl. split. intros H. unfold not. intros H'. inversion H'. intros H. reflexivity.
    + simpl. split. intros H. inversion H. intros H. contradiction.
    
  - destruct o.
    + simpl. split. intros H. inversion H. intros H. contradiction.
    + simpl. split. intros H. unfold not. intros H'. inversion H'. intros H. reflexivity.
Qed.

(* Theorem negate_result_not : forall (r : result) (o : result),
  negate_result r = o <-> ~ r = o.
Proof.
  intros r o.
  destruct r.
  - destruct o.
    + simpl. split. intros H. inversion H. intros H. contradiction.
    + simpl. split. intros H. unfold not. intros H'. inversion H'. intros H. reflexivity.
  - destruct o.
    + simpl. split. intros H. unfold not. intros H'. inversion H'. intros H. reflexivity.
    + simpl. split. intros H. inversion H. intros H. contradiction.
Qed. *)

Theorem all_diff_correct_noconflict : forall (c : all_different) (st : state),
  propagate_all_diff3 c st = noConflict <-> AllDifferent c st.
Proof.
  intros c st.
  rewrite negate_negate_result_not. simpl. rewrite all_diff_prop_correct.
  split.
  - intros H.
    unfold not in H. unfold AllDifferent in *.
    intros x y n m Hxinc Hyinc Hneq Hfxn Hfym Hnm.
    destruct H. intros H'.
    specialize (H' x y n m Hxinc Hyinc Hneq Hfxn Hfym). unfold not in H'. apply H'. exact Hnm.
  - intros H. unfold not. intros H'. contradiction.
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
  
  

