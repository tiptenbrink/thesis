const a = {"info":"1 goal (ID 102)","context":"st : state\n  vs, confl_vars : sstr.t\n  Hsub : sstr.Subset confl_vars vs\n  Hlt : dom_size (vars_dom_union st confl_vars) < vars_len confl_vars\n  v : string -> Z\n  Hvstate : valuation_in_state st vs v\n  Hdiff : AllDifferent confl_vars v","first_goal":"dom_size\n    (fold_right (fun (y : sstr.elt) (x : sint.t) => sint.union (st y) x)\n       sint.empty (rev (sstr.elements confl_vars))) >=\n  Datatypes.length (sstr.elements confl_vars)","other_goals":[]}

console.log(a.context)
console.log(a.first_goal)