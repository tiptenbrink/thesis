Require Import Coq.Strings.String.
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


Theorem all_diff_find_conflict_all_fold_correct : 
  forall (c : MSetString.t) (st : state) (x y : var) (fixedValues: MSetZString.t),
  all_diff_find_conflict_all_fold c st = (fixedValues, Some (x, y)) -> 
  exists (n : Z), x <> y /\ MSetString.In x c /\ MSetString.In y c /\ st x = fixed n /\ st y = fixed n.
Proof.
  intros c st x y fixedV Hfold.
  unfold all_diff_find_conflict_all_fold in Hfold.
  (* Use fold_rec induction principle *)
  specialize SetStringProps.fold_rec with (f := fold_f st) as Hind.
  specialize Hind with (i := (MSetZString.empty, None)).
  specialize Hind with (s := c).

  set (P := fun (s : MSetString.t) (acc : accum) =>
    match acc with
    | (_, Some (v1, v2)) => exists n, v1 <> v2 /\ MSetString.In v1 s /\ MSetString.In v2 s /\ st v1 = fixed n /\ st v2 = fixed n
    | (fixedValues, _) => forall (v : var) (n : Z), MSetZString.In (n, v) fixedValues -> st v = fixed n /\ MSetString.In v s
    end).

  specialize Hind with (P := P).

  assert (Hbase : forall s' : MSetString.t, MSetString.Empty s' -> P s' (MSetZString.empty, None)).
  { 
    intros vars Hempty. 
    unfold P. intros v n. intros Hinempty. inversion Hinempty.  
  }

  assert (Hstep : 
    forall (v : var) (a : accum) (s' s'' : MSetString.t),
    MSetString.In v c ->
    ~ MSetString.In v s' ->
    SetStringProps.Add v s' s'' ->
    P s' a -> P s'' (fold_f st v a)).
  {
    clear Hind Hbase x y fixedV Hfold. 
    intros v acc s_p_holds s_with_v Hvinc Hvnotins Hadd IH.
    destruct acc as [fixedValues [(x, y) |]].
    - unfold P.
       unfold fold_f.
      unfold P in IH. destruct IH as [n [Hxneqy [Hxinsph [Hyinsph [Hfxn Hfyn]]]]].
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
    - unfold P in IH. 
      destruct (fold_f st v (fixedValues, None)) as [fixedValues' [(v', cv) |]] eqn:Hfoldf.
        + unfold P.
          specialize (fold_f_correct_conflict st v cv v' fixedValues fixedValues' Hfoldf) as Hfoldf_corr.
          destruct Hfoldf_corr as [n [H0 [H1 [Hin Hfvn]]]].
          subst v'. subst fixedValues'.
          exists n.
          unfold P in IH.
          specialize (IH cv n Hin). destruct IH as [Hcv Hcvinsph].
          split.
          { destruct (v =? cv)%string eqn:Hv.
            - rewrite String.eqb_eq in Hv. subst cv. contradiction.
            - rewrite String.eqb_neq in Hv. exact Hv.
          }
          split.
          { apply Hadd. left. reflexivity. }
          split.
          { apply Hadd. right. exact Hcvinsph. }
          split.
          exact Hfvn.
          exact Hcv.
        + unfold P. clear P.
          (* vFix here is either v' in fixedValues or v *)
          intros vFix n Hin.
          unfold fold_f in Hfoldf.
          destruct (st v) as [| m] eqn:Hstv.
          * inversion Hfoldf. subst fixedValues'.
            specialize (IH vFix n Hin).
            destruct IH as [Hfvfixn Hvfixinsph].
            split.
            { exact Hfvfixn. }
            { apply Hadd. right. exact Hvfixinsph. }
          * destruct (find_conflict m fixedValues) as [c_var | ] eqn:Hfind.
            { simpl in Hfoldf. inversion Hfoldf. }

            { 
              inversion Hfoldf as [Hnvfixed]. clear Hfoldf.
              destruct (v =? vFix)%string eqn:Hv.
              - rewrite String.eqb_eq in Hv. subst vFix.
                destruct (n =? m)%Z eqn:Hnm.
                + rewrite Z.eqb_eq in Hnm. subst m.
                  split.
                  { exact Hstv. }
                  { apply Hadd. left. reflexivity. }
                + rewrite <- Hnvfixed in Hin.
                  rewrite ZStringFacts.add_iff in Hin.
                  destruct Hin as [Hin | Hin].
                  * inversion Hin. inversion H. simpl in H1.
                    rewrite Z.eqb_neq in Hnm. rewrite H1 in Hnm. contradiction.
                  * specialize (IH v n Hin).
                    destruct IH as [Hfvn Hvsph].
                    split.
                    { exact Hfvn. }
                    { apply Hadd. left. reflexivity. }
              - assert (MSetZString.In (n, vFix) fixedValues) as Hinfixed.
                { rewrite <- Hnvfixed in Hin.
                  rewrite ZStringFacts.add_iff in Hin.
                  destruct Hin as [Hin | Hin].
                  - inversion Hin. inversion H0. 
                    simpl in H1. rewrite String.eqb_neq in Hv. rewrite H1 in Hv. contradiction.
                  - exact Hin.
                }
                specialize (IH vFix n Hinfixed).
                destruct IH as [Hfvfixn Hvfixinsph].
                split.
                { exact Hfvfixn. }
                { apply Hadd. right. exact Hvfixinsph. }  
             }
  }
  specialize (Hind Hbase Hstep). rewrite Hfold in Hind.
  simpl in Hind.
  exact Hind.
Qed.


Definition all_diff_find_conflict_all (c : MSetString.t) (st : state) : option (var * var) :=
  match all_diff_find_conflict_all_fold c st
  with
  | (_, Some (v1, v2)) => Some (v1, v2)
  | _ => None
  end
.

Theorem all_diff_find_conflict_all_sound : forall (c : all_different) (st : state) (x y : var),
  all_diff_find_conflict_all c st = Some (x, y) -> ~ AllDifferent c st.
Proof.
  intros c st x y Hprop.
  unfold all_diff_find_conflict_all in Hprop.
  destruct (all_diff_find_conflict_all_fold c st) as [fixedValues [(x', y') | ]] eqn:Hfold.
  - inversion Hprop. subst x'. subst y'. clear Hprop.
    apply all_diff_find_conflict_all_fold_correct in Hfold.
    unfold not. intros Halldiff. unfold AllDifferent in Halldiff.
    destruct Hfold as [n [Hxneqy [Hxinc [Hyinc [Hfxn Hfyn]]]]].
    unfold not in Halldiff. apply Halldiff with (x := x) (y := y) (n := n) (m := n); try assumption.
    reflexivity.
  - inversion Hprop.
Qed.

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

Definition alldifferent_is_conflict (c : all_different) (st : state) : bool :=
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

Definition var_list := MSetString.t.

Definition NotAllDifferent (c : all_different) (st : state) : Prop :=
  forall (x y : var) (n m : Z),
    In x c ->
    In y c ->
    x <> y ->
    st x = fixed n -> st y = fixed m -> n <> m.

(* Ltac break_if_congruence_o H :=
  repeat match type of H with
  | context[if ?cond then _ else _] =>
      destruct cond eqn:?;
      try congruence
  | context[(_ && _)%bool] =>
      destruct (_ && _)%bool eqn:?;
      try congruence
  | context[(?x =? ?y)%Z] =>
      destruct (x =? y)%Z eqn:?;
      try congruence
  | context[?s ?x] =>
      destruct (?s ?x) eqn:?;
      try congruence
  end.

Ltac break_if_congruence H :=
  repeat match type of H with
  | context C [if ?cond then _ else _] =>
    let Hcond := fresh "Hcond" in
    destruct cond eqn:Hcond;
    try congruence
  | context C [(_ && _)%bool] =>
    let Hbool := fresh "Hbool" in
    destruct (_ && _)%bool eqn:Hbool;
    try congruence
  | context C [(?x =? ?y)%Z] =>
    let HeqZ := fresh "HeqZ" in
    destruct (x =? y)%Z eqn:HeqZ;
    try congruence
  | context C [(?x =? ?y)%string] =>
    let HeqStr := fresh "HeqStr" in
    destruct (x =? y)%string eqn:HeqStr;
    try congruence
  | context C [match ?x with | _ => _ end] =>  (* Handle match expressions *)
    let Hmatch := fresh "Hmatch" in
    destruct x eqn:Hmatch;
    try congruence
  | _ => idtac  (* Base case: do nothing if no matches *)
  end. *)


Theorem all_different_sound : forall (X : var_list) (st : state),
  alldifferent_is_conflict X st = true -> exists (x1 x2 : var) (n : Z), In x1 X /\ In x2 X /\ x1 <> x2 /\ st x1 = fixed n /\ st x2 = fixed n.
Proof.
  intros X st Hprop.
  unfold alldifferent_is_conflict in Hprop.
  destruct (all_diff_find_conflict_all X st) as [conflict |]; try congruence.
  destruct conflict as [x1 x2].
  exists x1. exists x2.
  unfold all_diff_with_conflict in Hprop.
  destruct (x1 =? x2)%string eqn:Hx1neqx2; try congruence.
  destruct (mem x1 X && mem x2 X) eqn:Hmem; try congruence.
  apply andb_prop in Hmem. destruct Hmem as [Hmemx1 Hmemx2]. rewrite MSetString.mem_spec in *.
  destruct (st x1) as [| n] eqn:Hx1st; try congruence.
  destruct (st x2) as [| m] eqn:Hx2st; try congruence.
  destruct (n =? m)%Z eqn:Hnm; try congruence.
  clear Hprop. rewrite Z.eqb_eq in Hnm.
  subst m.
  exists n.
  rewrite eqb_neq in Hx1neqx2.
  repeat split; assumption.
Qed.


  
