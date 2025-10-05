(* Maybe use these later *)
(* Require Coq.MSets.MSetInterface. *)
(* Require Import Coq.MSets.MSetEqProperties. *)
(* Require Import Coq.MSets.MSetFacts. *)

Require Coq.MSets.MSetAVL.
Require Coq.MSets.MSetProperties.
Require Coq.Structures.OrdersEx.
Require Import Coq.ZArith.BinInt.
From PROP Require Import Maps.

(* ################################### *)
(* ####### MSet instantiations ####### *)

Module sstr := MSetAVL.Make OrdersEx.String_as_OT.
Module sint := MSetAVL.Make OrdersEx.Z_as_OT.
Module Z_String_as_OT := OrdersEx.PairOrderedType OrdersEx.Z_as_OT OrdersEx.String_as_OT.
Module sintstr := MSetAVL.Make Z_String_as_OT.
Module sstr_prps := MSetProperties.Properties sstr.
Module sint_prps := MSetProperties.Properties sint.
Module sintstr_prps := MSetProperties.Properties sintstr.

(* #################################### *)
(* #### Important type definitions #### *)

Definition domain := sint.t.
Definition valuation := total_map Z.
Definition state := string -> domain.
Definition vars := sstr.t.

(* #################################### *)
(* ############ Constants ############# *)

Definition all_zero : valuation :=
  ( _ !-> Z0 ).


(* #################################### *)
(* ############ Functions ############# *)

Definition update_valuation (x : string) (n : Z) (v : valuation) : valuation :=
  t_update v x n.

(* ## varlist_eqb ## *)

Definition varlist_eqb_foldf (v1 : valuation) (v2 : valuation) (x : string) (r : bool) :=
  if r
    then ((v1 x) =? (v2 x))%Z
    else false.

Definition varlist_eqb (v1 : valuation) (v2 : valuation) (vs : vars) : bool :=
  sstr.fold (varlist_eqb_foldf v1 v2) vs true.

(* #################################### *)
(* ############## Props ############### *)
  
Definition InDomain (st : state) (x : string) (v : valuation) : Prop := sint.In (v x) (st x).

Definition valuation_in_domain (st : state) (vs : vars) (v : valuation) : Prop :=
  forall (x : string), sstr.In x vs -> InDomain st x v.

Definition Varlist_eq_all (v1 : valuation ) (v2 : valuation) (vs : vars) : Prop :=
  forall x, (sstr.In x vs) -> v1 x = v2 x.

Definition valid_state (st : state) (vs : vars) :=
  forall (x : string), sstr.In x vs -> ~ sint.Empty (st x).

(* ****************************************** *)
(* ############## P R O O F S ############### *)
(* ****************************************** *)

Lemma Varlist_eq_all_is_eqb : forall (v1 v2 : valuation ) (vs : vars),
  Varlist_eq_all v1 v2 vs <-> varlist_eqb v1 v2 vs = true.
Proof.
  intros v1 v2 vs.
  set (P :=
    fun (s : vars) (r : bool) =>
      Varlist_eq_all v1 v2 s <-> r = true
  ).
  apply sstr_prps.fold_rec with (P := P) (f := (varlist_eqb_foldf v1 v2)) (i := true).
  - unfold P. clear P. intros s Hempty. split.
    + reflexivity.
    + intros Heqb. intros x. intros Hxin.
      exfalso.
      apply (Hempty x).
      exact Hxin.
  - intros x r s s_w_x Hxinvs Hxnins Hadd.
    unfold P. clear P.
    intros IH.
    split.
    + intros Hall.
      assert (Varlist_eq_all v1 v2 s).
      { 
        clear IH. unfold Varlist_eq_all in *.
        intros x'. intros Hinx'.
        apply Hall. apply Hadd.
        right. exact Hinx'.
      }
      rewrite IH in H. rewrite H.
      unfold varlist_eqb_foldf.
      rewrite Z.eqb_eq. apply Hall.
      apply Hadd. left. reflexivity.
    + intros Hvarlist.
      unfold Varlist_eq_all.
      intros y. intros Hyinswx.
      destruct (x =? y)%string eqn:Hxy.
      * rewrite String.eqb_eq in Hxy. subst y.
        unfold varlist_eqb_foldf in Hvarlist.
        destruct r.
        { rewrite <- Z.eqb_eq. exact Hvarlist. }
        {congruence. }
      * apply Hadd in Hyinswx. destruct Hyinswx.
        { 
          rewrite String.eqb_neq in Hxy. rewrite H in Hxy. congruence. 
        }
        { 
          unfold varlist_eqb_foldf in Hvarlist.
          destruct r.
          + assert (true = true) as Heq_s by reflexivity.
            rewrite <- IH in Heq_s.
            apply Heq_s.
            exact H.
          + congruence.
        }
Qed.

Lemma varlist_eq_for_valuation_in_domain (st : state) :
  forall v v' vs, Varlist_eq_all v v' vs -> valuation_in_domain st vs v -> valuation_in_domain st vs v'.
Proof.
  intros v v' vs.
  intros Heq. intros Hvvalid.
  unfold valuation_in_domain in *.
  intros x Hxin.
  unfold InDomain.
  enough (v' x = v x).
  - rewrite H. apply Hvvalid. exact Hxin.
  - symmetry. apply Heq. exact Hxin.
Qed.

