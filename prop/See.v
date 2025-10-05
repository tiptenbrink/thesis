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

Definition all_diff_propagate (c : all_different) (st : state) : bool :=
  (* ... *)
.