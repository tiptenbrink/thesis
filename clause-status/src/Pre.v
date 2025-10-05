Require Import Coq.Strings.String.
Require Import Checker.Domain.
Require Import Checker.Variable.
Require Import Coq.NArith.NArith.
Require Import Coq.ZArith.ZArith.
Require Import Coq.Lists.List.
Require Import Lia.
Import Utility.Sets.
Import Utility.ListEx.

Module Z_String_as_OT := OrdersEx.PairOrderedType OrdersEx.Z_as_OT OrdersEx.String_as_OT.
Module sintstr := MSetAVL.Make Z_String_as_OT.


Record AllDifferentConstraint :=
  {
    vars_ad : sstr.t;
    var_ad_bounds : list (Z * N);
    consistency : length var_ad_bounds = sstr.cardinal vars_ad
  }.

Definition get_vars (c : AllDifferentConstraint) : list Var :=
  map 
  (fun x =>
    match x with
    | (x, (lb, x_size)) =>
      interval {| name := x; lower_bound := lb; size := N.to_nat x_size |}
    end
  )
  (combine (sstr.elements c.(vars_ad)) c.(var_ad_bounds)).

Definition valuation_from_assignment (c : AllDifferentConstraint) (a : Assignment) : string -> Z :=
  let vs := get_vars c in
  fun x =>
    match find (fun v =>
      match v with
      | interval v =>
        (v.(name) =? x)%string
      end
    ) vs with
    | None => Z0
    | Some v => a.(find_value) v
    end
  .

Definition AllDifferent (vs : list string) (v : string -> Z) : Prop :=
  forall x y, 
  x <> y -> In x vs -> In y vs -> v x <> v y.

(* Definition find_conflict_filter_f (n : Z) (el: (Z * string)) :=
  let (n', _) := el in (n =? n')%Z.

Definition find_conflict (x : string) (n : Z) (values : sintstr.t) : option (Z * string) := 
  sintstr.choose (sintstr.filter (find_conflict_filter_f n) values).

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

Definition all_different_fold_f (v : string -> Z) (x : string) (acc : option (string * string) * sintstr.t) :=
  values_or_conflict x (v x) acc.

Definition all_different_fold (vs : sstr.t) (v : string -> Z) :=
  sstr.fold (all_different_fold_f v) vs (None, sintstr.empty).

Definition dec_all_different (vs : sstr.t) (v : string -> Z) : bool :=
  match all_different_fold vs v with
  | (Some _, _) => false
  | (None, _) => true
  end
.

Definition alldifferent_decide (constraint : AllDifferentConstraint) (a : Assignment) : bool :=
  let valuation := valuation_from_assignment constraint a in
  dec_all_different constraint.(vars_ad) valuation
.
 *)
(* Definition AllDifferent (c : sstr.t) (v : string -> Z) : Prop :=
  (forall (x y : string), 
  x <> y -> sstr.In x c -> sstr.In y c -> v x <> v y).
 *)

Definition FullDomain := sint.t.

(* Note that we materialize each domain because otherwise computing the shared domain is quite expensive. *)
Definition state := string -> FullDomain.



(* Record BoundedDomain := {
  bd_lb : Z;
  bd_ub : Z;
  bd_holes : sint.t
}.

Definition dom_size (dom : BoundedDomain) : Z :=
  dom.(bd_ub) - dom.(bd_lb) + 1 - (Z.of_nat (sint.cardinal dom.(bd_holes))).
 *)
(* Definition dom_size (dom : FullDomain) : nat := sint.cardinal dom. *)

Definition vars_dom_union (st : state) (vs : sstr.t) := 
    sstr.fold 
    (fun x acc => sint.union (st x) acc)
    vs 
    sint.empty.

Definition vars_len (vs : sstr.t) : nat := sstr.cardinal vs.
 
Open Scope nat_scope.

(* Definition ex_confl_set (st : state) (vs : sstr.t) := 
  exists confl_vars, 
    sstr.Subset confl_vars vs 
      /\ 
    dom_size (vars_dom_union st confl_vars) < vars_len confl_vars.
 *)

Definition valuation_in_state (st : state) (vs : list string) (v : string -> Z) : Prop :=
  forall x, In x vs -> sint.In (v x) (st x).

Definition AllDifferent_sat (st : state) (vs : list string) :=
  exists v, valuation_in_state st vs v /\ AllDifferent vs v.

(* Lemma all_different_subset (v : string -> Z) :
  forall (vs : sstr.t) (vs' : sstr.t),
  AllDifferent vs v -> sstr.Subset vs' vs -> AllDifferent vs' v.
Proof.
  intros vs vs'. intros Hdiff Hsub.
  unfold AllDifferent in *.
  intros x y.
  intros Hxny Hinx Hiny.
  apply Hdiff; try assumption; apply Hsub; assumption.
Qed.
 *)
(* Lemma alldiff_valuation_values_props (c : sstr.t) (st : state) :
  forall (v: string -> Z), AllDifferent c v 
    -> 
  vars_len c = sint.cardinal (valuation_values c v) 
    /\ 
  forall n, sint.In n (valuation_values c v) -> exists x, sstr.In x c /\ v x = n.
Proof.
Admitted. *)
  (* intros v Hval_alldiff. unfold AllDifferent in Hval_alldiff.
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
Qed. *)

(* Lemma AllDifferent_elements (vs : sstr.t) (v : string -> Z) :
  AllDifferent vs v
    ->
  (forall (x y : string), 
  x <> y -> In x (sstr.elements vs) -> In y (sstr.elements vs) -> v x <> v y).
Proof.
  intros Hdiff x y Hxny Hinx Hiny.
  specialize (Hdiff x y Hxny).
  apply Hdiff; now apply sstr.elements_spec_in.
Qed. 
 *)
Lemma sint_cardinal_union_diff :
  forall s s', sint.cardinal (sint.union s s') = sint.cardinal (sint.diff s s') + sint.cardinal s'.
Proof.
  intros s s'.
  rewrite sint_prps.union_cardinal_inter.
  rewrite <- sint_prps.diff_inter_cardinal with (s := s) (s' := s'). lia.
Qed.

Ltac solve_disjunction :=
  first
    [ assumption
    | reflexivity
    | match goal with
      | |- _ \/ _ =>
          (left; solve_disjunction)
          ||
          (right; solve_disjunction)
      end
    ].

Ltac break_in_hyps :=
  repeat match goal with
  | [ H: In ?x _  |- In ?x _ ] => simpl in H
  end;
  repeat match goal with
  | [ H: _ \/ In ?x _ |- In ?x _ ] =>
      let Hnew := fresh H in
      destruct H as [Hnew | Hnew]; subst; try discriminate
  end;
  simpl.

Ltac solve_in := break_in_hyps; try solve_disjunction.

(* Definition is_domain_union (st : state) (vars : list string) (union : list Z) :=
  NoDup union
    /\
  forall n, In n union <-> (exists x, In x vars /\ sint.In n (st x)).

Definition ex_confl_vars (st : state) (vs : list string) := 
  exists confl_vars union,
    NoDup confl_vars
      /\
    incl confl_vars vs
      /\ 
    is_domain_union st confl_vars union
      /\ 
    length union < length confl_vars.
 *)

Definition is_domain_union (st : state) (variables : list string) (domain_union : list Z) :=
  NoDup domain_union
    /\
  forall n, In n domain_union <-> (exists x, In x variables /\ sint.In n (st x)).

Definition exists_conflict_variables (st : state) (constraint_variables : list string) := 
  exists conflict_variables conflict_domain_union,
    NoDup conflict_variables
      /\
    incl conflict_variables constraint_variables
      /\ 
    is_domain_union st conflict_variables conflict_domain_union
      /\ 
    length conflict_domain_union < length conflict_variables.


Import Datatypes.

Lemma conflict_if_ex_confl_vars (st : state) (constraint_variables : list string) :
  exists_conflict_variables st constraint_variables -> ~ AllDifferent_sat st constraint_variables.
Proof.