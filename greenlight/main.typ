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

#let example = thmbox("example", "Example", base_level: 1, inset: (x: 1em, top: 0.6em))

#let theorem = thmbox("theorem", "Theorem", base_level: 1, inset: (x: 1em, top: 0.6em))

#let lemma = thmbox("lemma", "Lemma", base_level: 1, inset: (x: 1em, top: 0.6em))

#let procedure = thmbox("procedure", "Procedure", base_level: 1, inset: (x: 1em, top: 0.6em))

#outline(depth: 3)

#import "@preview/showybox:2.0.3": showybox

#[
  #set heading(numbering: none)
]

#let numbered(c) = {
  [
    #set math.equation(numbering: "(1)")
    #c
  ]
}

```
Planning:
1. Finish the main human-readable proofs in the writing (not much work)
2. Finish the "Implementation considerations" sections in the results, which will go into more detail about important implementation details and lessons learned from them. (end of this week)
3. Add a section about the process of developing these proofs, most likely in the discussion (it therefore wouldn't really be the main "result" of my thesis, as I think the domain reasoning theory and the actual proofs are enough, but would like to hear your opinion). This part I expect to form the bulk of the work.
4. Discussion about the proof results/developments
5. Rewrite the preliminaries to only contain information relevant for the rest of the thesis. 
6. Rewrite the introduction
7. Improve the structure and readability. Currently, it's almost entirely text. Graphics and clearer separations and highlighting important parts (through boxes or other measures) could improve this. Furthermore, based on Benedikt's advice (I had a meeting with him a few week back) I want to link each human-readable lemma to the corresponding formal proof/code. I also need to figure out better syntax highlighting for the pseudocode.

Planning:
1-3 July 16
4-6 July 22 first full draft!

In the third week I would then finish 4/5/6 up to the point that there is a rough draft of the full document, which I would like to discuss the week after. Hopefully, by the 24th of July I then have a version that is greenlightable. I will be away the next week on vacation if indeed that goal is achieved. Hopefully we can have the actual greenlight meeting in the first week of August, after which I will prepare my defense and work on point 7 so that I can hand in the final version when you return and have the defense in the first week of September (or second depending on the exact timing). If you think this is realistic, I would like to already set a tentative date for the defense that I can share with close friends and family, to increase the likelihood of them being able to attend.
```

= Introduction

What are my results:
- Formally verified implementations of inference checking algorithms for two popular CP constraints + human-readable proofs; basically: conflict checking
- Precise language for what verifying these things actually mean
- Perforated intervals: theory and formal verification
- Formally verified method for tracking domains 

Research question?

From higher-level to lower level
+ How can we increase the confidence in optimality and infeasibility results in constraint programming solvers?
  - By logging solver decisions and developing a proof format
+ How do we develop a proof format?
  - By mimicking how SAT solvers work and adapting it to how LCG solvers work
+ How can we check a constraint programming infeasibility proof (of particular type)?
  - By converting it to pseudo-boolean, ...
  - or: by building a checker that uses native constraint programming reasoning
+ How can we ensure that the checker itself makes no mistakes?
  - By formally verifying it?
+ How do we formally verify it?

Research question: How can we formally verify inference checking of constraint programming constraints?

Research question: How difficult is it to develop and prove the soundness of checking algorithms in a constraint programming unsatisfiability proof checker for particular constraints?

*What methods can simplify the development of checking algorithms in a formally verified constraint programming infeasibility proof checker?*
Answer: a data structure that can track domains and efficiently update them based on a collection of atomic constraints.

What data structure can be used to track domains in the deduction step of a constraint programming unsatisfiability proof checker?

What data structure can track domains given atomic constraint updates?

Which methods can simplify supporting additional constraints in a formally verified unsatisfiability proof checker for constraint programming?

#note[This is still mostly unchanged from the 'Proposal' from the first stage review version.]

Constraint Programming (CP) solvers are complex pieces of software. Their complexity is two-fold: speed matters, so they are heavily engineered to solve problems as fast as possible. Furthermore, there is an inherent complexity to the algorithms and theoretical techniques used to find solutions. Consequently, they have a large surface area for bugs. Checking satisfiable instances is not difficult, but checking whether unsatisfiable instances are indeed unsatisfiable is more challenging. Proof logging, which can produce unsatisfiability proofs, offers a way to increase solver reliability as also UNSAT answers can be verified to be indeed UNSAT. Analagously to the DRUP format from SAT solvers (see @biere2021handbook, Ch. 16 for a detailed overview), previous @flippo2024proof and ongoing @sidorov2025checker work has introduced a proof format where both inferences and nogoods are represented as clauses of atomic constraints, as well as a checker @sidorov2025checker to verify this format. Lazy clause generation (LCG) solvers can be easily instrumented to produce these proofs, as their learned clauses are valid proof steps. In the format, each clause $cc$ can be checked by verifying whether it satisfies $K and not cc ->$ $bot$, where $K$ is the knowledge base of all previously verified steps as well as the model. In CP, there are many different constraints and propagators and the checker must be able to derive a conflict where the solver derives a conflict, i.e. it must reason just as strongly. This requires supporting many constraints in the checker. The checker is more reliable than the solver not just because it is simpler, as e.g. it does not have to do search, but also because it is formally verified, in Roqc (formerly Coq). That is why we call what the checker does _proof certification_. To support a constraint in the checker, this requires, for each constraint, the following:


= Background


#let jmono(c) = {
  set text(font: "JetBrains Mono", size: 8pt) 
  // zero-width joiner adds linebreak opportunity
  show "_": "_" + sym.zws
  [#c]
}

#let spro(c) = {
  set text(font: "Source Code Pro", size: 9pt, style: "italic")
  show "_": "_" + sym.zws
  [#c]
}

#let fact = jmono[fact]
#let assgn = jmono[assignment]
#let checker = jmono[cumulative_checker]
#let truev = `true`
#let premises = jmono[premises]
#let consq = jmono[consequent]
#let dlb = spro[lb]
#let dub = spro[ub]

#let ttrue = raw("true")
#let ffalse = raw("false")

#let boolatom(content) = {
  $bracket.double #content bracket.r.double$
}

#let start = jmono("start")
#let lower = jmono("lower")
#let upper = jmono("upper")
#let bounds = spro("bounds")
#let duration = jmono("duration")
#let resprofile = spro("profile")
#let capacity = jmono("capacity")
#let usage = jmono("usage")

== Constraint Programming

We begin with a formal treatment of constraint programming. We adhere closely to the classical definitions (as found in e.g. @rossi2006handbook), clearly indicating when we deviate from them.

#definition[
  A _domain_ $D$ is an $n$-tuple $angle.l D_1, D_2, ..., D_n angle.r$ that corresponds to an $n$-tuple of variables $X = angle.l x_1, x_2, ..., x_n angle.r$ such that the $i$th domain is the set of values that the $i$th variable is allowed to take. We also write, for $x in X$, that $D(x)$ is the set of all values that $x$ can take. 
]

It is common to work with finite domains, because a complete solver can then be constructed using a simple backtracking procedure. Most practical solvers also require this, but for our purposes this is not important. In fact, the primary domain representation introduced in this work supports infinite subsets of $ZZ$.

#let Dcross = $D_times (X)$

#definition[
  Given variables $X = angle.l x_1, x_2, ..., x_n angle.r$ and associated domain $D$, then a _constraint_ $C(X)$ is a subset of the Cartesian product $D(x_1) times D(x_2) times ... times D(x_n)$. This set corresponds to the set of feasible solutions when looking only at this constraint and its associated variables.
] <def:constraint>

As the above definition states, we consider only finite sets of variables for any particular problem. When solving physical problems, this is not a real restriction.


#definition[
  A _Constraint Satisfaction Problem_ (CSP) consists of variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$, domains $cal(D) = angle.l D_1, D_2, ..., D_n angle.r$, such that for each $x_i in cal(X)$, $D_i$ is the set of values that variable can take (we also write $cal(D)(x_i)$ to refer to $D_i$), and a set $cal(C)$, where each $C(X) in cal(C)$ is a constraint defined for a tuple of variables $X subset.eq cal(X)$. The triple ($cal(C)$, $cal(X)$, $cal(D)$) defines the CSP.
]

Without loss of generality, given a tuple of variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$, when we refer to a tuple $X subset.eq cal(X)$, we assume the variable ordering is identical in $X$ and $cal(X)$. Formally, $X = angle.l x_a_1, x_a_2, ..., x_a_k angle.r$, where we require that $a_1, a_2, ..., a_k$ is a subsequence of $1, 2, ..., n$.

#definition[
  For variables $cal(X) = angle.l x_1, x_2, ..., x_n angle.r$ and a domain $D$, an _assignment_ $v$ is an  $n$-tuple of values $angle.l v_1, v_2, ..., v_n angle.r$, where $v_i in D(x_i)$. Such a $v$ is said to be _consistent_ with respect to $D$. Consider some variables $X subset.eq cal(X) = angle.l x_a_1, x_a_2, ..., x_a_k angle.r$, then $v(X)$ is the $k$-tuple $angle.l v_a_1, v_a_2, ..., v_a_k angle.r$. An assignment $v$ _satisfies_ a constraint $C(X)$, where $X subset.eq cal(X)$, if $v(X) in C(X)$. 
] <def:assignment>

#definition[
  An assignment $v$ is a _solution_ to a CSP $(cal(C), cal(X), cal(D))$ if for all $C(X) in cal(C)$, it holds that $v(X) in C(X)$, i.e. the assignment satisfies all constraints.
]

We call a CSP satisfiable if there exists at least one solution. A solution then serves as a certificate for the satisfiability claim of a CSP. Checking whether the claim holds only requires checking whether the solution satisfies every constraint. This is not a hard problem.

A more general problem is the _Constraint Optimization Problem (COP)_, which includes additionally an objective function that must be either minimized or maximized. Suppose we have such a COP, which consists of a CSP $(cal(C), cal(X), cal(D))$ and an objective function $f(cal(X))$. We can verify optimality by first checking that the optimal solution with objective $p^star$ satisfies the underlying CSP and second by determining that the underlying CSP with the addition of the constraint $f(cal(X)) > p^star$ (or $<$ in the case of a minimization problem) is unsatisfiable. For this reason, we will now concern ourselves only with CSPs and infeasibility and will often use the term "CP (Constraint Programming) problem" to refer to a CSP.

We now provide a few simple examples to show how the earlier definitions work.

#example[
  Consider the variables $angle.l x, y, z angle.r$, with domains $D(x) = [0, infinity)$, $D(y) = [-20, 3]$ and $D(z) = {2, 8}$ The constraint $x + z <= 20$ is then the set $C(x, z) = {(x, z) in [0, infinity) times {3, 8} : x + z <= 20}$. Let an example assignment be $angle.l v_1 = 90, v_2 = 2, v_3 = 8 angle.r$. This assignment does not satisfy $C(x, z)$, as we have that $(90, 8) in.not C(x, z)$ (since 90 + 8 $lt.eq.not$ 20). However, the assignment $angle.l v_1 = 12, v_2 = -17, v_3 = 8 angle.r$, _does_ satisfy $C(x, z)$. 
] <ex:asgndom>

#example[
  Consider the same variables and domains as in @ex:asgndom, as well as the constraint $C(x, z)$. Now, the constraint $C(y)$ is defined as ${y in [-20, 3] : y != 0 }$. Then $cal(P)$ as $({C(x, z), C(y)}, X, D)$ is a CSP. Furthermore, the assignment $angle.l v_1 = 12, v_2 = -17, v_3 = 8 angle.r$ is a solution to the CSP.
]

When domains are finite, practical CSP solvers will eventually enumerate all solutions. However, they speed up this process by also interleaving search with reasoning that makes use of the problem's structure. This reasoning is called _propagation_ or _filtering_ and cuts off parts of the search space that cannot be part of any feasible solution. This happens by explicitly pruning the currently stored domains. 

Furthermore, in practice, solvers do not accept constraints of arbitrary form. Instead, they support a finite collection of constraint types, each with known rules for determining whether a particular assignment satisfies it. Frequently, these constraints also have a particular structure that allows tightening the domains of variables involved in the constraint without having to evaluate every possible assignment. With this in mind, we can restrict our definition of constraints in a way that makes them useful to solvers: 

#definition([Constraint [restricted]])[
  A _constraint_ is a computable function that, given an assignment of variables, spits out whether the constraint is satisfied or not. Hence, if we have $n$ variables involved in the constraint over a universe $UU$ (which in our case is generally $ZZ$), a constraint is a function $UU^n -> {ttrue, ffalse}$.
]

Given a constraint function $c(v)$, we can create an instance of the previous definition by considering the set ${v : c(v) = ttrue}$. Furthermore, if we want to be able to efficiently verify whether an assignment satisfies the constraint, we expect the constraint function to terminate in polynomial time.

We now discuss two examples of constraints that are used to model a variety of problems. Furthermore, we discuss what type of propagation can be performed when solving CP problems. The examples also serve to highlight different categories of propagation.


#let algo_keywords = _algo-default-keywords + ("match", "with", "case", "lambda", "def", "continue", "enum")

#show: thmrules.with(qed-symbol: $square$)
#let proof = thmproof("proof", "Proof")

== Alldifferent <sec:prelim:alldiff>

We first introduce a very simple constraint that requries each variable to take on a distinct value.

#definition[
  Given $n$ variables in $X$ and associated domains $D$, the _alldifferent_ constraint is defined as ${(v_1, v_2, ..., v_n) : forall i, j "s.t." 1 <= i, j <= n, "it holds that" v_i != v_j "and" v(i) in D(x_i) }$.
]

Particular algorithms used to prune domains for a particular type of constraint are known as _propagation algorithms_. We will not discuss the exact requirements for an algorithm to qualify as a propagation algorithm, as for our purposes we need only to understand they map domains to domains. We refer to @schulte2009weakmonotonprop and @rossi2006handbook (§14.1.1) for details.

As alldifferent is a popular and simple constraint, there are many different propagation algorithms (see e.g. @downing2012explainalldiff for algorithms for modern CP solvers and the earlier @vanhoeve2001alldifferent for a broad survey). Propagation algorithms can be differentiated not only by their time complexity, but also by their propagation strength. The following section will introduce a way to characterize this, called _local consistency_.

=== Local consistency

Consider the following example.

#todosm[Figure out good notation for constraint names.]

#example[
  Let $C = $ _alldifferent_($x, y, z$), $D(x) = {2, 3}, D(y) = {2}, D(z) = {2, 5}$. Then, because $y$ can only ever be 2, we have that $x$ and $z$ cannot be. #todo[Finish]
]

The propagation removed a number of inconsistent values from the domain. In fact, we can now say the domain has reached a certain level of _local consistency_, where local indicates we are speaking only of consistency with regards to this one constraint (local) as opposed to the entire problem (global). This specific level of consistency is often known as _bounds$(ZZ)$ consistency_. Loosely, this means every integer value in between the lower and upper bound of each variable domain is part of a solution containing only integers that fall between the upper and lower bounds of the domain of their respective variable. We can define this formally as follows (where we assume the domains are all integer):

#definition[
  An integer domain $D$ is _bounds$(ZZ)$ consistent_ with respect to a constraint $C(X)$ if we have that $forall x_i in X$ and $forall d_i in [min(D(x_i)), max(D(x_i))]$, there exists an assignment $v = angle.l d_1, d_2, ..., d_i, ..., d_n angle.r$ that satisfies $C(X)$ such that $d_j in [min(D(x_j)), max(D(x_j))]$, for all $j != i$.
]

There exist polynomial-time propagation algorithms for alldifferent that can achieve this level of consistency. This is not the case for every constraint, since such an algorithm existing for the next constraint we discuss, cumulative, would imply $P = N P$. However, for alldifferent we can actually do even better. The strongest possible form of local consistency is known as domain consistency, which we illustrate in the next example by giving a particular way to determine more inconsistent values.

#example[
  #todo[Finish]
]

We now give the formal definition of domain consistency. It can be interpreted as requiring that if we fix a variable to some arbitrary value in its domain, there exists at least one assignment satisfying the constraint.

#definition[
 A domain $D$ is _domain consistent_ (also known as generalized arc consistent or hyper-arc consistent) with respect to a constraint $C(X)$ if $forall x_i in X$ and $forall d_i in D(x_i)$, there exists an assignment $v = angle.l d_1, d_2, ..., d_i, ..., d_n angle.r$ that satisfies $C(X)$ such that $d_j in D(x_j)$, for all $j != i$.
]

We have so far followed the standard literature on CP, in which propagation algorithms are described as functions mapping domains to domains. This is a useful in particular for solvers, as at any given time they track the current domains of all variables, which are then dispatched to several propagation engines for filtering. Verifying their correctness, which in the end is our goal, would then involve verifying the correctness of this function. This is a difficult task, in particular if this function is heavily optimized. Instead, we seek to verify the output of these propagators. In order to do this, we need a way of representing such outputs using formal statements, which is an important step in order to verify them.

=== Formal description of propagation outputs

We now illustrate in an example how such an output could be described by a simple logical statement, which we could then verify.

#example[
  Consider a propagation algorithm $p$ for an alldifferent constraint $C({x, y, z})$ that maps the input domain $D(x) = {3, 4}, space D(y) = {3, 4}, space D(z) = {3, 4, 5}$ to $D'(z) = {5}$ (where the domains for $x$ and $y$ remain unchanged). Remember that this is because assigning $z$ to 3 or 4 would mean there are not enough possible values for $x$ and $y$. However, if the domains for $x$ and $y$ were different, this might not be valid. 

  To verify this particular reasoning, we want to establish a logical statement representing that, given the particular domains for $x$, $y$ and $z$, we know for sure that $z$ cannot be 3 or 4 if we also want them to satisfy $C$. The natural way to represent this is in an implication, where the premises include the initial domains and the constraint being satisfied and the right-hand side containing what we can then conclude.

  To write this formally, let $c: ZZ^n -> {ttrue, ffalse}$ such that it returns $ttrue$ when the constraint is satisfied for a particular assignment of $n$ variables. Then, since a propagation algorithm filters based on the fact that solutions must satisfy the constraint, we can consider as a premise $c(x, y) = ttrue$. Then, we could write something like:
  
  
  $ c(x, y, z) = ttrue and x in D(x) and y in D(y) and z in D(z) -> z != 3 and z != 4 $

  On the right-hand side, we have used the predicate "$z != c$"". We will also write the domains using such predicates, but then including also the relations $=, <=, >=$. These predicates play a fundamental role in our approach and we will write them as $[x diamond.small c]$, where $diamond.small in {<=. >=, =, !=}$. Furthermore, we will not include $c(x, y) = ttrue$ in the statement, leaving this as an implicit requirement.   This gives us:

  #numbered[
  $ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z >= 3] and [z <= 5] -> [z != 3] and [z != 4] $ <eq:genfact>
  ] 

  #todosm[give number and use below]

  We call the above a _generalized fact_, to distinguish it from a more precisely defined notion of _fact_ that we introduce later. #todosm[Link to where we define it]
] <ex:geninf>

An important property of the above facts is that, as implications, they can be converted to equivalent logical statements with an empty right-hand side, i.e. a fact $p -> q$ is equivalent to $p and not q -> bot$ (where $bot$ indicates conflict or contradiction). @eq:genfact would then be written:

#numbered[
  $ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and ([z = 3] or [z = 4]) -> bot $ <eq:genfactconfl>
]

This is clearly valid, since when $z = 3$ or $z = 4$, the constraint cannot be satisfied and our implicit premise $c(x,y,z) = ttrue$ is falsified. However, the left-hand side now contains nested structure and both $and$ and $or$ connectives. Instead, consider that facts of the form $p -> q_1 and q_2 and ... and q_m$ are equivalent to a series of facts $p -> q_1$, $p -> q_2$, ..., $p -> q_m$. Hence, verifying @eq:genfactconfl is reduced to verifying the below facts:

#numbered[
$ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z = 3] -> bot \
 [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z = 4] -> bot $ <eq:genfactmulti>
]

Here, we have a very simple structure on the left-hand side, which is simply a specification of a particular domain. During verification, it must then be established that this particular domain would admit no solution. This is often easier than exactly replicating the same right-hand side. In particular, consider the following example:

#example[
  #todosm[finish]
]

Now, in practice it is not expected that the conversion of @eq:genfactconfl to @eq:genfactmulti happens during verification. Instead, facts such as @eq:genfact should be rewritten into multiple facts, each with only a single consequent. This allows us to now define a strategy for verifying propagator reasoning. First, we formally define the predicates mentioned first in @ex:geninf to denote domains.

#definition("Atomic constraints")[
  An _atomic constraint_ is predicate $[x diamond.small c]$, where $x$ is an integer variable, $c$ an integer constant and $diamond.small$ a relation in ${<=, >=, =, !=}$.
]

We can now define our general strategy for verifying propagator reasoning.

#todosm[Probably should not really be a 'definition', clearly indicate it some other way]
#procedure("Propagator verification strategy")[
  To verify a propagation of a propagator $p$ for a constraint $c$ that maps domains $D$ to $D'$, we use the following strategy:
  1. Write the domains $D$ as a conjunction of atomic constraints. We overload $D$ by denoting this conjunction also by $D$.
  2. Write $D'$ as a similar conjunction of atomic constraints $d'_1 and ... and d'_l $, such that $D and d'_1 and ... and d'_m$ represents exactly $D'$. Then, we have a generalized fact $D -> d'_1 and ... and d'_m$ (for this to logical statement to be true, we implicitly assume the constraint $c$ to be satisfied#footnote[In the SMT literature we would call this making $c$ part of the 'background theory'])
  3. Separate $D -> d'_1 and ... and d'_l$ into separate facts $D -> d'_1$, $D -> d'_2$, ..., $D -> d'_m$.
  4. Verify a fact $D -> d'$ by assuming $D and not d'$ (which represents just another domain) and deriving that $c$ can then not be satisfied, i.e. $D and not d' -> bot$. For this, we need a function $V$ that can determine whether a domain admits any solutions (given a particular consraint has to be satisfied).
] <def:verifystrat>

This will be the primary strategy through which we verify the specialized reasoning of propagators for particular constraints. This approach has many benefits, as many practical CP solvers can readily generate such facts. To see why, see the section on proof logging. #todosm[link] @def:verifystrat builds upon previous work in two ways. First, consider the SAT problem, which is exactly a CSP but with Boolean variables and with constraints consisting of Boolean formulas (variables connected by $and$, $or$ and $not$). The SAT community pioneed RUP clauses (reverse unit propagation) @gelder2008rup @goldberg2003unsatcnf, which are also verified by negating the consequent and then deriving a conflict. This was brought to the more general CP context previously also by the unpublished work in @gange1certifying.

Now that we have a general verification strategy, we must determine how to construct the function $V$ in step 4 of @def:verifystrat. This will be discussed in the next section.

=== Alldifferent conflicts

We seek a way to, given some domain (represented as a conjunction of atomic constraints), determine whether a constraint is unsatisfiable. In the case of alldifferent, there is a powerful theorem (originally by Hall @hall1935representatives, formulated also in @vanhoeve2001alldifferent) that tells us exactly when alldifferent admits a solution.

#theorem("Hall")[
  Let $C(X)$ be an alldifferent constraint over the variables $X$ and let $D$ be their associated domain. Then there exists an assignment $v(X)$ that satisfies $C$ if and only if for every $K subset.eq X$, we have that $|union.big_(x in K) D(x)| >= |K|$.
]

In other words, if there is no solution given a particular domain $D$, then there must exist some subset of variables such that the union of the domains of all these variables is strictly smaller than the number of variables in this subset. Note that we used exactly this principle in e.g. @ex:geninf to derive a conflict. However, this theorem states that in fact _every_ conflict implies the existence of a subset of variables with smaller domain. This, combined with the fact that the required check to determine whether a subset $K$ is conflicting is very cheap, gives rise to a promising verification algorithm in the case that $K$ is known. First, we formally define the set we are interested in separately from the theorem's statement.

#definition("Tight Hall set")[
  Let $C(X)$ be an alldifferent constraint over the variables $X$ and let $D$ be their associated domain. Then we call a $K subset.eq X$ a _tight Hall set_ if $|union.big_(x in K) D(x)| < |K|$.
]

In using the term _tight Hall set_ we follow the terminology of @vanhoeve2001alldifferent. 
To find a tight Hall set given a fact $F$ (and hence a supposedly conflicting domain $D_F$), we can use the same procedure as that used by domain-consistent propagation algorithms for alldifferent. Since we have not implemented this, we give only a summary. The procedure makes use of graph theory, which we will not describe in detail. This algorithm is originally due to Régin @regin1994alldiff and we refer also to @vanhoeve2001alldifferent for more details.

#procedure("Find conflicting subset")[
  1. Determine a maximum matching $M$ on the bipartite graph $G=(X, V, E)$, where $X$ is the set of variables, $V$ is the union of the domains $D$ of the variables in $X$ and $x v in E$ if $v in D(x)$. This matching can be obtained by e.g. Hopcroft-Karp @hopcroft1973maxmath.
  2. If the maximum matching $M$ does not cover $X$ (if it does, then there is no conflict), let $K$ be the set of variables reachable from the unmatched variables through $M$-alternating paths (this can be found through e.g. breadth-first search). Then $K$ is a tight Hall set.
]

We now move on to a different constraint, which does not have a powerful tool like Hall's theorem.

#pagebreak()

== Cumulative <sec:prelim:cumulative>

The next constraint, called _cumulative_ @aggoun1993cumulative, is frequently used in scheduling problems and its language also reflects this. We first state its MiniZinc definition @nethercote2007minizinc @minizinc_cumulative_2024.

#definition[
  A _cumulative_ constraint consists of a set of activities $A$, where for each activity $a in A$ there is a variable start time $start(a)$, a processing time $duration(a)$ and a resource usage $usage(a)$. An activity $a$ is _active_ at time $t$ if $start(a) <= t < start(a) + duration(a)$. There is also a global resource bound $R$. The constraint then requires that at each time, the total resource usage of all activities active at that time is less than or equal to $R$.
]

What makes cumulative very different from alldifferent is that determining whether a single cumulative constraint has a solution is already NP-hard. In fact, if we had a polynomial time propagator that achieves bounds($ZZ$)-consistency, this would imply $P = N P$ @baptiste1999satcumul. Let us state an example of a cumulative constraint.

#example[
  #todosm[]
  // Consider a situation with a cooktop with two heating elements, as well as a number of ingredients that must be cooked on a stove. Therefore, only two ingredients can be cooked at the same time time. Furthermore, each ingredient takes a specific amount of time to cook. The processing times will be measured in increments of 5 minutes. We have the following ingredients: _potatoes_ ($P$) _vegaburger_ ($V$) and _broccoli_ ($B$), as well as two garnishes, _onion_ ($O$) and _garlic_ ($G$). This gives us a cumulative constraint where $A = {P, V, B, O, G}$, $p(P) = 3$, $p(V) = 2$, $p(B) = 1$, $p(O) = 1$, $p(G) = 1$ and $R = 2$.
] <ex:cum>

Since we cannot hope for efficient propagation algorithms that achieve any standard form of local consistency, instead we can look at some propagation algorithms for cumulative that achieve weaker filtering. One of the most important cumulative propagation algorithms is _timetable_, which has $O(n^2)$ @letort2012scalesweep and $O(n log n)$ @ouellet2013cumulative implementations. However, it has rather weak propagation strength. One of the strongest practical propagation algorithms is _energetic reasoning_ @erschler1990energy @baptiste1999satcumul. However, it suffers from a high time complexity, $O(n^3)$. Consequently, it is not implemented in many modern solvers. We therefore focus on timetable propagation here, as it has been more succesful in practice. For a treatment of cumulative propagation in the context of modern CP solves, we refer to @schutt2011improving.

Similarly to alldifferent, to verify inferences we must study the type of conflicts that can occur when writing timetable propagations $D -> d$ as $D and not d -> bot$. 

// We seek to build a formally verified checker for inferences made with cumulative timetable reasoning. The goal is to verify facts (in particular: inferences) of the form $a_1 and a_2 and ... a_n -> q$, where $a_1$, $a_2$, ..., $a_n$ and are atomic constraints and $q$ is either $bot$ or also an atomic constraint. Since such a fact is logically equivalen to $a_1 and ... and a_n and macron(q) -> bot $ no matter what $q$ is, this reduces to verifying whether the domain implied by $a_1 and ... a_n and macron(q)$ is incompatible with the constraint being satisfied. This is equivalent to assuming a solution exists that satisfies this domain and satisfies the constraint, and then showing this implies a logical contradiction (a "conflict").

// The checker is then a function that takes a fact and a constraint and returns `true` if it can deduce a conflict. We therefore list the possible types of conflicts that can be found using timetable reasoning. This is followed by the main idea of the checker, a detailed study of the algorithm and a proof sketch that aims to highlight the most important parts of the formal proof. This formal proof shows that, if the checker returns `true`, then the inference is indeed valid. Finally, we discuss some design considerations related specifically to the implementation in the Rocq interactive theorem prover.

=== Timetable conflicts

First, note that given an activity $x$ with processing time $duration(x)$ with starting time variable $start(x)$ with domain $[lower(x), upper(x)]$, then for times $t$ s.t. $upper(x) <= t < lower(x) + duration(x)$, we know that $x$ is active. This can be derived by observing that an activity is active at times $start(x) <= t < start(x) + duration(x)$ and then using the bounds. We say that for such $t$, activity $x$ is _mandatory_ (also known as _compulsory_). We also define the _resource profile_: which for each time $t$ is defined as the sum of the usages of all activities that are mandatory at that time. Reasoning about when activities are mandatory, two types of conflict can be identified. Each respond to a feature of timetable propagators, so we first describe the basic procedure. Note that more optimized versions exist, but we describe only the simplest form, which also forms the basis of our verification algorithm.

#procedure[
  1. Given a constraint $C$ with activities $A$, determine the constraint horizon, which is $[min_(a in A)lower(a), max_(a in A)upper(a)]$.
  1. Compute the resource profile for each time in the horizon, which gives a function $P$ that maps times to the remaining capacity at that time after subtracting the usage of each activity that is mandatory at that time. Let $M(t)$ be the set of activities mandatory at $t$, then $P(t) = R - sum_(x in M(t)) usage(x)$.
  2. For each time in the horizon, check whether $P(t) < 0$, if it is, report the fact $D(A) -> bot$, where $D(A)$ represents the domains of all activities in $A$. 
  3. For each activity, check 
]

The fundamental conflict concerns only a single time $t$: Suppose we have a cumulative constraint $C$ with capacity $capacity(C)$ and activities $x, y, z$ in that constraint that are mandatory at some time $t$. Then if the usages $usage(x) + usage(y) + usage(z) > capacity(C)$, there is a conflict. This conflict corresponds to the _conflict check_ step performed by timetable propagators. 

Derived from this fundamental conflict are _activity conflicts_: consider the same constraint $C$, with the same condition on the usages. Then the three activities cannot be active at the same time. Consider now that $y$ and $z$ are mandatory at all times $lower(x) <= t <= upper(x)$. That means that, no matter where $x$ is scheduled to start between its upper and lower bounds, the capacity would be exceeded. Therefore, this also means there is a conflict. In a more general case with more activities, there could be different activities mandatory at different times. Activity conflicts can also be seen as follows: there is an activivity conflict if scheduling $x$ at any time within its bounds would cause a time conflict. Activity conflicts correspond to the actual propagation performed by timetable propagators. To see this, we describe the 


We note that a time conflict implies an activity conflict for all involved activities at that time. To see why, note that an activity being mandatory at a time $t$ means that no matter at what time it is scheduled exactly, it will be active at $t$. But we know that the other activities are mandatory at $t$ (since we had a time conflict), so no matter where we schedule the activity, there would be a time conflict at $t.$ However, in the case of an activity conflict, it is not necessary for the capacity to be exceeded at any specific time $t$. 

A reason for differentiating between activity and time conflicts, despite the fact that a time conflict implies an activity conflict, is that each require a different type of certificate to check. A time conflict only requires a time $t$, after which it can check which activities are mandatory at that time and determine if the capacity is exceeded. However, an activity conflict, given an activity $x$, must check for all possible starting times of $x$ that it cannot be started there.

We have now discussed the two types of conflicts. In practice, the type of reasoning done to determine the existence of an activity conflict is actually the reasoning done for propagation. Such propagations, when their right-hand side is negated and added to the left-hand side of the inference, take the form of an activity conflict. #todosm[Interesting to prove this?] The following example highlights this fact.

#example[Consider a constraint $C$ with variables $x$ and $y$, $capacity(C) = 1$ and all usages equal to 1. Let $start(y) in [1, 10]$ and $duration(y) = 2$. Next, let $start(x) in [0, 2]$ and $duration(x) = 4$. Then, $x$ is mandatory at $t = 2$ and $t = 3$. $y$ is nowhere mandatory. $y$ cannot start at $t = 1$, since then it would also be active at $t = 2$, which would conflict with $x$. Similarly, it cannot be active at $t = 2$ or $t = 3$. Therefore, $y >= 4$ would be a valid propagation. If we represent this as a fact, this would be $[x >= 0] and [x <= 2] and [y >= 1] and [y <= 10] -> [y >= 4]$. Then, the logically equivalent conflict form would be: $[x >= 0] and [x <= 2] and [y >= 1] and [y <= 3] -> bot$ (after removing the redundant upper bound for $y$). There is no time conflict, because $y$ is still nowhere mandatory. However, this _is_ an activity conflict, since for all $1 <= t <= 3$, scheduling $y$ at those times would cause a conflict.]

#todo[We could highlight a number of propagation algorithms in the literature and show that this really holds for them. Or we could try to really formally define what 'timetable reasoning' really is.]

Now that we know the types of conflicts our checker should find, we discuss the main idea of the checker.

#pagebreak()

== Constraint Programming proof system

The CP proof system considered in this thesis, described in detail in @sidorov2025checker #todosm[if it is published], works as follows:

#definition[
  A fact is an implication defined by its #premises and $consq$. For a fact $omega$, $premises(omega)$ is a list of atomic constraints. $consq(omega)$ is a single atomic constraint, or it is empty.
]

#definition[
  Let $omega$ be a fact and $A$ an assignment. Then $omega$ is _valid_ for $A$ if whenever all atomic constraints in $premises(omega)$ hold for $A$, we have that the $consq(omega)$ holds, i.e. $premises(omega) -> consq(omega)$.
]

Within a CP proof, we distinguish two types of fact, _inferences_ and _nogoods_. Nogoods always have an empty consequent, so their premises holding would imply a contradiction. Inferences can have both empty and non-empty consequent and are only ever used to justify nogoods. Furthermore, inferences can refer to constraints in the model (or previously established nogoods) and are justified using an _inference rule_, which provides the information necessary on what reasoning to use to justify them. Inferences are never reused, they are only used for a single nogood justification. This nogood justification is called _deduction_.

=== Deduction step <sec:prelim:deduct>

Nogoods are deduced using inferences. Those inferences are all checked individually before they are passed to the deduction step. The deduction step assumes the inferences are in the precise order that allows justifying the nogood. The deduction then proceeds as follows:

1. Assume the atomic constraints in the premises of the nogood hold.
2. Go to the next inference. If, based on the premises in the nogood and previously assumed atomic constraints, the inference's premises hold, assume the inference's consequent holds. If it is empty, the nogood is valid.
3. Check whether all assumed atomic constraints imply a contradiction. If they do, the nogood is valid. Otherwise, proceed to step 2. If there are no further inferences, the nogood cannot be validated.

Here, "assuming an atomic constraint holds" indicates the information in the atomic constraint must be, somehow, remembered. Furthermore, in order to apply an inference, all its premises must be checked to see if they are satisfied by the current set of assumed atomic constraints. In order to do this efficiently, a domain is tracked for each variable. Assuming an additional atomic constraint involves updating the domain. The domain is represented in a way that makes this process efficient and does not require explicitly listing all values in the domain. Therefore, a holes-based representation is used, where a domain consists of an lower and upper bounds and a set of holes (values the variable cannot take). The domain can be open on both or one side by allowing the lower and upper bounds to take on values representing infinity and negative infinity. This is done not only because constraints are applied one at a time and to represent the initial state where every value is possible, but also because in the case of e.g. linear inequalities, constraints can be falsified even if a variable is only bounded on one side. 

=== Inference checking <sec:prelim:inf>

As mentioned, each inference in the proof is checked according to some inference rule. An inference may therefore also refer to one or more constraints in the model. The main focus of this thesis is how to check these inferences. An inference is a fact and to verifying it is justified by the model involves verifying that, for an inference $I$, $premises(I) -> consq(I)$ is logically implied by the model. To illustrate this, first an example using the cumulative constraint frequently used in scheduling. The constraint is described in detail in @sec:prelim:cumulative.

#example[
  Let $C$ be a cumulative constraint with activities $x$, $y$ and $z$ such that the capacity and usages are unit, and such that the duration of $x$ and $y$ are 1 and the duration of $z$ is 2. Then $[x = 0] and [y = 2] and [z >= 0] -> [z >= 1]$ is a valid inference. To see this, note that $x$ must be active at $t = 0$, therefore $z$ cannot be active at $t = 0$. Since we also know it must start at $t >= 0$, we know that indeed $z$ must start at least at $t >= 1$. However, smarter reasoning might have identified that then the second half of $z$ overlaps with $y$, therefore $[z >= 3]$ is also a valid consequent.
]

The previous example showed that the same premises allowed for at least 2 different valid inferences that use constraint-specific reasoning. The first might have originated from a solver that only reasons using starting times, which might have been a valuable trade-off to reduce time spent on propagation. #todosm[Make sure somewhere I mention the trade-off between propagation strength and propagation cost] Verifying the first also meant we did not even have to look at other timepoints than $t = 0$.

To minimize time spent checking, it is therefore valuable to look at the domains after negating the right-hand side and adding it to the left-hand side (which is logically equivalent), and then derive a conflict. This would mean that the first inference would be $[x = 0] and [y = 2] and [z >= 0] and [z <= 0]$. Since we only want to verify the consequent containing $z$, we can then focus on the domain for $z$, which means we first look at the timepoint $t = 0$. 

=== Domain operations

#todosm[Figure out exactly what to put here]

== Mathematical preleminaries

In @sec:prelim:deduct, it was mentioned that a domain is tracked for each variable during the deduction process.

#let Zext = $ZZ_"ext"$

=== $Zext$ <sec:zext>

The _extended integers_, denoted $Zext$, are defined as $ZZ union {-infinity, plus infinity}$. They are not as well studied as the extended _real_ numbers, which have applications in e.g. measure theory. We could not find any formalization and found only mentions as examples in a general theory on compactification in topology @peschke1990endstheory. We do note we are not the first to use it in CP, see e.g. @caballero2013typeext.  Since we are not concerned with performing arithmetic on them and use them only to define an order, we do not suffer from the fact that some arithmetic operations (such as $infinity - infinity$) do not have a natural definition.

==== Operations

We define comparison on $Zext$ such that $-infinity <= x <= +infinity$ holds for all $x in Zext$ and when $x, y in ZZ$ we also have $x <=#sub[#Zext] space y$ when $x <=#sub[$ZZ$] space y$. This clearly defines a total order.

We also define the $max$ and $min$ operations in the natural way, where we have, for example, $min({n, +infinity}) = n$ for $n in ZZ$.


// == Formal verification <sec:formalverif>

// While CP proof checkers are simpler to build than solvers, they still need to implement propagation algorithms. Therefore, proof checkers are ideally formally verified. The gold standard for this verification is a machine-checked mathematical proof that the program adheres to its specification.

// We refer to @peled2019formal for a broad introduction to formal verification.

// #todo[This section will be filled mostly with what is currently in the proposal]

#pagebreak()

= Results

// == Pseudocode

// The "language" of our pseudocode has the following features:

// === Sum types

// ```
// enum Domain =
//     | Unfixed
//     | Fixed(n: int)
// ```

// We can instantiate these using only their variant names, `Unfixed` or `Fixed(n)`.

The results are separated into five parts. First we describe the formalization and implementation of a theory for converting atomic constraints into a holes-based domain representation, using what we call _perforated intervals_ This is foundational to all the other results in this thesis. Next, we describe the implementation and formalization of the fact deduction procedure, which is based entirely on the procedure devised in @sidorov2025checker (the author of this thesis had no role in its theoretical development). Then, we describe a partial implementation of an alldifferent checker capable of verifying inferences for alldifferent constraints where the premises are without redundancy. This is followed by the description of a checker capable of verifying inferences for cumulative constraints that are derived using timetable reasoning. The development of this checker also involved creating building blocks that are expected to be useful for other constraint checkers. Finally, we describe a framework for developing additional constraints as well general recommendations for formalization and working in Rocq.

== Perforated intervals <sec:domain>

#let dom = spro[dom]

#let holes = spro[holes]

We begin with the theory of perforated intervals, because they are used in the other three implementation contributions of this thesis (fact deduction, cumulative checker, alldifferent checker). These parts all require reasoning over domains of variables implied by lists of atomic constraints, with the specific requirements as follows:
- Fact deduction requires efficiently checking whether atomic constraints hold and whether a group of atomic constraints imply an empty domain
- Our timetable cumulative checker requires the extraction of lower and upper bounds from a list of atomic constraints (which when considering not-equals constraints might be different from just the maximum upper bound, minimum lower bound)
- Our domain-consistent alldifferent checker requires building an enumerated domain from a list of atomic constraints

The integer domain representation introduced in this section based on what we call _perforated intervals_ fulfills all of these requirements. Perforated intervals consist of three pieces of data: lower and upper bounds as well as a set of holes (or perforations). The name was chosen to be distinct from punctured intervals used in e.g. analysis, which are usually missing exactly one value, while our perforated intervals can have many holes.

In this section, we begin with the formal definition and discuss some related concepts, including the introduction of the concept of a perforated interval being _tight_, in which case we can perform the efficient checks necessary for fact deduction. We then discuss these checks and their implementation. This is followed by a discussion on how we can build these domains by updating them based on atomic constraints. Then, the algorithm for how to actually tighten a domain is described. This section concludes with how managing multiple domains can be managed, since in practice we are always dealing with multiple variables.

#definition[
  A _perforated interval_ is a triple $(dlb, dub, holes)$, where $dlb, dub in Zext$ and $holes$ a finite subset of $ZZ$. 
]

We note that in our formalization, these perforated intervals are referred to simply as domains, as that is currently the only type of domain representation in the checker.
A punctured interval can be interpreted also as the set difference of two sets, $[dlb, dub] - holes$, where the interval must satisfy $[dlb, dub] subset.eq ZZ$. Since perforated intervals represent domains, we define when an element is in a perforated interval.

#definition[
  Let $n in ZZ$ and $dom = (dlb, dub, holes)$ a perforated interval, then $n in dom$ iff $dlb <= n <= dub$ and $n in.not holes$.
]

This induces a natural equivalency between perforated intervals.

#let domeqv = $tilde.eq$

#definition[
  Let $dom$ and $dom'$ be two perforated intervals. Then they are equivalent, written $dom domeqv dom'$, iff forall $n$, $n in dom <-> n in dom'$.
]

There exists examples of perforated intervals that are equivalent, but not equal.

#example[
  Let $dom = (5, +infinity, {5, 6})$ and $dom' = (7, +infinity, {})$. Then $dom domeqv dom'$. Let $dom_"empty" = (4, 6, {4, 5, 6})$ and $dom'_"empty" = (10, 5, {})$. Then also $dom_"empty" domeqv dom'_"empty"$.
] <ex:domeqv>

It is important to be able to determine whether an atomic constraint holds for all elements of a domain, since then we can check whether the premises of a fact hold. Furthermore, it should be easy to determine when a domain is inconsistent, which is necessary in the deduction step to validate a nogood. 

Not every perforated interval can be easily checked for these conditions. For example, verifying whether $dom_"empty"$ from @ex:domeqv is inconsistent requires looking at the holes and seeing that every element in the interval is in the set of holes. However, $dom'_"empty"$, checking its bounds immediately leads to the conclusion that it is empty. Similarly, to see whether $x >=6$ holds for $dom$ (again, from @ex:domeqv) requires inspecting the holes, while for $dom'$ comparing 6 with the lower bound suffices. We now state the exact condition for such checks to require only inspecting the bounds.

#definition[
 Let $dom = (dlb, dub, holes)$ be a perforated interval. Then $dom$ is called _tight_ if $dlb, dub in.not holes$.
]

In the next subsection, these checks are discussed in detail.

#let checkconsis = jmono[check_consistency]
#let checkholds = jmono[check_holds]

=== Checks

The two main checks we want to perform on a domain is whether it is consistent and whether a particular atomic constraint holds for all values in the domain. Let us describe these properties formally.

#definition[
  A domain $dom$ is _consistent_ (or _non-empty_), if there exists $n in ZZ$ such that $n in dom$.
]

#definition[
  Let $a = [diamond.small c]$ be an atomic constraint (so we have that $diamond.small in {<=, >=, !=, =}$). Then $a$ _holds_ for a domain $dom$ if for all elements $n in dom$, we can say $n diamond.small c$.
]

We describe a procedure for checking each of the two properties specifically for perforated intervals. #jmono[check_consistency(dom: PerforatedInterval) -> bool] first checks whether the lower bound is positive infinity or the upper bound is negative infinity (returning `false` in both cases) and then checks whether the lower bound is less than or equal than the upper bound. If so, it returns `true`. In pseudocode:

```
Definition check_consistency(dom: PerforatedInterval) -> bool:
  match lb(dom), ub(dom):
    case (positive_infinity, _):
      return false
    case (_, negative_infinity):
      return false
    case (_, _):
      return lb(dom) <= ub(dom)
```

The next function, #jmono[check_holds(dom: PerforatedInterval, atom: Atomic) -> bool] has different behavior for each atomic constraint.
- For $[<= c]$ constraints, it returns whether the upper bound is less than or equal to $c$. 
- For $[>= c]$ constraints, it returns whether the the lower bound is greater than or equal to $c$
- For $[= c]$ constraints, it checks whether the lower and upper bounds are equal to $c$
- For $[!= c]$, it checks whether $c$ is strictly greater than the upper bound, $c$ is strictly smaller than the lower bound, or if $c in holes$.

In pseudocode (where `is_element_of` checks whether a value is inside a set):

```
Definition check_holds(dom: PerforatedInterval, atom: Atomic) -> bool:
  match comparator(atom):
    case less_equal:
      return ub(dom) <=? value(c)
    case greater_equal:
      return value(c) <=? lb(dom)
    case equal:
      return (ub(dom) <=? value(c)) && (value(c) <=? lb(dom))
    case not_equal:
      if ub(dom) <? value(c):
        return true
      else if value(c) <? lb(dom):
        return true
      else:
        return is_element_of(value(c), holes(dom))
```

Our claim is now that when a perforated interval is tight, these functions decide the properties (with an additional requirement on #checkholds for the perforated interval to be consistent). This gives the following two lemmas.

#lemma[
  Let $dom$ be a tight, perforated interval. Then $dom$ is consistent if and only if #checkconsis$(dom) = $ `true`.
]

The proof has been formalized but we omit it here, as most cases can be dealt with simply by case splitting and do not depend on the perforated interval being tight. Instead, we highlight one specific case to illustrate why the perforated interval must be tight. When $dub$ is some number $U in ZZ$ and $dlb = - infinity$, notice that $dub in dom$ (and therefore it is consistent), since because the perforated interval is tight we have that $dub in.not holes$.


#lemma[
  Let $dom$ be a tight and consistent perforated interval and $a$ an atomic constraint. Then $a$ holds for $dom$ if and only if #checkholds$(dom, a) =$ `true`.
]

The reason we require consistency is because for an inconsistent and tight perforated interval, #checkholds might not return `true`, even though our definition for an atomic holding would be trivially true (as the perforated interval is then empty). The proof is again omitted here, but we highlight two cases. 
- When proving the forward implication for an atomic $a = [>= c]$ and we have that $dlb = -infinity$ and $dub$ is some number $U in ZZ$, #checkholds equals `true` if $c <= - infinity$. This can never be the case, so we must derive a contradiction. Since we assume $a$ holds, then the value $min({U,c,min(holes union 0)}) - 1$ has to be greater or equal to $c$ as it is in the perforated interval (since smaller than all holes and smaller than $U$). But by its definition it is strictly less than $c$. Hence, there is a contradiction. 
- When proving that when a not equals constraint holds #checkholds equals `true`, we look at the two possible outcomes of the triple or statement. In the non-trivial case, this then gives that $dlb <= c <= dub$ and $c in.not holes$. But that gives exactly that $c in dom$. But then the atomic constraint applies to $c$, so $c != c$, which is a contradiction.

Now that we know how to check consistency and whether an atomic constraint holds for a perforated interval, we will discuss in the next subsection how to actually build them.

=== Updates

For each type of atomic, a perforated interval can be updated such that the atomic holds for the perforated interval.

- For $[<= c]$ constraints, update the upper bound by taking the maximum of the current upper bound and $c$ (using the operation defined in @sec:zext).
- For $[>= c]$ constraints, update the lower bound by taking the minimum of the current upper bound and $c$.
- For $[x = c]$, update the upper and bound and then the lower bound just like for $<=, >=$-constraints to $c$.
- For $[x != c]$, update $holes$ by adding $c$.

We call the function that performs exactly this #jmono[apply_atomic(dom: PerforatedInterval, atomic: Atomic) -> PerforatedInterval] and the following lemma can be proven by examining the cases for $dlb$ and $dub$ and using the defined order on $Zext$. The lemma states that any integer is an element of a perforated interval that had an atomic applied if and only if that integer was an element of the original domain and it obeys the atomic constraint.

#let atomic = spro[atomic]

#lemma[
  Let $n in ZZ$, #dom a perforated interval and $[diamond.small c]$ an atomic constraint, then $n in #jmono[apply_atomic]\(dom, [diamond.small c]) <-> n in dom and n diamond.small c$.
] <lem:apply_atomic_spec>

To apply multiple atomic constraints at once, we simply use a fold over a list of atomic constraints, which we call #jmono[apply_atomics(dom: PerforatedInterval, atomics: list Atomic) -> PerforatedInterval]. Using a straightforward induction proof, we can prove a lemma similar to @lem:apply_atomic_spec.

#let atomics = spro[atomics]

#lemma[
  Let $n in ZZ$, #dom a perforated interval and #atomics a list of atomic constraints, then $n in #jmono[apply_atomics]\(dom, atomics) <-> n in dom and (forall [diamond.small c] in atomics, n diamond.small c$).
]

Armed with this lemma, we see that applying the order of atomic constraints has no effect on which logical domain is implied by them. This is a powerful tool for when we want to manage applying multiple atomic constraints.

=== Tightening procedure

In this section, only the case for tightening the lower bound is described. The upper bound case is fully symmetric. In our formal proofs, we have tried to use this symmetry to avoid duplicate proofs as much as possible. We describe this technique at the end of this section.

The tightening procedure is simple. Given a list of holes in strictly increasing order (so in particular it also has no duplicates) and an initial lower bound, we can tighten the lower bound by first iterating until we find a hole equal the current lower bound. The current bound is then increased by one. We then keep iterating until the next hole is not equal to the current bound (which happens when the list of holes skips at least one integer). We illustrate this with a simple example.

#example[
  Suppose we have a variable $x$ that we know is greater or equal than $5$. Given a list of holes (values that we know $x$ cannot take) of [3, 5, 6, 7, 9], we first iterate until we reach 5, so then we are left with [5, 6, 7, 9]. Then the bound is updated to 6, to 7, and to 8 as we iterate. However, since there is no hole at 8, we stop. Therefore, our lower bound is updated to 8.
]

We give pseudocode for the implementation. Here `list_from` simply iterates until it finds its second argument, returning the remaining list.

```
Definition tighten_bound_incr(hole: Z, bound: Z):
  if hole =? bound:
    return bound + 1
  else:
    return bound

Definition tighten_incr(holes: list Z, bound: Z):
  holes_from_bound := list_from(holes, bound)
  return fold(tighten_bound_incr, holes, bound)
```

We now apply this function to actually tightening the lower bound in a perforated interval. First, we check whether the domain is already tight by checking whether there exists a hole equal to the lower bound (and if the lower bound is still $-infinity$, we do nothing). If not, it is already tight. Otherwise, we turn take all elements in the set of holes and call `tighten_incr` with these holes and the current bound. Afterwards, we update the domain with the new, tight bound.

We are interested in proving two facts. The first is that tightening the bounds produces a new domain that is equivalent to the previous one, i.e. tightening does not change the elements that can be in the domain. This is useful when we care only that the bounds produced in the domain procedures are actually valid for the variable we are looking at, not if they are as good as they could be. The second fact is that after applying the tightening procedure (not just on the lower bound, but also upper bound) our domain is tight. If that holds, we can apply what we learned earlier about tight domains.

#todo[Finish this section]

// #lemma[
  
// ]

// === Domains and variables

// So far, the concept of a variable has not yet been introduced and domains only refer to some integer. In order to work with variables, each with a separate domain, we utilize a map datastructure where each 

=== Implementation considerations <sec:domain:impl>

=== Alternatives

Alternative representations are:

- list of intervals

Why not that? Harder to update just lower or upper bound, more difficult logic to establish whether a not-equals constraint holds, would require a more specialized datastructure (harder to verify)

#todosm[Look up more literature]

// == Fact deduction <sec:deduct>

// In this section, we formalized and implement the procedure described in @sec:prelim:deduct.

// === States

// A domain is _tightened_ if based on the holes, the bounds are as tight as they can be. This also implies we can efficiently check whether an atomic holds. We do not care about holes outside the bounds.
// - A domain is tightened if there is no hole at either of the bounds.  
//   - apply $<=$: we see if there is a hole at the bound. If that is the case, we apply the tightening procedure from the upper bound going down.
//   - apply $>=$: we see if there is a hole at the bound. If that is the case, we apply the tightening procedure from the lower bound going down.
//   - apply $=$: do both the lower and upper
//   - apply $!=$: see if either the lower or upper bound is at the hole, then do either lower or upper bound procedure

// Note: if domain becomes inconsistent, some premises might not check anymore. So if a premise check fails, we always want to normalize.

// A domain is _normalized_ if it is tightened, all holes are strictly within the bounds, and consistent; OR it is None.

// For normalize I think the best way to proceed is to simply rebuild the tree.

// === Operations

// 1. Build a domain from a fact, for instance at the start of the deduction process (when assuming all the nogood premises) or when checking an inference. We do not expect these to be conflicting, nor do we expect there to be a lot of redundancy. Therefore, we do not care (when applying an individual atomic) whether or not the resulting domain is tightened or normalized. So we want to apply many atomics in one go.
// 2. _After_ building the domain from the premises of a nogood, we need to check the premises of the inferences. So we want the domain to be tightened before we do this. So we need a tightening operation.
// 3. After applying a consequent, we will do more premise checking, so we want to efficiently apply a single atomic and have the domain still be tightened afterwards.
// 4. We want to be able to, at the end of applying all the inferences, check whether we have a conflict. For that we want to normalize it. We do not care about normalizing after applying each atomic, since we expect the conflict to be only reached at the end of the deduction step.


#pagebreak()

== Checking alldifferent (domain-consistent)

The checker for alldifferent verifies an inference if it can identify a set of variables such that the size of the unions of their domains is smaller than the number of variables. This necessarily means we have a conflict. We will now prove this fact.

In the below proofs, a _set_ is a list with a proof that it has no duplicates. Furthermore, there is an alldifferent constraint defined by variables _variables_. An assignment is a function that that sends variables to their assigned value.

#lemma[Let _conflict variables_ be a set of variables part of the alldifferent constraint, i.e. each $x in $ _conflict variables_ is an element of _variables_.  Furthermore, let _conflict domain union_ be the union of all values in the domains of _conflict variables_. More precisely, _conflict domain union_ is a set where we have that an integer $n$ is an element iff there exists a variable $x in$ _conflict variables_ s.t. $n in "dom"(x)$. Finally, we require that the length of _conflict domain union_ is strictly smaller than the length of _conflict variables_.

Then, there exists no solution satisfying the current state and satisfying the alldifferent constraint defined by _variables_.]

#proof[
  Our goal is to prove there exists no solution. That means that if such a solution exists, there must be a contradiction. Therefore, let $A$ be an assignment that satisfies the current state and the alldifferent constraint defined by _variables_. It is enough to show that the length of _conflict domain union_ is greater than or equal to the length of _conflict variables_, since we assumed the opposite and if this is the case we can derive a contradiction, which is our goal. 

  Now, the length of _conflict variables_ is the same as the length of _map(A, conflict variables)_, which is the list obtained by mapping all variables to their assignment according to $A$#footnote[This fact holds for any list and function and can be proven by induction. Length is defined recursively in the natural way.]. We will call this mapped list of values _conflict values_. We can now replace our goal with showing that the length of _conflict domain union_ is greater than or equal to _conflict values_.

  We now use a lemma that states that if a list has no duplicates and every element of that list is also in another, then the length of this list must be smaller than the list it is contained in. Applied to our goal, all that is then left to show is that _conflict values_ has no duplicates and is indeed contained in _conflict domain union_. 

  First, we show that _conflict values_ contains no duplicates. For this we use a lemma that states that when a function $f$ is injective (i.e., when $f(x)=f(y)$, $x=y$, also known as one-to-one) for all inputs that are elements of some list $L$, then if that list has no duplicates, _map(f, L)_ will also have no duplicates. Applied to our goal of showing _conflict values_ has no duplicates, it remains to show that $A$ is injective on _conflict variables_. For this, let $x$ and $y$ be two variables in _conflict_variables_ such that $A(x) = A(y)$. The goal is then to show that $x$ and $y$ are equal.
  
  There are two possible cases, either $x$ and $y$ are equal, or they are not. In the first case we trivially solve our goal. We are now left with the second case, where it is now known that $x$ and $y$ are not equal. Now, if $A(x) != A(y)$ we would have a contradiction and therefore we would be done, so this is what we will aim to show. Remember that $A$ obeys the alldifferent constraint with _variables_. But $x$ and $y$ are also both elements of _variables_. Therefore we can readily show that $A(x) != A(y)$.

  We have now proven the first subgoal, leaving only the requirement that _conflict values_ is contained in _conflict domain union_. Let $n$ be an arbitrary element of _conflict values_. Then we are done if $n$ is also in _conflict domain union_. First, note that since $n$ is in a mapped list, there must exist $x$ s.t. $x in$ _conflict variables_ and $n = A(x)$. #footnote[This fact holds for any list and function and can again be proven through induction through the definition of map].
  Now from our specification of _conflict domain union_, $n$ is an element exactly if there exists an $x'$ such that $x' in$ _conflict variables_ and $n in "dom"(x')$. Let $x$ be this $x'$. The first condition we already showed and since $A$ satisfies the current state and $x$ is assigned to $n$, we must have that $n in "dom"(x)$. 
]

#pagebreak()

== Checking cumulative (timetable) <check:cumul>



=== Main idea

In this subsection, we assume that a fact has already been converted from a list of atomic constraints to a list of activities and their bounds implied by the atomic constraints, as this is not explicitly related to cumulative. This is discussed in more detail in the next subsection and in the dedicated section on domain reasoning (@sec:domain).

We define two functions tailored to the two discussed conflict types. The first, #jmono[resource_profile(capacity: N, times: list Z, bounds: list ActivityBound) -> list N], computes a resource profile over a given set of times, reporting whether it finds a time conflict at any of the times. For each $t$, the value it reports is the capacity minus the sum of the usages of all activities mandatory at that $t$. The second function, #jmono[can_schedule_activity_with_profile(bound: ActivityBound, profile: list N) -> bool], takes as input a resource profile on all times within a particular activity's bounds and reports whether it is possible to schedule it at any time. Here it assumes that the particular activity can be scheduled on times where it is mandatory. If cannot find any such time, it reports an activity conflict.

It is assumed that most inferences will be either resource time conflicts with an empty consequent, or propagations that when in conflict form, entail an activity conflict. The latter case will have the conflicting activity in the right-hand side. Therefore, the checker works in the following order:
1. It checks if the inference has a consequent. If it does, it will first seek to determine a conflict for the activity present in the consequent. It does this using the #jmono[resource_profile] function applied to the time range $[lower, upper]$. If there is a time conflict in that range, the inference is also valid. Otherwise, the profile is given to #jmono[cannot_schedule_activity_with_profile], which tries to find an activity conflict. If there is none, il proceed to the next case.
2. If no conflict could be determined on the consequent's bounds or if there was no consequent, a resource profile will be constructed that ranges from the minimum start time among all variables to the maximum start time among all variables. If no conflict can be determined, it proceeds to the next case.
3. If the previous cases failed, the checker will seek to determine a conflict by checking all activities in the same way as it checked the one associated with the consquent. Once it finds one, it will report it. Otherwise, the checker fails to verify the inference.

=== Algorithm description

When highlighting the main idea, we mentioned that an inference is converted into a list of activities with bounds. Specifically, it is converted into a list with elements of type `ActivityBound`:

```
record ActivityBound:
  var: Id
  lower: Z
  upper: Z
  duration: N
  usage: N
```

The function that does this conversion is #jmono[infer_cumulative_bounds(constraint: CumulativeConstraint, fact: Fact) -> InferResult]. The result can either be that the fact is inconsistent (i.e. the atomic constraints imply an emptyp domain) or a `(list ActivityBound, option ActivityBound)` pair, where the optional bound refers is the bound associated with the variable in the consequent of the fact. The function makes use of the #jmono[infer_domains] of @sec:domain and the parameters in the constraint.

Now, let us define the two functions from the previous section in detail.

The #jmono[resource_profile] is defined in a natural way. For each element of the range of times it receives, it simply computes what activities are mandatory and adds up their usages, subtracting them from the constraint capacity. In case this would result in something less than zero, it reports an error instead. We describe this in pseudocode, noting that some optimizations have been removed for the sake of exposition (see also @subsec:cumul:impl). The function #jmono[is_mandatory] computes whether an activity is mandatory at time $t$ (by checking whether, for an activity $x$, $upper(x)$ <= t < $lower(x) + duration(x)$ holds). #jmono[xn_sum(l: list (Id \* N)) -> N] takes as input a list of variable-usage pairs and adds up all the usages. It is useful to include the variable for the proof. Finally, #jmono[map_valid(f: A -> B | error, l: list A) -> list B | error] is like a standard `map`, but will report a conflict if any of the individual operations report a conflict.

```
Definition resource_profile_t(capacity: N, bounds: list ActivityBound, t : Z) -> N | time_conflict:
  mandatory_at_t := filter(is_mandatory(t), bounds)
  mandatory_at_t_xn_list := map(b -> (var(b), usage(b)), mandatory_at_t)
  sum := xn_sum(mandatory_at_t_xn_list)
  if capacity < sum:
    return time_conflict
  else:
    return sum

Definition resource_profile(capacity: N, times: list Z, bounds: list ActivityBound) -> list N | time_conflict:
  map_valid(resource_profile_t(capacity, bounds), times)
```

Given an activity $x$ and its bounds, the #jmono[cannot_schedule_activity_with_profile] works by first converting the profile given to a list of bools that correspond to whether the activity can be active at the associated time. For each profile entry (it assumes the elements correspond exactly to the times $[lower(x), lower(x) + 1, ..., upper(x)]$) it first determines whether it is mandatory at that time. If it is, the value is `true`, since it is assumed the profile was already checked and did not exceed the capacity. Otherwise, it sees if the profile value (which is the remaining amount of resources after subtracting the usage of all mandatory activities) is greater than or equal to the resource usage of the activity. If it is, then the activity can be active and the value is `true`, otherwise it is set to `false`. The list of bools is then traversed. If it can find a set of consecutive `true` entries of length equal to the activity's processing time, the activity can be scheduled and the function will return false. 

The pseudocode can be found below. We again use the #jmono[is_mandatory] function, but also introduce the #jmono[has_n_true(n: N, l: list bool) -> bool] function, which traverses the list and returns `true` once it finds $n$ consecutive `true` values. Again, the code is somewhat simplified.

```
Definition can_be_active(bound: ActivityBound, usage_left: N, t: Z) -> bool:
  is_mandatory(t, bound) or (usage(bound) <= usage_left)

Definition profile_to_active_list(bound: ActivityBound, profile: list N) -> list bool:
  profile_range := range_inclusive(lower(bound), lower(bound) + length(profile) - 1)
  profile_with_times := combine(profile, profile_range)
  map(can_be_active(bound), profile_with_times)
  
Definition cannot_schedule_activity_with_profile(bound: ActivityBound, profile: list N) -> bool:
  active_list := profile_to_active_list(bound, profile)
  has_n_true(duration(bound), active_list)
```

Before we give the pseudocode of the main checker definition, we mention two additional functions. #jmono[cannot_schedule_activity(capacity: N, bounds: list ActivityBound, bound: ActivityBound) -> bool] composes the previously discussed #jmono[resource_profile] and #jmono[cannot_schedule_activity_with_profile] functions. It returns `true` if either the resource profile had a conflict or if it found an activity conflict. It builds the resource profile only on the timepoints within the activity's bounds. Finally, #jmono[resource_profile_full(capacity: N, bounds: list ActivityBound) -> bool] determines the earliest and latest possible starting times of all activities and then builds a resource profile on that interval, returning `true` if it can find a time conflict.

Written in pseudocode, the checker then looks like the following. As the name suggests, #jmono[any_true] runs a partially applied function on all elements a list, returning `true` if any of them return `true`.

```
Definition cumulative_checker (fact: Fact, constraint: CumulativeConstraint) -> bool:
  match inferred_cumulative_bounds(constraint, fact):
    case inconsistent_fact:
      return false
    case activity_bounds, maybe_rhs_bound:
      match maybe_rhs_bound:
        case Some rhs_bound:
          if cannot_schedule_activity(capacity(constraint), activity_bounds, 
                                      rhs_bound):
            return true
    
      if resource_profile_full(capacity(constraint), activity_bounds):
        return true
      if any_true(cannot_schedule_activity(capacity, activity_bounds), 
                  activity_bounds):
        return true
```

=== Proof


#let inferbounds = jmono[inferred_cumulative_bounds]
#let inferdoms = jmono[infer_domains]
#let cannotsched = jmono[cannot_schedule_activity]
#let resprofile = jmono[resource_profile]
#let var = jmono[var]
#let maybebound = spro[maybe_rhs_bound]
#let times = spro[times]
#let l_mandatory_t = spro[l_mandatory_t]
#let l_active_t = spro[l_active_t]
#let xn_of(c) = {
  jmono[xn_sum] + [(#c)]
}
#let cansched = jmono[can_schedule_activity_with_profile]
#let profile = spro[profile]



The main theorem we seek to prove is the following:

#theorem[
  Let $A$ be an assignment satisfying a cumulative constraint $C$. Then, for any fact $omega$, if $checker(omega, C) = truev$, $omega$ is a valid fact for $A$.
] <thm:cumulcheck>

In order to prove this, we rely on a lemma specifying the behavior of #inferbounds. But first, we define what it means for a list of `ActivityBound` to be valid. 

#definition[
  Given a cumulative constraint $C$, a list of `ActivityBound`s, #bounds, is _valid_ for an assignment $A$ if for every $b in bounds$, the acitivity defined by $(var(b), usage(b), duration(b)) in C$, and $lower(b) <= A(var(b)) <= upper(b)$.
]


Furthermore, we call an optional ActivityBound $maybebound$ valid if in the case of it not being empty, it is an element of a list of bounds that is also valid. The lemma shows, in essence, that #inferbounds negates the right-hand side of the fact and that the bounds are derived from the atomic constraints in the left-hand side of the fact.


#lemma[
  Let $bounds$, $maybebound = inferbounds$ $(C, omega)$ and let $bounds$, $maybebound$ being _valid_ for for $C$ and $A$ imply a contradiction. Then $omega$ is valid for $A$.
] <lem:inferred_cumulative_bounds_spec>

#proof[
  We omit the proof, as it relies heavily on the exact implementation (see @subsec:cumul:impl), but mention that it relies on the correctness proof of #inferdoms, which is discussed in @sec:domain.
  // implementation of  Using the definition of a fact being valid, we can show a fact $omega$ is valid by assuming $premises(omega)$ as well as $not#consq\(omega)$ (which is a redundant $top$ in case it is empty, and otherwise the negation of the atomic constraint) and then deriving a contradiction. We assume that #inferbounds uses a correct derives the bounds by repeatedly updating upper and lower bounds using the atomic constraints in the premises and negated consequent and that 
]

Next, we state lemmas (saving their proofs for later) for the correctness of #cannotsched and #resprofile, which underpin the checker. In the lemma, the requirement of uniqueness for #bounds means that each variable only occurs once.

#lemma[
  Let $A$ be an assignment satisfying $C$, let #bounds be a list of `ActivityBound` that is valid for $A$ and $C$ and let #bounds be unique. Then, for any list of timepoints #times, #resprofile$(capacity(C), bounds, times)$ does not report a conflict.
] <lem:resource_profile_contradiction>

#lemma[
  Let $A$ be an assignment satisfying $C$, let #bounds be a list of `ActivityBound` that is valid for $A$ and $C$ and let #bounds be unique. Then for any $b in bounds$, #cannotsched$(capacity(C), bounds, b)$ = `false`.
] <lem:cannot_schedule_activity_valid>

#proof[
  Let $A$, $C$ and $omega$ be as in the theorem statement. We know #checker$(omega, C) = truev$. Therefore, $inferbounds(C, omega)$ does not report an inconsistent fact and instead its result equals the pair $bounds$, $maybebound$. Applying @lem:inferred_cumulative_bounds_spec, we assume that $bounds$, $maybebound$ are valid for $A$ and $C$, after which we must prove a contradiction. From the definition of #checker, we see there are two cases:
  - #jmono[resource_profile_full] = `false`, which means the underlying #resprofile reported a conflict. But using @lem:resource_profile_contradiction, it should not have. Therefore, we have a contradiction.
  - There exists $b in bounds$ s.t. #cannotsched = `true`. This is either because #maybebound was not empty and since we know it was valid the bound contained had to be an element of bounds and indeed it could not be scheduled, or `any_true` was able to find a bound for which it was true. However, using @lem:cannot_schedule_activity_valid, it should be `false` for any bound in #bounds. Therefore, we have a contradiction.
  Having shown a contradiction in all possible cases, we are done.
]

We now focus on proving @lem:resource_profile_contradiction, which means we must show that for #bounds satisfying some assignment $A$ that satisfies $C$, no time conflict should be found by #resprofile. The main idea is that when $A$ satisfies $C$, the usage at all timepoints should be less than $capacity(C)$, and since the set of mandatory activities is a subset of the set of active activities, the usage of all mandatory activities should also be less than the capacity and no conflict should be found.



#proof([of @lem:resource_profile_contradiction])[
  For any list of timepoints #times, no time conflict should be found. That is equivalent to showing that there is some $t in times$ s.t. #jmono[resource_profile_t]$(capacity(C), bounds, t)$ returns a time conflict. Using the definition of that function, it returns a conflict if the $capacity(C)$ is strictly less than the sum of all usages of activities that are mandatory at $t$. Furthermore, since $A$ satisfies $t$, we know that the sum of the usages of active activities according to $A$ is less than or equal to $capacity(C)$. Let #l_active_t be this list of active activities at $t$, identified only by the pair $(x, usage(x))$ (for an activity $x$). Let #l_mandatory_t be the list of activities that are mandatory at $t$, also consisting of variable-usage pairs. We know $#xn_of[#l_active_t] <= capacity(C)$, so to derive a contradiction it is enough to show $#xn_of[#l_mandatory_t] <= #xn_of[#l_active_t]$ (since then it is $<=$ capacity, but we derived earlier it must be $>$).

  We can show this by proving that #l_mandatory_t is a sublist of #l_active_t (see @sec:sublist, a sublist means every element in the left list occurs less often than in the right list). For this, it is enough that #l_mandatory_t has no duplicates and that every element is in #l_active_t. The fact it has no duplicates comes from the fact it is the result of a filter (which only removes values) and a map (which preserves the variable) of #bounds, which we know is unique (every variable occurs only once). Next, since #bounds are valid, we know every bound is associated with in activity in $C$, and when an activity is mandatory, it is certainly active (if the bounds are correct, which we know they are since #bounds is valid). Therefore, every element in #l_mandatory_t is also in #l_active_t.
] 

Before we can now prove @lem:cannot_schedule_activity_valid, we need to prove a lemmma on the correctness of #cansched. This first requires us to prove that a resource profile, if there is no conflict, actually gives us what it wants. We first state the desired specification.

#definition[
  Let $c$ be some capacity and #bounds be a list of `ActivityBound`, then we call a profile (which has type list of $N$) _valid_ on $t_min$ to $t_max$, if the following holds:
  - Its length is equal to $t_max - t_min + 1$ (or it is empty if $t_min > t_max$)
  - For every $t$ s.t. $t_min <= t <= t_max$, the $n$th element (such that $n = t - t_min$) of the list should equal the result of #jmono[resource_profile_t]$(c, bounds, t)$ and this should not be a conflict.
]

The specification requires that the result of the profile, if it does not report a conflict, consists of exactly the results of the #jmono[resource_profile_t] in the right order. We can now state the correctness lemma for #cansched.

#lemma[
  Let $A$ be an assignment satisfying $C$, let #bounds be a list of `ActivityBound` that is valid for $A$ and $C$ and let #bounds be unique. Then for any $b in bounds$ and any resource profile #profile that is valid on $lower(b)$ to $upper(b) + duration(b) - 1$ with capacity equal to $capacity(C)$, #cansched$(b, profile)$ = `true`.
] 



#proof[
    #let entry = spro[profile_entry]
    #let rentry = spro[range_entry]
    #cansched$(b, profile)$ is equal to `true` only if there exists some set of length $duration(b)$ of consecutive `true`s in the active list. That is equivalent to there existing an index $n$ such that the number values of the active list that are `true`, starting from the $n$th one, is greater than or equal to $duration(b)$. We claim this is the case for $n$ equal to $A(var(b)) - lower(b)$. 

    Note that it is enough to simply show the $n$th, $n + 1$th, $n + duration(b) - 1$th values are `true`. If we look at the definition of active list and the properties of `combine` (we know that #profile is valid, so its length is equal to the range it is combined with) and `map`, the $k$th value of active list is equal to #jmono[can_be_active]$(b, entry(k), rentry(k))$ s.t. $entry(k)$ is the $k$th value of #profile and $rentry(k)$ is the $k$th value of the range #profile is combined with. Using the fact that the #profile is valid, we know that $entry(k) = jmono("resource_profile_t")(capacity(C), bounds, k+lower(b))$ and that $rentry(k) = k + lower(b)$.

    The chosen value for $n$ was $A(var(b)) - lower(b)$ so if we substitute $A(var(b)) - lower(b)$ up to $A(var(b)) - lower(b) + duration(b) - 1$ for $k$, what is then left to show is that that for all $t$ s.t. $A(var(b)) <= t < A(var(b)) + duration(b)$, we have that #jmono[can_be_active]$(b, jmono("resource_profile_t")(capacity(C), bounds, t), t)$ is `true`.
    
    Consider the case where $b$ is mandatory at $t$, then this function outputs `true`. Consider now the case where it is not mandatory. Now, we know that the `usage_left` parameter is equal to #jmono("resource_profile_t")$(capacity(C), bounds, t)$, which is equal to $capacity(C) - #xn_of[#l_mandatory_t]$ (there is no conflict because we know #profile is valid), where #l_mandatory_t is the list of mandatory activities based on #bounds. Therefore, it remains to be shown that $usage(b) + #xn_of[#l_mandatory_t] <= #xn_of[#l_active_t]$ (where again we introduce #l_active_t as the list of activities that are active and we know it is $<= capacity(C)$ since $C$ is satisfied). Since we assumed here $b$ is not mandatory, it is not included in #l_mandatory_t. However, we know it is active at $t$ since $t$ falls within the active time according to $A$, so it is included in #l_active_t. Then, using a similar argument as in @lem:resource_profile_contradiction, we can use that #l_mandatory_t is a sublist of #l_active_t to conclude the proof.
]

We now have the tools to prove @thm:cumulcheck.

#proof([of @thm:cumulcheck])[
  The checker returns `true`, therefore, #inferbounds cannot have reported that $omega$ is inconsistent. This means we have #bounds, #maybebound and we can apply @lem:inferred_cumulative_bounds_spec. Our goal is then, with #bounds, #maybebound being valid for $A$ and $C$ as assumptions, to derive a contradiction.
  
  We claim we are either in one of two cases:
  - `resource_profile_full` reported a time conflict, in which case we apply @lem:resource_profile_contradiction to derive a contradiction since no conflict should have been reported.
  - There is some $b in bounds$ s.t. #cannotsched = `true`, in which case we apply @lem:cannot_schedule_activity_valid to derive a contradiction since it should have returned `false` based on our assumptions.

  To finish the proof, observe that if #maybebound is non-empty, the fact that it is valid means it is in #bounds. If applying #cannotsched to it then returns `true`, we are in the second case.

  If either it is empty or did not return true, we could have that `resource_profile_full` reported a conflict, in which case we are in the first case. If it did not, we must have that the `any_true` found a $b in bounds$ s.t. there is an activity conflict, since otherwise the checker could not have returned `true`. So we are in the second case.
]


=== Implementation considerations <subsec:cumul:impl>

==== Control flow and errors

The pseudocode in the previous sections are written in a style that assumes the existence of more explicit control flow than exists in the language that the checker is implemented in (Rocq). This is done to aid readability. In truth, Rocq is a purely functional language and does not have the concept of an early return or the concept of an error. Instead, the fact that a function returned an error is inferred through different means. We highlight two examples.

1. The type signature of #resprofile in reality is simply `list N`. Instead, an error case is distinguished from a non-error case by setting the list to `nil`. This is primarily to allow the use of `map_valid`. 
2. #jmono[resource_profile_t] actual return type is `option N`, where the `None` case is the error. 

==== Reversed range input

We explicitly did not write an actual invocation of #resprofile in the pseudocode, as the actual implementation expects a range of times that is in _decreasing_ order, as opposed to the final profile, which is in increasing order. This is because `map_valid` reverses its input for performance reasons (as this allows writing it as a tail-recursive function).

==== Combined steps

A number of values are computed in a single iteration, as opposed to multiple ones, again for performance reasons. An example that actually has implications for the proof is the computation of the active list in #jmono[profile_to_active_list]. Instead of building another range, then combining and then mapping, a function called `z_map` is used that computes the time inputs as it recurses. 


#pagebreak()


== Building blocks

=== Bounds <sec:bounds>

=== `sublist` <sec:sublist>

=== `xn_sum` and `sub_list` <sec:xnsum>

Given two lists $l_1, l_2$ of type `(String * Nat)`, a sufficient condition for the sum of the `Nat`s in the lists (which we call `xn_sum`) would be for $l_1$ to not have duplicates and for every element of $l_1$ to also be an element of $l_2$.

However, this is a stricter condition than necessary. We can imagine a situation where certain variables actually do occur multiple times, because they are somehow weighted. A weaker condition is to ask that $l_1$ is a `sub_list` of $l_2$, which we define as follows:

#definition[
  Given two lists $l_1, l_2$ of type `list A`, we say that `sub_list`($l_1$, $l_2$) iff $forall a, a in l_1, #raw("count_occ")\(a, l_1) <= #raw("count_occ")\(a, l_2)$.
]

Here, `count_occ` counts the number of occurrences of an element in a particular list. This does require there to exist some way to compare the equality of items in a list, but this is always the case for our purposes. 

We prove a number of results for this notion of `sub_list` related to using `count_occ` in inductive proofs. For this, we introduce the function `remove_once` which removes an element exactly once. We also prove that the earlier condition of $l_1$ not containing duplicates and every element in $l_1$ also existing in $l_2$ implies `sub_list`. This follows immediately when you realize that an element existing means the count is at least one and when a list has no duplicates all counts are one.

Finally, we prove that `sub_list`($l_1$, $l_2$) indeed implies that `xn_sum`\($l_1$) $<=$ `xn_sum`\($l_2$). 

#proof[
  Given an arbitrary $l_1$, we aim to prove that for all $l_2$ s.t. `sub_list`($l_1$, $l_2$), we have `xn_sum`\($l_1$) $<=$ `xn_sum`\($l_2$). We prove this using induction on $l_1$.

  Base case: Given $l_1 = "nil"$, we see that the sum is equal to zero. Since we are working only with `Nat`s, and given that `xn_sum`\($l_2$) is an arbitrary `Nat`, we have proven the base case.

  Induction step: Given an element $a$ and arbitrary $l_1$, we must prove that `sub_list`($a :: l_1$, $l_2$) implies the sum of $a :: l_1$ is less than the sum for $l_2$ for all $l_2$. Our induction hypothesis is for our specific $l_1$ and for arbitrary $l_2$.

  We first let $l_2$ be arbitrary. We first notice that $a$ must occur at least once in $l_2$ because fo the `sub_list` relationship. Next, notice that `sub_list`($a :: l_1$, $#raw("remove_once")\(a, l_2$)) holds. By using the induction hypothesis on this, we have that `xn_sum`\($l_1$) $<=$ `xn_sum`$\(#raw("remove_once")\(a, l_2))$ holds. But adding $a$ to both lists increases the value on both sides exactly by the number value of $a$. This proves the induction step. Therefore, we are done.
]

=== `build_range`, `is_range` and `is_as_range` 

== Automation and proof search

#pagebreak()

= Discussion

== Domain representation

Our domain representation based on perforated intervals is rather non-standard. Indeed, we know of no special term to refer to this representations (perhaps due to its simplicity) and have used the term perforated interval in this work. Instead, in CP applications common domain representations are range sequences,  just an interval, or fully enumerated domains (the latter can be implemented in numerous ways, such as with a bitvector). For example, in the Chuffed @chuffed2025 constraint solver, integers are either fully enumerated or represented as a single interval. The Gecode @gecode2025 constraint solver uses range sequences. A newer representation is that of sparse sets @leclement2013sparseset, used e.g. in MiniCP @michel2021minicp. There exists also gap intervals trees @pohitos2010gaptrees. There has also been formalization work of other representations, see @ledein2020intervallist for lists of intervals and @dubois2025sparsesetverif for sparse sets. 

Some of these are clearly not feasible to fully replace the perforated interval, because they have no support for infinite domains. However, they _could_ be used without issue to replace the way we implement the set of holes, which relies only on the features of the `MSet`-interface in Rocq. Therefore, any implementation that satisfies this interface could serve as a drop-in replacement for our choice of an implementation based on red-black trees in the standard library.

Many propagators reason only over the bounds of variables. Therefore we can expect many facts to not contain any $!=$-constraints. 

== Fact deduction

// ```
// 45 - 04/11/24 - 1	    ->	  kick-off at november 6, 2024
// 46 - 11/11/24 - 2
// 47 - 18/11/24 - 3
// 48 - 25/11/24 - 4
// 49 - 02/12/24 - 5
// 50 - 09/12/24 - 6
// 51 - 16/12/24 - 7
// 52 - 23/12/24 - x (holiday)
// 53/1 - 30/12/24 - x (holiday)
// 2 - 06/01/25 - x (moving)
// 3 - 13/01/25 - x (moving)
// 4 - 20/01/25 - 7.5 (moving)
// 5 - 27/01/25 - 8.5
// 6 - 03/02/25 - 9 (moving+delay)
// 7 - 10/02/25 - 10	    ->	  first stage ready by 16/2
// 8 - 17/02/25 - 1	    ->    WMM presentation 1
// 9 - 24/02/25 - 2
// 10 - 03/03/25 - 3
// 11 - 10/03/25 - 4
// 12 - 17/03/25 - 5
// 13 - 24/03/25 - 6
// 14 - 31/03/25 - 7
// 15 - 07/04/25 - 8
// 16 - 14/04/25 - 9
// 17 - 21/04/25 - 10
// 18 - 28/04/25 - 11
// 19 - 05/05/25 - 12    ->    WMM presentation 2
// 20 - 12/05/25 - 13
// 21 - 19/05/25 - 14	  ->    greenlight ready by 25/5
// 22 - 26/05/25 - 1
// 23 - 02/06/25 - x (course)
// 24 - 09/06/25 - x (course)
// 25 - 16/06/25 - x (course)
// 26 - 23/06/25 - 2
// 27 - 30/06/25 - 3
// 28 - 07/07/25 - 4
// 29 - 14/07/25 - 5	    ->    hand in final version by 17/7
// 30 - 21/07/25 - 6	    ->    defense by 27/7
// ```
