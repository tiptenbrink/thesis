Require Import Coq.Strings.String.
Require Import Coq.Arith.PeanoNat.
Require Import Coq.MSets.MSetAVL.
Require Import Coq.MSets.MSetInterface.
Require Import Coq.MSets.MSetEqProperties.
Require Import Coq.MSets.MSetProperties.
Require Import Coq.MSets.MSetFacts.
Require Import Coq.Structures.Orders.
Require Import Coq.Structures.OrdersEx.
Require Import Coq.ZArith.BinInt.


(* Create the MSet module for strings. String_as_OT provides the ordering *)
Module MSetString := MSetAVL.Make String_as_OT.
Module MSetInt := MSetAVL.Make Z_as_OT.
Module Z_String_as_OT := PairOrderedType Z_as_OT String_as_OT.
Module MSetZString := MSetAVL.Make Z_String_as_OT.

Definition var := string.

Inductive domain := 
| int : MSetInt.t -> Z -> Z -> domain
| fixed : Z -> domain.

Definition state := var -> domain.

Definition In := MSetString.In.
Definition variables := MSetString.t.
Definition all_different := variables.

Definition AllDifferent (c : all_different) (st : state) : Prop :=
  forall (x y : var) (n m : Z),
    In x c ->
    In y c ->
    x <> y ->
    st x = fixed n -> st y = fixed m -> n <> m.

Definition mem := MSetString.mem.

Definition accum := (MSetZString.t * option (var * var))%type.

Definition fst_is_n (n : Z) (n_with_var : Z * var) : bool :=
  (fst n_with_var =? n)%Z.

Definition find_conflict (n : Z) (fixedValues : MSetZString.t) : option var :=
  let filtered := MSetZString.filter (fst_is_n n) fixedValues in
  match MSetZString.choose filtered with 
  | Some (_, v) => Some v
  | _ => None
  end
.

Module ZStringProps := MSetProperties.Properties MSetZString.
Module ZStringFacts := MSetFacts.Facts MSetZString.

Lemma fst_is_n_Proper : forall (n : Z), Proper (eq * eq ==> eq)%signature (fst_is_n n).
Proof.
  intros n.
  unfold Proper, respectful.
  intros [a1 b1] [a2 b2] [Ha Hb].
  unfold fst_is_n.
  now rewrite Ha.
Qed.

Lemma find_conflict_correct : forall (n : Z) (fixedValues : MSetZString.t) (v : var),
  find_conflict n fixedValues = Some v -> MSetZString.In (n, v) fixedValues.
Proof.
  intros n fixedValues v Hfind.
  unfold find_conflict in Hfind.
  destruct (MSetZString.choose (MSetZString.filter (fst_is_n n) fixedValues)) as [ n_v | ] eqn:Hchoose.
  2: inversion Hfind.
  apply ZStringFacts.filter_1 with (f := fst_is_n n). apply fst_is_n_Proper.
  apply MSetZString.choose_spec1 in Hchoose.
  apply ZStringFacts.filter_2 with (f := fst_is_n n) in Hchoose as Hfst. 2: apply fst_is_n_Proper.
  assert (n_v = (n, v)).
  {
    destruct n_v as [n' v'].
    unfold fst_is_n in Hfst. simpl in Hfst. apply Z.eqb_eq in Hfst. inversion Hfind as [Hvv']. 
    subst v'. subst n'.
    reflexivity.
  }
  subst n_v.
  exact Hchoose.
Qed.
  
Definition fold_f (st : state) (v : var) (acc : accum) : accum :=
  let (fixedValues, conflict) := acc in
  match conflict with
  | Some _ => acc
  | None =>
    match st v with
    | fixed n =>
      match find_conflict n fixedValues with
      | Some v' => (fst acc, Some (v, v'))
      | None => (MSetZString.add (n, v) fixedValues, None)
      end
    | _ => acc
    end
  end.

Lemma fold_f_correct_conflict : forall (st : state) (v : var) (c_var : var) (v' : var) (fixedValues fixedValues': MSetZString.t) , 
fold_f st v (fixedValues, None) = (fixedValues', Some (v', c_var)) -> (exists (n : Z), v' = v /\ fixedValues' = fixedValues /\ MSetZString.In (n, c_var) fixedValues /\ st v = fixed n).
Proof.
  intros st v c_var v' fixedValues fixedValues'.
  intros Hfold.
  unfold fold_f in Hfold.
  destruct (st v) as [| n] eqn:Hstv. inversion Hfold.
  exists n.
  destruct (find_conflict n fixedValues) as [c_var' | ] eqn:Hfind.
  - simpl in Hfold. inversion Hfold. subst v'. subst c_var'. subst fixedValues'.
    clear Hfold.
    split. reflexivity.
    split. reflexivity.
    split.
    { apply find_conflict_correct. exact Hfind. } 
    reflexivity.
  - inversion Hfold.
Qed.

(* Lemma fold_f_correct_fixed : forall (v : var) (v' : var) (preValues: MSetZString.t) (fixedValues: MSetZString.t) (st : state), 
fold_f v (preValues, None) st = (fixedValues, None) -> (exists (n : Z), MSetZString.In (n, v') fixedValues /\ st v = fixed n).
Proof.
Qed. *)

Definition all_diff_find_conflict_all_fold (c : MSetString.t) (st : state) : accum :=
  MSetString.fold 
    (fold_f st)
    c 
    (MSetZString.empty, None)
.

Module SetStringFacts := MSetFacts.Facts MSetString.
Module SetStringProps := MSetProperties.Properties MSetString.

Definition alldifferent_fold_prop (st : state) (s : MSetString.t) (acc : accum) := 
  match acc with
    | (_, Some (v1, v2)) => exists n, v1 <> v2 /\ MSetString.In v1 s /\ MSetString.In v2 s /\ st v1 = fixed n /\ st v2 = fixed n
    | (fixedValues, None) => (forall (v : var) (n : Z), MSetZString.In (n, v) fixedValues <-> st v = fixed n /\ MSetString.In v s) /\ (forall (x y : var) (n : Z), x <> y -> st x = fixed n -> st y = fixed n -> ~ In x s \/ ~ In y s)
  end.

Lemma fold_f_correct_noconflict : forall (st : state) (fixedBefore : MSetZString.t) (v : var) (fixedValues : MSetZString.t), 
  fold_f st v (fixedBefore, None) = (fixedValues, None) 
    -> 
  match st v with
  | fixed n => 
    MSetZString.In (n, v) fixedValues 
      /\
    (forall (v' : var), v <> v' -> st v' = fixed n -> ~ MSetZString.In (n, v') fixedBefore)
  | _ => fixedBefore = fixedValues
  end.
Proof.
  intros st fixedBefore v fixedValues. unfold fold_f. intros Hfoldf. 
  destruct (st v) as [| n] eqn:Hstv.
  { inversion Hfoldf. reflexivity. }
  destruct (find_conflict n fixedBefore) eqn:Hfind; try congruence.
  injection Hfoldf as Hfoldf.
  split.
  - rewrite <- Hfoldf.
    apply MSetZString.add_spec. left.
    reflexivity.
  - intros v'. intros Hvnotv' Hvfixedv'. unfold find_conflict in Hfind. destruct (MSetZString.choose
(MSetZString.filter (fst_is_n n) fixedBefore)) eqn:Hchoose.
    { destruct e. congruence. }
    apply MSetZString.choose_spec2 in Hchoose.
    specialize (Hchoose (n, v')).
    rewrite MSetZString.filter_spec in Hchoose.
    2: apply fst_is_n_Proper.
    (* rewrite <- Hfoldf. rewrite MSetZString.add_spec. *)
    rewrite <- MSetZString.mem_spec in *.
    unfold not. intros Hfalse.
    rewrite <- andb_true_iff in Hchoose.
    apply not_true_is_false in Hchoose.
    rewrite andb_false_iff in Hchoose.
    destruct Hchoose as [Hnotmem | Hnofst].
    + rewrite Hfalse in Hnotmem. congruence.
    + unfold fst_is_n in Hnofst. simpl in Hnofst. rewrite Z.eqb_neq in Hnofst. contradiction.
Qed.

Ltac destruct_eqb x y :=
  let H := fresh "H" in
  lazymatch type of x with
  | nat => destruct (Nat.eqb x y) eqn:H; [rewrite Nat.eqb_eq in H; subst | rewrite Nat.eqb_neq in H]
  | Z => destruct (Z.eqb x y) eqn:H; [rewrite Z.eqb_eq in H; subst | rewrite Z.eqb_neq in H]
  | var => destruct (String.eqb x y) eqn:H; [rewrite String.eqb_eq in H; subst | rewrite String.eqb_neq in H]
  | string => destruct (String.eqb x y) eqn:H; [rewrite String.eqb_eq in H; subst | rewrite String.eqb_neq in H]
  | _ => fail "Unsupported type for destruct_eqb"
  end; try congruence.

Lemma alldifferent_fold_step :
  forall (st : state) (c : MSetString.t) (x : MSetString.elt) (a : accum)
    (s' s'' : MSetString.t),
    MSetString.In x c ->
    ~ MSetString.In x s' ->
    SetStringProps.Add x s' s'' -> (alldifferent_fold_prop st) s' a -> (alldifferent_fold_prop st) s''
    (fold_f st x a).
Proof.
  intros st ct.
  intros v acc s_p_holds s_with_v Hvinc Hvnotins Hadd IH.
  destruct acc as [fixedValues [(x, y) |]].
  - unfold alldifferent_fold_prop in *.
    unfold fold_f.
    destruct IH as [n [Hxneqy [Hxinsph [Hyinsph [Hfxn Hfyn]]]]].
    exists n.
    unfold SetStringProps.Add in Hadd.
    split.
    { apply Hxneqy. }
    split.
    { apply Hadd. right. exact Hxinsph. }
    split.
    { apply Hadd. right. exact Hyinsph. }
    split.
    { exact Hfxn. }
    { exact Hfyn. }
  - unfold alldifferent_fold_prop in IH.
    destruct IH as [IH IHno_two_fix].
    destruct (fold_f st v (fixedValues, None)) as [fixedValues' [(v', cv) |]] eqn:Hfoldf.
    + unfold alldifferent_fold_prop.
      specialize (fold_f_correct_conflict st v cv v' fixedValues fixedValues' Hfoldf) as Hfoldf_corr.
      destruct Hfoldf_corr as [n [H0 [H1 [Hin Hfvn]]]].
      subst v'. subst fixedValues'.
      exists n.
      unfold alldifferent_fold_prop in IH.
      specialize (IH cv n). rewrite IH in Hin. destruct Hin as [H Hin].
      repeat split; try assumption.
      { destruct (v =? cv)%string eqn:Hv.
        - rewrite String.eqb_eq in Hv. subst cv. contradiction.
        - rewrite String.eqb_neq in Hv. exact Hv.
      }
      { apply Hadd. left. reflexivity. }
      { apply Hadd. right. exact Hin. }
    + unfold alldifferent_fold_prop.
      clear Hvinc.
      split.
      {
        (* vFix here is either v' in fixedValues or v *)
        intros vFix n.
        unfold fold_f in Hfoldf.
        destruct (st v) as [| m] eqn:Hstv.
        - inversion Hfoldf. subst fixedValues'.
          specialize (IH vFix n). rewrite IH.
          split.
          { 
            intros [Hvfix Hin]. split. exact Hvfix.
            apply Hadd. right. exact Hin.
          }
          {
            intros [Hvfix Hin]. split. exact Hvfix.
            apply Hadd in Hin. destruct Hin as [Hvvfix | Hin].
            - subst vFix. rewrite Hvfix in Hstv. inversion Hstv.
            - assumption.
          }
        - destruct (find_conflict m fixedValues) as [c_var | ] eqn:Hfind.
          { simpl in Hfoldf. inversion Hfoldf. }
          inversion Hfoldf as [Hnvfixed]. clear Hfoldf.
          destruct (v =? vFix)%string eqn:Hv.
          + rewrite String.eqb_eq in Hv. subst vFix.
            destruct (n =? m)%Z eqn:Hnm.
            * rewrite Z.eqb_eq in Hnm. subst m.
              repeat split; try intros; try assumption.
              { apply Hadd. left. reflexivity. }
              { apply MSetZString.add_spec. left. reflexivity. }
            * split.
              { intros Hin. 
                rewrite ZStringFacts.add_iff in Hin.
                destruct Hin as [Hin | Hin].
                + inversion Hin. inversion H. simpl in H1.
                  rewrite Z.eqb_neq in Hnm. rewrite H1 in Hnm. contradiction.
                + rewrite IH in Hin.
                  destruct Hin as [Hfvn Hvsph].
                  split.
                  { exact Hfvn. }
                  { apply Hadd. left. reflexivity. }
              }
              {
               intros [Hvn _].
               rewrite Hvn in Hstv. injection Hstv as Hnm_eq.
               rewrite Z.eqb_neq in Hnm.
               contradiction. 
              }
          + split.
            * intros Hin. assert (MSetZString.In (n, vFix) fixedValues) as Hinfixed.
              { rewrite ZStringFacts.add_iff in Hin.
                destruct Hin as [Hin | Hin].
                - inversion Hin. inversion H0. 
                  simpl in H1. rewrite String.eqb_neq in Hv. rewrite H1 in Hv. contradiction.
                - exact Hin.
              }
              specialize (IH vFix n).
              apply IH in Hinfixed.
              destruct Hinfixed as [Hfvfixn Hvfixinsph].
              split.
              { exact Hfvfixn. }
              { apply Hadd. right. exact Hvfixinsph. } 
            * intros [Hstvfix Hin].
              rewrite MSetZString.add_spec. right.
              rewrite IH.
              split. { assumption. }
              apply Hadd in Hin. destruct Hin as [Hvvfix | Hinspholds].
              { subst vFix. rewrite eqb_neq in Hv. contradiction. }
              { assumption. }
      }
      {
        intros x y n Hxneqy Hxn Hyn. rename s_p_holds into s. clear ct.
        specialize (IHno_two_fix x y n Hxneqy Hxn Hyn).
        specialize (fold_f_correct_noconflict st fixedValues v fixedValues' Hfoldf) as Hnoconfl. clear Hnoconfl.
        unfold SetStringProps.Add in Hadd.
        repeat rewrite Hadd. clear Hadd. repeat rewrite <- String.eqb_eq. repeat rewrite <- MSetString.mem_spec.
        repeat rewrite <- orb_true_iff. repeat rewrite not_true_iff_false. 
        repeat rewrite orb_false_iff.
        repeat rewrite String.eqb_neq.
        repeat rewrite <- SetStringFacts.not_mem_iff.
        destruct (st v) as [| m] eqn:Hstv.
        { 
          destruct (IHno_two_fix) as [Hxnotin | Hynotin].
          - left. enough (x <> v) as H.
            { 
              split.
              - symmetry. assumption.
              - assumption.
            }
            unfold not. intros Hvo. subst v. congruence.
          - right. enough (y <> v) as H.
            { 
              split.
              - symmetry. assumption.
              - assumption.
            }
            unfold not. intros Hvo. subst v. congruence.
        }
        specialize (fold_f_correct_noconflict st fixedValues v fixedValues' Hfoldf) as Hnoconfl. rewrite Hstv in Hnoconfl.
        destruct Hnoconfl as [HH Hn].
        unfold MSetString.elt in v.
        destruct (IHno_two_fix) as [Hxnotin | Hynotin]; clear IHno_two_fix.  
        - destruct (mem y s) eqn:Hyin.
          + rewrite MSetString.mem_spec in Hyin.
            assert (MSetZString.In (n, y) fixedValues).
            { apply IH. split; assumption. }
            destruct_eqb x v.
            * rewrite Hxn in Hstv. inversion Hstv. subst m.
              destruct_eqb v y.
              specialize (Hn y H0 Hyn) as Hcontra.
              contradiction.
            * left. split.
              { symmetry. assumption. }
              { assumption. }
          + destruct_eqb y v; destruct_eqb x v.
            * left. split. symmetry. assumption. assumption.
            * right. split.
              { symmetry. assumption. }
              { 
                rewrite <- MSetString.mem_spec.
                unfold mem in Hyin. rewrite Hyin. discriminate. 
              }
            * left. split. symmetry. assumption. assumption.
        - destruct (mem x s) eqn:Hxin.
          + rewrite MSetString.mem_spec in Hxin.
            assert (MSetZString.In (n, x) fixedValues).
            { apply IH. split; assumption. }
            destruct_eqb y v.
            * rewrite Hyn in Hstv. inversion Hstv. subst m.
              destruct_eqb v x.
              specialize (Hn x H0 Hxn) as Hcontra.
              contradiction.
            * right. split.
              { symmetry. assumption. }
              { assumption. }
          + destruct_eqb x v; destruct_eqb y v.
            * right. split. symmetry. assumption. assumption.
            * left. split.
              { symmetry. assumption. }
              { 
                rewrite <- MSetString.mem_spec.
                unfold mem in Hxin. rewrite Hxin. discriminate. 
              }
            * right. split. symmetry. assumption. assumption.
      }
Qed.

Lemma alldifferent_fold_ind :
  forall (c : MSetString.t) (st : state),
  (alldifferent_fold_prop st) c (all_diff_find_conflict_all_fold c st).
Proof.
  intros c st. unfold all_diff_find_conflict_all_fold.

  set (P := alldifferent_fold_prop st).
  specialize SetStringProps.fold_rec with (f := fold_f st) (i := (MSetZString.empty, None)) (s := c) (P := P) as Hind.

  apply Hind.
  {
    intros vars Hempty. 
    unfold P. simpl.
    assert (forall v, MSetString.In v vars <-> False).
    { intros v. split. 
      - intros Hin. unfold MSetString.Empty in Hempty. apply (Hempty v). exact Hin.
      - intros Hfalse. contradiction. 
    }

    split.
    - intros v n. rewrite ZStringFacts.empty_iff. rewrite (H v).
      split.
      + intros Hfalse. contradiction.
      + intros [_ Hinvars]. contradiction. 
    - intros x y n. intros. left.
      unfold not. intros Hin. rewrite <- (H x).
      exact Hin.
  }
  {
    apply alldifferent_fold_step.
  }
Qed.

  

Theorem all_diff_find_conflict_all_fold_correct : 
  forall (c : MSetString.t) (st : state) (x y : var) (fixedValues: MSetZString.t),
  all_diff_find_conflict_all_fold c st = (fixedValues, Some (x, y)) -> 
  exists (n : Z), x <> y /\ MSetString.In x c /\ MSetString.In y c /\ st x = fixed n /\ st y = fixed n.
Proof.
  intros c st x y fixedV Hfold.
  unfold all_diff_find_conflict_all_fold in Hfold.
  specialize (alldifferent_fold_ind c st) as Hind. unfold all_diff_find_conflict_all_fold in Hind.
  rewrite Hfold in Hind.
  unfold alldifferent_fold_prop in Hind.
  exact Hind.
Qed.


Definition all_diff_find_conflict_all (c : MSetString.t) (st : state) : option (var * var) :=
  match all_diff_find_conflict_all_fold c st
  with
  | (_, Some (v1, v2)) => Some (v1, v2)
  | _ => None
  end
.



Definition all_diff_with_conflict (c : all_different) (st : state) (var_1 : var) (var_2 : var) : bool :=
  if (var_1 =? var_2)%string
    then false
    else if (mem var_1 c && mem var_2 c) then
      match (st var_1, st var_2) with
      | (fixed n, fixed m) => if (n =? m)%Z then true else false
      | _ => false
      end
    else false
.

Definition all_diff_propagate (c : all_different) (st : state) : bool :=
  match all_diff_find_conflict_all c st with
  | Some (v1, v2) => all_diff_with_conflict c st v1 v2
  | None => false
  end
.

Lemma with_conflict_sound : forall (c : all_different) (st : state) (var_1 : var) (var_2 : var),
 (* Move the in check to the with_conflict and not equal *)
  all_diff_with_conflict c st var_1 var_2 = true -> ~ AllDifferent c st.
Proof.
  intros c st var_1 var_2.
  intros Hconfl.
  unfold all_diff_with_conflict in Hconfl.
  destruct (var_1 =? var_2)%string eqn:Hnotsame. inversion Hconfl.
  destruct (mem var_1 c && mem var_2 c) eqn:Hin.
  2: inversion Hconfl.
  destruct (st var_1) as [| n] eqn:Hst1. inversion Hconfl.
  destruct (st var_2) as [| m] eqn:Hst2. inversion Hconfl.
  unfold not. intros Halldiff.
  unfold AllDifferent in Halldiff.
  rewrite String.eqb_neq in Hnotsame.
  destruct (n =? m)%Z eqn:Hnm.
  apply andb_prop in Hin as [Hin1 Hin2].
  apply MSetString.mem_spec in Hin1.
  apply MSetString.mem_spec in Hin2.
  - specialize (Halldiff var_1 var_2 n m Hin1 Hin2 Hnotsame Hst1 Hst2).
    rewrite Z.eqb_eq in Hnm. rewrite Hnm in Halldiff. contradiction.
  - inversion Hconfl.
Qed.

Theorem all_diff_find_conflict_all_yes_conflict : forall (c : all_different) (st : state) (x y : var),
  all_diff_find_conflict_all c st = Some (x, y) -> all_diff_with_conflict c st x y = true.
Proof.
  intros c st x y Hprop.
  unfold all_diff_find_conflict_all in Hprop.
  destruct (all_diff_find_conflict_all_fold c st) as [fixedValues [(x', y') | ]] eqn:Hfold.
  - inversion Hprop. subst x'. subst y'. clear Hprop.
    apply all_diff_find_conflict_all_fold_correct in Hfold.
    unfold not. unfold all_diff_with_conflict.
    destruct Hfold as [n [Hxneqy [Hxinc [Hyinc [Hfxn Hfyn]]]]].
    destruct_eqb x y.
    rewrite <- MSetString.mem_spec in *.
    destruct (mem x c && mem y c) eqn:Hmemand.
    + rewrite Hfxn. rewrite Hfyn.
      destruct_eqb n n.
    + rewrite <- Hmemand. rewrite andb_true_iff. 
      split; assumption.
  - inversion Hprop.
Qed.



Theorem all_diff_find_conflict_all_sound : forall (c : all_different) (st : state) (x y : var),
  all_diff_find_conflict_all c st = Some (x, y) -> ~ AllDifferent c st.
Proof.
  intros c st x y Hprop.
  apply all_diff_find_conflict_all_yes_conflict in Hprop.
  apply (with_conflict_sound c st) with (var_1 := x) (var_2 := y).
  exact Hprop.
Qed.


Theorem all_diff_find_conflict_all_fold_both_complete : 
  forall (c : MSetString.t) (x y : var) (n : Z) (st : state),
  x <> y -> MSetString.In x c -> MSetString.In y c -> st x = fixed n -> st y = fixed n -> exists confl fixedValues, all_diff_find_conflict_all_fold c st = (fixedValues, Some confl). 
Proof.
  intros c x y n st.
  intros Hxneqy Hxinc Hyinc Hfxn Hfyn.
  unfold all_diff_find_conflict_all_fold.
  specialize (alldifferent_fold_ind c st) as Hind.
  unfold all_diff_find_conflict_all_fold in Hind.
  destruct (MSetString.fold (fold_f st) c (MSetZString.empty, None)) as [fixedValues maybeConfl] eqn:Hfold.
  destruct maybeConfl as [confl | ] eqn:Hconfl.
  - exists confl. exists fixedValues. reflexivity.
  - unfold alldifferent_fold_prop in Hind.
    destruct Hind as [_ Hnotin].
    specialize (Hnotin x y n Hxneqy Hfxn Hfyn).
    destruct Hnotin.
    + contradiction.
    + contradiction.
Qed.

Theorem all_different_complete : forall (c : all_different) (st : state),
  all_diff_propagate c st = true <-> ~ AllDifferent c st.
Proof.
  intros c st.
  split.
  - unfold all_diff_propagate.
    destruct (all_diff_find_conflict_all c st) as [(v1, v2) | ] eqn:Hconflict.
    + apply with_conflict_sound.
    + intros Hfalse. congruence.
  - intros Hnotalldiff.
    unfold all_diff_propagate.
    destruct (all_diff_find_conflict_all c st) as [(v1, v2) | ] eqn:Hconflict.
    + apply all_diff_find_conflict_all_yes_conflict.
      exact Hconflict.
    + unfold all_diff_find_conflict_all in Hconflict.
      destruct (all_diff_find_conflict_all_fold c st) as [fixedValues maybeConfl] eqn:Hresult.
      destruct maybeConfl as [(x, y) |].
      { inversion Hconflict. }
      clear Hconflict.
      unfold AllDifferent in Hnotalldiff.
      specialize (alldifferent_fold_ind c st) as Hind.
      rewrite Hresult in Hind. unfold alldifferent_fold_prop in Hind.
      destruct Hind as [_ H].
      exfalso.
      apply Hnotalldiff.
      intros x y n m.
      intros Hxinc Hyinc Hxneqy Hx Hy.
      destruct (n =? m)%Z eqn:Hnm.
      2: {
        rewrite Z.eqb_neq in Hnm. exact Hnm.
      }
      rewrite Z.eqb_eq in Hnm. subst m.
      specialize (H x y n Hxneqy Hx Hy).
      destruct H.
      * contradiction.
      * contradiction.
Qed.