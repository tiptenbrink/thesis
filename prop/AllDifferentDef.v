Require Import Coq.Strings.String.
Require Import Coq.Arith.PeanoNat.
Require Import Coq.MSets.MSetAVL.
Require Import Coq.MSets.MSetInterface.
Require Import Coq.MSets.MSetEqProperties.
Require Import Coq.MSets.MSetProperties.
Require Import Coq.MSets.MSetFacts.
Require Import Coq.MSets.MSetDecide.
Require Import Coq.Structures.Orders.
Require Import Coq.Structures.OrdersEx.
Require Import Coq.ZArith.BinInt.


(* Create the MSet module for strings. String_as_OT provides the ordering *)
Module MSetString := MSetAVL.Make String_as_OT.
Module MSetInt := MSetAVL.Make Z_as_OT.
Module Z_String_as_OT := PairOrderedType Z_as_OT String_as_OT.
Module MSetZString := MSetAVL.Make Z_String_as_OT.

Definition domain := MSetInt.t.
Definition vars := MSetString.t.
Definition state := string -> domain.
Definition valuation := string -> Z.
Definition InStr := MSetString.In.
Definition InZ := MSetInt.In.
Definition SubsetVars := MSetString.Subset.
Definition SubsetDom := MSetInt.Subset.
Definition vars_len := MSetString.cardinal.
Definition dom_size := MSetInt.cardinal.
Definition fixed_dom (n : Z) := MSetInt.singleton n.

Create HintDb short_unfold_db.
Hint Unfold InStr InZ SubsetVars SubsetDom MSetInt.elt MSetString.elt MSetInt.Subset : short_unfold_db.

Definition InDomain (st : state) (x : string) (v : valuation) : Prop := InZ (v x) (st x).

Definition FixedTo (st : state) (x : string) (n : Z) : Prop := MSetInt.Equal (fixed_dom n) (st x).

Lemma fixed_to_is :
    forall (st : state) (x : string) (n : Z) (v : valuation),
        FixedTo st x n -> InDomain st x v -> v x = n.
Proof.
    intros st x n v.
    intros Hfix Hin.
    unfold InDomain in Hin. unfold InZ in Hin. unfold fixed_dom in Hin.
    unfold FixedTo in Hfix. unfold MSetInt.Equal in Hfix. 
    apply MSetInt.singleton_spec.
    apply Hfix.
    assumption.
Qed.


Definition AllDifferentVC (c : vars) (st : state) : Prop :=
  forall (x y : string) (n m : Z),
  x <> y -> InStr x c -> InStr y c -> FixedTo st x n -> FixedTo st y m -> n <> m
.

Definition valuation_all_different (c : vars) (st : state) (v : valuation) : Prop :=
  (forall (x : string),
    InStr x c -> InDomain st x v)
    /\
  (forall (x y : string), 
  x <> y -> InStr x c -> InStr y c -> v x <> v y).

Definition AllDifferent (c: vars) (st : state) : Prop :=
    exists (v : valuation), valuation_all_different c st v.

(* Inductive Pairwise_unequal : MSetInt.t -> Prop :=
  | Pairwise_unequal_empty : Pairwise_unequal MSetInt.empty
  | Pairwise_unequal_add (n : Z) (s : MSetInt.t) (H : forall m, InZ m s -> n <> m) (H' : Pairwise_unequal s) : Pairwise_unequal (MSetInt.add n s)
  . *)

Definition valuation_values_foldf (v : valuation) (var : string) (values : MSetInt.t) :=
  MSetInt.add (v var) values.

Definition valuation_values (c : vars) (v : valuation) :=
  MSetString.fold (valuation_values_foldf v) c MSetInt.empty. 

Module SetStringProps := MSetProperties.Properties MSetString.
Module SetIntProps := MSetProperties.Properties MSetInt.

Ltac destruct_eqb x y :=
  let H := fresh "H" in
  lazymatch type of x with
  | nat => destruct (Nat.eqb x y) eqn:H; [rewrite Nat.eqb_eq in H; subst | rewrite Nat.eqb_neq in H]
  | Z => destruct (Z.eqb x y) eqn:H; [rewrite Z.eqb_eq in H; subst | rewrite Z.eqb_neq in H]
  | string => destruct (String.eqb x y) eqn:H; [rewrite String.eqb_eq in H; subst | rewrite String.eqb_neq in H]
  | _ => fail "Unsupported type for destruct_eqb"
  end; try congruence.  

Lemma alldiff_valuation_values_properties (c : vars) (st : state) :
  forall (v: valuation), valuation_all_different c st v 
    -> 
  vars_len c = MSetInt.cardinal (valuation_values c v) 
    /\ 
  (* Pairwise_unequal (valuation_values c v) 
    /\  *)
  forall n, InZ n (valuation_values c v) -> exists x, InStr x c /\ v x = n.
Proof.
  intros v Hval_alldiff. unfold valuation_all_different in Hval_alldiff.
  unfold valuation_values.
  set (P := 
      fun (s : MSetString.t) (acc : MSetInt.t) =>
      vars_len s = MSetInt.cardinal acc 
      (* /\ 
      Pairwise_unequal acc  *)
      /\ forall n, InZ n acc -> exists x, InStr x s /\ InStr x c /\ v x = n
  ).
  enough (P c (MSetString.fold (valuation_values_foldf v) c
  MSetInt.empty)).
  { 
    unfold P in H. clear P. destruct H as [Hcard Hn].
    repeat split; try assumption.
    intros n Hin. destruct (Hn n Hin) as [x [Hinc [_ Hvx]]].
    exists x. split; try assumption.
  }
  apply SetStringProps.fold_rec with (f := valuation_values_foldf v) (i := MSetInt.empty) (s := c) (P := P).
  - autounfold with short_unfold_db in *.
    unfold P in *. clear P. intros s Hempty.
    repeat split.
    + unfold vars_len. rewrite MSetInt.cardinal_spec. simpl. rewrite SetStringProps.cardinal_Empty in Hempty. rewrite Hempty. reflexivity. 
    (* + apply Pairwise_unequal_empty. *)
    + intros n Hinempty.
      exfalso.
      apply (MSetInt.empty_spec Hinempty).
  - intros var vals s s_v.
    intros Hin Hvarnots Hadd IH.
    unfold P in *. clear P.
    autounfold with short_unfold_db in *.
    destruct IH as [IH_card Hinvar].
    repeat split.
    + destruct Hval_alldiff as [_ Hdiff].
      unfold vars_len.
      rewrite SetStringProps.Add_Equal in Hadd.
      apply SetStringProps.Equal_cardinal in Hadd.
      rewrite Hadd.
      unfold valuation_values_foldf.
      rewrite (SetStringProps.add_cardinal_2 Hvarnots).
      assert (~ InZ (v var) vals) as Hvvarnotvals.
      { 
        intros Hvvarin.
        destruct (Hinvar (v var) Hvvarin) as [x [Hxins [Hxinc Hvx]]].
        apply Hdiff with (x := var) (y := x); try assumption.
        + intros Hvarisx. apply Hvarnots. rewrite Hvarisx. exact Hxins.
        + symmetry. assumption.
      }
      rewrite (SetIntProps.add_cardinal_2 Hvvarnotvals).
      f_equal.
      exact IH_card.        
    (* + apply Pairwise_unequal_add.
      * intros m Hmvals.
        specialize (Hinvar m Hmvals).
        destruct Hinvar as [y [Hyins [Hyinc Hvy]]].
        rewrite <- Hvy.
        apply Hval_alldiff; try assumption.
        unfold MSetString.elt in *.
        destruct_eqb var y.
      * exact IH_pair. *)
    + intros n Hinfoldf.
      unfold valuation_values_foldf in Hinfoldf.
      rewrite MSetInt.add_spec in Hinfoldf.
      destruct Hinfoldf as [Hvvar | Hnvals].
      * exists var.
        repeat split.
        { apply Hadd. left. reflexivity. }
        { exact Hin. }
        { symmetry. exact Hvvar. }
      * specialize (Hinvar n Hnvals).
        destruct Hinvar as [x [Hxins [Hxinc Hvx]]].
        exists x.
        repeat split; try assumption.
        apply Hadd.
        right. assumption.
Qed.

Lemma not_vc_is_not_alldiff : forall (c : vars) (st : state), ~ AllDifferentVC c st -> ~ AllDifferent c st.
Proof.
    intros c st. intros H. unfold not in *. intros Halldiff. apply H. clear H. unfold AllDifferent in Halldiff. unfold AllDifferentVC.
    destruct Halldiff as [v].
    intros x y n m. 
    intros Hxneqy Hxin Hyin Hxfix Hyfix.
    unfold valuation_all_different in H.
    destruct H as [Hdom Hdiff].
    specialize (Hdiff x y Hxneqy Hxin Hyin).
    specialize (fixed_to_is st) as Hfixed.
    specialize (Hfixed x n v Hxfix (Hdom x Hxin)) as Hvxn.
    specialize (Hfixed y m v Hyfix (Hdom y Hyin)) as Hvym.
    rewrite <- Hvxn. rewrite <- Hvym.
    exact Hdiff.
Qed.

Definition var_union_d (st : state) (v : string) (d: domain) :=
    MSetInt.union (st v) d.

Definition vars_union_domain (st : state) (vs : vars) := 
    MSetString.fold 
    (var_union_d st)
    vs 
    MSetInt.empty.

Lemma vars_union_domain_correct (st : state) (vs : vars) : 
    forall (x : string), InStr x vs -> SubsetDom (st x) (vars_union_domain st vs).
Proof.
  intros v. intros Hin.
  autounfold with short_unfold_db in *.
  set (P := 
      fun (s : MSetString.t) (acc : MSetInt.t) =>
      forall var, InStr var s -> MSetInt.Subset (st var) acc
  ).
  enough (P vs (MSetString.fold (var_union_d st) vs MSetInt.empty)).
  { unfold P in *. clear P. unfold vars_union_domain. apply H. exact Hin. }
  apply SetStringProps.fold_rec with (f := var_union_d st) (i := MSetInt.empty) (s := vs) (P := P); clear v Hin.
  - unfold P in *. clear P. intros s Hempty.
    intros v Hin.
    unfold InStr in Hin.
    exfalso.
    apply (Hempty v).
    assumption.
  - intros v dom s s_v.
    intros Hin Hvnots Hadd IH.
    unfold P in *. clear P.
    unfold var_union_d. unfold MSetInt.Subset in *.
    intros s_v_el Hs_v_el n_dom Hn_dom.
    rewrite MSetInt.union_spec.
    unfold MSetString.elt in *.
    unfold MSetInt.elt in *.
    unfold SetStringProps.Add in *.
    rewrite (Hadd s_v_el) in Hs_v_el. 
    destruct_eqb s_v_el v.
    + left. assumption.
    + destruct Hs_v_el as [ His | Hs_v_el].
      { rewrite His in H. contradiction. }
      clear Hadd. right. apply (IH s_v_el).
      * assumption.
      * assumption.
Qed.

Definition nonempty_doms (st : state) (vs : vars) :=
  forall x, InStr x vs -> ~ MSetInt.Empty (st x).

(* Definition pairwise_unequal_atleast_n (s : MSetInt.t) :
  Pairwise_unequal s -> dom_size s = MSetInt.cardinal s.
Proof.
  intros Hpair.
  unfold dom_size. *)

Lemma all_different_subset (st : state) (v : valuation) :
  forall (vs : vars) (vs' : vars),
  valuation_all_different vs st v -> SubsetVars vs' vs -> valuation_all_different vs' st v.
Proof.
  intros vs vs'. intros H Hsub.
  unfold valuation_all_different in *.
  destruct H as [Hdom Hdiff].
  split.
  - intros x. intros Hin.
    apply Hdom. apply Hsub. assumption.
  - intros x y.
    intros Hxny Hinx Hiny.
    apply Hdiff; try assumption; apply Hsub; assumption.
Qed.

Lemma val_list_sub (st : state) :
  forall (vs : vars) (v : valuation), 
  valuation_all_different vs st v -> MSetInt.Subset (valuation_values vs v) (vars_union_domain st vs).
Proof.
  intros vs v.
  unfold MSetInt.Subset. unfold MSetInt.elt.
  intros Halldiff.
  intros n. intros Hinvals.
  unfold valuation_all_different in *.
  specialize (alldiff_valuation_values_properties vs st v Halldiff) as H.
  destruct H as [_ Hvalvals].
  destruct Halldiff as [Hdom Hdiff].
  (* we have to do some induction for valuation_values *)
  enough (exists x, InStr x vs /\ v x = n) as Hins.
  - destruct Hins as [x [Hxin Hvx]].
    specialize vars_union_domain_correct as Huniondom.
    autounfold with short_unfold_db in *.
    apply Huniondom with (a := n) (x := x); try assumption.
    rewrite <- Hvx.
    apply (Hdom x Hxin).
  - apply Hvalvals.
    exact Hinvals.
Qed.

Definition ex_confl_set (c : vars) (st : state) := 
(exists (confl_vars : vars), SubsetVars confl_vars c /\ dom_size (vars_union_domain st confl_vars) < vars_len confl_vars).

Lemma vars_dom_union (c : vars) (st : state) :
  ex_confl_set c st -> ~ AllDifferent c st.
Proof.
  intros H.
  destruct H as [confl_vars [Hsub Hlt]].
  unfold AllDifferent. intros Halldiff.
  destruct Halldiff as [v Hv].
  enough (dom_size (vars_union_domain st confl_vars) >= vars_len confl_vars).
  - apply Nat.lt_nge in Hlt.
    contradiction.
  - apply all_different_subset with (vs' := confl_vars) in Hv; try assumption.
    destruct (alldiff_valuation_values_properties confl_vars st v Hv) as [Hvals Hins].
    rewrite Hvals.
    unfold ge.
    apply SetIntProps.subset_cardinal.
    unfold MSetInt.Subset.
    intros n Hin.
    destruct (Hins n Hin)  as [x [Hxin Hvx]].
    subst n.
    destruct Hv as [Hdom _].
    specialize (Hdom x Hxin).
    unfold InDomain in Hdom.
    specialize (vars_union_domain_correct st confl_vars x Hxin) as Hunion.
    autounfold with short_unfold_db in *.
    apply Hunion.
    exact Hdom.
Qed.


Definition all_different_dec (vs : vars) (v: valuation) : bool :=
  (* Use the algo for VC consistency *)
  

(* Definition valuation_all_different (c : vars) (st : state) (v : valuation) : Prop :=
  (forall (x : string),
    InStr x c -> InDomain st x v)
    /\
  (forall (x y : string), 
  x <> y -> InStr x c -> InStr y c -> v x <> v y).

Definition AllDifferent (c: vars) (st : state) : Prop :=
    exists (v : valuation), valuation_all_different c st v. *)