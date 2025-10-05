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

Definition domain := MSetInt.t.

Definition state := var -> domain.

(* To check if a matching is maximum, we must check if no augmenting paths exist *)

(* Steps: given a matching, if size is equal to number of variables, there is no conflict, otherwise we need to see if any augmenting paths exist. *)

(* We must decide what should be verified *)
