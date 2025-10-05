Require Import Coq.Arith.PeanoNat.
Require Import Coq.ZArith.BinInt.
From PROP Require Import Maps.
From PROP Require Import CPTypes.
From PROP Require Import CPTactics.
From PROP Require Import DecideCP.


Definition AllDifferent (c : vars) (v : valuation) : Prop :=
  (forall (x y : string), 
  x <> y -> sstr.In x c -> sstr.In y c -> v x <> v y).


Definition find_conflict_filter_f (n : Z) (el: (Z * string)) :=
  let (n', _) := el in (n =? n')%Z.

Lemma filter_proper :
  forall n,
  Morphisms.Proper
    (Morphisms.respectful
      (RelationPairs.RelProd eq eq) eq)
    (find_conflict_filter_f n).
Proof.
  intros n.
  unfold Morphisms.Proper, Morphisms.respectful.
  intros [u1 u2] [v1 v2] Hrel.
  inversion Hrel. 
  assert (u1 = fst (u1, u2)) by reflexivity.
  rewrite H1.
  assert (v1 = fst (v1, v2)) by reflexivity.
  now rewrite H.
Qed.

Definition find_conflict (x : string) (n : Z) (values : sintstr.t) : option (Z * string) := 
  sintstr.choose (sintstr.filter (find_conflict_filter_f n) values).

Lemma find_conflict_correct :
  forall x n values,
    match find_conflict x n values with
    | Some (n', y) => n = n' /\ sintstr.In (n, y) values
    | None => forall n' y, sintstr.In (n', y) values -> n' <> n
    end.
Proof.
  intros x n values.
  destruct (find_conflict x n values) as [[n' y] | ] eqn:Hfind.
  - unfold find_conflict in Hfind.
    apply sintstr.choose_spec1 in Hfind.
    apply sintstr.filter_spec in Hfind.
    + unfold find_conflict_filter_f in Hfind.
      destruct (n =? n')%Z eqn:Hnn'.
      * destruct Hfind as [Hin _ ]. 
        rewrite Z.eqb_eq in Hnn'. subst n'. split; easy.
      * destruct Hfind as [_ Hcontra]. congruence.
    + apply filter_proper.
  - unfold find_conflict in Hfind.
    apply sintstr.choose_spec2 in Hfind.
    unfold sintstr.Empty in Hfind.
    intros n' y Hin.
    specialize (Hfind (n', y)).
    unfold not in Hfind.
    rewrite sintstr.filter_spec in Hfind.
    {
      unfold find_conflict_filter_f in Hfind.
      destruct (n =? n')%Z eqn:Hnn'.
      - unfold not. intros Hnisn'. apply Hfind.
        split; easy.
      - rewrite Z.eqb_neq in Hnn'. symmetry. exact Hnn'.
    }
    apply filter_proper.
Qed.

Definition values_or_conflict (x : string) (n : Z) (acc : option (string * string) * sintstr.t) :=
  let (maybeConfl, values) := acc in
    match maybeConfl with
    | Some confl => (Some confl, values)
    | None => match find_conflict x n values with
              | Some (_, y) => (Some (x, y), values)
              | None => (None, sintstr.add (n, x) values)
              end
    end
.

Lemma values_or_conflict_correct : forall x n acc,
  match acc with
  | (Some (v1, v2), values) => values_or_conflict x n acc = (Some (v1, v2), values)
  | (None, values) => 
    match values_or_conflict x n acc with
    | (Some (v1, v2), values_after) => v1 = x /\ values_after = values /\ sintstr.In (n, v2) values
    | (None, values_after) => sintstr_prps.Add (n, x) values values_after /\ (forall y m, y <> x -> sintstr.In (m, y) values -> m <> n)
    end
  end.
Proof.
  intros x n [maybeConfl values].
  destruct maybeConfl as [[v1 v2] | ].
  - unfold values_or_conflict. reflexivity.
  - destruct (values_or_conflict x n (None, values)) as [maybeConfl values_after] eqn:Hresult.
    + destruct maybeConfl as [[v1 v2] | ].
      * unfold values_or_conflict in Hresult.
        destruct (find_conflict x n values) as [[n' y] |] eqn:Hfind.
        -- specialize (find_conflict_correct x n values) as Hfind2. rewrite Hfind in Hfind2.
          inversion Hresult. subst v1. subst v2. subst values_after.
          repeat split; easy.
        -- inversion Hresult.
      * unfold values_or_conflict in Hresult.
        specialize (find_conflict_correct x n values) as Hfind_facts.
        destruct (find_conflict x n values) as [[n' y] |] eqn:Hfind.
        { inversion Hresult. }
        { 
          inversion Hresult as [Hadd]. clear Hresult.
          split.
          - apply sintstr_prps.Add_add.
          - intros y m.
            intros Hxny Hnyin.
            destruct_eqb m n.
            apply Hfind_facts with (y := y) (n' := n).
            exact Hnyin.
        }
Qed.

Definition all_different_fold_f (v : valuation) (x : string) (acc : option (string * string) * sintstr.t) :=
  values_or_conflict x (v x) acc.

Definition all_different_fold (vs : vars) (v : valuation) :=
  sstr.fold (all_different_fold_f v) vs (None, sintstr.empty).

Lemma Add_in :
  forall n x s s' (H : sintstr_prps.Add (n, x) s s'), 
  forall y m, sintstr.In (m, y) s' -> (m = n /\ x = y) \/ sintstr.In (m, y) s.
Proof.
  intros x n s s'.
  intros Hadd y m Hin.
  apply Hadd in Hin.
  destruct Hin as [Heq | Hin].
  - left.
    inversion Heq.
    inversion H. simpl in H1.
    inversion H0. simpl in H2. 
    subst y. subst m.
    split; reflexivity.
  - right. exact Hin.
Qed.

Lemma all_different_fold_var_eq :
  forall vs v1 v2,
    Varlist_eq_all v1 v2 vs ->
    all_different_fold vs v1 = all_different_fold vs v2.
Proof.
  intros vs v1 v2 Heq.
  unfold all_different_fold.
  apply sstr_prps.fold_rel with (R := fun r1 r2 => r1 = r2) (f := (all_different_fold_f v1)) (g := (all_different_fold_f v2)) (i := (None, sintstr.empty)) (j := (None, sintstr.empty)) (s := vs).
  - reflexivity.
  - intros x acc acc' Hin Hacc_eq.
    subst acc'.
    unfold all_different_fold_f.
    rewrite Heq.
    + reflexivity.
    + exact Hin.
Qed.
  

Lemma all_different_fold_props :
  forall v vs,
    match all_different_fold vs v with
    | (Some(x, y), values) => exists n, x <> y /\ sstr.In x vs /\ sstr.In y vs /\ v x = n /\ v y = n
    | (None, values) => (forall x n, sintstr.In (n, x) values <-> v x = n /\ sstr.In x vs) /\ (forall x y n m, x <> y -> sintstr.In (n, x) values -> sintstr.In (m, y) values -> n <> m)
    end.
Proof.
  intros v vs.

  set (P :=
    fun (s : sstr.t) (acc : option (string * string) * sintstr.t) =>
      match acc with
      | (Some(x, y), values) => exists n, x <> y /\ sstr.In x s /\ sstr.In y s /\ v x = n /\ v y = n
      | (None, values) => (forall x n, sintstr.In (n, x) values <-> v x = n /\ sstr.In x s) /\ (forall x y n m, x <> y -> sintstr.In (n, x) values -> sintstr.In (m, y) values -> n <> m)
      end
  ).

  assert (P vs (all_different_fold vs v)).
  {
    apply sstr_prps.fold_rec with (f := (all_different_fold_f v)) (P := P) (i := (None, sintstr.empty)) (s := vs).
    { unfold P; clear P.
      intros s Hempty.
      split.
      - intros x n. split.
        + intros Hin.
          exfalso.
          apply (sintstr.empty_spec Hin).
        + intros [_ Hcontra].
          exfalso.
          apply (Hempty x Hcontra).
      - intros x y n m Hxny Hin.
        exfalso.
        apply (sintstr.empty_spec Hin).
    }
    {
      intros x [maybeConfl values_before] s sx Hxvs Hnots Hadd IH.
      unfold P in *; clear P.
      unfold all_different_fold_f.
      unfold sstr.elt in *.
      specialize (values_or_conflict_correct x (v x) (maybeConfl, values_before)) as Hvalconfl.
      destruct maybeConfl as [[v1 v2] |].
      - rewrite Hvalconfl.
        destruct IH as [n [Hv1nv2 [Hv1s [Hv2s [Hv1 Hv2]]]]].
        exists n.
        repeat split; try assumption.
        + apply Hadd. right. exact Hv1s.
        + apply Hadd. right. exact Hv2s.
      - destruct (values_or_conflict x (v x)
      (None, values_before)) as [maybeConfl values] eqn:Hres.
        destruct IH as [IH1 IH2].
        destruct maybeConfl as [[v1 v2] | ].
        + (* Here we're in the case where we found a conflict where there was none previously, so therefore our n should be v x *)
          exists (v x).
          destruct Hvalconfl as [Hv1 [Hvalues Hv2before]].
          subst v1. subst values_before.
          specialize (IH1 v2 (v x)).
          rewrite IH1 in Hv2before.
          destruct Hv2before as [Hv2 Hv2sin].
          repeat split.
          * intros Hxv2. subst v2. contradiction.
          * apply Hadd. left. reflexivity.
          * apply Hadd. right. exact Hv2sin.
          * exact Hv2.
        + clear Hres.
          destruct Hvalconfl as [Haddvalues Hnovx].
          split.
          {
            intros y n. clear IH2. clear Hnovx.
            destruct_eqb y x.
            - split.
              + intros Hinvalues.
                apply Haddvalues in Hinvalues.
                destruct Hinvalues as [Hvxn | Hinbefore].
                * inversion Hvxn. inversion H.
                  simpl in H1.
                  split; try assumption.
                  apply Hadd. left. reflexivity.
                * rewrite IH1 in Hinbefore.
                  destruct Hinbefore as [Hvxn Hxins].
                  contradiction.
              + intros [Hvxn _].
                rewrite Hvxn in Haddvalues.
                apply Haddvalues.
                left. reflexivity.
            - split.
              + intros Hinvalues.
                apply Haddvalues in Hinvalues.
                destruct Hinvalues as [Hcontra | Hinbefore].
                { inversion Hcontra.
                  inversion H1.
                  simpl in H2.
                  symmetry in H2. contradiction.
                }
                rewrite IH1 in Hinbefore.
                destruct Hinbefore as [Hvyn Hyins].
                split.
                * exact Hvyn.
                * apply Hadd. right. exact Hyins.
              + intros [Hvyn Hyinsx].
                apply Haddvalues. right.
                rewrite IH1. split.
                * exact Hvyn.
                * apply Hadd in Hyinsx. destruct Hyinsx.
                  { symmetry in H0. contradiction. }
                  assumption.
          }
          {
            intros v1 v2 n m. 
            intros Hv1nv2 Hin1 Hin2.
            specialize Add_in with (H := Haddvalues) as Hadd_in.
            apply Hadd_in in Hin1.
            apply Hadd_in in Hin2.
            clear Hadd_in.
            destruct Hin1 as [[Hn Hv1] | Hin1].
            - subst n. subst v1.
              destruct Hin2 as [[Hm Hv2] | Hin].
              + subst m. subst v2.
                contradiction.
              + symmetry. apply Hnovx with (y := v2).
                * symmetry. assumption.
                * assumption.
            - destruct Hin2 as [[Hm Hv2] | Hin2].
              + subst m. subst v2.
                apply Hnovx with (y := v1); assumption.
              + apply IH2 with (x := v1) (y := v2); assumption.
          }   
    }
  }
  apply H.
Qed.


Definition dec_all_different (vs : vars) (v : valuation) : bool :=
  match all_different_fold vs v with
  | (Some _, _) => false
  | (None, _) => true
  end
.

Definition dec_var_eq_all_different :
  c_dec_var_eq dec_all_different.
Proof.
  unfold c_dec_var_eq.
  intros v1 v2 vs.
  intros v1v2_eq.
  unfold dec_all_different.
  rewrite all_different_fold_var_eq with (v1 := v1) (v2 := v2).
  - reflexivity.
  - exact v1v2_eq.
Qed.

Lemma dec_iff_all_diff :
  c_dec_iff_c_prop dec_all_different AllDifferent.
Proof.
  unfold c_dec_iff_c_prop.
  intros vs v.
  unfold dec_all_different.
  specialize (all_different_fold_props v vs) as Hfold.
  destruct (all_different_fold vs v) as [maybeConfl values] eqn:Hres.
  destruct maybeConfl as [[x y] |].
  - split; try easy.
    intros Hall_diff.
    exfalso.
    unfold AllDifferent in Hall_diff.
    destruct Hfold as [n [Hxny [Hxin [Hyin [Hvx Hvy]]]]].
    subst n. symmetry in Hvy.
    apply (Hall_diff x y); assumption.
  - split; try easy.
    intros H. clear H.
    unfold AllDifferent.
    intros x y Hxny Hxin Hyin.
    destruct Hfold as [Hinvalues Hneq].
    apply Hneq with (x := x) (y := y).
    + exact Hxny.
    + rewrite Hinvalues. split; easy.
    + rewrite Hinvalues. split; easy.
Qed.

Definition all_different_ctx: ConstraintCtx := {|
  c_prop := AllDifferent;
  c_dec := dec_all_different;
  Hiff := dec_iff_all_diff;
  Hc_dec_var_eq := dec_var_eq_all_different
|}.

Definition AllDifferent_dec (st : state) (vs : vars) :=
  c_sat_all st vs dec_all_different.

Definition AllDifferent_sat (st : state) (vs : vars) :=
  satisfiable st vs AllDifferent.

Theorem satisfiable_iff_sat_all (st : state) vs (Hst : valid_state st vs) :
  AllDifferent_dec st vs = true <-> AllDifferent_sat st vs.
Proof.
  apply (satisfiable_iff_sat_all st all_different_ctx vs Hst). 
Qed.


Definition valuation_values_foldf (v : valuation) (var : string) (values : sint.t) :=
  sint.add (v var) values.

Definition valuation_values (c : vars) (v : valuation) :=
  sstr.fold (valuation_values_foldf v) c sint.empty.

Definition vars_len := sstr.cardinal.

Create HintDb short_unfold_db.
Hint Unfold sint.elt sstr.elt sint.Subset : short_unfold_db.

Lemma alldiff_valuation_values_props (c : vars) (st : state) :
  forall (v: valuation), AllDifferent c v 
    -> 
  vars_len c = sint.cardinal (valuation_values c v) 
    /\ 
  forall n, sint.In n (valuation_values c v) -> exists x, sstr.In x c /\ v x = n.
Proof.
  intros v Hval_alldiff. unfold AllDifferent in Hval_alldiff.
  unfold valuation_values.
  set (P := 
      fun (s : sstr.t) (acc : sint.t) =>
      vars_len s = sint.cardinal acc 
      /\ forall n, sint.In n acc -> exists x, sstr.In x s /\ sstr.In x c /\ v x = n
  ).
  enough (P c (sstr.fold (valuation_values_foldf v) c
  sint.empty)).
  { 
    unfold P in H. clear P. destruct H as [Hcard Hn].
    repeat split; try assumption.
    intros n Hin. destruct (Hn n Hin) as [x [Hinc [_ Hvx]]].
    exists x. split; try assumption.
  }
  apply sstr_prps.fold_rec with (f := valuation_values_foldf v) (i := sint.empty) (s := c) (P := P).
  - autounfold with short_unfold_db in *.
    unfold P in *. clear P. intros s Hempty.
    repeat split.
    + unfold vars_len. rewrite sint.cardinal_spec. simpl. rewrite sstr_prps.cardinal_Empty in Hempty. rewrite Hempty. reflexivity. 
    + intros n Hinempty.
      exfalso.
      apply (sint.empty_spec Hinempty).
  - intros var vals s s_v.
    intros Hin Hvarnots Hadd IH.
    unfold P in *. clear P.
    autounfold with short_unfold_db in *.
    destruct IH as [IH_card Hinvar].
    repeat split.
    + unfold vars_len.
      rewrite sstr_prps.Add_Equal in Hadd.
      apply sstr_prps.Equal_cardinal in Hadd.
      rewrite Hadd.
      unfold valuation_values_foldf.
      rewrite (sstr_prps.add_cardinal_2 Hvarnots).
      assert (~ sint.In (v var) vals) as Hvvarnotvals.
      { 
        intros Hvvarin.
        destruct (Hinvar (v var) Hvvarin) as [x [Hxins [Hxinc Hvx]]].
        apply Hval_alldiff with (x := var) (y := x); try assumption.
        + intros Hvarisx. apply Hvarnots. rewrite Hvarisx. exact Hxins.
        + symmetry. assumption.
      }
      rewrite (sint_prps.add_cardinal_2 Hvvarnotvals).
      f_equal.
      exact IH_card.        
    + intros n Hinfoldf.
      unfold valuation_values_foldf in Hinfoldf.
      rewrite sint.add_spec in Hinfoldf.
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

Definition dom_union (st : state) (v : string) (d: domain) :=
    sint.union (st v) d.

Definition vars_union_domain (st : state) (vs : vars) := 
    sstr.fold 
    (dom_union st)
    vs 
    sint.empty.

Definition dom_size := sint.cardinal.

Definition ex_confl_set (st : state) (vs : vars) := 
(exists (confl_vars : vars), sstr.Subset confl_vars vs /\ dom_size (vars_union_domain st confl_vars) < vars_len confl_vars).

Lemma all_different_subset (v : valuation) :
  forall (vs : vars) (vs' : vars),
  AllDifferent vs v -> sstr.Subset vs' vs -> AllDifferent vs' v.
Proof.
  intros vs vs'. intros Hdiff Hsub.
  unfold AllDifferent in *.
  intros x y.
  intros Hxny Hinx Hiny.
  apply Hdiff; try assumption; apply Hsub; assumption.
Qed.

Lemma vars_union_domain_correct (st : state) (vs : vars) : 
    forall (x : string), sstr.In x vs -> sint.Subset (st x) (vars_union_domain st vs).
Proof.
  intros v. intros Hin.
  autounfold with short_unfold_db in *.
  set (P := 
      fun (s : sstr.t) (acc : sint.t) =>
      forall var, sstr.In var s -> sint.Subset (st var) acc
  ).
  enough (P vs (sstr.fold (dom_union st) vs sint.empty)).
  { unfold P in *. clear P. unfold vars_union_domain. apply H. exact Hin. }
  apply sstr_prps.fold_rec with (f := dom_union st) (i := sint.empty) (s := vs) (P := P); clear v Hin.
  - unfold P in *. clear P. intros s Hempty.
    intros v Hin.
    unfold sstr.In in Hin.
    exfalso.
    apply (Hempty v).
    assumption.
  - intros v dom s s_v.
    intros Hin Hvnots Hadd IH.
    unfold P in *. clear P.
    unfold dom_union. unfold sint.Subset in *.
    intros s_v_el Hs_v_el n_dom Hn_dom.
    rewrite sint.union_spec.
    autounfold with short_unfold_db in *.
    unfold sstr_prps.Add in *.
    rewrite (Hadd s_v_el) in Hs_v_el. 
    destruct_eqb s_v_el v.
    + left. assumption.
    + destruct Hs_v_el as [ His | Hs_v_el].
      { rewrite His in H. contradiction. }
      clear Hadd. right. apply (IH s_v_el).
      * assumption.
      * assumption.
Qed.

Lemma conflict_if_ex_confl_set (vs : vars) (st : state) :
  ex_confl_set st vs -> ~ AllDifferent_sat st vs.
Proof.
  intros H.
  destruct H as [confl_vars [Hsub Hlt]].
  unfold AllDifferent_sat. intros Halldiff.
  destruct Halldiff as [v [Hdom Hdiff]].
  enough (dom_size (vars_union_domain st confl_vars) >= vars_len confl_vars).
  - apply Nat.lt_nge in Hlt.
    contradiction.
  - apply all_different_subset with (vs' := confl_vars) in Hdiff; try assumption.
    destruct (alldiff_valuation_values_props confl_vars st v Hdiff) as [Hvals Hins].
    rewrite Hvals.
    unfold ge.
    apply sint_prps.subset_cardinal.
    unfold sint.Subset.
    intros n Hin.
    destruct (Hins n Hin)  as [x [Hxin Hvx]].
    subst n.
    specialize (vars_union_domain_correct st confl_vars x Hxin) as Hunion.
    autounfold with short_unfold_db in *.
    apply Hunion.
    apply Hdom.
    apply Hsub.
    exact Hxin.
Qed.

Definition mem_check (vs : vars) (x : string) :=
  sstr.mem x vs.

Lemma mem_check_proper :
  forall vs,
  Morphisms.Proper (Morphisms.respectful eq eq)
(mem_check vs).
Proof.
  intros vs.
  unfold Morphisms.Proper, Morphisms.respectful.
  intros x y Hxy. subst y. reflexivity.
Qed.

Definition check_conflict_set (st : state) (confl_vars : vars) (vs : vars) :=
  if (sint.cardinal (vars_union_domain st confl_vars) <? sstr.cardinal confl_vars)
    then sstr.for_all (mem_check vs) confl_vars
    else false.

Lemma check_then_ex (st : state) (confl_vars : vars) (vs : vars) :
  check_conflict_set st confl_vars vs = true ->
    ex_confl_set st vs.
Proof.
  intros Hchecked.
  unfold ex_confl_set.
  exists confl_vars.
  unfold check_conflict_set in Hchecked.
  destruct (sint.cardinal
  (vars_union_domain st confl_vars) <?
  sstr.cardinal confl_vars) eqn:Hlt.
  2: discriminate Hchecked.
  destruct (sstr.for_all (mem_check vs) confl_vars) eqn:Hallmem.
  2: discriminate Hchecked.
  clear Hchecked.
  split.
  - unfold sstr.Subset. intros x Hinconfl.
    rewrite sstr.for_all_spec in Hallmem. 
    2: apply mem_check_proper.
    unfold sstr.For_all in Hallmem.
    rewrite <- sstr.mem_spec.
    apply Hallmem.
    exact Hinconfl.
  - rewrite <- Nat.ltb_lt.
    exact Hlt.
Qed.

Definition choose_if_some (st : state) (x : string) (v : valuation) :=
  match sint.choose (st x) with
  | Some n => t_update v x n
  | _ => v
  end.

Definition choose_valid_v (vs : vars) (st : state) := 
  sstr.fold (choose_if_some st) vs all_zero.

Lemma choose_valid_v_is_valid (st : state) :
  forall vs,
  valid_state st vs -> valuation_in_domain st vs (choose_valid_v vs st).
Proof.
  intros vs Hst.
  set (P := 
      fun (s : sstr.t) (acc : valuation) =>
      valuation_in_domain st s acc
  ).
  unfold choose_valid_v.
  apply sstr_prps.fold_rec with (f := choose_if_some st) (i := all_zero) (s := vs) (P := P).
  {
    intros s Hempty.
    unfold P; clear P. unfold valuation_in_domain.
    intros x Hin.
    exfalso.
    apply (Hempty x).
    exact Hin.
  }
  intros x v s sx.
  intros Hin Hvarnots Hadd IH.
  unfold P in *; clear P.
  unfold valuation_in_domain.
  intros y Hyinsx.
  unfold sstr.elt in *.
  unfold choose_if_some.
  destruct (sint.choose (st x)) as [n | ] eqn:Hchosen.
  - destruct_eqb y x.
    + unfold InDomain. rewrite t_update_eq.
      apply sint.choose_spec1 in Hchosen.
      exact Hchosen.
    + unfold InDomain. rewrite t_update_neq.
      apply Hadd in Hyinsx. destruct Hyinsx as [Hxy | Hyins].
      * symmetry in Hxy. contradiction.
      * apply IH. exact Hyins.
      * symmetry. exact H.
  - apply sint.choose_spec2 in Hchosen.
    exfalso.
    apply (Hst x).
    + exact Hin.
    + exact Hchosen.
Qed.
  

Lemma confl_set_if_conflict (vs : vars) (st : state) (Hst : valid_state st vs) :
  ~ AllDifferent_sat st vs -> ex_confl_set st vs.
Proof.
  intros Hconfl.
  rewrite <- satisfiable_iff_sat_all in Hconfl.
  2: exact Hst.
  destruct (AllDifferent_dec st vs) eqn:Hdec.
  { contradiction. }
  clear Hconfl.
  unfold AllDifferent_dec in Hdec.
  specialize (if_c_sat_all_false st all_different_ctx vs Hst Hdec) as Hall_false.
  clear Hdec.
  unfold ex_confl_set.
  unfold c_dec in Hall_false.
  unfold all_different_ctx in Hall_false.
  unfold dec_all_different in Hall_false.
  specialize all_different_fold_props as Hfold.
  remember (choose_valid_v vs st) as v eqn:Hv.
  specialize (choose_valid_v_is_valid st vs Hst) as Hvvalid.
  rewrite <- Hv in Hvvalid.
  specialize (Hall_false v Hvvalid).
  specialize (Hfold v vs).
  destruct (all_different_fold vs v) as [maybeConfl values] eqn:Hfoldres.
  destruct maybeConfl as [[x y] | ].
  2: congruence.
  clear Hall_false.
  destruct Hfold as [n [Hxny [Hxin [Hyin [Hvx Hvy]]]]].
  clear Hfoldres.
  (* Unfortunately no easy way to now construct confl_vars... *)
  (* As the chosen might be really bad, telling us nothing *)


