From Coq Require Import Strings.String.
Require Import Coq.ZArith.BinInt.
From Coq Require Import Bool.Bool.
From Coq Require Import Lists.List.
From PROP Require Import Maps.
From PROP Require Import CPTypes.

Definition CProp := vars -> valuation -> Prop.

Definition CDec := vars -> valuation -> bool.

Definition c_dec_iff_c_prop (c_dec : CDec) (c_prop : CProp) :=
  forall vs v, c_dec vs v = true <-> c_prop vs v.

Definition c_dec_var_eq (c_dec : CDec) := 
  forall (v1 v2 : valuation) (vs : vars),
    Varlist_eq_all v1 v2 vs -> c_dec vs v1 = c_dec vs v2.

Definition satisfiable (st : state) (c_vars : vars) (c_prop: CProp) : Prop :=
  exists v : valuation, valuation_in_domain st c_vars v /\ c_prop c_vars v.

Module FindVal.
  Import CPTypes.

Definition all_foldf_inner (st : state) (l : list valuation) (x : string) (n : Z) (acc : list valuation) :=
  acc ++ map (fun (v : valuation) => t_update v x n) l.

Definition all_foldf (st : state) (x : string) (l : list valuation) : list valuation :=
  sint.fold (all_foldf_inner st l x) (st x) nil.

Lemma all_foldf_props (st : state) :
  forall (l : list valuation) x,
    (* We assume only ever call with non-nil l *)
    ~ sint.Empty (st x) -> l <> nil -> (
      (all_foldf st x l) <> nil
        /\
      (forall v n, In v l -> sint.In n (st x) -> In (x !-> n; v) (all_foldf st x l))
        /\
      (forall y, (y = x \/ forall v, In v l -> InDomain st y v) -> forall v', In v' (all_foldf st x l) -> InDomain st y v')
    ).
Proof.
  intros l x Hstnonempty Hnotnil.
  set (P :=
    fun (s : sint.t) (acc : list valuation) =>
        (~ sint.Empty s -> acc <> nil)
          /\
        (forall v n, In v l -> sint.In n s -> In (x !-> n; v) acc)
          /\
        (forall y, (y = x \/ (forall v, In v l -> InDomain st y v)) -> forall v', In v' acc -> InDomain st y v')
  ).
  
  assert (P (st x) (all_foldf st x l)).
  {
    apply sint_prps.fold_rec with (f := (all_foldf_inner st l x)) (P := P) (i := nil) (s := st x).
    - unfold P. clear P.
      intros s Hempty.
      repeat split.
      + contradiction.
      + intros v n Hvin Hin. exfalso.
        apply (Hempty n).
        exact Hin.
      + intros y Hdom v Hin.
        destruct Hin.
    - intros n a s sn Hin Hnots Hadd IH.
      unfold P in *. clear P.
      repeat split.
      {
        destruct IH as [IH _].
        intros Hsnnonempty.
        unfold all_foldf_inner.
        intros Hcontra.
        apply app_eq_nil in Hcontra.
        destruct Hcontra as [_ Hcontra].
        apply map_eq_nil in Hcontra.
        contradiction.
      }
      {
        destruct IH as [_ [IH _]].
        intros v sn_el Hinvl Hinsn.
        unfold all_foldf_inner.
        apply in_or_app.
        destruct (sn_el =? n)%Z eqn:Hn.
        - rewrite Z.eqb_eq in Hn. subst sn_el.
          right.
          rewrite in_map_iff.
          exists v.
          split.
          + reflexivity.
          + exact Hinvl.
        - left.
          apply IH.
          { assumption. }
          rewrite (Hadd sn_el) in Hinsn.
          destruct Hinsn.
          + subst sn_el. rewrite Z.eqb_neq in Hn. contradiction.
          + exact H. 
      }
      {
        destruct IH as [_ [_ IH]].
        intros y Hdom.
        intros v Hvfold.
        unfold all_foldf_inner in Hvfold.
        apply in_app_or in Hvfold.
        destruct Hvfold.
        { apply IH; try assumption. }
        clear IH.
        rewrite in_map_iff in H.
        destruct H as [v_in_l].
        destruct Hdom as [Hxy | Hdom].
        - subst y.
          destruct H as [Hvdef _].
          unfold InDomain.
          rewrite <- Hvdef.
          rewrite t_update_eq.
          exact Hin.
        - destruct (x =? y)%string eqn:Hxy.
          {
            rewrite String.eqb_eq in Hxy. subst y.
            destruct H as [Hvdef _].
            unfold InDomain.
            rewrite <- Hvdef.
            rewrite t_update_eq.
            exact Hin.
          }
          destruct H as [Hvdef Hinl].
          assert (v y = v_in_l y) as Hvy.
          { rewrite <- Hvdef. apply t_update_neq. 
            rewrite String.eqb_neq in Hxy. exact Hxy. }
          unfold InDomain.
          rewrite Hvy.
          apply Hdom.
          exact Hinl.
      }
  }
  unfold P in H. clear P.
  destruct H as [H1 [H2 H3]].
  repeat split.
  - apply H1. apply Hstnonempty.
  - apply H2.
  - apply H3.
Qed.


Definition all_valuations (st : state) (vs : vars) :=
  sstr.fold (all_foldf st) vs (all_zero :: nil)
.

Lemma all_valuations_props (st : state) : forall vs, 
  valid_state st vs -> forall v, 
  (valuation_in_domain st vs v -> exists v', Varlist_eq_all v v' vs /\ In v' (all_valuations st vs)) 
    /\
  (In v (all_valuations st vs) -> valuation_in_domain st vs v).
Proof.
  intros vs Hvalid.

  (* Given that we have folded all variables in s, for any valuation valid on that domain, there exists a valuation in the result equal on the variables in s  *)
  set (P :=
    fun (s : sstr.t) (l : list valuation) =>
      l <> nil /\
      (forall (v : valuation), 
        valuation_in_domain st s v -> exists v', Varlist_eq_all v v' s /\ In v' l)
          /\
        (forall (v : valuation), In v l -> valuation_in_domain st s v)
  ).

  assert (P vs (all_valuations st vs)).
  {
  apply sstr_prps.fold_rec with (f := (all_foldf st)) (P := P) (i := all_zero :: nil) (s := vs).
  - unfold P. clear P. intros s Hempty.
    repeat split.
    + symmetry. apply nil_cons.
    + intros v Hdom.
      exists all_zero.
      split.
      * unfold Varlist_eq_all. intros x Hin.
        exfalso.
        apply (Hempty x).
        exact Hin.
      * unfold In. left. reflexivity.
    + intros v Hinv.
      unfold valuation_in_domain. intros x Hin.
      exfalso.
      apply (Hempty x).
      exact Hin.
  - intros x l s s_x Hinvs Hnots Hadd IH.
    unfold P in *. clear P.
    destruct IH as [IHnnil [IH IHdom]].
    destruct (all_foldf_props st l x ((Hvalid x) Hinvs) IHnnil) as [Hall_1 [Hall_2 Hall_3]].
    repeat split.
    {
     clear Hall_2. clear Hall_3. apply Hall_1.
    } 
    { 
      clear IHdom. clear Hall_3.
      intros v. intros Hvvalid.
      assert (valuation_in_domain st s v) as Hvalids.
      { unfold valuation_in_domain. intros s_el Hs.
        apply Hvvalid. apply Hadd.
        right. exact Hs. }
      specialize (IH v Hvalids).
      destruct IH as [v' [Hvv' Hinv']].
      exists (t_update v' x (v x)).
      split.
      - unfold Varlist_eq_all. intros s_x_el Hs_x_in.
        symmetry. destruct (s_x_el =? x)%string eqn:Hx.
        + rewrite String.eqb_eq in Hx. subst s_x_el. 
          apply t_update_eq. 
        + rewrite String.eqb_neq in Hx.
          apply Hadd in Hs_x_in.
          destruct Hs_x_in.
          { rewrite H in Hx. contradiction. }
          rewrite (Hvv' s_x_el H).
          apply t_update_neq. symmetry. exact Hx.
      - apply Hall_2.
        + exact Hinv'.
        + apply Hvvalid. apply Hadd. left. reflexivity.
      }
      {
        clear Hall_2. clear Hvalid. clear IHnnil. clear IH.
        intros v Hin.
        intros s_x_el Hins_x.
        apply Hall_3.
        - clear Hall_3.
          destruct (s_x_el =? x)%string eqn:Hx_sxel.
          + rewrite String.eqb_eq in Hx_sxel. subst s_x_el.
            left. reflexivity.
          + right. intros v_inl Hv_inl.
            apply IHdom.
            * exact Hv_inl.
            * apply Hadd in Hins_x. destruct Hins_x.
              { apply String.eqb_neq in Hx_sxel. symmetry in H. contradiction. }
              { exact H. }
        - exact Hin.
      }
  }
  unfold P in H. clear P.
  destruct H as [Hnil [Heqex Hdom]].
  intros v.
  split.
  - apply Heqex.
  - apply Hdom.
Qed.

(* Find an evaluation that returns true *)
Fixpoint true_valuation (c_dec : vars -> valuation -> bool) (vs : vars) (vl : list valuation) : option valuation :=
  match vl with
  | nil => None
  | v :: tail => if c_dec vs v 
                  then Some v
                  else true_valuation c_dec vs tail
  end.

  Lemma extract_valuation_true (c_dec : CDec) (vs : vars) : forall (l : list valuation) (v : valuation),
  true_valuation c_dec vs l = Some v -> c_dec vs v = true /\ In v l.
Proof.
  intros l v H.
  induction l as [| v' l IHl].
  - simpl in H. discriminate H.
  - simpl in H.
    destruct (c_dec vs v') eqn:Heval.
    + injection H as H. subst v'.
      split.
      * exact Heval.
      * unfold In. left. reflexivity.
    + simpl. 
      split.
      * apply (IHl H).
      * right. apply (IHl H).
Qed.

Lemma extract_valuation_false (c_dec : vars -> valuation -> bool) (Hc_dec_var_eq : c_dec_var_eq c_dec) (vs : vars) : forall (l : list valuation) (v : valuation),
  true_valuation c_dec vs l = None -> In v l -> c_dec vs v = false.
Proof.
  induction l as [| v' l IHl].
  - intros v Hnone Hin. simpl in Hin. destruct Hin.
  - intros v Hnone Hin.
    destruct (varlist_eqb v v' vs) eqn:Hveqvars.
    + simpl in Hnone.
      destruct (c_dec vs v') eqn:Hv'.
      * discriminate Hnone.
      * rewrite <- Hv'. 
        unfold c_dec_var_eq in Hc_dec_var_eq.
        apply (Hc_dec_var_eq v v' vs).
        apply Varlist_eq_all_is_eqb.
        exact Hveqvars.
    + simpl in Hnone.
      destruct (c_dec vs v') eqn:Hv'.
      * discriminate Hnone.
      * destruct Hin as [Hvisv' | Hin].
        { rewrite Hvisv' in Hv'. exact Hv'. }
        { destruct (IHl v).
          - exact Hnone.
          - exact Hin. 
          - reflexivity. }
Qed.

End FindVal.



Definition c_sat_all (st : state) (vs : vars) (c_dec : CDec) : bool :=
  match FindVal.true_valuation c_dec vs (FindVal.all_valuations st vs) with
  | Some _ => true
  | None   => false
  end.


Module DecProofs.
  Import FindVal.




(* We use the definition of our solver to extract a valuation, which we then use as
the concrete example to prove p is satisfiable. *)
Theorem c_sat_all_sound (st : state) c_prop c_dec (Hiff : c_dec_iff_c_prop c_dec c_prop) vs (Hst : valid_state st vs) :
    c_sat_all st vs c_dec = true -> satisfiable st vs c_prop.
Proof.
  destruct (true_valuation c_dec vs (all_valuations st vs)) eqn:E.
  - intros H.
    unfold satisfiable.
    apply extract_valuation_true in E.
    destruct E as [Hdectrue Hinall].
    exists v.
    unfold c_dec_iff_c_prop in Hiff.
    split.
    + apply all_valuations_props.
      * exact Hst.
      * exact Hinall.
    + rewrite <- Hiff.
      exact Hdectrue.
  - intros H. unfold c_sat_all in H. rewrite E in H. discriminate H. 
Qed.

Lemma c_sat_all_complete (st : state) c_prop c_dec (Hiff : c_dec_iff_c_prop c_dec c_prop) (Hc_dec_var_eq : c_dec_var_eq c_dec) vs (Hst : valid_state st vs) :
  satisfiable st vs c_prop -> c_sat_all st vs c_dec = true.
Proof.
  unfold satisfiable. intros H.
  destruct H as [v [Hvalid H]].
  unfold c_dec_iff_c_prop in Hiff.
  specialize (Hiff vs v).
  unfold c_sat_all.
  destruct (true_valuation c_dec vs (all_valuations st vs)) eqn:E.
  - reflexivity.
  - symmetry. rewrite <- Hiff in H. rewrite <- H.
    destruct (all_valuations_props st vs Hst v) as [Hexeq _].
    destruct (Hexeq Hvalid) as [v_inall [Hv_inall_eq Hv_inall]]. clear Hexeq.
    enough (c_dec vs v_inall = false) as Hvfalse.
    { rewrite (Hc_dec_var_eq) with (v1 := v) (v2 := v_inall).
      - exact Hvfalse.
      - exact Hv_inall_eq. 
    }
    apply extract_valuation_false with (l := (all_valuations st vs)).
    + apply Hc_dec_var_eq.
    + apply E.
    + apply Hv_inall.
Qed. 

End DecProofs.

(** ******** TESTS ********* *)

Record ConstraintCtx := mkConstrCtx {
  c_prop : CProp;
  c_dec : CDec;
  Hiff : c_dec_iff_c_prop c_dec c_prop;
  Hc_dec_var_eq : c_dec_var_eq c_dec
}.

Theorem satisfiable_iff_sat_all (st : state) (c : ConstraintCtx) vs (Hst : valid_state st vs) :
  c_sat_all st vs c.(c_dec) = true <-> satisfiable st vs c.(c_prop).
Proof.
  split.
  - apply DecProofs.c_sat_all_sound.
    * apply c.(Hiff).
    * apply Hst.
  - apply DecProofs.c_sat_all_complete.
    * apply c.(Hiff).
    * apply c.(Hc_dec_var_eq).
    * apply Hst.
Qed.

Lemma if_c_sat_all_false (st : state) (c : ConstraintCtx) vs (Hst : valid_state st vs) :
  c_sat_all st vs c.(c_dec) = false -> forall v, valuation_in_domain st vs v -> c.(c_dec) vs v = false.
Proof.
  intros Hfalse.
  specialize (FindVal.extract_valuation_false c.(c_dec) c.(Hc_dec_var_eq)) as Hextract.
  unfold c_sat_all in Hfalse.
  destruct (FindVal.true_valuation c.(c_dec) vs
  (FindVal.all_valuations st vs)) eqn:Htrueval.
  { congruence. }
  clear Hfalse.
  intros v Hvvalid.
  destruct (FindVal.all_valuations_props st vs Hst v) as [Hvareq _].
  specialize (Hvareq Hvvalid).
  destruct Hvareq as [v_inl [Hvareq Hv_inl]].
  apply Hextract with (v := v_inl) in Htrueval.
  - rewrite Hc_dec_var_eq with (v2 := v_inl); assumption.
  - exact Hv_inl.
Qed.

(* Ltac satisfy_or_not_satisfy :=
  rewrite <- satisfiable_iff_solver;
  idtac;
  try match goal with
  | [ |- solver _ <> true ] => rewrite not_true_iff_false
  end;
  unfold solver;
  simpl;
  reflexivity.  *)


