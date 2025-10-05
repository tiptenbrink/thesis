Require Import Coq.NArith.NArith.
Require Import Coq.ZArith.ZArith.
Require Import Coq.Strings.String.
Require Import Coq.Bool.Bool.
Require Import Coq.Lists.List.
Require Import Coq.Logic.FinFun.
Require Import Lia.
From PROP Require Import Maps.
From PROP Require Import CPTypes.
From PROP Require Import CPTactics.
From PROP Require Import DecideCP.

Record CumulativeParams := mkCumul {
  capacity : N;
  p_times : string -> N;
  usages : string -> N;
}.

Section WithZScope.
  Open Scope Z_scope.

Definition ActiveAt (start_time : Z) (p_time : N) (t : Z) : Prop :=
  let end_time := (start_time + (Z.of_N p_time)) in
        start_time <= t <= end_time
      .

Definition is_active_at (start_time : Z) (p_time : N) (t : Z) : bool :=
  let end_time := (start_time + (Z.of_N p_time)) in
    (start_time <=? t) && (t <=? end_time).

Lemma is_active_iff_active_at :
  forall start_time p_time t,
    ActiveAt start_time p_time t <-> is_active_at start_time p_time t = true.
Proof.
  intros s p t.
  unfold ActiveAt. unfold is_active_at.
  rewrite andb_true_iff.
  repeat rewrite Z.leb_le.
  reflexivity.
Qed.

End WithZScope.

(* How do we define the correctness here? *)
Definition resource_sum_foldf (params : CumulativeParams) (x : string) (acc : N) : N :=
  acc + params.(usages) x
.

Definition resource_sum (params: CumulativeParams) (vs : vars) (v : valuation) :=
  sstr.fold (resource_sum_foldf params) vs N0 
.

Definition Cumulative (params : CumulativeParams) (vs : vars) (v : valuation) : Prop :=
  forall t,
    forall active, 
      (forall x, sstr.In x active <-> ActiveAt (v x) (params.(p_times) x) t) ->
        ((resource_sum params active v) < params.(capacity))%N
.

Fixpoint build_list_helper (n : nat) : list nat :=
  match n with
  | 0 => 0 :: nil
  | S n' => n :: (build_list_helper n')
  end.

Lemma not_sn_le_n :
  forall n,
    ~ (S n <= n).
Proof.
  induction n.
  - intros H. inversion H.
  - intros H. apply le_S_n in H. apply IHn.
    exact H.
Qed.

Lemma list_helper_correct : 
  forall N, 
    build_list_helper N <> nil /\
    NoDup (build_list_helper N) /\
    forall n, n <= N <-> In n (build_list_helper N).
Proof.
  intros N.
  induction N.
  - simpl. repeat split.
    + intros Hnnil. discriminate Hnnil.
    + apply NoDup_cons.
      * easy.
      * apply NoDup_nil.
    + left. inversion H. reflexivity.
    + intros H.
      destruct H.
      { subst n. reflexivity. }
      { contradiction. }
  - destruct IHN as [IHnonil [IHnodup IHin]].
    repeat split.
    + simpl. intros Hnil.
      discriminate Hnil.
    + simpl. apply NoDup_cons.
      * intros HSNin.
        rewrite <- IHin in HSNin.
        apply not_sn_le_n in HSNin.
        contradiction.
      * exact IHnodup.
    + intros Hlt.
      simpl.
      inversion Hlt.
      { left. reflexivity. }
      { subst m. right. apply IHin. exact H0. }
    + intros Hin.
      simpl in Hin.
      destruct Hin as [HSNn | Hin].
      { rewrite HSNn. reflexivity. }
      { rewrite <- IHin in Hin. apply le_S in Hin. exact Hin. }
Qed.

Section WithZScope.
  Open Scope Z_scope.

Definition shift_nat (c : Z) (n : nat) : Z := (Z.of_nat n) + c.

Lemma shift_inj : forall c,
  Injective (shift_nat c).
Proof.
  intros c.
  unfold Injective.
  intros n m Hshift.
  unfold shift_nat in Hshift.
  lia.
Qed.

Definition shift_list (shift : Z) (range : list nat) : list Z :=
  map (shift_nat shift) range.

Lemma shift_correct : 
  forall shift N Nz,
    Nz = (Z.of_nat N) ->
      forall n, shift <= n <= (Nz + shift) <-> In n (shift_list shift (build_list_helper N)).
Proof.
  intros shift N Nz.
  intros HNz.
  intros n.
  destruct (list_helper_correct N) as [_ [_ Hhelper]].
  unfold shift_list.
  rewrite in_map_iff.
  setoid_rewrite <- Hhelper.
  unfold shift_nat.
  split.
  - intros Hn.
    exists (Z.to_nat (n - shift)).
    lia.
  - intros Hex. destruct Hex as [x [Hx]].
    lia.
Qed.

(* Alternative: replace this by something that proves termination: see e.g. http://adam.chlipala.net/cpdt/html/Cpdt.GeneralRec.html https://stackoverflow.com/questions/10292421/error-in-defining-ackermann-in-coq *)
Definition build_range (start_incl : Z) (end_incl : Z) : list Z :=
  shift_list start_incl (build_list_helper (Z.abs_nat (end_incl - start_incl))).

Lemma build_range_correct : 
  forall s e,
    s <= e ->
      forall n, s <= n <= e <-> In n (build_range s e).
Proof.
  intros s e Hslte n.
  unfold build_range.
  specialize (shift_correct s (Z.abs_nat (e - s)) (e - s)) as Hshift.
  assert (e = e - s + s) as He.
  { lia. }
  rewrite He at 1.
  apply Hshift.
  lia.
Qed.

Lemma build_range_nodup :
  forall s e,
    NoDup (build_range s e).
Proof.
  intros s e.
  unfold build_range.
  unfold shift_list.
  apply Injective_map_NoDup.
  - apply shift_inj.
  - apply list_helper_correct.
Qed.

End WithZScope.

Record Activity := mkAct {
  x : string;
  start : Z;
  p_time : N;
  usage : N;
}.

Definition activity (params : CumulativeParams) (v : valuation) (x : string) : Activity :=
  mkAct x (v x) (params.(p_times) x) (params.(usages) x) 
.

Definition activity_list (params : CumulativeParams) (v : valuation) (vs : vars) : list Activity :=
  sstr.fold (fun x acc => (activity params v x) :: acc) vs nil
.

Definition activities_at_t (l : list Activity) (t : Z) : list Activity :=
  filter (fun a => is_active_at a.(start) a.(p_time) t) l
.

Definition sub_list {A} (eq_dec : forall x y : A, {x = y}+{x <> y} ) (l1 l2 : list A) :=
  (forall a, In a l1 -> (count_occ eq_dec l1 a <= count_occ eq_dec l2 a)%nat).

Lemma sub_list_in {A} (eq_dec : forall x y : A, {x = y}+{x <> y})  :
  forall (l1 l2 : list A), sub_list eq_dec l1 l2 -> forall a, In a l1 -> In a l2.
Proof.
  intros l1 l2.
  intros Hsub.
  intros a Hin.
  unfold sub_list in Hsub.
  specialize (Hsub a Hin).
  destruct (in_dec eq_dec a l2) as [Hin2 | Hnin2].
  - exact Hin2.
  - rewrite count_occ_not_In in Hnin2.
    rewrite Hnin2 in Hsub.
    rewrite count_occ_In in Hin.
    exfalso.
    clear Hnin2.
    assert (count_occ eq_dec l1 a > 0)%nat.
    { exact Hin. }
    remember (count_occ eq_dec l1 a) as n.
    clear Heqn; clear eq_dec; clear a; clear l1; clear l2; clear A.
    lia.
Qed. 

Definition eq_counts {A} (eq_dec : forall x y : A, {x = y}+{x <> y} ) (l1 l2 : list A) :=
  (forall a, (In a l1 \/ In a l2) -> (count_occ eq_dec l1 a = count_occ eq_dec l2 a)%nat).

Fixpoint remove_once {A} (eq_dec : forall x y : A, {x = y}+{x <> y}) (a : A) (l : list A) :=
  match l with
  | nil => nil
  | a' :: l' => if eq_dec a a'
                    then l'
                    else a' :: (remove_once eq_dec a l')
  end.

Lemma remove_once_one_less_count {A} (eq_dec : forall x y : A, {x = y}+{x <> y}) :
  forall l a, pred (count_occ eq_dec l a) = count_occ eq_dec (remove_once eq_dec a l) a. 
Proof.
  induction l.
  - intros a. simpl. reflexivity.
  - intros a'.
    simpl. destruct (eq_dec a a').
    + subst a'. rewrite <- pred_Sn. 
      destruct (eq_dec a a); try contradiction.
      reflexivity.
    + destruct (eq_dec a' a).
      { symmetry in e. contradiction. }
      simpl.
      destruct (eq_dec a a').
      { contradiction. }
      apply IHl.
Qed.

Ltac resolve_eq_dec_self a :=
  let T := type of a in
  match goal with
  | [ eq_dec : forall x y : T, {x = y} + {x <> y} |- _ ] =>
    let H := fresh "H" in
    destruct (eq_dec a a) as [H|H];
    [ clear H  (* clear the trivial a = a hypothesis *)
    | contradiction  (* resolve the contradictory a <> a case *)
    ]
  end.

Lemma remove_once_one_same_if_neq {A} (eq_dec : forall x y : A, {x = y}+{x <> y}) :
  forall l a a', a <> a' -> count_occ eq_dec l a' = count_occ eq_dec (remove_once eq_dec a l) a'. 
Proof.
  induction l.
  - intros a. simpl. reflexivity.
  - intros a1 a2 Ha1a2.
    simpl. 
    destruct (eq_dec a a2) as [| Haa2].
    + subst a2. 
      destruct (eq_dec a1 a).
      * subst a1. contradiction.
      * simpl. 
        resolve_eq_dec_self a.
        f_equal.
        apply IHl. exact Ha1a2.
    + destruct (eq_dec a1 a) as [| Ha1a].
      * subst a1. reflexivity.
      * simpl. destruct (eq_dec a a2).
        { subst a2. contradiction. }
        clear n.
        apply IHl. exact Ha1a2.
Qed. 

Lemma remove_once_one_In {A} (eq_dec : forall x y : A, {x = y}+{x <> y}) :
  forall l a a', In a' (remove_once eq_dec a l) -> In a' l. 
Proof.
  induction l.
  - intros a a'. intros Hnil. simpl in Hnil. contradiction.
  - intros a1 a2.
    simpl. destruct (eq_dec a1 a).
    + subst a1. intros Hin. right. exact Hin.
    + simpl. intros Hin. destruct Hin.
      * left. exact H.
      * right. apply IHl with (a := a1).
        exact H.
Qed.

Lemma S_pred_gt_0 :
  forall (n : nat), n > 0 -> S (pred n) = n.
Proof.
  intros n Hngt.
  lia.
Qed.

Lemma S_lt :
  forall n m, S n <= S m -> n <= m.
Proof.
  intros n m H.
  lia.
Qed.


Open Scope N_scope.

(* Fixpoint conflicting_activities_rec (capacity : N) (l : list Activity) (summed : list Activity) (current : N) : option (list Activity) :=
  match l with
  | nil => None
  | a :: l' => 
    let new_current := a.(usage) + current in
      if new_current <=? capacity 
        then conflicting_activities_rec capacity l' (a :: summed) new_current
        else Some (a :: summed)
  end
. *)

Fixpoint usage_sum_rec (l : list Activity) (current : N) : N :=
  match l with
  | nil => current
  | a :: l' => usage_sum_rec l' (current + a.(usage))
  end.

Definition usage_sum (l : list Activity) : N :=
  usage_sum_rec l N0.

Lemma usage_sum_add :
  forall l n,
  usage_sum_rec l n = usage_sum l + n.
Proof.
  intros l.
  induction l.
  - simpl. reflexivity.
  - intros n. simpl. unfold usage_sum. simpl.
    specialize (IHl (n + usage a)) as Hnusage.
    specialize (IHl (usage a)) as Husage.
    rewrite Hnusage.
    rewrite Husage.
    lia.
Qed.

Lemma activity_eq_dec :
  forall x y : Activity, {x = y}+{x <> y}.
Proof.
  intros x y. decide equality.
  - apply N.eq_dec.
  - apply N.eq_dec.
  - apply Z.eq_dec.
  - apply String.string_dec.
Qed.

(* Fixpoint usage_sum_rec_count (l_all : list Activity) (l : list Activity) (current : N) : N :=
  match l with
  | nil => current
  | a :: l' => usage_sum_rec_count l_all l' (current + N.of_nat (count_occ activity_eq_dec l_all a) * a.(usage))
  end.

Definition fold_f_usage (l : list Activity) (s : N) (a : Activity) :=
  s + ((N.of_nat (count_occ activity_eq_dec l a)) * a.(usage)).

Lemma usage_sum_count_occ_sum :
  forall l i, usage_sum_rec l i = fold_left (fold_f_usage l) (nodup activity_eq_dec l) i.
Proof.
  intros l i.
  induction l.
  - simpl. reflexivity.
  - simpl. destruct (in_dec activity_eq_dec a l).
    + admit.
    +  *)

Lemma usage_sum_gt :
  forall l i a, In a l -> usage_sum_rec l i >= a.(usage).
Proof.
  intros l i a Hin.
  induction l as [| a'].
  - destruct Hin.
  - simpl.
    destruct Hin.
    + subst a'. rewrite usage_sum_add. lia.
    + apply IHl in H.
      rewrite usage_sum_add in *. lia.
Qed.

Lemma usage_sum_remove_once :
  forall l i a, In a l -> usage_sum_rec (remove_once activity_eq_dec a l) i  = usage_sum_rec l i - a.(usage).
Proof.
  induction l.
  - intros i a Hnil. destruct Hnil.
  - intros i a' Hin.
    simpl.
    destruct (activity_eq_dec a' a).
    + subst a'.
      repeat rewrite usage_sum_add. lia.
    + simpl. 
      assert (In a' l).
      {
       simpl in Hin. destruct Hin.
       - symmetry in H. contradiction.
       - exact H.
      }
      assert (In a' l) as Hainl by assumption.
      apply IHl with (i := i) in H. repeat rewrite usage_sum_add in *.
      assert (usage_sum (remove_once activity_eq_dec a' l) = usage_sum l - usage a') as Husage_remove.
      { lia. }
      rewrite Husage_remove.
      specialize (usage_sum_gt l N0 a') as Hgt.
      apply Hgt in Hainl.
      clear Husage_remove; clear H; clear Hgt; clear n; clear IHl; clear Hin.
      unfold usage_sum in *.
      lia.
Qed.



Lemma usage_sum_eq_counts :
  forall l1 l2 i, eq_counts activity_eq_dec l1 l2 -> usage_sum_rec l1 i = usage_sum_rec l2 i.
Proof.
  intros l1. induction l1.
  - induction l2.
    + intros. simpl. reflexivity.
    + intros i Heq. 
      unfold eq_counts in Heq.
      specialize (Heq a).
      assert (In a nil \/ In a (a :: l2)).
      { right; simpl; left; reflexivity. }
      apply Heq in H.
      simpl in H.
      destruct (activity_eq_dec a a).
      * discriminate H.
      * contradiction.  
  - intros l2 i Heqcounts.
    assert (count_occ activity_eq_dec l2 a > 0)%nat as Hcounta.
    {
      assert (In a (a :: l1)) as Hcounta.
      { simpl; left; reflexivity. }
      rewrite count_occ_In with (eq_dec := activity_eq_dec) in Hcounta.
      rewrite <- Heqcounts.
      - exact Hcounta.
      - simpl. left. left. reflexivity.  
    }
    assert (In a l2) as Hainl2.
    {
     rewrite count_occ_In. exact Hcounta. 
    }
    assert (eq_counts activity_eq_dec l1 (remove_once activity_eq_dec a l2)).
    {
      clear IHl1.
      unfold eq_counts in *.
      intros a'.
      specialize (Heqcounts a').
      intros Hin.
      destruct (activity_eq_dec a a').
      - subst a'.
        simpl in *.
        destruct (activity_eq_dec a a).
        + clear e; clear Hin.
          rewrite <- remove_once_one_less_count.
          apply eq_add_S.
          rewrite S_pred_gt_0.
          * apply Heqcounts. left. left. reflexivity.
          * exact Hcounta.
        + contradiction.
      - rewrite <- remove_once_one_same_if_neq with (a := a) (a' := a').
        + simpl in Heqcounts.
          destruct (activity_eq_dec a a').
          { contradiction. }
          apply Heqcounts.
          destruct Hin.
          * left. right. exact H.
          * apply remove_once_one_In in H.
            right. exact H.
        + assumption.
    }
    
    specialize (IHl1 (remove_once activity_eq_dec a l2) i).
    apply IHl1 in H.
    clear IHl1; clear Heqcounts; clear Hcounta.
    specialize (usage_sum_remove_once l2 i a) as Hremove.
    specialize (Hremove Hainl2). rewrite Hremove in H.
    simpl. repeat rewrite usage_sum_add in *.
    clear Hremove.
    rewrite N.add_assoc. rewrite H.
    specialize (usage_sum_gt l2 i a Hainl2) as Husagegt.
    rewrite usage_sum_add in Husagegt.
    lia.
Qed.
    



(* Lemma sub_list_ex {A} (eq_dec : forall x y : A, {x = y}+{x <> y}) :
  forall l1 l2, sub_list eq_dec l1 l2 -> exists l3, eq_counts eq_dec (l1 ++ l2) l3.
Proof.
  intros l1 l2 Hsub. *)



Definition sub_activity_list (l1 l2 : list Activity) :=
  sub_list activity_eq_dec l1 l2.
    
Lemma usage_sum_lt_i :
  forall l i, i <= usage_sum_rec l i.
Proof.
  intros l i.
  induction l.
  - simpl. reflexivity.
  - simpl. rewrite usage_sum_add in *.
    lia.
Qed.

Lemma usage_sum_app :
  forall l1 l2, usage_sum (l1 ++ l2) = usage_sum l1 + usage_sum l2.
Proof.
  intros l1 l2.
  induction l1.
  - unfold usage_sum. simpl. reflexivity.
  - unfold usage_sum. simpl. repeat rewrite usage_sum_add.
    rewrite IHl1. lia.
Qed.

Lemma usage_sum_sub_list :
  forall l1 l2 i, sub_activity_list l1 l2 -> usage_sum_rec l1 i <= usage_sum_rec l2 i.
Proof.
  induction l1.
  - intros l2 i Hsub. simpl. rewrite usage_sum_add. lia.
  - intros l2 i Hsub.
    assert (count_occ activity_eq_dec l2 a > 0)%nat as Hcounta.
    {
      unfold sub_activity_list in Hsub; unfold sub_list in Hsub.
      specialize (Hsub a).
      assert (In a (a :: l1)) as Hcounta.
      { simpl; left; reflexivity. }
      apply Hsub in Hcounta; clear Hsub.
      simpl in *.
      destruct (activity_eq_dec a a).
      2: contradiction.
      clear IHl1; clear e; clear i.
      lia.
    }
    assert (sub_activity_list l1 (remove_once activity_eq_dec a l2)).
    {
      clear IHl1.
      unfold sub_activity_list in *; unfold sub_list in *.
      intros a' Hin.
      assert (In a' (a :: l1)).
      { simpl. right. exact Hin. }
      apply Hsub in H; clear Hsub.
      simpl in *.
      destruct (activity_eq_dec a a').
      - subst a'. 
        rewrite <- remove_once_one_less_count.
        apply S_lt.
        rewrite S_pred_gt_0.
        + exact H.
        + exact Hcounta.
      - rewrite <- remove_once_one_same_if_neq with (a := a).
        + exact H.
        + assumption.
    }
    apply IHl1 with (i := i) in H; clear IHl1.
    assert (In a l2) as Hainl2.
    { rewrite count_occ_In. exact Hcounta. }
    rewrite usage_sum_remove_once in H; try assumption.
    specialize (usage_sum_gt l2 i a Hainl2) as Husagegt.
    simpl. repeat rewrite usage_sum_add in *.
    clear Hsub; clear Hcounta; clear Hainl2.
    lia.
Qed.



(* Definition conflicting_activities (capacity : N) (l : list Activity) : option (list Activity) :=
  conflicting_activities_rec capacity l nil N0.


Definition conflicting_activities_step (capacity : N) (l : list Activity) (summed : list Activity) (current : N) : (option (list Activity) :=
  match l with
  | nil => None
  | a :: l' => 
    let new_current := a.(usage) + current in
      if new_current <=? capacity 
        then conflicting_activities_rec capacity l' (a :: summed) new_current
        else Some (a :: summed)
  end
.


Lemma conflicting_correct :
  forall c l s n l',
    conflicting_activities_rec c l s n = Some l'
      ->
    (forall a, In a l' -> In a l \/ In a s).
Proof.
  intros c l s n l'.
  intros Hsome.
  intros a Hin.
  induction l.
  - admit.
  - unfold conflicting_activities_rec in Hsome.

  intros Hconfl. intros a.
  

  
  induction l.
  - admit.
  - intros l' Hcal.
    split.
    {
      intros a'.
      destruct (conflicting_activities c l) eqn:Hcl.
      - specialize (IHl l0).


      
      destruct IHl as [IHconfl IHsub].

    }

    unfold conflicting_activities in Hcal.
    simpl in Hcal.
    destruct (usage a + 0 <=? c) eqn:Ha.
    + unfold conflicting_activities. 


  - unfold usage_sum. unfold usage_sum_rec.
    simpl. lia.
  - destruct (conflicting_activities c (a :: l)) as [lc |]eqn:Hconfl.
    + destruct (conflicting_activities c l) as [lc' |] eqn:Hlconfl.
      { 
        unfold conflicting_activities in Hconfl. 
        unfold conflicting_activities_rec in Hconfl.
          
      } *)
     


Definition sum_acc := (list Activity * N * bool)%type. 

Definition f_capacity (capacity : N) (combined : list Activity) (new : N) : sum_acc :=
  (combined, new, new <=? capacity).

Definition resource_sum_f (capacity : N) (acc : sum_acc) (a : Activity) : sum_acc :=
  match acc with
  | (_, _, false) => acc
  | (summed, current, _) =>
    f_capacity capacity (a :: summed) (current + a.(usage))
  end
.

Lemma resource_sum_f_correct : forall c a acc,
  match acc with
  | (summed, current, false) => resource_sum_f c acc a = (summed, current, false)
  | (summed, current, true) => 
    match resource_sum_f c acc a with
    | (summed_after, new, false) => 
      summed_after = a :: summed
        /\
      new = current + a.(usage)
        /\
      new > c
    | (summed_after, new, true) =>
      summed_after = a :: summed
        /\
      new = current + a.(usage)
        /\
      new <= c
    end
  end
.
Proof.
  intros c a acc.
  destruct acc as [[s n] below].
  destruct below.
  - destruct (resource_sum_f c (s, n, true) a) as [[s_after n_after] below] eqn:Hres.
    unfold resource_sum_f in Hres.
    unfold f_capacity in Hres.
    destruct below.
    + inversion Hres.
      repeat split.
      rewrite <- N.leb_le.
      exact H2.
    + inversion Hres.
      repeat split.
      rewrite N.leb_nle in H2.
      lia.
  - unfold resource_sum_f. reflexivity.
Qed.

(* Definition res_sum (capacity : N) (l : list Activity) acc :=
  fold_left (resource_sum_f capacity) l (nil, N0, true)
. *)


Definition res_sum_fold (capacity : N) (l : list Activity) acc :=
  fold_left (resource_sum_f capacity) l acc
.
(* For proving this, it was important to keep acc general! *)
Lemma res_sum_fold_correct :
  forall c l summed sum_result b (acc : sum_acc),
    match acc with
    | (acc_summed, acc_n, acc_b) =>
    (res_sum_fold c l acc = (summed, sum_result, b)) -> 
      ((acc_b = false -> b = false)
        /\
      (usage_sum acc_summed = acc_n -> usage_sum summed = sum_result )
        /\
      (forall a', In a' summed -> ((In a' summed \/ In a' acc_summed) /\ ((count_occ activity_eq_dec summed a' <= count_occ activity_eq_dec l a' + count_occ activity_eq_dec acc_summed a')%nat))) 
        /\
      if b 
        then 
          usage_sum l + acc_n = sum_result
            /\
          (acc_n <= c -> sum_result <= c)
        else
          if acc_b 
            then sum_result > c
            else acc_n > c -> sum_result > c
          )
      end.
Proof.
  intros c l summed sum_result b.
  induction l.
  - intros acc. destruct acc as [[acc_summed acc_n] acc_b]. intros Hres.
    simpl in *. inversion Hres.
    repeat split.
    + intros H. exact H.
    + intros H. exact H.
    + right. exact H.
    + reflexivity. 
    + destruct b.
      * split. { reflexivity. } { intros H. exact H. }
      * intros Hsum. exact Hsum.
  - intros acc. 
    specialize (resource_sum_f_correct c a acc) as Hresource_sum.
    destruct acc as [[acc_summed acc_n] acc_b] eqn:Hacc.
    rewrite <- Hacc in *.
    simpl in *.
    intros Hres.
    specialize (IHl (resource_sum_f c acc a)).
    destruct (resource_sum_f c acc a) as [[fl fs] fb] eqn:Hf.
    specialize (IHl Hres).
    repeat split.
    + intros Haccb.
      subst acc_b.
      inversion Hresource_sum.
      subst fb. subst fs. subst fl.
      destruct IHl as [IHfalse _].
      apply IHfalse.
      reflexivity.
    + destruct IHl as [_ [IHl _]].
      destruct acc_b.
      * destruct fb.
        { 
          intros Haccusage.
          destruct Hresource_sum as [Hfl [Hfs Hfslec]].
          subst fl. subst fs.
          apply IHl. unfold usage_sum.
          simpl. rewrite usage_sum_add. rewrite Haccusage.
          reflexivity.
        }
        {
          intros Haccusage.
          destruct Hresource_sum as [Hfl [Hfs Hfslec]].
          subst fl. subst fs.
          apply IHl. unfold usage_sum.
          simpl. rewrite usage_sum_add. rewrite Haccusage.
          reflexivity.
        }
      * inversion Hresource_sum.
        subst fl. subst fs. subst fb.
        exact IHl.
    + destruct IHl as [_ [_ [IHinl _]]].
      specialize (IHinl a' H).
      destruct IHinl as [IHin IHcount].
      destruct IHin as [IHin | IHinfl].
      { left. exact H. }
      { left. exact H. }
    + destruct IHl as [_ [_ [IHinl _]]].
      specialize (IHinl a' H).
      destruct IHinl as [IHinfl IHcount].
      destruct acc_b; destruct fb; inversion Hresource_sum.
      * destruct Hresource_sum as [Hfl [Hfs Hfslec]].
        subst fl. subst fs. simpl in IHinfl.
        simpl in *.
        destruct (activity_eq_dec a a').
        { subst a'. lia. }
        { apply IHcount. }
      * destruct Hresource_sum as [Hfl [Hfs Hfslec]].
        subst fl. subst fs. simpl in IHinfl.
        simpl in *.
        destruct (activity_eq_dec a a').
        { subst a'. lia. }
        { apply IHcount. }
      * subst fl. subst fs.
        destruct (activity_eq_dec a a').
        { subst a'. lia. }
        { apply IHcount. }
    + unfold usage_sum in *.
      simpl in *.
      destruct IHl as [Hbfalse [_ [_ IHsums]]].
      destruct acc_b eqn:Hacc_b.
      * destruct b.
        { 
          destruct IHsums as [IHsum IHle].
          destruct fb.
          - destruct Hresource_sum as [Hfl [Hfs Hfslec]].
            subst fl. subst fs.
            split.
            + rewrite <- IHsum.
              repeat rewrite usage_sum_add.
              lia.
            + intros Haccle. apply IHle.
              exact Hfslec.
          - assert (false = false) as Hfalse by reflexivity.
            apply Hbfalse in Hfalse.
            discriminate Hfalse.
        }
        {
          destruct fb.
          - intros. exact IHsums. 
          - destruct Hresource_sum as [Hfl [Hfs Hfslec]].
            subst fl. subst fs.
            apply IHsums.
            exact Hfslec.
        } 
      * inversion Hresource_sum.
        subst fl. subst fs. subst fb. clear Hresource_sum.
        destruct b.
        {
          assert (false = false) as Hfalse by reflexivity.
          apply Hbfalse in Hfalse.
          discriminate Hfalse.
        }
        {
         exact IHsums. 
        }
Qed.

Definition res_sum (capacity : N) (l : list Activity) :=
  res_sum_fold capacity l (nil, N0, true)
.

Lemma res_sum_correct :
  forall c l,
    match res_sum c l with
    | (summed, sum_result, b) =>
      usage_sum summed = sum_result
        /\
        (forall a', In a' summed -> (In a' summed /\ ((count_occ activity_eq_dec summed a' <= count_occ activity_eq_dec l a')%nat))) 
        /\
      if b
        then 
          sum_result <= c
            /\
          usage_sum l = sum_result
        else sum_result > c
    end.
Proof.
  intros c l.
  destruct (res_sum c l) as [[summed sum_result] b] eqn:Hres.
  specialize (res_sum_fold_correct c l summed sum_result b (nil, N0, true)) as H.
  unfold res_sum in Hres.
  simpl in H.
  specialize (H Hres).
  destruct H as [Hfalse [Hsumr [Hin Hsums]]].
  repeat split.
  - apply Hsumr.
    unfold usage_sum. simpl. reflexivity.
  - exact H.
  - specialize (Hin a' H).
    destruct Hin as [_ Hcount].
    lia.
  - destruct b.
    + destruct Hsums as [Hsum Hle].
      split.
      * apply Hle. lia.
      * rewrite <- Hsum.
        lia.
    + exact Hsums.
Qed.

Theorem res_sum_semantics :
  forall c l,
    match res_sum c l with
    | (_, sum_result, true) =>
      usage_sum l = sum_result  
        /\     
      usage_sum l <= c
    | (summed, sum_result, false) =>
      usage_sum summed = sum_result
        /\
      usage_sum summed > c
        /\
      sub_activity_list summed l
        /\
      usage_sum l > c
    end.
Proof.
  intros c l.
  specialize (res_sum_correct c l) as H.
  destruct (res_sum c l) as [[summed sum_result] b].
  destruct b.
  - destruct H as [Hsum_result [Hin [Hle Husage]]].
    split.
    + exact Husage.
    + rewrite Husage. exact Hle.
  - destruct H as [Hsum_result [Hin Hgt]].
    assert (sub_activity_list summed l) as Hsub.
    {
      unfold sub_activity_list; unfold sub_list.
      intros a Hinsummed.
      apply Hin. exact Hinsummed.
    }
    repeat split.
    + rewrite Hsum_result. reflexivity.
    + rewrite Hsum_result. exact Hgt.
    + exact Hsub. 
    + specialize (usage_sum_sub_list summed l N0 Hsub) as Husagelt.
      repeat rewrite usage_sum_add in *.
      rewrite <- Hsum_result in Hgt.
      lia.
Qed.


Definition dec_cumulative (params: CumulativeParams) (horizon_start : Z) (horizon_end : Z) (vs : vars) (v : valuation) : bool :=
  let c_activities := activity_list params v vs in
  forallb 
    (fun t => 
      match res_sum params.(capacity) (activities_at_t c_activities t) with
      | (_, _, b) => b
      end
    )
    (build_range horizon_start horizon_end)
.

Lemma forallb_false {A} :
  forall f l,
    forallb f l = false ->
      exists (a : A), In a l /\ f a = false.
Proof.
  induction l.
  - intros Hnil. simpl in Hnil. discriminate Hnil.
  - intros Hforall. simpl in *.
    rewrite andb_false_iff in Hforall.
    destruct Hforall.
    + exists a.
      split.
      * left. reflexivity.
      * exact H.
    + specialize (IHl H).
      destruct IHl as [a' [Ha' Hfa']].
      exists a'.
      split.
      * right. exact Ha'.
      * exact Hfa'.
Qed.

Lemma dec_cumulative_props :
  forall params s e vs v,
    match dec_cumulative params s e vs v with
    | true => True
    | false => exists t, exists active, (forall x, sstr.In x active <-> ActiveAt (v x) (params.(p_times) x) t) /\ resource_sum params active v > params.(capacity)
    end.
Proof.
  intros params s e vs v.
  destruct (dec_cumulative params s e vs v) eqn:Hres.
  - reflexivity.
  - unfold dec_cumulative in Hres.
    apply forallb_false in Hres.
    destruct Hres as [t [Htin Hsum]].
    exists t. 
    specialize (res_sum_semantics params.(capacity) ((activities_at_t (activity_list params v vs)
    t))) as Hres_sum.
    destruct (res_sum (capacity params)
    (activities_at_t (activity_list params v
    vs) t)) as [[summed sum_result] allowed] eqn:Hres.
    rewrite Hsum in Hres_sum.



    

Lemma not_cumul :
  forall params s e vs v,
    dec_cumulative params s e vs v = false ->
      ~ Cumulative params vs v  
  .
Proof.
  intros params s e vs v.
  intros Hnotcumul. intros Hcumul.
