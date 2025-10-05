#import "ams.typ": ams-article
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#import "@preview/algo:0.3.4": algo, i, d, comment, code, _algo-default-keywords
#import "@preview/curryst:0.3.0": rule, proof-tree

#show: ams-article.with(
  title: ["Proof Certification for CP" \ Tip ten Brink],
  bibliography: bibliography("bib.yml"),
)

#let note(body, note_text: [Note], gap: 2mm, small: false) = {
  let size = if small {
    8pt
  } else {
    10pt
  }

  let weight = if small {
    "regular"
  } else {
    "bold"
  }
  
  set text(fill: red, size: size, weight: weight)
  box([#note_text: #body 
  #place()[    
    #set text(size: 0pt)
    #figure(kind: "todo", supplement: "", caption: body, [])
  ]])
}

#let todo(body) = {
  note(body, note_text: [TODO])
}

#let todosm(body) = {
  note(body, note_text: [TODO], small: true)
}

#let cc = $frak(c)$
#let uu = $frak(u)$

#let definition = thmbox("definition", "Definition", base_level: 1, inset: (x: 1.2em, top: 0.6em))

#let example = thmbox("example", "Example", base_level: 1, inset: (x: 0.8em, top: 0.6em))

= Introduction

Constraint Programming (CP) is a paradigm often used to solve combinatorial problems. CP has a number of important characteristics:

- It employs "declarative" problem modelling, where the logical representation of the problem is separate from the actual method used for solving it
- It has a strict separation between methods to reduce the search space (through deduction referred to as "propagation") and methods to explore that search space efficiently

#note[See proposal document for more expanded motivation for now]

== Pseudocode conventions

#todo[find good place for this subsection]

Our pseudo-code uses a Pyton-like syntax interspersed with mathematical notation and generally uses a functional style, preferring option/maybe types over nullable types.

= Constraint programming

To understand the CP solvers we aim to make more robust, the following section introduces the important concepts underpinning modern constraint programming.

#definition[
  A _domain_ $D$ is an $n$-tuple $angle.l D_1, D_2, ..., D_n angle.r$ that corresponds to an $n$-tuple of variables $X = angle.l x_1, x_2, ..., x_n angle.r$ such that the $i$th domain is the set of values that the $i$th variable is allowed to take. We also write, for $x in X$, that $D(x)$ is the set of all values that $x$ can take. 
]

// Suppose each variable $x in X$ is an element of some larger set $UU$. A domain can then be seen as a function $D: X -> cal(P)(UU)$, where $cal(P)(UU)$ is the power set of $UU$.


#let Dcross = $D_times (X)$

#definition[
  Given variables $X = angle.l x_1, x_2, ..., x_n angle.r$ and associated domain $D$, then a _constraint_ $C(X)$ is a subset of the Cartesian product $D(x_1) times D(x_2) times ... times D(x_n)$. 
  // We will write this Cartesian product as $Dcross$. 
]

As the above definition states, we consider only finite sets of variables for any particular problem. As any physical solution has some finite precision and we only ever have finite resources, this is not an issue for any practical problem. Furthermore, we shall restrict ourselves to finite _domains_. As we shall see in upcoming examples, this is also not a significant restriction, as we can still make our domains arbitrarily large and hence can achieve arbitrary precision, just not infinite.

#definition[
  A _Constraint Satisfaction Problem_ (CSP) consists of variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$, domains $cal(D) = angle.l D_1, D_2, ..., D_n angle.r$, such that for each $x_i in cal(X)$, $cal(D)(x_i)$ is the domain of that variable, and a set $cal(C)$, where each $C(X) in cal(C)$ is a constraint defined for a tuple of variables $X subset.eq cal(X)$. The triple ($cal(C)$, $cal(X)$, $cal(D)$) defines the CSP.
]

Without loss of generality, given a tuple of variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$, when we refer to a tuple $X subset.eq cal(X)$, we assume the variable ordering is identical in $X$ and $cal(X)$. Formally, $X = angle.l x_a_1, x_a_2, ..., x_a_k angle.r$, where we require that $a_1, a_2, ..., a_k$ is a subsequence of $1, 2, ..., n$.

#definition[
  For variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$ and a domain $D$, an _assignment_ $v$ is an  $n$-tuple of values $angle.l v_1, v_2, ..., v_n angle.r$, where $v_i in D(x_i)$. Consider some variables $X subset.eq cal(X) = angle.l x_a_1, x_a_2, ..., x_a_k angle.r$, then $v(X)$ is the $k$-tuple $angle.l v_a_1, v_a_2, ..., v_a_k angle.r$. An assignment $v$ _satisfies_ a constraint $C(X)$, where $X subset.eq cal(X)$, if $v(X) in C(X)$. 
]

#definition[
  An assignment $v$ is a _solution_ to a CSP $(cal(C), cal(X), cal(D))$ if we have that for all $C(X) in cal(C)$, where for each $C(X)$, we have that $v(X) in C(X)$, i.e. the assignment satisfies all constraints.
]

// #todo[Make sure numbering for defs/examples doesn't increase a level here]

We now provide a few simple examples to show how these definitions work.

#example[
  Consider the variables $angle.l x, y, z angle.r$, with domains $D(x) = [0, 800]$, $D(y) = [-20, 3]$ and $D(z) = {2, 8}$ The constraint $x + z <= 20$ is then formally defined as the set $C(x, z) = {(x, z) in [0, 800] times {3, 8} : x + z <= 20}$. Let an example assignment be $angle.l v_1 = 90, v_2 = 2, v_3 = 8 angle.r$. This assignment does not satisfy $C(x, z)$, because $(90, 8) in.not C(x, z)$, since 90 + 8 $lt.eq.not$ 20. However, the assignment $angle.l v_1 = 12, v_2 = -17, v_3 = 8 angle.r$, _does_ satisfy $C(x, z)$. 
] <ex:asgndom>

#example[
  Consider the same variables and domains as in @ex:asgndom, as well as the constraint $C(x, z)$. Now, the constraint $C(y)$ is defined as ${y in [-20, 3] : y != 0 }$. Then $cal(P)$ as $({C(x, z), C(y)}, X, D)$ is a CSP. Furthermore, the assignment $angle.l v_1 = 12, v_2 = -17, v_3 = 8 angle.r$ is a solution to the CSP.
]

#note[The below section might be too detailed.]

Since we consider only finite amounts of variables with finite domains, @basicsolve with main procedure #smallcaps[solve] describes a complete algorithm that can solve any CSP. As input it takes a CSP $cal(P)$ and it returns either `None` or `Some`$(cal(Q))$. Here, we require that $cal(Q)$ is in some way _equivalent_ to our original $cal(P)$ and that we can easily generate an assignment in terms of the variables of the original problem that is also a solution to the original problem.

#let algo_keywords = _algo-default-keywords + ("match", "with", "case", "lambda", "def")
#figure(
  [
    #algo(
      title: "solve",
      parameters: ($cal(P)$,),
      keywords: algo_keywords
    )[
      $cal(P)'$ := #smallcaps[propagate($cal(P)$)]\
      $(cal(C)', cal(X)', cal(D)') = cal(P)'$\
      if $exists x in cal(X)'$ s.t. $cal(D)'(x) = nothing$:#i\
        return `None`#d\
      else if $forall x in cal(X)'$ s.t. $|cal(D)'(x)| = 1$:#i\
        return `Some`($cal(P))$#d\
      else:#i\
        $cal(Q)_1, cal(Q)_2, ..., cal(Q)_k$ := #smallcaps[split]$(cal(P)')$\
        for i in {1,2, ..., k}:#i\
          match #smallcaps[solve]$(cal(Q)_i)$:#i\
            case `Some`$(cal(Q))$: return `Some`$(cal(Q))$ #d#d\
    
          return `None`
    ] 
  ],
  caption: [Complete CSP algorithm @schutt2011improving (p. 14).],
  kind: "algorithm",
  supplement: "Algorithm"
) <basicsolve>

#let propagateproc = { text(font: "New Computer Modern")[#smallcaps[propagate]] }
#let splitproc = { 
  // Somehow the space at the end actually removes the space in math mode
  text(font: "New Computer Modern")[#smallcaps[split] ] 
}

To achieve this, the subroutines #smallcaps[propagate] and #smallcaps[split] must satisfy some conditions. We first consider two simple versions. Define #splitproc such that it picks a variable with a domain containing more than one value and splits it, returning the two resulting problems. The #splitproc procedure can be written as follows, where #smallcaps[split_domain]$(D, x)$ splits a domain $D$ into two such that they are the same for all variables except the domain of the provided $x$, which is partitioned into two:

#algo(
  title: "split",
  parameters: ($cal(P)$,),
  keywords: algo_keywords,
  stroke: 0pt,
  fill: none,
  line-numbers: false,
)[
  $(cal(C), cal(X), cal(D)) = cal(P)$\
  for $x_i$ in $cal(X)$:#i\
    if $|cal(D)(x_i)| != 1$:#i\
      $cal(D)_1, cal(D)_2$ := #smallcaps[split_domain]$(cal(D), x)$ \
      return $(cal(C), cal(X), cal(D)_1), (cal(C), cal(X), cal(D)_2)$
          
]

In other words, #splitproc branches on a variable, splitting the problem into two subproblems. Next, define #propagateproc as follows:

#algo(
  title: "propagate",
  parameters: ($cal(P)$,),
  keywords: algo_keywords,
  stroke: 0pt,
  fill: none,
  line-numbers: false,
)[
  $(cal(C), cal(X), cal(D)) = cal(P)$\
  $cal(D)' := cal(D)$\
  for $C(X)$ in $cal(C)$:#i\
    if $|C(X)| = 0 $:#i\
      $cal(D') := $#i\
      | $x in X => nothing$\
      | $x in.not X => cal(D)'(x)$#d#d#d\

  return ($cal(C)$, $cal(X)$, $cal(D)'$)
]

This definition says that if there are no assignments that satisfy a constraint, we set the domains of the variables involved in the constraint to the empty set.

It should be clear that our full algorithm is complete. It only rejects a subproblem when it becomes infeasible (a constraint is no longer satisfied) and it considers all possible domains #todosm[the language in this paragraph is not very precise]. However, the algorithm is clearly exponential in $sum_(x in cal(X))|D(x)|$. Adding even one possible value to a domain doubles the search space and we only constrain the search space when a constraint is already infeasible.

== Propagators <sec:prop>

Let us consider #propagateproc in more detail. For it to be correct, every constraint must be associated with at least one _propagator_ (one propagator can also be responsible for multiple constraints). Consider a propagator $p$ and a constraint $C(X)$. Following is from @rossi2006handbook (Ch. 14). A propagator is a function that maps domains to domains.  

#todosm[Continue this section]

In order to discuss more advanced methods, it will be useful to construct an example that we can reason about easily, but can clearly be related to real-world problems. We will first define a specific type of widely-used global constraint. Next, we introduce some very powerful propagation and search techniques and apply them to the example.

== Cumulative

As a running example, we first discuss a very useful global constraint, _cumulative_. We use the MiniZinc definition @nethercote2007minizinc @minizinc_cumulative_2024.

#definition[
  A _cumulative_ constraint consists of a set of activities $A$, where for each activity $a in A$ there is a variable start time $s(a)$, a processing time $p(a)$ and a resource usage $r(a)$. A process $a$ is _active_ at time $t$ if $s(a) <= t <= s(a) + p(a)$. There is also a global resource bound $R$. The constraint then requires that at each time, the total resource usage of all activities active at that time is lesser or equal than $R$.
]

#example[
  Consider a situation with two cooking stoves, as well as a number of ingredients that must be cooked on a stove. Therefore, only two ingredients can be cooked at the same time time. Furthermore, each ingredient takes a specific amount of time to cook. The processing times will be measured in increments of 5 minutes. We have the following ingredients: _potatoes_ ($A$ardappelen) _schnitzel_ ($V$lees) and _broccoli_ ($G$roente), as well as two garnishes, _onion_ ($O$) and _nuts_ ($N$). This gives us a cumulative constraint where $A = {A, V, G, O, N}$, $p(A) = 3$, $p(V) = 2$, $p(G) = 1$, $p(O) = 1$, $p(N) = 1$ and $R = 2$.
] <ex:cum>

The cumulative constraint can be decomposed. We describe the time decomposition @schutt2011improving (Ch. 4). 

#definition[
  In the _time decomposition_ of the cumulative constraint with activities $A$, processing times $p$, resource usages $r$ and total resource usage $R$, we define the following variabes and constraints:

  $ 
  cal(B)_1 = {a_t : "activity" a "is active at time" t} \
  cal(B)_2 = {[a <= t] : "activity" a "starts before or at" t} \
  cal(C)_1 = {[a <= t] -> [a <= t + 1]: "enforce lesser than or equal"} \
  cal(C)_2 = {a_t <-> [a <= t] and not [a <= t - p(a)] : "enforce semantics of" a_t} \
  cal(C)_3 = { sum_(a in A) r(a) dot a_t <= R : "enforce resource constraint"}
  $

  For $cal(B)_1$ and $cal(B)_2$, they are defined for every allowed time $t$ and activity $a$. For $cal(C)_1$, $t$ must be strictly less than the final allowed time and it is enforced for every activity $a$. The constraints in $cal(C)_2$ are defined exactly as above for every $a$ when $t >= p(a)$, otherwise the proposition $not [a <= t - p(a)]$ is always true and is omitted. Finally, the constraints in $cal(C)_3$ are defined for every allowed time $t$. 
]

Note that for an acitvity $a$, the starting time $s(a)$ can be computed as  $min { t : a_t = 1}$.

\

Among the simplest type of constraints is a propositional constraint, consisting only of Boolean variables and the basic logical connectives (conjunction, disjunction and negation). The problem of determining a solution to a CSP that contains only Boolean variables and such propositional constraints is also known as the Boolean satisfiability problem or SAT. Since SAT is NP-complete (and the first one to be proven to be as such), many other problems can be expressed in terms of SAT. 

We just established that SAT is a type of CSP. Therefore, it seems promising (and is promising, as we will soon see) to apply the sophisticated techniques used in SAT solving to solving more general CP problems. Let us first introduce a number of important SAT concepts.

== SAT

Let us first make the notion of a "formula" precise.

#definition[
  A _Boolean formula_, or _propositional formula_ can be inductively constructed using any of the following constructors:
  $
  |& x \
  |& not space (p: "formula") \
  |& and (p space q : "formula") \
  |& or (p space q : "formula") \
  |& ⊥ \
  |& ⊤, \
  $

  where $x$ signifies a variable from some given set, ⊥ is the `false` constant (known also as the _empty clause_), ⊤ is the `true` constant, and the others are operators acting on one or two formulas, which evaluate according to the normal rules for negation ($not$), disjunction ($or$) and conjunction ($and$). For $and$ and $or$, we will use infix notation, e.g. $x and y$ is a valid formula. We will also use the abbrevation $x -> y$ for $not x or y$ (signifying an implciation) and $x <-> y$ for $(x -> y) and (y -> x)$.
]

A Boolean formula $cal(F)$ gives rise to a CSP by taking $X$ to be the set of all variables used in $cal(F)$, setting $D(x) = {0, 1}$ for all $x in X$ and introducing a single constraint consisting of all assignments that satisfy $cal(F)$. An assignment satisfies a formula $cal(F)$ if it makes it evaluates to 1 if all variables in the formula are replaced by their assigned values.

#definition[
  Consider a set of Boolean variables $B$. Then the corresponding set of literals consist of ${b : b in B} union {not b : b in B}$.
]

So a literal is a propositional variable or its negation. For a variable $x$, we can denote its negation as either $not x$, or $macron(x)$.

#definition[
  A _clause_ is a set of literals ${l_1, l_2, ..., l_n}$, where we see the clause as a disjunction of literals. So if we speak of a clause consisting of, $x, y$ and $macron(z)$, then we mean the disjunction $x or y or macron(z)$.
]

#definition[
  A formula in _conjunctive normal form_ (CNF) consists of a set of clauses ${cc_1, cc_2, ..., cc_n}$, where the propositional formula is a conjunction of these clauses. So if we speak of the CNF formula ${cc_1 = x, cc_2 = {y, macron(z)}, cc_3 = {x, z}}$, then we mean the propositional formula $x and (y or macron(z)) and (x or z)$. This is the _set notation_ for CNFs.
]

Given some formulas that must be true, there are some simple rules to deduce new formulas that then must also be true. We will now describe some of these rules.

#definition[
  The _propositional resolution rule_ can be stated as follows:
  
  $
    #proof-tree(
      rule(
        $alpha or beta$,
        $x or alpha$,
        $macron(x) or beta$,
      )
    )
  $
  
  Here, $alpha$ and $beta$ can be any propositional formula. The rule says that, if we know that $x or alpha$ must hold, as well as $macron(x) or beta$, then we can infer that $alpha or beta$ must also hold. $alpha or beta$ is called the _resolvent_. 
]

On CNFs, resolution is _refutation complete_ @biere2021handbook (Ch. 3, Complete Algorithms), which means that a CNF formula is unsatisfiable if and only if you can infer the empty clause by applying the resolution rule repeatedly. In CNFs, $x or alpha$ and $macron(x) or beta$ are called the _resolved clauses_. However, even in the general case they take the form of disjunctions, so we will always refer to them as clauses.

#example[
  Consider the following CNF:
  
  $ cc_1 = x, cc_2 = { macron(x), y }, cc_3 = { macron(y) or macron(x) } $

  First apply the resolution rule to $cc_1$ and $cc_2$, which gives us the resolvent $frak(r)_1 = y$, which we can add to our CNF as an additional clause. Now apply the rule to $frak(r)_1$ and $cc_3$, yielding a new clause $frak(r)_2 = macron(x)$. Finally, applying the rule to $cc_1$ and $frak(r)_2$ yields the empty clause, proving the unsatisfiability of this particular formula.
]

#definition[
  Also known as unit resolution, _unit propagation_ is a special case of resolution. It requires that one of the resolving clauses consists of only one literal. 
]

This allows inferences of e.g.:
  
  #let numbered(body) = {
    math.equation(block: true, numbering: "(1)")[
      #body
    ]
  }
  
  #numbered[
    #proof-tree(
      rule(
        $alpha$,
        $x$,
        $macron(x) or alpha$,
      )
    ),
  ] <unitres>

We say "e.g." because there is a second inference where the places of $x$ and $macron(x)$ are swapped, which is also unit propagation.

Note that unit propagation is not refutation-complete for CNFs, but it can be applied in linear time with respect to the number of clauses.

#todo[Make the connection/switch to the language where our state consists also of undefined variables]

== Assignment

Am _assignment_ is a mapping from variables to values (where we allow variables to be undefined). Formally, we can define an assignment as a function $nu$: $VV -> {0, 1, uu}$, where $uu$ signifies that a variable is undefined. If an assignment satisfies a formula, then the assignment is a _model_. An assignment is _complete_ if no variables are undefined.

== Clause states

A clause can be in a number of states. It is

- _falsified_ if all literals are assigned 0,
- _satisfied_ if at least one literal is assigned 1,
- _unit_ if all are 0, except one which is undefined, in which case we say _unit in $x$_, for a variable $x$,
- _unresolved_ otherwise.

== Unit propagation (continued)

Unit propagation can be seen differently in the case where we _set_ the values of variables during the solving process and where clauses have a state that changes over time (as before). In that case we can describe unit propagation as follows:

$ cc "is unit in" l => "assign" l = 1, $

for a clause $cc$ and a literal $l$, where of course if $l$ corresponds to some negated variable, we actually assign the variable the value 0.

To see why the notion is equivalent to the rule in @unitres, consider the following formula:

$ (x or y) and (y or macron(x)) $

Assume that all variables are initially assigned the value $uu$ (they are undefined). Next, we set $x = 0$. Then the clause ($x or y$) becomes unit and we assign $y = 1$.

Equivalently to "setting" $x$ to 0, we could have added the clause $macron(x)$, giving us the formula:

$ (x or y) and (y or macron(x)) and macron(x) $

Now, we can use @unitres like so:

$
  #proof-tree(
    rule(
      $y$,
      $macron(x)$,
      $x or y$,
    )
  )
$

After this, we could add $y$ as an additional clause, which means that $y$ has to be `true`.

== Antecedent and decision level

#let dd = $frak(d)$
#let nn = $frak(n)$

When a variable $x$ is assigned a value during unit propagation, it is an _implied_ variable. When solving, the _antecedent_ (or _reason_) denotes the reason for assigning the variable that value.

When a variable is implied, the antecedent is the unit clause used in the propagation. When it is assigned during search, the antecedent is set to $dd$, for unassigned variables, the antecedent is $nn$. 

The decision level of a variable is equal to the depth of the decision tree (where a decision is only a variable assigned during search) after the decision. So if during solving, the decisions made are (in that order) $x = 0, y = 1, z = 1$, then the corresponding decision levels are 1, 2, 3.

== Reverse unit propagation

Let $cal(F)$ and $cal(F)'$ be two CNF formulas. We say that $cal(F)$ _implies $cal(F)'$ by unit propagation_ if for every clause $C in cal(F)'$, unit propagation derives a conflict on $F and not C$. This is also written as $F scripts(tack.r)_1 cal(F')$.

#example[
  Consider the formulas $cal(F) = x and y$, $cal(F)' = (x or z) and y$. Then $cal(F)'$ consists of two caluses. We have $not (x or z) = macron(x) and macron(z)$. Clearly, $cal(F) and macron(x) and macron(z)$ leads to a conflict by unit propagation (take the resolved clauses to be $x$ and $macron(x)$). Furthermore, $cal(F) and macron(y)$ also allows deriving the empty clause using unit propagation. Therefore, $cal(F) scripts(tack.r)_ 1 cal(F)'$. 
]

Now consider the special case where $cal(F)'$ consists of only one clause, which we call $C$. Then if $cal(F)$ implies $C$ by unit propagation (so $cal(F) scripts(tack.r)_1 C$), we say $C$ is a _reverse unit propagation_ (RUP) clause with respect to $cal(F)$.

In more detail, consider a clause $C = (l_1 or l_2 or ... or l_k)$, then $C$ is a RUP clause with respect to $cal(F)$, if $cal(F) and macron(l_1) and macron(l_2) and ... and macron(l_k)$ leads to a conflict by unit propagation.

https://www.msoos.org/2022/04/proof-traces-for-sat-solvers/

== Clausal constraints

Constraints $cal(C)_1$ and $cal(C)_2$ are already propositional and can be readily transformed to CNF. However, the CNF encoding of $cal(C)_3$ is more difficult. For a general approach, we refer to @joshi2015totalizer.

= Other

#note[This section is just a collection of written out definitions, experimentations, etc. that may or may not make it to the actual preliminaries]

== Proof logging for CP

Proof logging, better than VeriPB

#definition[
  An _atomic constraint_ consists of an integer variable $x$, a constant $c in ZZ$ and a relation $diamond.small in {>=, <=, = , !=}$ that requires $x diamond.small c$ to hold. An atomic constraint is written as $angle.l x diamond.small c angle.r$.
]

We note that atomic constraints can be associated with some truth value, i.e. $angle.l x <= 3 angle.r$ can either be true or false, if $x$ is assigned a value. We can therefore associate a Boolean variable with the entire constraint, e.g. $b <=> angle.l x <= 3 angle.r$. Some predicate containing atomic constraints can then be associated with an equivalent standard propositional formula where the atomic constraints are replaced with Boolean variables. This is the interpretation that should be used in the following definitions. In similar vein, if we name an atomic constraint $angle.l x diamond.small c angle.r$, e.g. we name it $a$, then when we use $a$ in a formula we are actually referring to its associated variable, which we will also write as $a$.

#definition[
  Let $angle.l a_1, a_2, ..., a_n angle.r$ be a tuple of $n$ atomic constraints. Then the formula $a_1 and a_2 and ... and a_n -> "" bot$ is a _nogood_. 
]

#definition[
  Let $angle.l a_1, a_2, ..., a_n, q angle.r$ be a tuple of $n+1$ atomic constraints. Then the formula $a_1 and a_2 and ... and a_n -> q$ is an _inference_. 
]

#definition[
  A _fact_ is either a nogood or an inference.
]

#todosm[Understand below fully]

#definition[
  #todosm[Fix this]
  _Inference rule_ is a predicate that takes a fact $omega$, and constraints $C$ of the original CSP (these constraints together are an inference hint). 

  It is true only if $omega$ is true for all assignments that satisfy the constraints.

  So constraints $C$ imply some domain, and $omega$ must be true in that domain.
]

We can write facts in clausal form as follows:

An inference is then $not(a_1 and a_2 and ... and a_n) or q$, which is equivalent to $macron(a_1) or macron(a_2) or ... or macron(a_n) or q$.

Similarly, a nogood is is then just $macron(a_1) or macron(a_2) or ... or macron(a_n)$.

Remember that in SAT solving, we call a clause _unit_ if all literals in a clause are false, except one, which is undefined. This leads to a definition for when we call a fact unit.

#definition[
  A fact $a_1 and a_2 and ... and a_n -> q$ (where $q$ is $bot$ in case of a nogood) is _unit_ if all $macron(a_i)$ and $q$ conflict individually (or equivalently, all $a_i$ and $q$ must be true), except for one $macron(p)_k$ or $q$. This sole non-conflicting atomic is called the _consequent_.
]

#example[
  Consider the constraint $x + y >= 10$. Then consider the fact $angle.l x = 10 angle.r and angle.l x = 1 angle.r -> "" bot$. Together they give a valid inference rule. 
]

== Solver

== Cumulative global propagator

Suppose we have the following bounds for the start time $s(a)$ of an activity $a$, $s >= L$ and $s <= U$. Then, if $U < L + p(a)$ the _compulsory part_ is the interval $[U, L + p(a)]$. 

Propagating based on the information about these compulsory parts is called _time-table reasoning_. 

It is also possible to reason about the energies (resources) using e.g. the edge-finding algorithm, for which we refer to @schutt2011improving (Ch 4).

=== Consistency check

A consistency check can be performed by building a resource profile, which consists of the compulsory parts of all activities. Then, a record of the resource usage at each time can be built by iterating through all times in a compulsory part. When the usage exceeds the capacity, an infeasibility is detected.

If we know that the capacity is exceeded when a set of activities $A$ is active at time $t$, we can provide the following explanation, called a _pointwise explanation_ (again, see @schutt2011improving):

$ and.big_(a in A) bracket.l.double s(a) >= t + 1 - p(a)  bracket.r.double and bracket.l.double s(a) <= t bracket.r.double $

== Problems

=== Class problem <class>

Consider a small, special school with two years, $Y_1$ and $Y_2$, that on Monday both need 3 subjects, $A$rithmetic, $B$iology and $C$rafts. Each subject has a single teacher.

Year 1 needs 3 hours of Arithmetic, 3 hours of biology and 1 hour of Crafts, while Year 2 needs 4 hours of Arithmetic, 1 hour of Biology and 2 hours of Crafts. A year cannot have its subject divided into two blocks, it must be given in one go. 

We can model this as a number of non-overlapping tasks with start times $A_1, B_1, C_1$ with processing times $3, 3, 1$ respectively, as well as start times $A_2, B_2, C_2$ with processing times $4, 1, 2$. Next, we also have that we have just one teacher per subject, so subjects must also be disjunct (so e.g. $A_1$ cannot overlap with $A_2$). 

Finally, we have the constraint that the Biology teacher only arrives at $t=2$, and that our day is 7 hours long. 

=== Disjunctive scheduling

You have a set of $N$ tasks with index $i in {0...(N-1)}$, where for each task $i$ there is a processing time $p_i > 0$.

Now we cannot have overlapping times. We have integer variables $s_i$ for each task $i$ that indicates the start time. For each pair $i, j$, we can assign a precedence literal $l_(i, j)$ that has the value true iff $s_j + p_j <= s_i$

Using two implies constraints, we can also say:

$l_(i, j) => s_j - s_i <= -p_j $

For the other way, we would say $s_j + p_j > s_i$, or equivalently $s_j + p_j >= s_i + 1$. Or with lesser than or equals, $-s_j - p_j <= -s_i - 1$. So:

$not l_(i, j) => s_i - s_j <= p_j - 1$

--- 

We have two variables $s_1$ and $s_2$ that cannot overlap. Suppose we know the makespan is less than or equal to some integer $M$. Then a no-overlap constraint $C(s_1, s_2) subset.eq [0, M] times [0, M]$. So we can say $C(s_1, s_2) = {(x, y) in [0, M] times [0, M]: x + t_1 <= y or y + t_2 <= x}$.

---

To represent a NoOverlap constraint using cumulative, you can use a cumulative constraint where the total capacity is 1 and each task uses 1 unit of energy.

=== Cooking

Consider a cooking schedule where one has two stove pits and three dishes to cook, so only two can be cooked at the same time. Consider the case where the three dishes are: _potatoes_ ($A$) _vegetarian schnitzel_ ($V$) and _broccoli_ ($G$). The cooking times are 15, 10 and 5, which we will measure in increments of 5 minutes, so we have that $p(A) = 3$, $p(V) = 2$, $p(G) = 1$. 

We model this using the cumulative constraint, which when decomposed gives us the variables and constraints:

#let cclr = $cc(#raw("leq"))$
#let ccaa = $cc(#raw("act"))$
#let ccas = $cc(#raw("start"))$
#let ccam = $cc(#raw("remove"))$
#let ccres = $cc(#raw("resource"))$

Time is [0, 5] as in the worst case we schedule only one at a time, in which case it would take 6 time units.

- Boolean variables $A_1$ until $A_5$, similar for $V$ and $G$
- Boolean variables $[A <= 1]$ until $[A <= 5]$, similar for $V$ and $G$
- $cal(C)_1$ we will write the clauses $([a <= t] or not [a <= t + 1])$ as $cclr_(a t)$, since that clause enforces the lesser than or equal nature of the atomic constraint variables
- $cal(C)_2$, which each decomposes into the three clauses $(a_t or not [a <= t] or [a <= t - p(a)])$, $(not a_t or [a <= t])$ and $(not a_t or not [a <= t - p(a)])$ as $ccaa_(a t)$, $ccas_(a t)$, and $ccam_(a t)$, respectively, because either we "activate" the activity at time $t$, or based on it being active we ensure it "starts" before, while otherwise we "remove" its activity earlier.
- While in general $cal(C)_3$ is not easy to encode, since in this case the amount of activities is one more than the resource constraint and they all have weight one, for each $t$ we have the clause $(not A_t or not V_t or not G_t)$, which we denote with $ccres_t$.

Let us solve this problem by hand using CDCL.

#let spat = $space @ space$

Every variable starts unassigned and all our clauses consist of at least two variables, so we cannot perform unit propagation. However, note that we can set $[a <= 5] = 1$ for all activities. Unfortunately this does not propagate anything  yet. Let us begin our search by setting $A_0 = 1 spat 1$, where the $@ space 1$ indicates that this was at decision level 1.

Immediately, we can unit propagate the $ccas(A_0)$ clause, deriving $[A <= 0] = 1$, which immediately propagates $[A <= t] = 1$ for all $t$. 

#table(
  columns: (auto, auto, auto),
  inset: 6pt,
  align: horizon,
  table.header(
    [*Time $t$*], [$cclr$ for $A$], $ccres$
  ),
  $ 0 $,
  $ not [A <= 0] or [A <= 1] $,
  $ not A_0 or not V_0 or not G_0 $,
  $ 1 $,
  $ not [A <= 0] or [A <= 1] $,
  $ not A_1 or not V_1 or not G_1 $,
  $ 2 $,
  $ not [A <= 2] or [A <= 3] $,
  $ not A_2 or not V_2 or not G_2 $,
  $ 3 $,
  $ not [A <= 3] or [A <= 4] $,
  $ not A_3 or not V_3 or not G_3 $,
  $ 4 $,
  $ not [A <= 4] or [A <= 5] $,
  $ not A_4 or not V_4 or not G_4 $,
  $ 5 $,
  $ not [A <= 5] or [A <= 6] $,
  $ not A_5 or not V_5 or not G_5 $,
)

#table(
  columns: (auto, auto, auto, auto),
  inset: 6pt,
  align: horizon,
  table.header(
    [*Time $t$*], [$ccaa$ for $A$], [$ccas$ for $A$], [$ccam$ for $A$],
  ),
  $ 0 $,
  $ (A_0 or not [A <= 0]) $, 
  $ (not A_0 or [A <= 0]) $, 
  $  $,
  $ 1 $,
  $ (A_1 or not [A <= 1]) $, 
  $ (not A_1 or [A <= 1]) $, 
  $  $,
  $ 2 $,
  $ (A_2 or not [A <= 2]) $, 
  $ (not A_2 or [A <= 2]) $, 
  $ $,
  $ 3 $,
  $ (A_3 or not [A <= 3] or [A <= 0]) $, 
  $ (not A_3 or [A <= 3]) $, 
  $ (not A_3 or not [A <= 0]) $,
  $ 4 $,
  $ (A_4 or not [A <= 4] or [A <= 1]) $, 
  $ (not A_4 or [A <= 4]) $, 
  $ (not A_4 or not [A <= 1]) $,
  $ 5 $,
  $ (A_5 or not [A <= 5] or [A <= 2]) $, 
  $ (not A_5 or [A <= 5]) $, 
  $ (not A_5 or not [A <= 2]) $,
)

Using column 1 of the second table we see that we can now unit propagate all those clauses to derive $A_1 = 1, A_2 = 1, A_3 = 0, A_4 = 0, A_5 = 0$.

Now we must make another search decision. Let us set $V_0 = 1 spat 2$. We propagate as before, deriving also $V_1 = 1, V_2 = 0, V_3 = 0, V_4 = 0, V_5 = 0$.

Now, the $ccres(0)$ clause propagates, because $not A_0 = 0$ and $not V_0 = 0$, so we get $G_0 = 0$ and similarly $G_1 = 0$. 

== Explanation

Definition 4.6 (eliminating explanation). Let p = {b1 , . . . , bj } be a node in the search
tree and let a ∈ dom(x) be a value that is removed from the domain of a variable x by
constraint propagation at node p. An eliminating explanation for a, denoted expl(x != a),
is a subset (not necessarily proper) of p such that expl(x != a) ∪ {x = a} is a nogood.

== Reified constraints

Given a constraint $C(X)$, a _reified_ constraint introduces an additional variable $b$, whose domain is defined as ${0, 1}$ (a Boolean variable). Then the reified constraint is $R(X union {b}) = {(1, d) : d in C(X)} union {(0, d) : d in D(x_0) times D(x_2) times ... times D(x_n) without C(X)}$. So it is the product of C(X) with {1}, together with the product of {0} with the set of values that are in the domain but do not satisfy the constraint. A reified constraint for C(X) is more often written as $b <-> C(X)$.

As an example, consider the constraint $x <= 3$ with $D(x) = ZZ$. So for $X = {x}$, we write $C(X) = {x in Z : x <= 3}$. Then the reified constraint $b <-> x <= 3$ is ${(1, x) in {1} times ZZ : x <= 3 } union {(0, x) in {0} times ZZ : x > 3}$. Or, written more clearly, the set ..., (1, 1), (1, 2), (1, 3), (0, 4), (0, 5), (0, 6), ... 

== Cumulative constraint

The _cumulative_ constraint describes cumulative resource usage. In the MiniZinc definition @nethercote2007minizinc @minizinc_cumulative_2024, the constraint consists of a set of activities $A$, where for each activity $a in A$ there is a variable start time $s(a)$, a processing time $p(a)$ and a resource usage $r(a)$. There is also a global resource bound $R$. The constraint then requires that at each time, the total resource usage of all activities active at that time is lesser or equal than $R$.

The cumulative constraint can be decomposed according to the _time decomposition_ @schutt2011improving (Ch. 4). 

$ 
cal(B)_1 = {a_t : "activity" a "is active at time" t} \
cal(B)_2 = {[a <= t] : "activity" a "starts before or at" t} \
cal(C)_1 = {[a <= t] -> [a <= t + 1]: "enforce lesser than or equal"} \
cal(C)_2 = {a_t <-> [a <= t] and not [a <= t - p(a)] : "enforce semantics of" a_t} \
cal(C)_3 = { sum_(a in A) r(a) dot a_t <= R : "enforce resource constraint"}
$

For $cal(B)_1$ and $cal(B)_2$, they are defined for every allowed time $t$ and activity $a$, for $cal(C)_1$, $t$ must be strictly less than the final allowed time and it is enforced for every activity $a$. The constraints in $cal(C)_2$ are defined exactly as above for every $a$ when $t >= p(a)$, otherwise the proposition $not [a <= t - p(a)]$ is always true and is omitted. Finally, $cal(C)_3$ is defined for every allowed time $t$. 

Constraints $cal(C)_1$ and $cal(C)_2$ are already propositional and can be readily transformed to CNF. However, the CNF encoding of $cal(C)_3$ is more difficult. For a general approach, we refer to @joshi2015totalizer.



== Arc consistency

Also known as generalized arc consistency, hyper-arc consistency or domain consistency. Let $C(X)$ be a constraint defined on a sequence of variables $X = x_1, x_2, ..., x_n$. The elements of $C(X)$ must be tuples of the form $(d_1, d_2, ..., d_n)$ where $d_i in D(x_i)$. Now consider every $(i, v)$ where $v in D(x_i)$. Then $C(X)$ is arc consistent if for each $(i, v)$, we have that $C(X) sect (D(x_1) times ... times D(x_(i-1)) times {v} times D(x_(i+1)) times ... times D(x_n)) != nothing$.

In other words, $C(X)$ is arc consistent if for each $1 <= i <= n$, we have that for every $v in D(x_i)$ there exists a tuple $(d_1, ..., d_n) in C$ such that $d_i = v$. Definition due to @rossi2006handbook (Ch. 6, Global Constraints).

Again in other words, $C(X)$ is arc consistent if for every variable $x in X$, for every value $v in D(X)$, there exists an assignment that sets that that variable to  such that that assignment satisfies $C(X)$. 

For some more intuition: Suppose there are $n$ variables, each with a domain of exactly size $m$. Then $C(X)$ is arc consistent if we can find $n m$ assignments, where each assignment ($i, j$) s.t. $i <= n$ and $j <= m$ must satisfy $C(X)$ and where the $i$th variable of that assignment is mapped to the $j$th value of the domain of the $i$th variable. To find each assignment, in the worst case we must try $m^(n-1)$ possible values to find one that satisfies one. A full search would thus try $n m^n$ values.

For a particular $v$ and variable $x_i$, such a tuple is called a _support_ for the constraint $C(X)$ (@rossi2006handbook, Ch. 4, Backtracking). Making a constraint arc consistent thus involves removing all unsupported values from the domains of its variables.

// Or reformulated, consider $V = {(i, v) : x_i in X and v in D(x_i)}$. 

As an example, consider the variables $x$, $y$ and $z$, with respective domains ${a, b}$, ${R, S, T}$ and ${psi, phi}$. Then the constraint $C(x, y, z) = { (a, R, psi), (b, S, phi)}$ is not arc consistent. This is because for variable 2, $y$, there is the value $T$ and $(D(x) times {T} times D(z)) sect C(x, y, z) = nothing$, i.e. if we assume $y=T$, there is no way to instantiate $x$ and $z$ to satisfy the constraint. If $T$ was removed, then we _would_ have that $C(x, y, z)$ is arc consistent.

== Forward checking

Forward checking maintains arc consistency on constraints with exactly one uninstantiated variable. Consider a constraint $C(X)$, where the uninstantiated variable is $x_i$. Then arc consistency can be enforced in $O(|D(x_i)|)$, simply by checking all possible values for $x_i$.

== Non-chronological search / backjumping

In @basicsolve, standard chronological search is used. Non-chronological search involves backtracking _more_ than one level. This is called _backjumping_. (according to @rossi2006handbook (Ch. 4, Backtracking) this term is due to J. Gaschnig).



== SAT form of @class

Consider the following SAT representation of the ABC Subject Problem.

We use the following Boolean variables, split into two sets $cal(B)_1$ and $cal(B)_2$:

#let xy_bf(text) = {
  let first_two = text.slice(0, 2)
  let last_two = text.slice(2)
  
  raw(first_two) + raw("_leq_") + raw(last_two)
}

#let leqf = $<= #h(0em) #sub[f] thin$

$ 
cal(B_1) = {[S i leqf Z j ]: "subject" S "for year" i "finish" <= "subject" Z "for year" j} \
cal(B_2) = {[S i <= t ]: "subject" S "for year" i "starts" <= t} \
cal(C_1) = {[S i <= t] -> [S i <= t + 1 ]: "enforce lesser than or equal"}
$

The constraints in $cal(C_2)$ must enforce the no-overlap constraints. Consider the no-overlap constraint between A1 and B1. This can be modeled as:

$
r_1 <-> ("A1" + 3 <= "B1" ) \
r_2 <-> ("B1" + 3 <= "A1")
$

We see that $r_1$ here coincides with our Boolean variable $("A1" leqf "B1")$ in $cal(B)_1$. Considering our Boolean representation of the integers, suppose we consider the case where we know $"B1" <= 4$, as well as the first constraint from above. This is then represented as:

$ ["A1" leqf "B1"] <-> (["B1" <= 4 ]-> ["A1" <= 1]) $

Doing some simplifications by rewriting $->$ and $<->$ using $not$ and $and$, as well as using associativity of $and$ and $or$, we get:

$ not ["A1" leqf "B1"] or not ["B1" <= 4 ] or ["A1" <= 1] "(forward)" $
$ not (not ["B1" <= 4 ] or ["A1" <= 1]) or ["A1" leqf "B1"] "(backward)" $

Manipulating further (remembering that $a or (b and c)$ is equivalent to $(a or b) and (a or c))$:

$ not ["A1" leqf "B1"] or not ["B1" <= 4 ] or ["A1" <= 1] "(forward)" $
$ (["A1" leqf "B1"] or not ["A1" <= 1]) and (["A1" leqf "B1"] or ["B1" <= 4]) "(backward)" $

This gives the 3 clauses:

$ 
not ["A1" leqf "B1"] or not ["B1" <= 4 ] or ["A1" <= 1] \
(["A1" leqf "B1"] or not ["A1" <= 1]) \
(["A1" leqf "B1"] or ["B1" <= 4])
$

But remember we assumed $["B1" <= "4"]$, so if we add that this implies those 3 clauses, we can use the earlier rule as well as the fact that tautologies can be removed to arrive at the following two clauses:

$
not ["A1" leqf "B1"] or not ["B1" <= 4 ] or ["A1" <= 1] \
["A1" leqf "B1"] or not ["B1" <= 4 ] or not ["A1" <= 1] 
$

Now to arrive at all constraints in $cal(C)_2$, consider all variables $[S i leqf Z j]$, and for each such variable every valid pair $[Z j <= t], [S i <= t - p(S i)]$, where $p(S i)$ indicates the length of that class. With valid we mean such that the right hand side is in the interval $[0, 7]$. 

If we return to our variable $["A1" leqf "B1"]$, this would give:

$
["B1" <= 7], ["A1" <= 4] \
["B1" <= 6], ["A1" <= 3] \
["B1" <= 5], ["A1" <= 2] \
["B1" <= 4], ["A1" <= 1] \
["B1" <= 3], ["A1" <= 0]
$

= Interesting background / quotes / other

== Words

*paradigm*: A pattern, a way of doing something, especially a pattern of thought, a system of beliefs, a conceptual framework. (Wiktionary)

*framework*: (figuratively) A basic conceptual structure (Wiktionary)

*combinatorial problem*: 

- Combinatorial problems are those in which the inputs, outputs and states tend to range over *discrete* sets. (Edmund on StackOverflow)
- Combinatorial problems involve finding a grouping, ordering, or assignment of a discrete, finite set of objects that satisfies given conditions. (Hoos & Stützle, Stochastic Local Search, 2005)
- Combinatorial optimization searches for an optimum object in a finite collection of objects. (Schrijver, 2003)
- A combinatorial problem consists in finding, among a finite set of objects,
one that satisfies a set of constraints (Rodríguez-Carbonell, Introduction: Combinatorial Problems, 2024)
- Combinatorial optimization is a subfield of mathematical optimization that consists of finding an optimal object from a finite set of objects, where the set of feasible solutions is discrete or can be reduced to a discrete set. (Wikipedia)

- What is a combinatorial problem: Travelling Salesman Problem
- What is not a combinatorial problem: what is the path of a cannonball that is shot at a specific angle and velocity
- Often NP-hard

== What is the essence of CP?

In the foreword of @baptiste2001constraint, Prof. Peter Brucker said the following:
_"One of the roots of constraint programming is artificial intelligence
where researchers focused on the use of logics and deduction for the
resolution of complex problems. Principles of constraint programming
became precise in the late 1970's and early 1980's. These principles are:
*deduction of additional constraints from existing ones by logical reasoning*, and the *application of search algorithms which are used to explore
the solution space*. Although these principles are very general they have
been most successfully implemented in connection with scheduling problems. Scheduling problems are usually defined by temporal and capacity
constraints which can be formulated explicitly in an easy way. Furthermore, efficient operations research algorithms can be adapted to the
constraint programming framework in connection with scheduling problems. Early success in this area stimulated further research aimed at
the design and implementation of further algorithms embeddable into
constraint programming tools.
Based on these ideas ILOG S.A., a French software company, developed a commercial constraint programming solver and constraint-based
scheduling and vehicle routing systems."_

In 1977, Stallman and Sussman @stallman1977forward (p. 163) wrote _"Our research strategy has been the application of artificial intelligence techniques to the construction of an expert problem solver in a non-trivial domain. [...] We have developed two methods. One is
a method of electrical network analysis we call analysis by *propagation of constraints*.
The other is the technique of *efficient combinatorial search* by dependency-directed
backtracking."_

And in 1996, Mark Wallace says @wallace1996practical (Section 1.1) that the most important features of constraint programming are "declarative problem modelling", "propagation of the effects of decisions" and "efficient search for feasible solutions".

Schutt says the following in his 2011 PhD thesis:
_"In general, a Cp problem is stated as constraint satisfaction problem. Its main
solving principles are well-formulated by Baptiste et al. (2001) as follows.
- Strict separation of deductive methods (constraint propagators) and search
algorithms
- Principle of locality (each constraint must be propagated as much as possible,
independent of the presence or non-presence of other constraints)
- Strict separation between the (logical) representation of constraints and their
propagation agreeing with the Kowalski equation for Logic Programming: Algorithm = Logic + Control (Kowalski 1979)."_

== What makes CP different from Answer Set Programming / SMT solving / SAT / MIP

=== SAT

Clearly, CP allows modelling in a more general form

== Earlier introduction

#note[Following is still unedited from the kick-off meeting text]

The primary topic is "Proof Certification for Constraint Programming (CP)", building on the work currently being done in the Algorithmics group at the TU Delft. This includes the recent paper by Maarten Flippo et al. @flippo2024proof.

Constraint programming is a paradigm or framework often used to solve combinatorial optimization problems. Modern CP solvers, including Pumpkin (which is developed within the Algorithmics group), are increasingly complex pieces of software. They utilize techniques such as Lazy Clause Generation (LCG) to improve performance, but can contain bugs. Furthermore, it is difficult to verify that a problem is indeed unsatisfiable when the solver reports this as being the case.

By logging (part of) the steps it takes, the decision process of solvers can be verified. @flippo2024proof explores this and checks the decisions by encoding them in a pseudo-Boolean format and using a verifier for that format. Currently, the group is exploring the development of a formally verified checker dedicated for CP proofs with native CP reasoning that does not require encoding. There is also work to be done to improve performance and to support more constraints, allowing for stronger reasoning and shorter proofs.

Possible sub-topics:

- Formally verified checker
  - Explore ways to make the proof assistant proofs more legible and more reusable also for additional constraints
  - Alternative frameworks and tools, F\*, Hax
- Support for logging and checking additional constraints
- Pre-process the proof

All of these would improve proof certification in the field of CP, making solvers more robust. This can have many benefits. With greater confidence in solvers, industry users have greater trust in their results and can use them in more circumstances with less risk. Less bugs could mean more focus on productive work to improve solver performance. Overall, this will increase the power of solvers, making more problems tractable. This can have economic benefits, but also societal benefits. More efficient rosters in e.g. hospitals can reduce health care costs.