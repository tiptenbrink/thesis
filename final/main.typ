#import "ams.typ": ams-article, ams-biblio
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#import "@preview/algo:0.3.4": algo, i, d, comment, code, _algo-default-keywords
#import "@preview/curryst:0.3.0": rule, proof-tree

#import "@preview/great-theorems:0.1.2": *
#import "@preview/rich-counters:0.2.2": *




#show: ams-article.with(
  title: ["Proof step checking in a formally verified constraint programming unsatisfiability proof checker" \ Tip ten Brink],
)
#let mathcounter = rich-counter(
  identifier: "mathblocks",
  inherited_levels: 1
)
#show: great-theorems-init

#set raw(syntaxes: ("Custom.sublime-syntax", "Tiplang.sublime-syntax"))

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

#let pinkl = oklch(70%, 0.1, 20deg, 15%)
#let greyl = oklch(70%, 0, 20deg, 15%)
#let ochrl = oklch(70%, 0.1, 55deg, 15%)
#let bluel = oklch(70%, 0.1, 240deg, 15%)

#let cc = $frak(c)$
#let uu = $frak(u)$

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

#let mymathblock(type, color) = {
  mathblock(
    blocktitle: type,
    counter: mathcounter,
    fill: color,
    inset: (x: 1em, y: 0.8em),
    radius: 0em,
    prefix: (count) => {
      [*#type #count*]
    },
    titlix: (title) => [(#title):]
  )
}


#let definition = mymathblock("Definition", bluel)

// #let definition = thmbox("definition", "Definition", base_level: 1, inset: (x: 1.2em, y: 0.8em), radius: 0em, fill: bluel)
#let example = mymathblock("Example", ochrl)
#let theorem = mymathblock("Theorem", pinkl)
#let lemma = mymathblock("Lemma", pinkl)
#let procedure = mymathblock("Procedure", greyl)

#let mycodeblock(type) = {
  mathblock(
    blocktitle: type,
    counter: mathcounter,
    fill: greyl,
    inset: (x: 1em, y: 0.8em),
    radius: 0em,
    prefix: (count) => {
      [*#type #count*]
    },
    titlix: (title) => [(#title):]
  )
}

#let mycodedesc(type) = {
  mathblock(
    blocktitle: type,
    counter: mathcounter,
    fill: greyl,
    inset: (x: 1em, y: 0.8em),
    radius: 0em,
    prefix: (count) => {
      [*#type #count*:]
    },
    titlix: (title) => [\ #title]
  )
}

#let pseudocode = mycodeblock("Pseudocode")
// #let pseudocode = thmbox("pseudocode", "Pseudocode", separator: [#linebreak()], namefmt: name => {
//   //set text(font: "New Computer Modern Mono", size: 10pt) 
//   //[(*#name*)]
//   [(#name)]
// }, base_level: 1, inset: (x: 1em, y: 0.8em), radius: 0em, fill: greyl)

#let snippet = mycodeblock("Snippet")

#let notation = mymathblock("Notation", greyl)

// #let funclink(name: "name_me") = {
//   [#figure(kind: "function", supplement: name) #label("fun" + name)]
// }

#let funlink(label_name, name) = {
  let pseudo_nmbr = context {
    let label_el = query(label_name).first()
    let head_ctr = (mathcounter.at)(label_name)
    let label_ctr = label_el.counter.display()
    let head_ctr_p1 = (head_ctr.first(), head_ctr.at(1) + 1)
    // link(label_name, )
    [(Pseudocode #numbering("1.1", ..head_ctr_p1))]
  }
  [#metadata(("funlink", jmono(name), pseudo_nmbr))#label("fun:" + name)]
  // [
  //   // #figure(kind: "funlink", supplement: cnt, [#sym.zws]) #label("fun:" + name)
  // ]
}

#let fundesc = mycodedesc("Function Description")

// #let funcdesc(capt, content, name: "name_me", label_nm: none) = {
//   //#set par(justify: false)
//   show figure: set align(left)

//   show figure.caption: cpt => {
//     strong({
//       [Function Description ]
//       context counter(heading).get().first()
//       [.]
//       context cpt.counter.display(cpt.numbering)
//     })
//     [\ ]
//     cpt.body
//   }
//   show figure: fg => {
//     block(fill: greyl, inset: (x: 1em, y: 0.8em), {
//         fg.caption
//         [#fg.body]
//       }
//     )
//   }

//   [
//     #figure(
//       placement: none, 
//       kind: "function",
//       supplement: name,
//       caption: capt,
//       content
//     ) #{ if label_nm != none { label(label_nm) } }
//   ]
// }

#show ref: it => {
  let el = it.element
  if el == none {
    it
  } else if el.func() == figure {
    if el.kind == "function" {
      let sec_cnt = context counter(heading).at(el.location()).first()
      jmono[#el.supplement]
      [ (Function Description ]
      sec_cnt
      [.]
      link(el.location(), [#el.counter.get().first()])
      [)]
    } else {
      it
    }
  } else if el.func() == metadata {
    if type(el.value) == array and el.value.first() == "funlink" {
      if it.supplement == [l] {
        link(it.target, [#el.value.at(1) #el.value.at(2)])
      } else {
        link(it.target, [#el.value.at(1)])
      }
    }
  } else {
    it
  }
}

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

#let nonumber(body) = {
  set heading(numbering: none)
  body
}

#let proof_table(rows, caption, rules: true) = {
  let total_rows = rows.len() / 3 + 1 // +1 for header
  let headers = if rules {
    ([*Index*], [*Fact*], [*Rule*], [*Implied by*])
  } else {
    ([*Index*], [*Fact*], [*Implied by*])
  }
  figure(
    table(
      columns: if rules { (2fr, 7fr, 3fr, 3fr) } else { (auto, auto, auto) },
      align: (center, left, left),
      stroke: (x, y) => if y == total_rows - 1 { (top: 0.25pt) } else { none },
      fill: (x, y) => if calc.even(y+1) { luma(240) } else { white },
      inset: 6pt,
      ..headers,
      ..rows
    ),
    kind: "proof",
    supplement: "Proof",
    caption: caption
  )
}

// ```
// Planning:
// 1. Finish the main human-readable proofs in the writing (not much work)
// 2. Finish the "Implementation considerations" sections in the results, which will go into more detail about important implementation details and lessons learned from them. (end of this week)
// 3. Add a section about the process of developing these proofs, most likely in the discussion (it therefore wouldn't really be the main "result" of my thesis, as I think the domain reasoning theory and the actual proofs are enough, but would like to hear your opinion). This part I expect to form the bulk of the work.
// 4. Discussion about the proof results/developments
// 5. Rewrite the preliminaries to only contain information relevant for the rest of the thesis. 
// 6. Rewrite the introduction
// 7. Improve the structure and readability. Currently, it's almost entirely text. Graphics and clearer separations and highlighting important parts (through boxes or other measures) could improve this. Furthermore, based on Benedikt's advice (I had a meeting with him a few week back) I want to link each human-readable lemma to the corresponding formal proof/code. I also need to figure out better syntax highlighting for the pseudocode.

// Planning:
// 1-3 July 16
// 4-6 July 22 first full draft!

// In the third week I would then finish 4/5/6 up to the point that there is a rough draft of the full document, which I would like to discuss the week after. Hopefully, by the 24th of July I then have a version that is greenlightable. I will be away the next week on vacation if indeed that goal is achieved. Hopefully we can have the actual greenlight meeting in the first week of August, after which I will prepare my defense and work on point 7 so that I can hand in the final version when you return and have the defense in the first week of September (or second depending on the exact timing). If you think this is realistic, I would like to already set a tentative date for the defense that I can share with close friends and family, to increase the likelihood of them being able to attend.
// ```

#pagebreak(weak: true)

#nonumber[= Abstract]


= Introduction

// #todo[The following still needs to be worked out]

// Research questions, from higher-level to lower level
// + How can we increase the confidence in optimality and infeasibility results in constraint programming solvers? (with a special interest in LCG solvers)
//   - By logging solver decisions and developing a proof format
// + How do we develop a proof format?
//   - By following the lessons of SAT proof formats and adapting it so it works well for LCG solvers
// + How can we check a constraint programming infeasibility proof (of particular type)?
//   - By converting it to pseudo-boolean, ...
//   - or: by building a checker that uses native constraint programming reasoning: nogood deduction and inference checking
// + How do we do inference checking? *(from this point on my contributions begin)*
//   - By taking facts $A -> q$ and checking $A and not q -> bot$ (where we interpret $A and not q$ as a domain)
//   - By determining for a particular propagator what kind of conflicts can occur
// + How can we ensure that the checker itself makes no mistakes?
//   - By formally verifying it
// + How can we do formally verified deduction?
//   - By tracking domains with a easily verifiable data structure
// + How can we do formally verified inference checking?
//   - By using the domain tracking for interpreting $A and not q$ as a domain

// *Three main sub-questions:*
// 1. How can we develop inference checker algorithms for propagator reasoning in constraint programming unsatisfiability proofs?
// 2. How can we _formally verify_ these inference checker algorithms?
// 3. How can we formally verify the deduction step in a constraint programming unsatisfiability proof checker?

// As one single research question: *How can we develop formally verified inference checkers and formally verify the deduction step in a constraint programming unsatisfiability proof checker?*

// What are my results?
// - Formally verified implementations of inference checking algorithms for two popular CP constraints + human-readable proofs; basically: conflict checking
// - Precise language for what verifying these things actually mean, the "requirements" of implementing an inference checker for a new constraint
// - Perforated intervals: theory and formal verification
// - Formally verified method for tracking domains
// - Formally verified implementation of deduction step

// #note[below begins the actual introduction]

Constraint Programming (CP) solvers are complex pieces of software. Their complexity is twofold: performance matters, so they are heavily engineered to solve problems as fast as possible. Furthermore, there is an inherent complexity to the algorithms and theoretical techniques used to find solutions, which have been developed over many years. Consequently, they have a large surface area for bugs. When these cause crashes or other observable misbehavior, this provides a signal that there are issues. If it does find a solution, even when there is some unknown bug, this is also not as problematic. This is because a solution can be checked to ensure it satisfies all constraints. The nefarious case is when the solver declares no solution exists, i.e., that the problem is unsatisfiable. How can we check that this is indeed the case? How do we know the solver did not miss some part of the search space due to some unknown bug? One avenue is to prove the solver's completeness @carlier2012certified, which would ensure that if a solution exists, it would find it. However, this is challenging, in particular without sacrificing performance. Instead, the solver can record the steps it took to determine the unsatisfiability of a particular instance, producing a proof of unsatisfiability. This proof can then be verified by a program that is more trusted than the solver. This approach, known as proof logging, has already seen great success. This success began with SAT solvers (see Biere et al. @biere2021handbook, Ch. 15 for a detailed overview), where nearly every modern solver that participates in competitions now produces proofs. In fact, it is now mandatory to participate in competitions @sat2013.

This success has only recently been extended to CP solvers. Flippo et al. @flippo2024proof have shown that a modern LCG (lazy clause generation, @feydy2009rengineered) solver can be instrumented to produce unsatisfiability proofs in a format inspired by the DRUP format @goldberg2003unsatcnf @gelder2008rup in SAT. However, while producing such proofs has now been demonstrated, verifying them remains a challenge. In the work of Flippo et al., in order to be verified, the CP problem proof had to be encoded in a pseudo-Boolean model @gocht2022auditable. Among the main strengths of CP is the ability to efficiently encode the problem with constraints that retain much of the problem's structure. Encoding this in a pseudo-Boolean model loses much of this. Furthermore, the CP proof can mention the constraint-specific reasoning that solvers employ in order to prune the search space more efficiently. When encoding into a format that does not know about these types of reasoning, verification can also not make use of this specialized reasoning.

This has led to a collaborative effort, of which this work is a part, to verify a CP proof using the strengths of CP, which means developing a CP proof checker that can perform specialized reasoning over particular constraints. This requires explicitly supporting these constraints in the checker. This entirely removes the encoding step, but requires more complicated verification algorithms. This verification must be trusted to a higher degree than the solver, as otherwise the conclusion can still be questioned. Therefore, the checker can be formally verified, achieving the highest possible level of trust in its correctness. We note that in the case of pseudo-Boolean proofs, the verification is straightforward enough that this is not an absolute requirement.

To create a formally verified CP checker, a new proof system @sidorov2025checker was developed that better captures the integer reasoning performed by CP solvers and does not require re-encoding the problem. Proofs are sequences of proof steps. The final conclusion requires that each individual proof step is valid, in addition to the reasoning that actually extracts this final conclusion from these valid proof steps. A natural question is then to focus on the individual proof steps and ask: _How can we develop formally verified checkers for individual proof steps in a CP unsatisfiability proof checker_? Our contribution is then to determine how to check these individual steps using formally verified algorithms, leaving the overall checker to the wider collaboration.

In the proof system of Sidorov et al. @sidorov2025checker, there are two types of proof steps: inferences, which involve reasoning over particular constraints, and deductions, which combine information of multiple inferences to deduce new facts. We also separate inferences into two types: inferences that correspond to a particular type of CP propagation algorithm, and inferences that are more general-purpose. The latter case includes inferences that rewrite previously deduced facts as well as inferences that bring a variable's initial domain into the context. This work only focuses on the first category, i.e., propagator inferences. The other category was handled by the wider effort this work is a part of. As there are many different CP constraints, often with multiple propagation algorithms, each with their own specialized reasoning, verifying these propagator inferences requires developing many inference checking algorithms. Therefore, we cannot hope to develop verification algorithms for every constraint and propagator in this work. Instead, we restrict ourselves to two popular constraints, alldifferent and (timetable) cumulative. Furthermore, we develop a general methodology that can be applied to other constraints to ease the development and allow the checker to be extended in the future. For the deduction step, however, we do not develop a general methodology, as it is independent of the constraint type and is fully general. Instead, we simply present its implementation and formalization. Furthermore, we introduce a theory and formalization of perforated intervals, which is pivotal in the implementation and formalization of both inference and deduction checking. Perforated intervals are a representation of (potentially infinite) subsets of $ZZ$, which are used to describe variable domains. They consist of (optional) bounds and a set of holes. We describe the operations that can be performed on perforated intervals and under what conditions these can be performed efficiently. These operations and properties are all formally verified. Finally, we present some findings of working with Rocq, which is the interactive theorem prover and programming language used for the implementation of the checker.

// This work is part of a larger program that seeks to improve the reliability of CP solvers. Previous work addressed this with an approach to produce proofs of unsatisfiability and an initial proof format that could be encoded as a pseudo-Boolean proof. More specifically, this work is part of a follow-up effort that wants to improve the problems with that approach by developing a formally verified CP unsatisfiability proof checker. The question then becomes, how can we develop this checker and how do we improve the proof format to make use of native CP reasoning? Concurrently to our contributions and as part of the larger effort, this improved format and the overall structure of the checker were developed. 

// However, in particular this left two questions unanswered, which form our main contributions. First, how can we develop formally verified inference checkers? Second, how can we formalize the deduction checker in a constraint programming proof checker? To answer the first question, we develop a methodology for developing inference checkers, present two specific implementations and formalizations and introduce core components (perforated intervals and domain maps), as well as describing findings specific to working with an interactive theorem prover (Rocq, in our case). For the second question, we formalize the deduction step and the core components necessary for its formalization (again, preforated intervals and domain maps).

// However, there are a number of unanswered questions we seek to address in this work.

// and propagators and the checker must be able to replicate the reasoning performed by these constraints and propagators. This requires explicitly supporting them in the checker. The checker is more reliable than the solver not just because it is simpler, as e.g. it does not have to do search, but also because it is formally verified in Roqc (formerly Coq). That is why we call what the checker does _proof certification_.

We now describe the structure of this thesis. First, in @sec:background we present the background necessary for understanding our approach and results. This includes a description of the proof system and checker used in this thesis, which are being developed concurrently to do this thesis by Sidorov et al. @sidorov2025checker. We then describe our general approach in @sec:approach. In particular, we describe the difference between handling deductions and propagator inferences and exactly which proof steps are considered in this work. Then we describe our contribution in 6 top-level sections: *@sec:methodology)* methodology for developing formally verified propagator inference checking algorithms; *@sec:perfint)* the formalization and implementation of a theory for converting atomic constraints into a holes-based domain representation (termed perforated intervals). This is foundational to all the other results in this thesis; *@sec:deduct)* the implementation and formalization of the fact deduction procedure (@proc:deduct), which also discusses maps of variable domains; *@check:alldiff)* an alldifferent checker capable of verifying inferences for alldifferent constraints where the premises are without redundancy; *@check:cumul)* a checker capable of verifying inferences for cumulative constraints that are derived using timetable reasoning; *@sec:rocq)* general findings for working in Rocq in the context of constraint programming. Having described our results, we discuss them in @sec:discussion.
// #todosm[also describe impl consider?]
// Furthermore, point 3 and 4 will also describe building blocks that are useful beyond just the alldifferent and cumulative constraints. Section 1-4 will also have an "implementation considerations" subsection that are specific to the implementation in Rocq. Their main part will not require any knowledge of Rocq.

#pagebreak(weak: true)

= Background <sec:background>




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

#let cD = $cal(D)$
#let cX = $cal(X)$

// Our main goal is to determine how to develop checkers for individual proof step in a formally verified CP unsatisfiability proof checker of the CP proof system of Sidorov et al. @sidorov2025checker. More specifically, we aim to implement and formalize the proof system's deduction proof step and develop a methodology for implementing checkers for inference steps describing constraint programming propagator reasoning. 

== Constraint Programming

We begin with a formal treatment of constraint programming. 
// Compared to the standard definitions of e.g. @rossi2006handbook, which are more set-oriented, we choose more "functional" definitions that are more convenient for formal verification.

#definition(title: [Domain])[
  A _domain_ $cD$ is a mapping from a set of variables $cX$ to sets that represent the values a variable is allowed to take. For any variable $x in cX$, we require $cD(x) subset.eq ZZ$.
]

In the theory of constraint programming, it is possible to replace $ZZ$ with other sets. However, our approach is tailored to integers. It is also common to work only with finite domains, because a complete solver can then be constructed using a simple backtracking procedure. Most practical solvers also require this, but for our purposes, this is not important. In fact, the primary domain representation introduced in this work supports infinite subsets of $ZZ$. 

#definition(title: [Assignment])[
  Given variables $cal(X)$, an _assignment_ is a mapping $theta: cal(X) -> ZZ$. Such a $theta$ is said to be _consistent_ with respect to a domain $cal(D)$ if for all $x in cX$, $theta(x) in cD(x)$. We use $Theta(cal(X))$ to refer to the set of all possible assignments over $cX$.
] <def:assignment>

#let Dcross = $D_times (X)$

// We consider only finite sets of variables. We use $Theta(cal(X))$

#definition(title: [Constraint])[
  Given variables $cX = {x_1, ..., x_n}$, a _constraint_ is a predicate $c: Theta(cX) -> {ttrue, ffalse}$. An assignment $theta$ _satisfies_ a constraint $c$ if $c(theta) = ttrue$. A domain $cD$ _satisfies_ a constraint $c$ if every assignment consistent with $cD$ satisfies $c$.
] <def:constraint>

For a constraint to be practical, we expect it to be a computable function that terminates in polynomial time.

#definition(title: [CSP])[
  A _Constraint Satisfaction Problem_ (CSP) is a triple ($cal(C)$, $cal(X)$, $cal(D)$), where $cal(C)$ is a set of constraints, $cal(X)$ is a set of variables and $cal(D)$ is a domain (for the set of variables $cX$).
]

#definition(title: [Solution])[
  An assignment $theta$ is a _solution_ to a CSP $(cal(C), cal(X), cal(D))$ if for all $c in cal(C)$, it holds that $c(theta) = ttrue$, i.e., the assignment satisfies all constraints.
]

We call a CSP satisfiable if there exists at least one solution. A solution then serves as a certificate for the satisfiability claim of a CSP. Checking whether the claim holds only requires checking whether the solution satisfies every constraint. This is not a hard problem.

A more general problem is the _Constraint Optimization Problem (COP)_, which includes, in addition, an objective function that must be either minimized or maximized. Suppose we have such a COP, which consists of a CSP $(cal(C), cal(X), cal(D))$ and an objective function $f(cal(X))$. We can verify optimality by first checking that the optimal solution with objective $p^star$ satisfies the underlying CSP and second by determining that the underlying CSP with the addition of the constraint $f(cal(X)) > p^star$ (or $<$ in the case of a minimization problem) is unsatisfiable. For this reason, we will now concern ourselves only with CSPs and infeasibility and will often use the term "CP (Constraint Programming) problem" to refer to a CSP.

We now provide a few simple examples to show how the earlier definitions work.

#example(title: [Linear inequality])[
  A linear inequality $x + y <= 20$ is then formally a function $c$ that takes an assignment $theta$ that returns $ttrue$ if $theta(x) + theta(z) <= 20$. Let an example assignment be $angle.l theta(x) = 90, theta(y) = 2, angle.r$. This assignment does not satisfy $c$, as we have that $90 + 2 lt.eq.not 20$. However, the assignment $angle.l theta(x) = 12, theta(y) = -17 angle.r$, _does_ satisfy $c$. 
] <ex:asgndom>

#example(title: [CSP and solution])[
  Consider the same variables as in @ex:asgndom, as well as the constraint $c$. Furthermore, consider the domain $angle.l cD(x) = [0, infinity), cD(y) = [4, 100]$ and a second constraint $c'$ representing the equation $y != 20$. Then $({c, c'}, cX, cD)$ is a CSP. Furthermore, the assignment $angle.l theta(x) = 12, theta(y) = 4 angle.r$ is a solution to the CSP.
]

When domains are finite, practical CSP solvers will eventually enumerate all solutions. However, they speed up this process by also interleaving search with reasoning that makes use of the problem's structure. This reasoning is called _propagation_ or _filtering_ and cuts off parts of the search space that cannot be part of any feasible solution. This happens by explicitly pruning the currently stored domains. 

// Furthermore, in practice, solvers do not accept constraints of arbitrary form. Instead, they support a finite collection of constraint types, each with known rules for determining whether a particular assignment satisfies it. Frequently, these constraints also have a particular structure that allows tightening the domains of variables involved in the constraint without having to evaluate every possible assignment. The following, more restrictive definition captures this fact.

// #definition([Constraint predicate])[
//   A _constraint_ is a computable function that, given an assignment of variables, spits out whether the constraint is satisfied or not. We also call this function the _constraint predicate_. Hence, if we have $n$ variables involved in the constraint over a universe $UU$ (which in our case is generally $ZZ$), a constraint is a function $UU^n -> {ttrue, ffalse}$.
// ] <def:constraint_comp>

// Given a constraint predicate $c$, we can create an instance of the previous definition (@def:constraint) by considering the set ${v : c(v) = ttrue}$. Furthermore, if we want to be able to efficiently verify whether an assignment satisfies the constraint, we expect the constraint function to terminate in polynomial time.

In the next two sections, we discuss two different constraints, alldifferent and cumulative. These were selected based on a combination of popularity and intuition about how challenging they would be to verify. During the discussion of these constraints, we also introduce the intuition necessary for verifying the reasoning performed during propagation. 


#let algo_keywords = _algo-default-keywords + ("match", "with", "case", "lambda", "def", "continue", "enum")

#show: thmrules.with(qed-symbol: $square$)
#let proof = thmproof("proof", "Proof")

== Alldifferent <sec:prelim:alldiff>

We first introduce the alldifferent constraint, which allows constraining variables to take on distinct values. 

#definition(title: [Alldifferent])[
  Given a set of variables $X$, the _alldifferent$(X)$_ constraint is defined to return #ttrue given an assignment $theta$ if for all pairs $x, y in X$ s.t. $x != y$, we have that $theta(x) != theta(y)$.
]

Particular algorithms used to prune domains for a particular type of constraint are known as _propagation algorithms_. We will not discuss the exact requirements for an algorithm to qualify as a propagation algorithm, as for our purposes, we need only to understand that they map domains to domains. We refer to @schulte2009weakmonotonprop and @rossi2006handbook (§14.1.1) for details.

As alldifferent is a popular and simple (in the sense that it is simple to define, as it is not simple to solve) constraint, there are many different propagation algorithms (see e.g. @downing2012explainalldiff for algorithms for modern CP solvers and the earlier @vanhoeve2001alldifferent for a broad survey). Propagation algorithms can be differentiated not only by their time complexity but also by their propagation strength. The following section will introduce a way to characterize this, called _local consistency_.

=== Local consistency

Consider the following example.

#let alldiff = jmono[alldifferent]

#example(title: [Bounds consistent propagation])[
  Let $c = alldiff(x, y_1, y_2, z_1, z_2)$, $cD(x) = {1, 2, 3, 4, 5}$, $cD(y_1) = {0, 1}$, $cD(y_2) = {0, 1}$, $cD(z_1) = {2, 4}$, $cD(z_2) = {2, 4}$. Then we can propagate that $x >= 2$, because if $x$ were equal to 1, $y_2$ and $y_1$ would both have to be zero, which is not allowed.
] <ex:boundscons>

The propagation removed 1 from the domain of $x$. In fact, we can now say the domain has reached a certain level of _local consistency_, where local indicates we are speaking only of consistency with regards to this one constraint (local) as opposed to the entire problem (global). This specific level of consistency is known as _bounds$(ZZ)$ consistency_ @choi2006boundscons. Loosely, this means the lower and upper bounds of each variable domain are part of a solution containing only integers that fall between the upper and lower bounds of the domain of their respective variable. We can define this formally as follows (where we assume the domains are all integer):

#definition(title: [Bounds consistency])[
  An integer domain $cD$ is _bounds$(ZZ)$ consistent_ with respect to a constraint $c$ and variables $X$ if we have that $forall x in X$ and $forall d in {min(cD(x)), max(cD(x))}$, there exists an assignment $theta$ consistent with $cD$ that satisfies $c$ such that $theta(x') in [min(cD(x')), max(cD(x'))]$, for all $x' in X$ s.t. $x' != x$.
]

#example(title: [Check bounds consistenty of domain])[
  To see why the domains of @ex:boundscons are now bounds consistent after propagating $x >= 2$, we must check the lower and upper bounds of all variables. For all bounds except the new lower bound of $x$, clearly there exists a solution. For $x = 2$, set $y_1 = 0$, $y_2 = 1$, $z_1 = 3$, $z_2 = 4$. Note that setting $z_1 = 3$ is allowed since $3 in [min(D(z_1)), max(D(z_1))]$.
]

There exist polynomial-time propagation algorithms for alldifferent that can achieve this level of consistency. This is not the case for every constraint, since such an algorithm existing for the next constraint we discuss, cumulative, would imply $P = N P$. However, for alldifferent we can actually do even better. The strongest possible form of local consistency is known as domain consistency, which we illustrate in the next example.

#example(title: [Inconsistent values])[
  While the domains of @ex:boundscons were bounds consistent after propagating $x >= 2$, the domains still contain values that cannot be part of any feasible solution. If $x = 2$, then $z_1$ and $z_2$ would both have to be 4, which is not allowed. Furthermore, if $x = 4$, $z_1$ and $z_2$ would both have to be 2, which is also not allowed. Once we have done this, $D(x) = {3, 5}$, and there exists a solution containing any value from any domain.
]

We now give the formal definition of domain consistency. It can be interpreted as requiring that if we fix a variable to some arbitrary value in its domain, there exists at least one assignment satisfying the constraint.

#definition(title: [Domain consistency])[
 A domain $cD$ is _domain consistent_ (also known as generalized arc consistent or hyper-arc consistent) with respect to a constraint $c$ and variables $X$ if $forall x in X$ and $forall d in cD(x)$, there exists an assignment $theta$ consistent with $cD$ that satisfies $c$ such that $theta(x') in D(x')$, for all $x' in X$ s.t. $x' != x$.
]

We have seen that propagation algorithms can be differentiated by time complexity and by specific notions of propagation strength (local consistency). This involved some specific examples of propagations. The next subsection discusses how we can formally describe such propagations, which will be an important step towards introducing the proof system for verifying the unsatisfiability of CP problems. This is because, when a solver propagates, it relies on these propagations for its eventual unsatisfiability conclusion. Therefore, the proof system must somehow describe these propagations. Furthermore, the formal description will provide us with a clue about what properties of a constraint we want to use.

== Formal description of propagation outputs <sec:formaldesc>

We now illustrate in an example how a particular propagation output can be described by a simple logical statement, which can then be certified.

#example(title: [Formally describing propagation])[
  Consider a particular propagation for $c = alldiff(x, y, z)$ that maps the input domain $D(x) = {3, 4}, space D(y) = {3, 4}, space D(z) = {3, 4, 5}$ to $D'(z) = {5}$ (where the domains for $x$ and $y$ are unchanged). This is because assigning $z$ to 3 or 4 would mean there are not enough possible values for $x$ and $y$. However, if the domains for $x$ and $y$ were different, this might not be valid. 

  To verify this particular reasoning, we want to establish a logical statement representing that, given an assignment $theta$ consistent with particular domains for $x$, $y$, and $z$, we know for sure that $theta(z)$ cannot be 3 or 4 if we also want $theta$ to satisfy $c$. The natural way to represent this is in an implication, where the premises include the initial domains and the constraint being satisfied, and the right-hand side contains what we can then conclude.
  
  $ c(theta) = ttrue and theta(x) in D(x) and theta(y) in D(y) and theta(z) in D(z) -> theta(z) != 3 and theta(z) != 4 $

  On the right-hand side, we have written the domain update as $theta(z) != 3 and theta(z) != 4$. In practice, any domain update will remove some values or tighten a bound. This is equivalent to satisfying some additional constraints requiring this removal or a tighter bound. For example, we can write $theta(z) != 4$ as "$theta$ satisfies the constraint $z != 4$". In this case, we could require $theta$ to satisfy the constraint $z >= 5$ or $z = 5$. These constraints, known as atomic constraints, play a fundamental role in many CP solvers and also in the proof system. We use the notation $[x diamond.small c]$, where $diamond.small in {<=. >=, =, !=}$. We can go further and use these even for representing the domains. Furthermore, we will not include $c(theta) = ttrue$ in the statement, leaving this as an implicit requirement, giving:

  #numbered[
  $ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z >= 3] and [z <= 5] -> [z != 3] and [z != 4] $ <eq:genfact>
  ] 

  We call the above a _generalized fact_, to distinguish it from a more narrowly defined notion of _fact_ that we introduce later in @def:fact.
] <ex:geninf>

An important property of the above facts is that, as implications, they can be converted to equivalent logical statements with an empty right-hand side, i.e., a fact $p -> q$ is equivalent to $p and not q -> bot$ (where $bot$ indicates conflict or contradiction). @eq:genfact would then be written:

#numbered[
  $ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and ([z = 3] or [z = 4]) -> bot $ <eq:genfactconfl>
]

This is valid, since when $theta(z) = 3$ or $theta(z) = 4$, the constraint cannot be satisfied and our implicit premise $c(theta) = ttrue$ is falsified. However, the left-hand side now contains nested structures and both $and$ and $or$ connectives. Instead, consider that facts of the form $p -> q_1 and q_2 and ... and q_m$ are equivalent to a series of facts $p -> q_1$, $p -> q_2$, ..., $p -> q_m$. Hence, verifying @eq:genfactconfl is reduced to verifying the following facts:

#numbered[
$ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z = 3] -> bot \
 [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] and [z = 4] -> bot $ <eq:genfactmulti>
]

Here, we have a very simple structure on the left-hand side, which is simply a specification of a particular domain. During verification, it must then be established that this particular domain would admit no solution. This is often easier than exactly replicating the same right-hand side. Before showing this with an example, we formally define atomic constraints and introduce some useful notation.

#definition(title: "Atomic constraints")[
  An _atomic constraint_ is a constraint defined by a variable $x$, $c in ZZ$ and $diamond.small in {<=, >=, =, !=}$, that given an assignment $theta$ returns $ttrue$ if $theta(x) diamond.small c$. For an atomic constraint $a$ (defined by $x, diamond.small$ and $c$), we overload the notation $[x diamond.small c]$ to mean the logical proposition $a(theta) = ttrue$ and $a$ itself.
] <def:atomic>

#notation(title: [Induced domain and domain as fact l.h.s.])[
  Let $cal(A) = a_1, a_2, ..., a_m$ be a collection of atomic constraints over the variables $cX$. Then $cD_(cal(A))$ refers to the domain induced by $cal(A)$, so for all $x$ in $cX$,  $cD_(cal(A))(x) = {n in ZZ : forall [x' diamond.small c] in cal(A) "s.t." x' = x, n diamond.small c}$. Furthermore, we will often write facts as $D -> q$ instead of $a_1 and ... and a_m -> q$, in which case $D$ is the domain induced by the fact's actual left-hand side. Furthermore, the fact $D and not q -> bot$ then refers to the fact $a_1 and ... and a_m and not q -> bot$.
]

We now present the example.

#example[
  Consider two propagators, $p_"weak"$ and $p_"strong"$. Here, $p_"weak"$ is a weaker propagator, so it cannot achieve the same level of domain tightening. Then, a propagator output for $p_"weak"$ might be are $D -> [x >= 3]$ and a propagator output for $p_"strong"$ might be $D -> [x >= 5]$. If we use a verification algorithm based on $p_"strong"$ and input $D$, we #todosm[finish]
]

In practice, the conversion of @eq:genfactconfl to @eq:genfactmulti does not happen during verification. Instead, facts such as @eq:genfact should be rewritten into multiple facts, each with only a single consequent, already during the production of the proof. The two facts we would then encounter in a proof would be the following (note that the facts in @eq:genfactmulti could also occur in the proof if the propagator had actually been given their left-hand side as inputs, in which case it would have found that they are a conflict):

#numbered[
$ [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] -> [z != 3] \
 [x >= 3] and [x <= 4] and [y >= 3] and [y <= 4] -> [z != 4] $ <eq:genfactsplit>
]

This allows us to now define a strategy for verifying propagator reasoning. 

#procedure(title: "Informal propagator verification strategy")[
  To verify a propagation of a propagator $p$ for a constraint $c$ that maps domains $D$ to $D'$, we use the following strategy:
  + Write $D$ as a conjunction of atomic constraints. We again use $D$ to refer to this conjunction.
  + Write $D'$ as a similar conjunction of atomic constraints $d'_1 and ... and d'_m $, such that $D and d'_1 and ... and d'_m$ represents exactly $D'$. Then, we have a generalized fact $D -> d'_1 and ... and d'_m$ (for this logical statement to be true, we implicitly assume the constraint $c$ to be satisfied)
    // #footnote[In the SMT literature we would call this making $c$ part of the 'background theory'])
  + Separate $D -> d'_1 and ... and d'_m$ into separate facts $D -> d'_1$, $D -> d'_2$, ..., $D -> d'_m$.
  + Verify a fact $D -> d'$ by assuming $D and not d'$ (which represents just another domain) and deriving that $c$ can then not be satisfied, i.e. $D and not d' -> bot$. This requires the construction of an algorithm $V$ that takes $c$ and a domain, and returns $ttrue$ if it can show that $c$ is unsatisfiable under that domain.
] <proc:verifystrat>

This will be the primary strategy through which we verify the specialized reasoning of propagators for particular constraints. This approach has many benefits, as many practical CP solvers can readily generate such facts (see @sec:solvinglogging, which discusses solving and proof logging in more detail). @proc:verifystrat builds upon previous work in two ways. First, consider the SAT problem, which is exactly a CSP but with Boolean variables and with constraints consisting of Boolean formulas (variables connected by $and$, $or$ and $not$). The SAT community pioneered RUP clauses (reverse unit propagation) @gelder2008rup @goldberg2003unsatcnf, which are also verified by negating the consequent and then deriving a conflict. This was brought to the more general CP context previously by the unpublished work of Gange et al. @gange1certifying.

We have seen, as mentioned in the final step of @proc:verifystrat, that in order to verify a propagation, we must be able to determine when a constraint has no solutions given a particular domain. We now return to alldifferent and discuss what is already known about this in the literature.

== Alldifferent (conflicts)

We seek a way to, given some domain (represented as a conjunction of atomic constraints), determine whether a constraint is unsatisfiable. In the case of alldifferent, there is a powerful theorem (originally by Hall @hall1935representatives, formulated also in @vanhoeve2001alldifferent) that tells us exactly when alldifferent admits a solution.

#theorem(title: "Hall")[
  Let $C(X)$ be an alldifferent constraint over the variables $X$ and let $D$ be their associated domain. Then there exists an assignment $v(X)$ that satisfies $C$ if and only if for every $K subset.eq X$, we have that $|union.big_(x in K) D(x)| >= |K|$.
] <thm:hall>

In other words, if there is no solution given a particular domain $D$, then there must exist some subset of variables such that the union of the domains of all these variables is strictly smaller than the number of variables in this subset. Note that we used exactly this principle in e.g. @ex:geninf to derive a conflict. However, this theorem states that in fact _every_ conflict implies the existence of a subset of variables with a smaller domain. This, combined with the fact that the required check to determine whether a subset $K$ is conflicting is very cheap, gives rise to a promising verification algorithm in the case that $K$ is known. First, we formally define the set we are interested in separately from the theorem's statement.

#definition(title: "Tight Hall set")[
  Let $C(X)$ be an alldifferent constraint over the variables $X$ and let $D$ be their associated domain. Then we call a $K subset.eq X$ a _tight Hall set_ if $|union.big_(x in K) D(x)| < |K|$.
]

In using the term _tight Hall set_, we follow the terminology of @vanhoeve2001alldifferent. 
To find a tight Hall set given a fact $F$ (and hence a supposedly conflicting domain $D_F$), we can use the same procedure as that used by domain-consistent propagation algorithms for alldifferent. Since we have not implemented this, we give only a summary. The procedure makes use of graph theory, which we will not describe in detail. This algorithm is originally due to Régin @regin1994alldiff, and we also refer to @vanhoeve2001alldifferent for more details.

#procedure(title: "Find conflicting subset")[
  1. Determine a maximum matching $M$ on the bipartite graph $G=(X, V, E)$, where $X$ is the set of variables, $V$ is the union of the domains $D$ of the variables in $X$ and $x v in E$ if $v in D(x)$. This matching can be obtained by e.g., Hopcroft-Karp @hopcroft1973maxmath.
  2. If the maximum matching $M$ does not cover $X$ (if it does, then there is no conflict), let $K$ be the set of variables reachable from the unmatched variables through $M$-alternating paths (this can be found through e.g., breadth-first search). Then $K$ is a tight Hall set.
] <proc:findhall>

We now move on to a different constraint, which does not have a powerful tool like Hall's theorem.

#pagebreak()

== Cumulative <sec:prelim:cumulative>

The next constraint, called _cumulative_ @aggoun1993cumulative, is frequently used in scheduling problems, and its language also reflects this. It has many variants, we adapt the definition used by MiniZinc @nethercote2007minizinc @minizinc_cumulative_2024.

#definition(title: [Cumulative])[
  Let $A$ be a set of activities, where for each activity $a in A$ there is a fixed processing time $duration(a)$ and resource usage $usage(a)$. Each activity is associated with a variable $start(a)$ that refers to the activity's start time. Then, given an assignment $theta$, an activity $a$ is _active_ at time $t$ if $theta(start(a)) <= t < theta(start(a)) + duration(a)$. There is also a global resource bound $R$. Then, the _cumulative$(A)$_ constraint returns #ttrue given an assignment $theta$ if at each time $t$, the total resource usage of all activities active at $t$ is less than or equal to $R$.
]

While for alldifferent there exists a polynomial time algorithm that decides unsatisfiability, determining whether a single cumulative constraint has a solution is already NP-hard. In fact, if we had a polynomial time propagator that achieves bounds($ZZ$)-consistency, this would already imply $P = N P$ @baptiste1999satcumul. Let us state an example of a cumulative constraint and a possible propagation.

#example(title: [Timetable reasoning])[@ex:cum:params shows an example of a cumulative constraint with 4 activities. The #lower and #upper columns refer to the lower and upper bounds of the domains of the activities' start times.
  #figure(
    table(
    columns: 5,
    stroke: (x, y) => (
      left: if x == 1 { 1pt + black } else { none },
      top: if y > 0 and calc.odd(y) { 1pt + black } else { none },
      bottom: if calc.odd(y) { 1pt + black } else { none },
      right: none,
    ),
    
    // header
    [*Activity*], [$usage$], [$duration$], [$lower$], [$upper$],
  
    // rows
    [$x$], [1], [2], [0], [10],
    
    [$a$], [1], [2], [0], [1],
    
    [$b$], [1], [3], [0], [1],
  
    [$c$], [2], [2], [2], [3],
    ),
    caption: [Activity parameters],
  ) <ex:cum:params>

  For activities $a$, $b$, and $c$, there are certain times where they are certainly active, their so-called mandatory parts (see @sec:timetable for more details). Consider activity $a$. It starts at either $t = 0$ or $t = 1$. In either case, because its duration is 2, it is active at $t = 1$. Using similar reasoning for the other activities, we can create the following "resource profile", shown in @img:cum:timeline. A square is colored if an activity is certainly active at that time. The height is equal to the activity's usage.

  #figure(
    image("placeholder.png", width: 40%),
    caption: [#todo[timeline that shows mandatory parts for above example]],
  ) <img:cum:timeline>

  Based on this profile, we see that $x$ cannot start at $t = 0$, as then for $t = 1$ the capacity would be exceeded. Similarly, for all times up to $t = 4$. Only at $t = 5$ is there no violation. Therefore, we can propagate $[x >= 5]$ (where we use $x$ to also refer to the start time variable). We can represent this propagation with the following fact:

  #numbered[
    $ [a >= 0] and [a <= 1] and [b >= 0] and [b <= 1] and [c >= 2] and [c <= 5] and [x >= 0] arrow [x >= 5] $ <eq:cum:fact>
  ] 

  The above reasoning is known as timetable reasoning.
  
  // Consider a situation with a cooktop with two heating elements, as well as a number of ingredients that must be cooked on a stove. Therefore, only two ingredients can be cooked at the same time time. Furthermore, each ingredient takes a specific amount of time to cook. The processing times will be measured in increments of 5 minutes. We have the following ingredients: _potatoes_ ($P$) _vegaburger_ ($V$) and _broccoli_ ($B$), as well as two garnishes, _onion_ ($O$) and _garlic_ ($G$). This gives us a cumulative constraint where $A = {P, V, B, O, G}$, $p(P) = 3$, $p(V) = 2$, $p(B) = 1$, $p(O) = 1$, $p(G) = 1$ and $R = 2$.
] <ex:cum>



Since we cannot hope for efficient propagation algorithms that achieve any standard form of local consistency, instead we can look at some propagation algorithms for cumulative that achieve weaker filtering. One of the most important cumulative propagation algorithms is _timetable_, which has $O(n^2)$ @letort2012scalesweep and $O(n log n)$ @ouellet2013cumulative implementations. However, it has rather weak propagation strength. One of the strongest practical propagation algorithms is _energetic reasoning_ @erschler1990energy @baptiste1999satcumul. We also refer to @schutt2011improving for a treatment of cumulative in learning CP solvers. However, it suffers from a high time complexity, $O(n^3)$. Consequently, it is not implemented in many modern solvers. We therefore focus on timetable propagation here, as it has been the most successful in practice. 
 
As with alldifferent, to verify propagation outputs such as @eq:cum:fact we must study the type of conflicts that can occur when writing timetable propagations $D -> d$ as $D and not d -> bot$. However, while for alldifferent we have a necessary condition for conflicts, such a condition is not known for timetable propagation conflicts. Our contribution includes the categorization of these conflicts, which is based on the timetable propagation algorithm. We discuss this algorithm in the next subsection.
// For timetable there is no ,
// We seek to build a formally verified checker for inferences made with cumulative timetable reasoning. The goal is to verify facts (in particular: inferences) of the form $a_1 and a_2 and ... a_n -> q$, where $a_1$, $a_2$, ..., $a_n$ and are atomic constraints and $q$ is either $bot$ or also an atomic constraint. Since such a fact is logically equivalen to $a_1 and ... and a_n and macron(q) -> bot $ no matter what $q$ is, this reduces to verifying whether the domain implied by $a_1 and ... a_n and macron(q)$ is incompatible with the constraint being satisfied. This is equivalent to assuming a solution exists that satisfies this domain and satisfies the constraint, and then showing this implies a logical contradiction (a "conflict").

// The checker is then a function that takes a fact and a constraint and returns `true` if it can deduce a conflict. We therefore list the possible types of conflicts that can be found using timetable reasoning. This is followed by the main idea of the checker, a detailed study of the algorithm and a proof sketch that aims to highlight the most important parts of the formal proof. This formal proof shows that, if the checker returns `true`, then the inference is indeed valid. Finally, we discuss some design considerations related specifically to the implementation in the Rocq interactive theorem prover.

=== Timetable propagation <sec:timetable>

Given an activity $x$ with processing time $duration(x)$ and starting time variable $start(x)$ with domain $[lower(x), upper(x)]$, then for times $t$ s.t. $upper(x) <= t < lower(x) + duration(x)$ we know that $x$ is active. This can be derived by observing that an activity is active at times $start(x) <= t < start(x) + duration(x)$ and then using the bounds. We say that for such $t$, $x$ is _mandatory_ (also known as _compulsory_). We also define the _resource profile_, which for each time $t$ is defined as the sum of the usages of all activities that are mandatory at that time. 
// Reasoning about when activities are mandatory, two types of conflict can be identified. Each respond to a feature of timetable propagators,
Based on these concepts, we describe the basic procedure for timetable propagation in @proc:timetable. Note that more optimized versions exist, but we describe only the simplest form, which also forms the basis of our verification algorithm. In particular, a significant optimization is to not look at any individual time point, but only at the time intervals where the resource profile changes. 

#procedure(title: [Timetable propagator])[
  + (Determine horizon) Given a cumulative constraint $c$ with activities $A$, determine the constraint horizon, which is $[min_(a in A)lower(a), max_(a in A)upper(a)]$.
  + (Resource profile) Compute the resource profile for each time in the horizon, which gives a function $P$ that maps times to the remaining capacity at that time after subtracting the usage of each activity that is mandatory at that time. Let $M(t)$ be the set of activities mandatory at $t$, then $P(t) = R - sum_(x in M(t)) usage(x)$.
  + (Resource profile check) For each time in the horizon, check whether $P(t) < 0$; if it is, report the fact $D(A) -> bot$, where $D(A)$ represents the domains of all activities in $A$. 
  + (Propagation) Note that for each $t_"start"$ and activity $a$, $a$ can start at $t_start$ if we have $P(t) >= usage(a)$ for all $t$ s.t. $t_start <= t < t_start + duration(a)$. For each activity, a single pass starting from $lower(a)$ to $upper(a)$ can propagate $a >= t'$ if for all $lower(a) <= t < t'$ we have that $a$ cannot start. Similarly, a single pass starting from $upper(a)$ and down to $lower(a)$ can propagate $a <= t'$. The fact is then of the form $D(A) -> [a <= t']$ (or $[a >= t']$ if the lower pass identified a new bound). Furthermore, it is possible for $a$ to not be able to start at any time $lower(a) <= t <= upper(a)$. Then, the fact is of the form $D(A) -> bot$. 
] <proc:timetable>

We have seen two different constraints and defined how we can describe the reasoning made by propagators using "facts". We now discuss how these facts can be combined to to form a proof of infeasibility. In the next section, we first describe proofs of infeasibility in the context of SAT, where they already standard, after which we introduce the specific proof system we use in this work.

// We also saw that for alldifferent we can precisely describe when there is a conflict, while for cumulative this is not possible and we instead described the propagation algorithm we seek to verify. Next, we discuss proofs of infeasibility and their relation to CP, which will serve as the necessary background to introduce the specific proof system we use.

// Next, we introduce the proof system we use to write our proofs of infeasibility in and connect this to the facts we already introduced.

== Proofs of infeasibility in SAT

Proofs of infeasibility have become standard in SAT, which can be seen as a special case of CP. Ideas from SAT have also inspired the proof system considered here. Therefore, we first discuss SAT and unsatisfiability proofs for SAT, after which we discuss the CP proof system used in this work.

The problem of determining a solution to a CSP that contains only Boolean variables and propositional constraints (in conjunctive normal form) is also known as the Boolean satisfiability problem or SAT. Since SAT is NP-complete (and the first one to be proven to be as such), many other problems can be expressed in terms of SAT. Furthermore, it is in a way the "simplest" such problem, as variables can only have two possible values.

In SAT, most proofs of unsatisfiability consist of a sequence of clauses that are redundant with respect to the problem's propositional constraints. A clause is a disjunction of propositional variables or their negation, e.g., $x or not y or z$.

One of the first widely used formats, and the one that played an important role in inspiring the CP proof system we introduce in @sec:proofsystem, is the RUP format. For this, we must first define what a RUP (reverse unit propagation) clause is. This requires introducing the concept of unit propagation.

#procedure(title: [Unit propagation])[
  Given a clausal constraint $l_1 or l_2 or ... or l_n$, where each $l_i$ is a literal (so a propositional variable or its negation), if every literal except one is $ffalse$, we know that the remaining literal must be $ttrue$. This reasoning is known as _unit propagation_.
]

#definition(title: "RUP")[
  Consider a conjunction of clauses $cal(F) = cc_1 and cc_2 and ... and cc_n$ and a clause $cc$. If performing unit propagation on $cal(F) and not cc$ implies a contradiction, then $cc$ is a _reverse unit propagation_ (RUP) clause with respect to $cal(F)$.
]

We consider an example to make this more intuitive.

#example(title: [RUP])[
  Let $cal(F) = (x or y) and (not y)$ and $cc = x$. Observe that by unit propagation on $cal(F)$, we must have that $y = ffalse$, which then implies $x = ttrue$. But $not cc$ implies that $x = ffalse$, so $cal(F) and not cc$ implies a contradiction. Note that this is a similar trick to what we do in @proc:verifystrat, where to verify $cal(F) -> cc$ we verify $cal(F) and not cc -> bot$. 
]

A RUP proof then consists of a sequence of RUP clauses, ending with the empty clause to prove unsatisfiability. A RUP proof can then be verified as described in @proc:rup. Note that it is more standard to traverse the proof in a backwards direction @goldberg2003unsatcnf, but this is not important for our purposes.

#let rr = $frak("r")$

#procedure(title: [RUP proof verification])[
  Given: a sequence of RUP clauses $rr_1, rr_2, ..., rr_n$ and a conjunction of clauses $cal(F) = cc_1 and ... and cc_m$ that we seek to show is unsatisfiable.
  1. Set $C := cal(F)$ and $P := rr_1, rr_2, ..., rr_n$.
  2. Let $rr$ be the first element of $P$ and remove it from $P$. If $P$ is empty, reject the proof.
  3. Perform unit propagation on $C and not rr$. If this does not lead to a contradiction, reject the proof. Otherwise, move on to the next step.
  4. If $rr$ was the empty clause, $cal(F)$ is unsatisfiable. Otherwise, set $C := C and rr_1$ and go back to step 2.
] <proc:rup>

// TODO: maybe add some more stuff from flippo related work



// CP in general?

== CP proof system <sec:proofsystem>

The CP proof system considered in this work is exactly the proof system of Sidorov et al. @sidorov2025checker, which is part of the same collaborative effort. Proofs in this proof system are sequences of _facts_, which we already informally introduced in @ex:geninf as a way to describe reasoning performed by propagation. However, facts are not only used to describe propagator reasoning, as we shall soon see. We now define what a fact is and then give its meaning.

=== Facts

#definition(title: [Fact])[
  A fact is an implication defined by its #premises and $consq$. For a fact $omega$, $premises(omega)$ is a set of atomic constraints. $consq(omega)$ is a single atomic constraint, or it is empty.
] <def:fact>

Each of the two lines in @eq:genfactsplit are examples of a fact.

#definition(title: [Assignment satisfies fact])[
  Let $omega$ be a fact and $theta$ an assignment. Then $theta$ _satisfies_ $omega$ if, when $theta$ satisfies all atomic constraints in $premises(omega)$, we have that $theta$ also satisfies $consq(omega)$, i.e. $premises(omega) -> consq(omega)$. An empty consequence, written also as $bot$, indicates the "always false" constant. 
] <def:satisfies_fact>

With the above definitions, we can write a fact $omega$ with $premises(omega) = {a_1, a_2, ..., a_m}$ and $consq(omega) = q$ as $a_1 and a_2 and ... and a_m -> q$. If $consq(omega)$ is empty, we write $a_1 and a_2 and ... and a_m -> bot$. This latter type of fact is known as a _nogood_, which is directly related to the nogoods encountered during CP solving (see @sec:solvinglogging) and shows up as deductions in our proof system (see @ex:deduct for an example). However, nogoods can also show up as inferences when propagators run into conflicts (@eq:genfactmulti contains two examples).

The previous definition refers to a particular assignment. However, we want to say something about any assignment that solves the problem, as this will later allow us to determine when a problem is unsatisfiable. 

#definition(title: [Fact holds for CSP])[
  Let $cal(P)$ be a CSP and $omega$ a fact. Then we say $omega$ _holds_ for $cal(P)$, if for every solution $theta$ of $cal(P)$, we have that $theta$ satisfies $omega$.
]

The previous definitions should make it clear that facts are nothing more than constraints that are redundant with respect to the CSP, meaning they do not change the satisfiability of the CSP.

#showybox(
  frame: (
    radius: 0pt,
    inset: 10pt,
    thickness: 0.5pt
  ),
  sep: (
    gutter: 10pt,
    thickness: 0.25pt
  ),
  spacing: 14pt,
  [*_Aside_*],
  [
  Given a set of constraints $cal(C)$, where each $c in cal(C)$ is a computable function, we can consider as the underlying proof system something at least as powerful as Peano arithmetic. Then we can express, for a given $c in cal(C)$ and assignment $theta$, $c(theta) = ttrue$ in this proof system (as Peano arithmetic can model the computable functions). Then we can describe the logical truth of a sentence $a_1 and a_2 and ... and a_m -> q$ in this system as the corresponding fact being satisfied by all assignments $theta$ that, for all $c in cal(C)$, satisfy $c(theta) = ttrue$. 
  ]
)

We now show that if the fact $top -> bot$ holds for a particular CSP, then that CSP is unsatisfiable. Here we use the notation "$top$" to indicate the constant that is always true, which in our definition of fact corresponds to having no premises.

#lemma(title: "CSP unsatisfiability")[
  Let $cal(P)$ be a CSP. If the fact $top -> bot$ holds for $cal(P)$, then $cal(P)$ is unsatisfiable.
]
#proof[
  Let $theta$ be a solution to $cal(P)$. Since $top -> bot$ holds for $cal(P)$, it must be satisfied by $theta$. Since the premises are empty, we immediately know that the left-hand side is satisfied. But then the right-hand side must be true. However, this implies a contradiction. We have shown that the existence of a solution implies a contradiction. Hence, there is no solution to $cal(P)$.
]

The proof system must make it possible to verify that $top -> bot$ is a valid fact. We have already seen how to verify a particular type of fact, namely those used to represent propagator reasoning for a particular constraint (@proc:verifystrat). These "propagator facts" are part of a class of facts we call _inferences_. Their defining factor is that they can be considered independently, requiring only knowledge of their associated constraint. Clearly, unless the CSP contains some trivially unsatisfiable constraint, we cannot do this for $top -> bot$. Instead, the proof format supports deriving new facts from other facts. This allows combining the knowledge of multiple constraints, which is often needed to prove unsatisfiability. It is also closely related to how modern CP solvers work (see @sec:solvinglogging). The following example shows how two different inferences can be combined to derive a new fact, in a process called _deduction_.

#example(title: [Fact derivation])[
  Consider a particular CSP. The table below gives an example of how a new fact can be derived for this CSP. The third row is the new fact. Furthermore, we have two inference facts (row 1 and row 2) that have already been verified to hold for the CSP and are implied by some constraints numbered i and ii, which can be seen in the "Implied by" column.  The fact we seek to deduce also has information in the "Implied by" column, which in this case refers to the two inferences we need. To see why the fact is implied by the two inferences, consider an assignment such that the left-hand side is satisfied. Then, we know $x in (-infinity, 3]$ and $y in [6, infinity)$. We must then show that the right-hand side is satisfied, which in this case means we must derive a contradiction. Now, fact 1 holds for the CSP, and since our current domain for $x$ implies $x <= 5$, we can record for $z$ the domain $[7, infinity)$. Furthermore, since $y >= 6$, certainly $y != 5$ and hence $z <= 6$. However, this is incompatible with $[7, infinity)$ and hence we have a contradiction. Therefore, fact 3 holds for the CSP.  
  
  #proof_table((
    [1], [$[x <= 5] arrow [z >= 7]$], [i],
    [2], [$[y != 5] arrow [z <= 6]$], [ii],
    [3], [$[x <= 3] and [y >= 6] arrow bot$], [1, 2]
  ), [This proof snippet, consisting of three steps, is an example of how a new fact can be derived from previous ones. The third row is the new fact, which is derived from the previous two.], rules: false)
] <ex:deduct>

What we saw in @ex:deduct was a _deduction_ step. Facts derived with deduction always have an empty consequence (which makes them nogoods). The next section discusses deduction in more detail.

// Within a CP proof, we distinguish two types of fact, _inferences_ and _nogoods_. Nogoods always have an empty consequent, so their premises holding would imply a contradiction. Inferences can have both empty and non-empty consequent and are only ever used to justify nogoods. Furthermore, inferences can refer to constraints in the model (or previously established nogoods) and are justified using an _inference rule_, which provides the information necessary on what reasoning to use to justify them. Inferences are never reused, they are only used for a single nogood justification. This nogood justification is called _deduction_.

=== Deduction steps <sec:prelim:deduct>

Deduction derives new facts using a sequence of inferences that are already known to hold for a CSP. Those inferences are all checked individually before they are passed to the deduction step. The deduction step assumes the inferences are in the precise order that allows justifying the nogood. To describe this process precisely, we need to define what it means for an atomic constraint to be satisfied by a domain.

@proc:deduct describes the exact process that we informally followed in @ex:deduct.

#procedure(title: [Deduction check])[
  Given: a sequence of previously verified facts $cal(I) = angle.l I_1, I_2, ..., I_n angle.r$ and a nogood $N = n_1 and ... and n_m -> bot$ to be verified.
  1. Let $cal(D)$ be the domain induced by the atomic constraints $n_1 and ... and n_m$. If there is a variable with an empty domain, the nogood is trivially satisfied, generally indicating a mistake. In our implementation, we therefore reject the deduction.
  2. Let $I = a_1 and ... and a_l -> q$ be the first fact in the sequence $cal(I)$ and remove it from $cal(I)$. If there is no such fact, reject and return that the deduction is invalid. Otherwise, if there exists an atomic constraint $a in {a_1, ..., a_l}$ s.t. $cD$ does not satisfy $a$, reject and return that the deduction is invalid. Otherwise, go to step 3. 
  3. If $q$ was empty, return that the nogood is valid. Otherwise, update $cD$ with the atomic constraint in $q$ (if $q$ refers to a variable $x$, remove the values from $cD(x)$ that violate $q$). If there is a variable with an empty domain in the updated domain, return that the nogood is valid. Otherwise, go back to step 2.
] <proc:deduct>

Our claim is now that if @proc:deduct accepts a deduction and if every $I in cal(I)$ holds for a particular CSP $cal(P)$, then $omega$ also holds for $cal(P)$. One of our contributions is the formal proof of this for our specific implementation of @proc:deduct. Note also that the above description does not mention how domains are tracked and updated. That is part of our contribution, see @sec:deduct. 

A _valid deduction_ is defined as a deduction that is accepted by @proc:deduct. For a more formal description of the validity of a deduction (which differs from our implementation and formalization, as our work proof predates it), we refer to Sidorov et al. @sidorov2025checker.

Now that we know how to combine inferences to deduce new facts, we will discuss precisely what type of inferences there are and how to check them.

=== Inference steps <sec:prelim:inf>

Inferences are facts that, as opposed to facts derived through deduction, can be verified independently. They rely either on a constraint in the original CSP, an initial domain in the CSP (which we can also view as a constraint), or on a previously established fact (which is just a redundant constraint). In general, they could also rely on multiple constraints at once, but this is not important in this work, and hence we will assume they rely only on a single constraint. However, annotating inferences only with their associated constraint is not enough. This is because there are multiple types of derivation possible for one constraint. For example, while in this work we focus on timetable propagation for cumulative, it would be possible to also verify energetic reasoning. To support this, every inference is also annotated with a so-called _inference rule_, which, informally, is the strategy it should use to verify the inference. The formal definition is given in @def:infrule.

#definition(title: [Inference rule])[
  An _inference rule_ is a predicate that takes a fact $omega$ and a constraint $c$ as input. 
] <def:infrule>

In the informal @proc:verifystrat (propagator verification strategy), an inference rule corresponds to the algorithm $V$ in the final step. However, instead of a domain, an inference rule takes a fact (which can then optionally be converted into a domain). As stated earlier, it would be possible to construct inference rules that reason over multiple constraints, but we do not consider this case. Hence, we leave it out of the definition. The next definition states when an inference rule is valid.

#definition(title: [Inference rule validity])[
  An inference rule $cal(R)$ is _valid_ if for all constraints $c$, all facts $omega$, and all assignments $theta$ that satisfy $c$, we have that $cal(R)(omega, c) = ttrue$ implies that $theta$ satisfies $omega$.
] <def:infrulevalid>

It is easy to show that given a fact $omega$, a CSP with constraints $cal(C)$, a constraint $c in cal(C)$ and a valid inference rule $cal(R)$, $cal(R)(omega, c) = ttrue$ implies that $omega$ holds for the CSP. In practice, an inference rule only works for a particular type of constraint. Such a practical implementation can then be turned into an inference rule by simply rejecting any constraint that is not of the correct type. In fact, the trivial "always false" predicate would be a valid inference rule. Inference rule validity, therefore, only requires _soundness_, not completeness.

// Each inference rule then requires the implementation of a function with the following signature: `check_inference(fact: Fact, constraint: Constraint) -> bool`, which returns `true` if it is able to verify the fact using the constraint. In practice, verification of a fact fact $D -> q$ often proceeds by determining that the associated constraint is unsatisfiable given the domain implied by $D and not q$. This was discussed in @sec:formaldesc and also in @proc:verifystrat.

In this work, we only develop inference steps related to propagator reasoning. To understand the other types of inference steps, we first present an example of a full deduction proof stage.

#example(title: [Deduction])[ In @proof:fullstage we see a complete example of a deduction stage. Here $c_1$ is an alldifferent constraint over the variables $a, b$ and $c$; $c_2$ is a cumulative constraint with parameters as in @ex:cum:params of @ex:cum; $f_1$ is the fact $[z != 7] -> bot$; $f_2$ is the fact $[z = 7] and [c >= 6] -> bot$. First, notice that the deduction relies on the initial domains that are part of the CSP definition. These are materialized in the deduction using the `domain` inference rule. Furthermore, the deduction relies on previously established facts. Since deduced facts are nogoods, if we were to repeat exactly those facts, we would not know which conclusion to draw from them. Therefore, the `fact_equiv` rule is used to rewrite the nogoods into equivalent facts with the conclusion necessary for this deduction. Then, two propagator inference rules are used, each of which relies on a constraint in the CSP. Finally, the deduction mentions that it relies on exactly the previous 9 steps for its derivation. 

  #proof_table((
    [1], [$top arrow [x >= 0]$], [`domain`], [$cD_"init" (x)$],
    [2], [$top arrow [a >= 0]$], [`domain`], [$cD_"init" (a)$],
    [3], [$top arrow [b >= 0]$], [`domain`], [$cD_"init" (b)$],
    [4], [$top arrow [b <= 1]$], [`domain`], [$cD_"init" (b)$], 
    [5], [$top arrow [c >= 0]$], [`domain`], [$cD_"init" (c)$],
    [6], [$top arrow [z = 7]$], [`fact_equiv`], [$f_1$],
    [7], [$[z = 7] arrow [c <= 5]$], [`fact_equiv`], [$f_2$],
    [8], [$[a >= 0] and [a <= 1] and [b >= 0] and [b <= 1] and [c >= 0] and [c <= 5] arrow [c >= 2]$], [`alldifferent`], [$c_1$],
    [9], [$[a >= 0] and [a <= 1] and [b >= 0] and [b <= 1] and [c >= 2] and [c <= 5] and [x >= 0] arrow [x >= 5]$], [`timetable`], [$c_2$],
    [10], [$[x <= 4] and [a <= 1] arrow bot$], [`deduction`], [1, 2, 3, 4, 5, 6, 7, 8, 9]
  ), [Example of a practical deduction stage that makes use of multiple inference types.]) <proof:fullstage>
]

We now describe the different inference steps in detail.

+ _Propagator inference step_: inference step that describes the reasoning of a particular propagator for a particular constraint. Each different propagator and constraint must be explicitly supported, or must be translated to a type of reasoning that is supported by the checker. We aim to develop a methodology that aids in the support of new constraints and propagators in the checker.
+ _Initial domain inference step_: a CSP consists of variables, domains, and constraints. As deductions can only use inferences to support their derivation, the checker supports a special inference step type that uses the initial domain to infer a particular atomic constraint in order for deductions to use the initial domains.
+ _Nogood inference step_: all deduction steps derive nogood facts. If a new deduction step wants to use a nogood in a way other than directly implying a contradiction, it has to be rewritten as an equivalent fact.

The nogood inference step and the initial domain inference step are not part of our contributions, but instead part of the collaborative effort to develop a CP unsatisfiability proof checker. They are therefore not discussed any further. We do mention that the formally verified machinery used to handle and track domains, which is one of our main contributions, was used in their implementation.

Checking propagator inference steps involves the definition of a valid inference rule. In the formally verified checker, this means the implementation of a function with the following signature: `check_inference(fact: Fact, constraint: Constraint) -> bool`. The function should only return true if any solution to the constraint satisfies that fact (this implies inference rule validity for a particular CSP if the constraint is part of the CSP).

We finish this section with a short description of the precise definition of a proof.

// As mentioned, each inference in the proof is checked according to some inference rule. An inference may therefore also refer to one or more constraints in the model. The main focus of this thesis is how to check these inferences. An inference is a fact and to verifying it is justified by the model involves verifying that, for an inference $I$, $premises(I) -> consq(I)$ is logically implied by the model. To illustrate this, first an example using the cumulative constraint frequently used in scheduling. The constraint is described in detail in @sec:prelim:cumulative.

// #example[
//   Let $C$ be a cumulative constraint with activities $x$, $y$ and $z$ such that the capacity and usages are unit, and such that the duration of $x$ and $y$ are 1 and the duration of $z$ is 2. Then $[x = 0] and [y = 2] and [z >= 0] -> [z >= 1]$ is a valid inference. To see this, note that $x$ must be active at $t = 0$, therefore $z$ cannot be active at $t = 0$. Since we also know it must start at $t >= 0$, we know that indeed $z$ must start at least at $t >= 1$. However, smarter reasoning might have identified that then the second half of $z$ overlaps with $y$, therefore $[z >= 3]$ is also a valid consequent.
// ]

// The previous example showed that the same premises allowed for at least 2 different valid inferences that use constraint-specific reasoning. The first might have originated from a solver that only reasons using starting times, which might have been a valuable trade-off to reduce time spent on propagation. #todosm[Make sure somewhere I mention the trade-off between propagation strength and propagation cost] Verifying the first also meant we did not even have to look at other timepoints than $t = 0$.

// To minimize time spent checking, it is therefore valuable to look at the domains after negating the right-hand side and adding it to the left-hand side (which is logically equivalent), and then derive a conflict. This would mean that the first inference would be $[x = 0] and [y = 2] and [z >= 0] and [z <= 0]$. Since we only want to verify the consequent containing $z$, we can then focus on the domain for $z$, which means we first look at the timepoint $t = 0$. 

=== Proof definition

Our description on paper of a valid proof in the CP proof system of Sidorov et al. @sidorov2025checker is somewhat more informal than what can be found in  @sidorov2025checker. This is because this work was developed concurrently with the formal development of the proof system. Hence, some parts of the implementation predate the formal description on paper of @sidorov2025checker. In particular, this is the case for the deduction step. Now, before we define the notion of proof, we define the different proof steps and their combination into a proof stage.

#let fact = jmono[fact]
#let rule = jmono[rule]
#let constr = jmono[constraint]

#definition(title: [Inference step])[An inference step $I$ consists of a fact $fact(I)$, a valid inference rule $rule(I)$ and a constraint $constr(I)$.]

Note that in the above definition of an inference step, we leave implicit the fact that we can write the initial domains of a CSP as constraints. Hence, an inference step can also refer to the initial domain of a particular variable. Furthermore, remember that, given the above definition of an inference step, if $rule(I)(fact(I), constr(I)) = ttrue$, we know that $fact(I)$ holds for the given CSP.

#definition(title: [Proof stage])[
  A proof stage $S$ is a sequence of facts $cal(I)$ (the _inferences_) and a fact $fact(S)$ with empty consequence (the _deduction fact_). Given a CSP $(cal(X), cal(D), cal(C))$, $S$ is _valid_ if the following holds: 
  + (Inference validity) For every inference $I in cal(I)$ we have that $constr(I) in cal(C)$ and $rule(I)(fact(I), constr(I)) = ttrue$.
  + (Deduction validity) @proc:deduct (deduction check), instantiated with $cal(I)$ and $omega_"deduct"$, returns that the deduction is valid.
]

#definition(title: [Unsatisfiability proof])[
  Given a CSP $(cX, cD, cal(C))$, a _proof_ $Pi$ is a sequence of proof stages ($S_1, S_2, ..., S_n$), where a stage $S_k$ must be valid with respect to the CSP $(cX, cD, cal(C) union {fact(S_i) : 1 <= i < k})$. $Pi$ is an _unsatisfiability proof_ if for some stage $S in Pi$, $fact(S) = top -> bot$.
]

== Constraint solving and proof logging <sec:solvinglogging>

To aid understanding of the proof system, we briefly discuss the connections of the proof steps to CP _solving_ and how it is possible to implement proof logging. We concern ourselves mainly with _learning_ CP solvers, i.e., solvers that use some form of learning close to conflict-driven clause learning (CDCL, see Ch. 4 of Biere et al. @biere2021handbook) in SAT. In particular, we consider the architecture known as lazy clause generation @feydy2009rengineered (LCG, see also Schutt @schutt2011improving, §2.4). Many state-of-the-art solvers employ this architecture, and it is also used by the Pumpkin solver @pumpkin2024, which is the solver that supports outputting proofs that can be verified by our checker.

LCG solvers are characterized by the existence of a high-priority SAT engine as a global propagator that maintains a (lazily generated) propositional view of the problem. Furthermore, other propagators are expected to explain their inferences and conflicts in terms of clauses. These _explanations_ correspond exactly to the formal description of propagation outputs we discussed in @sec:formaldesc. For example, the propagation in @ex:cum (cumulative example) would be explained exactly by @eq:cum:fact. Note that there are often multiple explanations possible (see e.g. Schutt @schutt2011improving), but any valid explanation $D -> q$ requires that $D and not q -> bot$. To see why these explanations are clauses, any atomic constraint $[x diamond.small c]$ can be viewed as a Boolean variable that is true when the constraint is satisfied, and false otherwise. Furthermore, an implication $a_1 and ... and a_n -> q$ is logically equivalent to the clause $not a_1 or ... or not a_n or q$.

We will briefly discuss CDCL. CP solvers perform extensive search, making decisions until a conflict is reached, producing a nogood (i.e., a domain under which the problem has no solutions). The conflict is then analyzed (utilizing the explanations mentioned earlier), improving the nogood. This nogood is then added to the constraint database (it _learns_ the nogood), preventing the solver from returning to this branch of the search tree. Furthermore, it frequently prevents the solver from exploring other fruitless branches. These conflict nogoods are exactly the deduction nogoods in our proof. The inference steps used to derive a particular nogood are then the explanations for the propagations that led to the conflict.

In conclusion, the inferences and deductions correspond to explanations and conflict nogoods that an LCG solver uses even if it does not produce a proof. These can then be used, with hardly any additional logic necessary, to construct a CP proof. Of course, there are still many practical difficulties, for which we refer to Flippo et al. @flippo2024proof.

== Formal verification

The CP unsatisfiability proof checker developed by the collaborative effort this work is a part of is formally verified in Rocq (formerly known as Coq) v8.20 @rocq-8-20 @bertot2004coq. Therefore, all the implementations and formalizations in this work are also done in Rocq. We refer to Peled et al. @peled2019formal for a broad introduction to formal verification. Rocq, which is both an interactive theorem prover and a programming language, allows us to both implement the checker, state its specification, and prove that the implementation adheres to the specification. The proof is machine-checked by Rocq's kernel. The logic of Rocq is known as the Calculus of Inductive Constructions @mohring2015coic, which is a typed $lambda$-calculus. We will not discuss this logic in detail, as we primarily view Rocq as a tool and do not study it on its own. We do mention that Rocq allows programming with _dependent types_ @nordstrom1990martinlof, a powerful construct that allows types to depend on elements of other types. If we use the example of Bove & Dybjer @bove2009dependent, consider the type $A^n$ of vectors of length $n$ of component type $A$. The type $A^n$ then _depends_ on $n$.

Rocq was chosen for a number of reasons; we highlight two of them:

- Most languages and provers with capabilities similar to Rocq (and including Rocq) are slow. Their expressive machinery weighs them down, and they are often interpreted rather inefficiently. However, Rocq provides a powerful extraction mechanism that allows Rocq code to be compiled to OCaml. While OCaml is not a low-level language and features garbage collection, it has been used for performance-sensitive systems and has orders of magnitude better performance than interpreting Rocq directly.
- It is a mature toolchain that has been used to verify large software projects. For example, an optimizing C compiler known as CompCert has been verified in Rocq @leroy2025compcert. This maturity has many benefits, such as IDE support, an ecosystem of community-developed libraries, and helpful resources.

== Mathematical background

In @sec:prelim:deduct, it was mentioned that a domain is tracked for each variable during the deduction process. These domains need not be finite. For example, the domain induced by a single $>=$ atomic constraint will still be infinite. Therefore, it will be useful to consider an extension of the integers for the domain representation discussed in @sec:perfint.

#let Zext = $ZZ_"ext"$

=== $Zext$ <sec:zext>

The _extended integers_, denoted $Zext$, are defined as $ZZ union {-infinity, plus infinity}$. They are not as well studied as the extended _real_ numbers, which have applications in e.g., measure theory. We could not find any formalization and found only mentions as examples in a general theory on compactification in topology @peschke1990endstheory. We do note we are not the first to use it in CP, see e.g. @caballero2013typeext.  Since we are not concerned with performing arithmetic on them and use them only to define an order, we do not suffer from the fact that some arithmetic operations (such as $infinity - infinity$) do not have a natural definition.

==== Operations

We define comparison on $Zext$ such that $-infinity <= x <= +infinity$ holds for all $x in Zext$ and when $x, y in ZZ$ we also have $x <=#sub[#Zext] space y$ when $x <=#sub[$ZZ$] space y$. This defines a total order.

We also define the $max$ and $min$ operations in the natural way, where we have, for example, $min({n, +infinity}) = n$ for $n in ZZ$.


// == Formal verification <sec:formalverif>

// While CP proof checkers are simpler to build than solvers, they still need to implement propagation algorithms. Therefore, proof checkers are ideally formally verified. The gold standard for this verification is a machine-checked mathematical proof that the program adheres to its specification.

// We refer to @peled2019formal for a broad introduction to formal verification.

// #todo[This section will be filled mostly with what is currently in the proposal]
#pagebreak()

= Related work

// #todosm[This seems to be true after a quick search, but make sure this really is true!]
// Infeasibility proofs are not standard in CP. In fact, in the 2023 and 2024 editions of the XCSP competition @audemard2023xcsp3 @audemard2024xcsp3, and the MiniZinc challenge @tack2023challengeminizinc @tack2024challengeminizinc, the only solver with support for generating proofs of infeasibility was the Pumpkin solver @pumpkin2024, which is the solver that pioneered the format and proof system used in this work @flippo2024proof @sidorov2025checker.

// Instead, we must look to the SAT and SMT communities, where unsatisfiability proofs are already widely used. In fact, unsatisfiability proofs have been mandatory for solvers participating in the unsatisfiability track of the SAT Competition since 2013 @sat2013. For a detailed discussion of unsatisfiability proofs in SAT, see Chapter 15 of Biere et al. @biere2021handbook. We summarize the most important details below. In fact, one of the approaches for proofs of unsatisfiability in CP, VeriPB, was actually used in the SAT Competition @bogaerts2023satcompveripb, not in the MiniZinc challenge or XCSP competition, as these have no special rules or requirements for proof logging and/or certification.

// Furthermore, state-of-the-art SMT solvers such as CVC4, Z3, and veriT also support proof production @barrett2015smtproofs. Barrett et al. @barrett2015smtproofs describe SMT proofs as an interleaving of SAT proofs and SMT-specific theory proofs. For this reason, we focus on SAT proofs of infeasibility.  After discussing SAT, we discuss pseudo-boolean proofs of unsatisfiability, which have already been used successfully within constraint programming. 

// === Pseudo-Boolean

// Pseudo-Boolean models consist of Boolean variables, but instead of clausal constrainsts they allow linear inequalities over these variables. Proof logging for CP was first implemented by the Glasgow CP solver @gocht2022auditable @gocht2022certifying, which encodes constraints in pseudo-Boolean form and uses a cutting planes proof system. They use an external verifier, VeriPB, to verify the proofs. This same verifier is used in the work by Flippo et al. @flippo2024proof, which introduced an initial version of the proof format used in this work, which we discuss in detail in @sec:proofsystem.

// While the pseudo-Boolean approach has many benefits over earlier attempts at using SAT proofs directly in CP @veksler2010CSPprof, we summarize the findings mentioned in Flippo et al. @flippo2024proof and Sidorov et al. @sidorov2025checker that support the development of a proof system more native to CP:

// - Constraints and reasoning: Many constraints are not easy to express in pseudo-Boolean form and can have a significantly larger size. An example where this is the case is cumulative. Furthermore, the encoding must be trusted, while expressing them natively requires no transformation at all. Finally, all reasoning must be expressed in a way the pseudo-Boolean verifier understands. This hinders generalizability. 
// - Domains: Pseudo-Boolean models only support binary variables, which means that integer variables must all be encoded in binary. It also does not allow using infinite domains, which can be useful in cases such as the linear constraint.

// We do note that the verifier used by Gocht et al. @gocht2022auditable, VeriPB, also has a formally verified back-end, known as CakePB @gocht2024subgraphvercakepb. This means they can achieve a similar level of trust as our approach.

#pagebreak()

= Approach <sec:approach>


Our main goal is to determine how to develop formally verified checkers for individual proof steps, where the proof steps are as described in @sec:proofsystem. We repeat the different proof steps here and discuss our approach for each one, highlighting the expected difficulties.

*Propagator inference step*: For each possible type of reasoning (propagator + constraint combination), it is necessary to implement a checker of signature `check_inference(fact: Fact, constraint: Constraint) -> bool` and prove that it is sound. Since there are many constraints and propagators, we cannot hope to implement them all. Instead, we focus on implementing two important ones to serve as an example, using them as inspiration for the development of a general methodology for developing new propagator inference checkers. To ensure an inference checker faithfully checks a particular propagator, the checker should successfully verify every valid propagation $D -> q$ by that propagator. Rewriting propagations as $D and not q -> bot$ and determining under what conditions conflicts occur is expected to make this easier. Furthermore, as each checker only receives a fact as input, we want some procedure to convert it into a domain structure that provides more information.

*Initial domain inference step*: We do not discuss this step as its implementation and formalization are not part of our contribution, but rather part of the collaborative effort. We refer to Sidorov et al. @sidorov2025checker for more details.

*Nogood inference step*: We do not discuss this step as its implementation and formalization are not part of our contribution, but rather part of the collaborative effort. We refer to Sidorov et al. @sidorov2025checker for more details.

*Deduction step*: The main difficulty with checking a deduction step, as we see in @proc:deduct (deduction check), comes from tracking the domains, updating them, checking whether they satisfy atomic constraints and, checking if there is a variable with an empty domain. Furthermore, as the deduction steps do not depend on any constraint-specific reasoning, there is only a single thing to implement and formally verify. Therefore, a general methodology is not required.

Furthermore, we notice that both the propagator inference step and the deduction step require reasoning about domains: in particular, they require going back and forth between a richer, more efficient domain representation and atomic constraints. We therefore seek to develop building blocks that can be used both in the deduction checker and in inference checkers. Finally, we expect difficulty with the implementation, as we will have to express the checker algorithms in the language of a proof assistant, which is functional. Furthermore, our informal notions might not always translate well to rigorous formal statements.

The remaining sections describe our contributions, where each separate contribution is a top-level section. 

#pagebreak(weak: true)

= Inference checker methodology <sec:methodology>

The first major contribution we present is a methodology for developing propagator inference checkers. Before describing the general methodology, we summarize its use for developing a checker for the timetable propagator for the cumulative constraint. This should give an intuitive idea of its usefulness and the various steps. The dedicated section on this checker (@check:cumul) describes this in more detail and also contains proofs. 

#example(title: [Methodology application to cumulative])[
  Consider the cumulative timetable propagation algorithm (@proc:timetable). Let $c$ be a cumulative constraint with activities $A$. 
  + First, we notice that the algorithm has an explicit conflict check in step 3 (resource profile check). It reports the fact $D -> bot$, where $D$ is simply the domain of all activities. We have identified our first _conflict type_, as the reported fact already has an empty consequence. This conflict occurs if there exists a time $t$ where the resource profile already overloads the constraint's capacity. We will also name this conflict, terming it a _time conflict_.
  + Next, we see that the timetable algorithm has two types of propagation. If it determines that a task $x$ whose start time has $L$ as a lower bound cannot start for all times $L <= t < L'$, then it propagates $x >= L'$. The second type is analogous, but then for a start time with upper bound $U$ it determines that the task cannot start at $U' < t <= U'$. Hence, it propagates $x <= U'$. If we then consider the situation where we negate the consequent, we see that the two types of propagation actually have the same conflict condition. In the case of the increased lower bound, negating the consequent means that $L <= x < L'$, but at these times, we saw that it cannot start. Hence, there is a conflict. We see the same for the upper bound case. This means we have identified a second conflict type, which we term an _activity conflict_. This conflict occurs if an activity cannot be scheduled anywhere within its bounds. Note that the timetable algorithm also reports a conflict in this situation.
  + We must now build a formally verified algorithm for each conflict type. We will not go into details on how to do this for cumulative here, see @check:cumul.
  + Then, notice that for the two propagation types, the variable that is in the consequent refers to exactly the activity that will have an activity conflict. Hence, we can use the variable in the consequent to guide our algorithm to consider that activity first.
  + We can now combine the different conflict checks and our use of the consequent as a hint into a checking algorithm that will verify any timetable propagation.
] <ex:infmethod:cum>

Now that we have seen an example, we can introduce the general methodology, which has exactly the same steps as above. Consider a propagator $p$ for a constraint of type $cal(T)$. We propose the following methodology for developing an inference checker that can verify every fact describing a propagation by $p$. This builds on @proc:verifystrat (strategy for verifying propagators) and the proof system used in this work (@sec:proofsystem).

#procedure(title: [Methodology for inference checker development])[
  1. (*Identify propagator conflict checks*) Many propagators have conflict checks. For each conflict check, describe the conditions when such a conflict check would find a conflict. This gives a list of _conflict types_. _Example: in cumulative timetable, at each time point it is checked whether mandatory activities exceed the capacity._
  2. (*Propagation conflict types*) Exhaustively describe the different types of propagation that can occur. For each such type of propagation, determine the exact (domain) conditions under which the propagator will perform such a propagation. _Example: in cumulative timetable a lower bound for a task's starting time that is initially $L$ can be increased to some value $L'$ if scheduling that task at any time from $L$ to $L' - 1$ would cause the capacity to be exceeded._ Suppose we call this domain condition $D$ and the propagated constraint $q$. Then $D and not q$ is another conflict type. This further expands the list of conflict types.
  3. (*Conflict checkers*) For each of the conflict types identified in steps 1 and 2, build a formally verified algorithm that is able to identify that particular conflict. If no additional information is available, this algorithm is not necessarily of significantly lower implementation complexity than the propagation algorithm itself. However, the propagated atomic constraint is by definition tighter than the original bound. Therefore, this domain will always be more restricted than the domain a propagator would have to deal with. In many cases, this can reduce the number of considered cases, allowing a simpler, but less efficient, algorithm to be used.
  4. (*Consequent hint*) Optionally, the information that a particular variable was restricted to a particular bound can be used by the verification algorithm. This can further restrict the number of considered cases, as potentially only that particular variable must be checked. _Example: in cumulative timetable we know that if a particular activity was propagated, we need only inspect if we cannot schedule that activity on its domain._
  5. (*Infer domain and combine*) Combine the different conflict checkers into a single checker for the fact. Then, given a fact, convert it into a domain (where for a fact $A -> q$ we use the domain $A and not q$) and feed it to the checker.
] <proc:methodinf>

We have successfully applied @proc:methodinf to the cumulative constraint. Furthermore, we will discuss the post-hoc application of this methodology to the checker for linear inequalities, which is not part of our contribution and was developed prior to the creation of this methodology. However, in some cases, the methodology does not actually have to be used. This is the case for the other constraint we implement a checker for: alldifferent. We will discuss that case first. We finish with a brief discussion of _conflict type_, which we believe is the most important contribution of our methodology.

== Application to alldifferent

In the background section on alldifferent (@sec:prelim:alldiff), we saw that there exists a powerful theorem for alldifferent that provides a necessary condition for the unsatisfiability of an alldifferent constraint (@thm:hall). Furthermore, this condition is easy to check. This means that we do not have to investigate the propagation algorithm in order to discover the different conflict types, as every conflict type is already captured by this theorem. Consequently, there is only one conflict type (an alldifferent conflict).

Consequently, we did not apply the general methodology in order to develop a checker for alldifferent. Instead, we check only the necessary condition. This is described in more detail in @check:alldiff. We do mention that, if the domain materialization that we perform in our implementation proves unavoidable, it might be beneficial to develop a more specialized checker for weaker alldifferent propagators. In that case, it might be possible to still apply the methodology.

== Application to linear inequalities

As part of the collaborative work we are a part of, a linear inequality checker has also been developed. When we try to apply our methodology to this checker post-hoc, we see a similar problem as will alldifferent: there is only one conflict type, namely when the minimum value (based on bounds reasoning) of the left-hand side of the checker exceeds the constant on the right-hand side. Therefore, the methodology cannot really be applied; there are not enough steps in the propagation algorithm to apply it to.

== Conflict types <sec:infmethod:conflicttypes>

For a particular propagator $p$ for constraints of type $cal(T)$, a _conflict type_ is a conflict characterized by a particular domain condition: if the domain condition is satisfied, the constraint becomes unsatisfiable. In the case of cumulative, we saw two different types: _time conflicts_ and _activity conflicts_. If a propagator performs a conflict check, the conditions it checks for are exactly the domain conditions of a conflict type. Furthermore, for every propagation $D -> q$, the domain condition $D$ combined with the condition $not q$ is the domain condition of a conflict type. It is possible for multiple types of propagations to degenerate to the same conflict type when the negated consequent is added. We saw this case for cumulative: when propagating, one must separately propagate the lower and upper bounds, but the propagations actually have the same conflict type (the activity conflict).

// The linear inequality checker implemented in the proof checker was developed before the creation of our methodology. However, we can still inspect its implementation and 

#pagebreak(weak: true)

= Perforated intervals <sec:perfint>

// == Pseudocode

// The "language" of our pseudocode has the following features:

// === Sum types

// ```
// enum Domain =
//     | Unfixed
//     | Fixed(n: int)
// ```

// We can instantiate these using only their variant names, `Unfixed` or `Fixed(n)`.



#let dom = spro[dom]

#let holes = spro[holes]

As discussed in the approach (@sec:approach), both the deduction step and the inference checkers need some machinery to reason about variable domains and atomic constraints. We present here the theory and formally verified implementation of a particular domain representation that fulfills the following specific requirements:
- Deduction requires efficiently checking whether atomic constraints hold and whether a group of atomic constraints implies an empty domain.
- Our timetable cumulative checker requires the extraction of lower and upper bounds from a list of atomic constraints (which, when considering not-equals constraints, might be different from just the maximum upper bound, minimum lower bound).
- Our alldifferent checker requires building an enumerated domain from a list of atomic constraints.

We call the domain representation introduced here _perforated intervals_. A perforated interval consists of three pieces of data: lower and upper bounds as well as a set of holes (or perforations). The name was chosen to be distinct from punctured intervals used in e.g., analysis, which are usually missing exactly one value, while our perforated intervals can have many holes.

In this section, we begin with the formal definition and discuss some related concepts, including the introduction of the concept of a perforated interval being _tight_, in which case we can perform the efficient checks necessary for fact deduction. We then discuss these checks and their implementation (together with their correctness specification) in @sec:perfint:checks. This is followed by a discussion in @sec:perfint:updates on how we can build these domains by updating them based on atomic constraints. Then, the algorithm for how to actually tighten a domain is described in @sec:perfint:tightening, followed by proofs that this algorithm actually results in a tight domain. We conclude with a discussion of some implementation considerations in @sec:perfint:impl.

#definition(title: [Perforated interval])[
  A _perforated interval_ is a triple $(dlb, dub, holes)$, where $dlb, dub in Zext$ and $holes$ is a finite subset of $ZZ$. 
]

We note that in our formalization, these perforated intervals are referred to simply as domains, as that is currently the only type of domain representation in the checker.
A perforated interval can also be interpreted as the set difference of two sets, $[dlb, dub] - holes$, where the interval must satisfy $[dlb, dub] subset.eq ZZ$. Since perforated intervals represent domains, we define when an element is in a perforated interval.

#definition(title: [Elements])[
  Let $n in ZZ$ and $dom = (dlb, dub, holes)$ a perforated interval, then $n in dom$ iff $dlb <= n <= dub$ and $n in.not holes$.
]

This induces a natural equivalence between perforated intervals. 

#let domeqv = $tilde.eq$

#definition(title: [Domain equivalence])[
  Let $dom$ and $dom'$ be two perforated intervals. Then they are _equivalent_, written $dom domeqv dom'$, iff forall $n$, $n in dom <-> n in dom'$.
]

There exist examples of perforated intervals that are equivalent, but not equal. We will often say these have the same _logical domain_.

#example(title: [Unequal but equivalent])[
  Let $dom = (5, +infinity, {5, 6})$ and $dom' = (7, +infinity, {})$. Then $dom domeqv dom'$. Let $dom_"empty" = (4, 6, {4, 5, 6})$ and $dom'_"empty" = (10, 5, {})$. Then also $dom_"empty" domeqv dom'_"empty"$.
] <ex:domeqv>

It is important to be able to determine whether an atomic constraint holds for all elements of a domain (i.e., when a domain satisfies the constraint, see @def:atomic and @def:constraint), since then we can check whether the premises of a fact hold. Furthermore, it should be easy to determine when a domain is inconsistent, which is necessary in the deduction step. 

Not every perforated interval can be easily checked for these conditions. For example, verifying whether $dom_"empty"$ from @ex:domeqv is inconsistent requires looking at the holes and seeing that every element in the interval is in the set of holes. However, $dom'_"empty"$, checking its bounds immediately leads to the conclusion that it is empty. Similarly, to see whether $x >=6$ holds for $dom$ (again, from @ex:domeqv) requires inspecting the holes, while for $dom'$ comparing 6 with the lower bound suffices. We now state the exact condition for such checks to require only inspecting the bounds.

#definition(title: [Tightness])[
 Let $dom = (dlb, dub, holes)$ be a perforated interval. Then $dom$ is called _tight_ if $dlb, dub in.not holes$.
]

In the next subsection, these checks are discussed in detail.

== Checks <sec:perfint:checks>

#todo[More examples?]

We want our domain to support efficiently answering the following two questions:
1. (Check atomic holds) Is a particular atomic constraint true for every value in the domain? (@def:atomic_holds)
2. (Check domain consistency) Is the domain non-empty? (@def:domconsistent)

Let us describe these properties formally.

#definition(title: [Domain consistency])[
  A domain $dom$ is _consistent_ (or _non-empty_), if there exists $n in ZZ$ such that $n in dom$.
] <def:domconsistent>

In the remainder of this section, we will make use of _unbound atomic constraints_. We call them _unbound_ because (as opposed to @def:atomic), they do not refer to any variable. Instead, they are a constraint on some number, without any reference to the concept of a variable. We will use the notation $[diamond.small c]$, where $c in ZZ$ and $diamond.small in {<=, >=, !=, =}$), to refer to them. We will also frequently omit "unbound" when this does not lead to confusion. Note also that an atomic constraint (as in @def:atomic) can be seen as a pair consisting of an unbound atomic constraint and a variable identifier.

#definition(title: [Atomic holds])[
  Let $a = [diamond.small c]$ be an atomic constraint. Then $a$ _holds_ for a domain $dom$ if for all elements $n in dom$, we can say $n diamond.small c$.
] <def:atomic_holds>

Note that if $dom$ is the domain of some variable $x$, @def:atomic_holds is equivalent to $dom$ satisfying the atomic constraint $[x diamond.small c]$ (@def:atomic and @def:constraint).



We describe a procedure for checking each of the two properties specifically for perforated intervals. The first _check function_ -- @fun:check_consistency[l] -- first checks whether the lower bound is positive infinity or the upper bound is negative infinity (returning `false` in both cases) and then checks whether the lower bound is less than or equal to the upper bound. If so, it returns `true`.

#funlink(<pseudo:check_consistency>, "check_consistency")
#pseudocode(title: "Domain consistency check")[
```tiplang2
Definition check_consistency(dom: PerforatedInterval) -> bool:
  match (lb(dom), ub(dom)):
    case (positive_infinity, _):
      return false
    case (_, negative_infinity):
      return false
    case (_, _):
      return lb(dom) <= ub(dom)
```
] <pseudo:check_consistency>


The next _check function_ -- @fun:check_holds[l] -- has different behavior for each atomic constraint.
- For $[<= c]$ constraints, it returns whether the upper bound is less than or equal to $c$. 
- For $[>= c]$ constraints, it returns whether the lower bound is greater than or equal to $c$
- For $[= c]$ constraints, it checks whether the lower and upper bounds are equal to $c$
- For $[!= c]$, it checks whether $c$ is strictly greater than the upper bound, $c$ is strictly smaller than the lower bound, or if $c in holes$.

#funlink(<desc:is_element_of>, "is_element_of")
#fundesc(title: [Returns whether `element` is an element of `set`.])[
  ```tiplang2
  Definition is_element_of(element: E, set: Set[E]) -> bool:
  ```
] <desc:is_element_of>

#funlink(<pseudo:check_holds>, "check_holds")
#pseudocode(title: [Check if atomic holds for domain])[```tiplang2
Definition check_holds(dom: PerforatedInterval, atom: Atomic) -> bool:
  match comparator(atom):
    case less_equal:
      return ub(dom) <=? constant(atom)
    case greater_equal:
      return constant(atom) <=? lb(dom)
    case equal:
      return (ub(dom) <=? constant(atom)) && (constant(atom) <=? lb(dom))
    case not_equal:
      if ub(dom) <? constant(atom):
        return true
      else if constant(atom) <? lb(dom):
        return true
      else:
        return is_element_of(constant(atom), holes(dom))
```] <pseudo:check_holds>



Our claim is now that when a perforated interval is tight, the check functions decide the properties (with an additional requirement on @fun:check_holds for the perforated interval to be consistent). In order to use the check functions correctly, an implementation would have to ensure the domains are tight before giving them to those functions. This gives the following two lemmas, which also serve as the correctness specifications of the check functions.

#lemma(title: [`check_consistency` decides consistency if tight])[
  Let $dom$ be a tight, perforated interval. Then $dom$ is consistent if and only if @fun:check_consistency$(dom) = $ `true`.
] <lem:check_consistenty_decides>

The proof has been formalized, but we omit it here, as most cases can be dealt with simply by case splitting and do not depend on the perforated interval being tight. Instead, we highlight one specific case to illustrate why the perforated interval must be tight. When $dub$ is some number $U in ZZ$ and $dlb = - infinity$, notice that $dub in dom$ (and therefore it is consistent), since the perforated interval is tight we have that $dub in.not holes$.


#lemma(title: [`check_holds` decides atomic holding if tight, consistent])[
  Let $dom$ be a tight and consistent perforated interval and $a$ an atomic constraint. Then $a$ holds for $dom$ if and only if @fun:check_holds$(dom, a) =$ `true`.
] <lem:check_holds_decides>

The reason we require consistency is that for an inconsistent and tight perforated interval, @fun:check_holds might not return `true`, even though our definition for an atomic holding would be trivially true (as the perforated interval is then empty). *Note*: we have _not_ formalized the forward direction of this proof for all cases, which is not needed for soundness. However, we have done it for the two cases we mention below, which are the most difficult part:
- When proving the forward implication for an atomic $a = [>= c]$ and we have that $dlb = -infinity$ and $dub$ is some number $U in ZZ$, @fun:check_holds equals `true` if $c <= - infinity$. This can never be the case, so we must derive a contradiction. Since we assume $a$ holds, then the value $min({U,c,min(holes union 0)}) - 1$ has to be greater or equal to $c$ as it is in the perforated interval (since smaller than all holes and smaller than $U$). But by its definition, it is strictly less than $c$. Hence, there is a contradiction. _For the upper bound case, we have not formally proven the forward implication due to time constraints._
- When proving that when a not equals constraint holds @fun:check_holds equals `true`, we look at the two possible outcomes of the triple or statement. In the non-trivial case, this then gives that $dlb <= c <= dub$ and $c in.not holes$. But that gives exactly that $c in dom$. But then the atomic constraint applies to $c$, so $c != c$, which is a contradiction.

Now that we know how to check consistency and whether an atomic constraint holds for a perforated interval, we will discuss in the next subsection how to actually build them, which is done by iteratively updating an initial domain representing all of $ZZ$.

== Updates <sec:perfint:updates>

For each type of atomic, a perforated interval can be updated such that the atomic holds for the perforated interval. This can, for example, be used to track the domains of variables during deduction step checking (@sec:deduct) or to extract lower and upper bounds from a fact (see @sec:res:infcheck for details).

- For $[<= c]$ constraints, update the upper bound by taking the maximum of the current upper bound and $c$ (using the operation defined in @sec:zext).
- For $[>= c]$ constraints, update the lower bound by taking the minimum of the current upper bound and $c$.
- For $[x = c]$, update the upper bound and then the lower bound just like for $<=, >=$-constraints to $c$.
- For $[x != c]$, update $holes$ by adding $c$.

We call the function that performs exactly this #jmono[apply_atomic(dom: PerforatedInterval, atomic: Atomic) -> PerforatedInterval], and the following lemma can be proven by examining the cases for $dlb$ and $dub$ and using the defined order on $Zext$. The lemma states that any integer is an element of a perforated interval that had an atomic applied if and only if that integer was an element of the original domain and it obeys the atomic constraint.

#let atomic = spro[atomic]

#lemma(title: [`apply_atomic` specification])[
  Let $n in ZZ$, #dom a perforated interval, and $[diamond.small c]$ an atomic constraint, then $n in #jmono[apply_atomic]\(dom, [diamond.small c]) <-> n in dom and n diamond.small c$.
] <lem:apply_atomic_spec>

When we have a large number of atomic constraints we want to use to build a domain (during e.g. inference checking, or from the premises of a deduction step), we simply use a fold over a list of atomic constraints, which we call #jmono[apply_atomics(dom: PerforatedInterval, atomics: list Atomic) -> PerforatedInterval]. Using a straightforward induction proof, we can generalize @lem:apply_atomic_spec as follows:

#let atomics = spro[atomics]

#lemma(title: [`apply_atomics` specification])[
  Let $n in ZZ$, #dom a perforated interval and #atomics a list of atomic constraints, then $n in #jmono[apply_atomics]\(dom, atomics) <-> n in dom and (forall [diamond.small c] in atomics, n diamond.small c$).
]

Armed with this lemma, we see that applying the order of atomic constraints has no effect on which logical domain is implied by them. This is a powerful tool for when we want to manage applying multiple atomic constraints. 

In @sec:perfint:checks, we described the check functions for perforated intervals. They work correctly only when given tight domains. How to achieve tightness is described in the next section.

== Tightening procedure <sec:perfint:tightening>

In this section, only the case for tightening the lower bound is described. The upper bound case is fully symmetric. In our formal proofs, we have tried to use this symmetry to avoid duplicate proofs as much as possible. We describe this technique at the end of this section.

The tightening procedure is simple. Given a list of holes in strictly increasing order (so in particular it also has no duplicates) and an initial lower bound, we can tighten the lower bound by first iterating until we find a hole equal to the current lower bound. The current bound is then increased by one. We then keep iterating until the next hole is not equal to the current bound (which happens when the list of holes skips at least one integer). We illustrate this with a simple example.

#example(title: "Tightening")[
  Suppose we have a variable $x$ that we know is greater than or equal to $5$. Given a list of holes (values that we know $x$ cannot take) of [3, 5, 6, 7, 9], we first iterate until we reach 5, so then we are left with [5, 6, 7, 9]. Then the bound is updated to 6, to 7, and to 8 as we iterate. However, since there is no hole at 8, we stop. Therefore, our lower bound is updated to 8.
]

We give pseudocode for the implementation. Here, `tighten_lb_with_holes` is "Recursive", which indicates it is a recursive function. Furthermore, the second case is the case where the list is non-empty, after which the head of the list is assigned to the variable `h` and the remaining elements to `holes'`. `filter_greater_eq(l: list Z, b: Z)` simply iterates until it finds a value greater or equal than its second argument, after which it returns all elements starting from there (in the same order as the original list).

#pseudocode(title: [Tighten lower bound given holes])[```
Recursive tighten_lb_with_holes(holes: list Z, lb: Z) -> Z:
  match holes:
    case nil:
      return lb
    case h :: holes':
      if h =? lb:
        return tighten_lb_with_holes(holes', lb + 1)
      else:
        return lb
```]
#pseudocode(title: [Tighten domain lower bound])[```
Definition tighten_lb(dom: PerforatedInterval) -> PerforatedInterval:
  match lb(dom):
    case lb_value:
      if is_element_of(lb_value, holes(dom)):
        holes_from_lb := filter_greater_eq(holes(dom), lb_value)
        updated_lb := tighten_lb_with_holes(holes_from_lb, lb_value)
        return (updated_lb, ub(dom), holes(dom))
      else:
        return dom
    case _:
      return dom
```]

Note that in `tighten_lb` we first check if we need to do any tightening at all. Furthermore, note that we do not update the holes, as removal is not cheap, and we would potentially have to remove many elements after tightening the bounds.

#let tightenlbholes = jmono[tighten_lb_with_holes]
#let tightenlb = jmono[tighten_lb]
#let filterge = jmono[filter_greater_eq]

We are interested in proving two facts: *1) (tighten equivalency)* tightening the bounds produces a new domain that is equivalent to the previous one, i.e., tightening does not change the elements that can be in the domain. This is useful when we care only that the bounds produced in the domain procedures are actually valid for the variable we are looking at, not if they are as good as they could be. _Critically, this is actually all that is needed to prove the soundness of the checker._ *2) (tightening tightens)* after applying the tightening procedure (not just on the lower bound, but also the upper bound), our domain is tight. If that holds, we can apply what we learned earlier about tight domains. We begin with the fact that tightening creates a new equivalent domain. As before, we only write down the case for tightening the lower bound. 

=== Tighten equivalency

We first need a number of intermediary lemmas that relate to #tightenlbholes. The first one says that if a value obeys some bound and is not a hole, that value will still obey the tightened bound. To see why (in the case of a lower bound), tightening always terminates when we reach a value not in the holes. Since it is a valid lower bound, it was originally below the value. But since the value is not in the hole, it can never increase beyond the value.

#lemma(title: [Soudness of #tightenlbholes])[
 Let $holes$ be a list of integers and $y in ZZ$ s.t. $y in.not holes$. Furthermore, let $dlb in ZZ$ s.t. $dlb <= y$. Then, $tightenlbholes(holes, dlb) <= y$.
] <lem:tighten_with_holes_sound>
#proof[
  We prove this by induction over $holes$. First, in the case when $holes$ is empty, we immediately return the bound unchanged. But since one of our assumptions is that $dlb <= y$, if it remains unchanged, then still $tightenlbholes(holes, dlb) <= y$. Now consider the inductive case, where we have $y in.not (h "::" holes')$ and $dlb <= y$. We then have to show that $tightenlbholes((h :: holes'), dlb) <= y$. Consider that if $h != dlb$, the bound remains unchanged. Therefore, we can again use our assumption that $dlb <= y$. In the other case, we must show, after simplifying, that $tightenlbholes(holes', h + 1) <= y$. First, note that $y in.not (h "::" holes')$ indicates $y != h$ and $y in.not holes'$. Furthermore, as we did induction over general $dlb$, our induction hypothesis states that $forall b, y in.not holes' and b <= y -> tightenlbholes(holes', b) <= y$. Therefore, we can apply our induction hypothesis with $b = dlb + 1$. We already had that $y in.not holes'$, so all that remains is to show that $dlb + 1 <= y$. Since $dlb <= y$, it is enough to show $y != dlb$. But we already have $y != h$, and in the case we are considering $h = dlb$.
] 

Next, we have that tightening can only ever increase (so it is also monotonic). 

#lemma(title: [Monotonicity of #tightenlbholes])[
  Let $holes$ be a list of integers and $dlb in ZZ$. Then $dlb <= tightenlbholes(holes, dlb)$.
] <def:tighten_holes_monotonic>
#proof[
  We again use induction over $holes$. For empty $holes$, $tightenlbholes\(holes,$ $dlb) = dlb$, so in that case we are done. In the inductive case, we must show $dlb <= tightenlbholes((h "::" holes'), dlb)$. Consider first the case where $h = dlb$. Then we have to show $dlb <= tightenlbholes(holes', dlb+1)$. Then we can use our induction hypothesis (which, since we were general in $dlb$, states $forall b, b <= tightenlbholes(holes', b)$) to find that $dlb + 1 <= tightenlbholes(holes', dlb+1)$, so certainly $dlb$ is also less than or equal. In the case where $h != dlb$, we just have to show $dlb <= dlb$ by the definition of $tightenlbholes$, so we are done immediately.
] 

Then, we prove the equivalence of having a bound and a hole and having a tight bound and a hole.

#lemma(title: [Tightened bound equivalency])[
  Let $holes$ be a list of integers and $dlb, y in ZZ$. Then the following are equivalent:
  1. $dlb <= y$ and $y in.not holes$
  2. $tightenlbholes(filterge(holes, dlb), dlb) <= y$ and $y in.not holes$
] <def:tighten_holes_equiv>
#proof[
  Let $holes, dlb, y$ be as in the assumptions.
  
  $1 => 2$: Clearly we have $y in.not holes$. Then we apply @lem:tighten_with_holes_sound ($tightenlbholes$ soundness), after which it remains to be shown that $dlb <= y$ and $y in.not filterge(holes, dlb)$. The first is part of our assumptions. To see why $y in.not filterge(holes, dlb)$, consider that $filterge(holes, dlb)$ is a subset of $holes$, so since $y in.not holes$, certainly it is not in the subset.
  
  $2 => 1$: Again, $y in.not holes$ is immediate from our assumptions. Then, since $dlb <= tightenlbholes\($$filterge\(holes,$$ dlb), dlb)$ by the monotonicity of tightening (@def:tighten_holes_monotonic), and because we have $tightenlbholes\($$filterge(holes, dlb),$$ dlb) <= y$ by assumption, we have $dlb <= y$ as required.
] 

#let tightenfilter = [$tightenlbholes\($$filterge(holes, dlb))$]

#lemma(title: [`tighten_lb` preserves logical domain])[
 Let #dom a perforated interval. Then $tightenlb(dom) domeqv dom$. 
]
#proof[
  Let $n in ZZ$ and $dom = (dlb, dub, holes)$. We must show that $n in dom <-> n in tightenlb(dom)$.
  First, suppose $dlb in {infinity, -infinity}$. Then we see that $tightenlb$ does not modify the domain. Therefore, we look only at the case where $dlb in ZZ$. Next, consider the case where $dlb in.not holes$. Again, the domain remains unchanged, so we may now assume $dlb in holes$. We have that $tightenlb(dom) = $$(tightenfilter,$ $ dub,$ $ holes)$, so all that remains to be shown is that $dlb <= n <-> tightenfilter <= n$. For this, we can apply @def:tighten_holes_equiv (tightened bound equivalency), since for both the $=>$ and $arrow.l.double$ we also have that $n in.not holes$. 
]

=== Tightening tightens

Now that we have seen that our implementation of tightening creates an equivalent domain, we want to show that this actually creates a domain that is tight. This is not trivial to prove and relies on the $holes$ being sorted. In our implementation, the $holes$ set is implemented using a tree data structure, allowing efficient iteration in sorted order. We again state only the case for lower bounds. We first state and prove a lemma about the exact behavior of $tightenlbholes$. This is almost exactly what we want, but here we expect $holes$ to not contain any "redundant" holes. In our practical implementation, this is ensured by $filterge$.

#lemma(title: [Tighten holes specification])[
  Let $holes$ be a list of strictly increasing integers and let $dlb in ZZ$. Then, if we have that for each $h in holes, dlb <= h$, this implies $tightenlbholes(holes, dlb) in.not holes$.
] <lem:tighten_holes_spec>
#proof[
  #todosm[]
]

#lemma(title: [Tightened lower bound is not in holes])[
  Let $dom$ be a perforated interval. Then, $dlb\(tightenlb$$\(dom))$ $in.not$ $ holes\(tightenlb$$(dom))$.
]
#proof[
  First, observe that $tightenlb$ does not change the holes, so let $holes$ be the holes of $dom$. Furthermore, if $dlb(dom)$ is not finite or is already not an element of $holes$, we are also done. In the other case, we have that $dlb(tightenlb(dom)) = tightenfilter$. Let us abbreviate this value by $dlb'$. Therefore, we must show that $dlb' in.not holes$. First, we see that $dlb <= dlb'$ by the monotonicity of $tightenlbholes$. We will now determine that $dlb' in.not holes$ by showing that $dlb' in holes$ implies a contradiction. Since $dlb' in holes$ and also $dlb <= dlb'$, we know that $dlb' in filterge(holes, dlb)$. This is because $holes$ is sorted in strictly increasing order (by our implementation of the perforated interval), so since $filterge$ returns the part of the list to the right of $dlb$, we know the returned elements are exactly those elements in the original list greater than or equal to $dlb$. It is enough to show that $dlb' in.not filterge(holes, dlb)$, as that implies a contradiction. We can now apply @lem:tighten_holes_spec (tighten holes spec) with $holes = filterge(holes, dlb)$, which, if we substitute the meaning for $dlb'$, finishes the proof.
]

We have seen how we can check whether a perforated interval is empty and whether an atomic constraint holds for it, how we can update it, and how we can tighten it. We also saw that when a perforated interval is tight, the efficient checks we implement actually decide the properties we seek to check. We now conclude our discussion of perforated intervals with a discussion of some considerations that matter for the actual implementation and formalization.

== Implementation considerations <sec:perfint:impl>

=== #Zext

We implement #Zext exactly with the properties as described in @sec:zext. For this, we introduce a new inductive type in Rocq, as shown in @snip:zext. Here, `Z` is the integer type of Rocq. The type corresponds exactly to the three cases of $Zext$: either it is an integer, $-infinity$, or $+infinity$.

#snippet(title: [Definition of #Zext in Rocq])[```
Inductive Zext :=
| zz : Z -> Zext
| neg_inf : Zext
| pos_inf : Zext.
```] <snip:zext>

We then define a module that is a subtype of `UsualOrderedTypeFull` from the `Structures.Orders` file of the Rocq standard library. `Usual` here relates to the fact that we have the usual Leibniz equality between elements. We then need to define and prove the required properties, such as `compare`. We also get the notation. Furthermore, by including a number of other modules that provide additional facts, we get a large amount of lemmas for free, nearly the same number as are available for `Z`. In particular, we include `GenericMinMax`, which automatically defines `min` and `max` and a number of useful lemmas (which we extend with additional standard library modules that provide additional properties for free).

We also implement a number of tactics. We noticed that various of the lemmas that are automatically available are automatically unwrapped and stated in terms of the defined `Zext.compare`, instead of the more natural comparison operators we define. Therefore, we provide tactics that automatically replace instances of `Zext.compare` with the operators that have nicer notation and interpretation. The most essential tactic is `zext_as_z`, which rewrites $Zext$ comparisons that we know are between finite numbers in terms of the standard $ZZ$ comparison operators. Combined with the `lia` tactic, many goals can then be solved. We also provide some tactics to destruct instances of $Zext$ into the possible cases and try to solve the goal, but even with just a few instances, this can already be slow and generate too many cases. We found that doing the destruction manually often kept things more manageable. In fact, the infinity cases are often rather easy to solve with just simplification and tactics such as `easy`.

We believe the value of using $Zext$ as opposed to using e.g., `option Z` is twofold:
1. Since we get the definition of `min` and `max` and associated lemmas for free, we do not require defining special functions which work differently depending on whether `option Z` is a lower bound or upper bound. This also applies to writing tactics.
2. The code and proofs are easier to read, as $<=, >=, <, >$ have a very well-known intuitive meaning.

The proofs do not necessarily become easier, as tactics could also be written for `option Z` that would achieve similar convenience. We expected that the use of the `order` tactic would simplify many proofs, but we were unable to get it to work even in simple cases. It would most likely be easier to extend the `lia` tactic to $Zext$ than the previous approach. This would make most proofs trivial, but was not attempted in this work.

==== Holes

We implement the set of holes of a perforated interval with the `MSetInterface` from the Rocq standard library. More specifically, we use `MSetRBT` @filliatre2004functorproofprog @appel2011rbt. This implementation uses a red-black tree and therefore provides logarithmic lookup, deletion and insertion. Furthermore, when converting a set into a list, one gets the list in strictly increasing sorted order. `MSetRBT` was chosen due to the arguments provided in @appel2011rbt: they require much less bookkeeping computations using the Rocq `Z` integer type and were benchmarked to perform faster. However, we do not provide any systematic comparison in this work.

==== Tighten symmetry

We only stated and proved all the tightening lemmas for the lower bound case. However, we also want to prove the upper bound case. The proofs are almost entirely symmetrical, simply turning $<=$ into $>=$ and vice versa would be enough. However, we do not want to duplicate these proofs, as the proof is basically the same. Instead, we made the definitions and lemmas generic over $<=$ and $>=$. We first define a simple type `Sign` that is either plus or minus. Then, for $<=, <, <?$ we define operations that take a `Sign` as an additional parameter, where in the minus case the order of the arguments is swapped. We give one example below.

#snippet(title: [Definitions for implementing tightening symmetry])[
```
Inductive Sign :=
| plus
| min.

Definition le_flip (sign : Sign) x y :=
  match sign with
  | plus => Z.le x y
  | min => Z.le y x
  end.
```]

Next, we define notation that makes it clear the actual direction of the operator depends on the provided sign. For example, we use the notation `x <=[z] y` to mean `le_flip z x y`. Finally, we define the following tactic:

#snippet(title: [Tactic for automatically simplifying signed comparisons.])[```
Ltac simpl_sign :=
  match goal with
  | [ sign : Sign |- _ ] =>
    unfold sign_to_z in *; unfold le_flip in *; 
    unfold lt_flip in *; unfold ltb_flip in *; 
    destruct sign
  end.
```]

This tactic searches for a variable of type sign and, if it exists, unfolds all the earlier definitions and then splits into two cases. In our proofs, we often use this tactic at the very end, followed by `lia`. We also define a function `sign_to_z` that returns +1 for `plus` and -1 for `min`, which we use in our generic tighten function to either increase or decrease, depending on the sign. 

This strategy removes most of the duplication present in the tightening proofs, leaving only a few cases like the actual `tighten_lb` and `tighten_ub` that work on domains.

// === Alternatives

// Alternative representations are:

// - list of intervals

// Why not that? Harder to update just lower or upper bound, more difficult logic to establish whether a not-equals constraint holds, would require a more specialized datastructure (harder to verify)

// #todosm[Look up more literature]

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

#pagebreak(weak: true)

= Deduction step checker <sec:deduct>

In the previous section, we introduced the perforated interval. With that as a building block, we now describe the formalization and implementation of the deduction step checking procedure (@proc:deduct). To track the domains, we use a map data structure that maps strings to perforated intervals. We will simply refer to these as "domain maps" (or `Domains` in pseudocode). Before we present the pseudocode of our implementation for the deduction step, we will go into more detail about the operations available on domain maps and how they can be constructed.

== Domain maps <sec:domainmap>

A domain map can be constructed directly from a list of atomic constraints, which then represents the domains of the variables when assuming every atomic constraint in the list must hold. The function that does this, `domains_from_atomics(atoms: list BoundAtomic) -> Domains`, first builds a map where each variable maps to all atomics associated with exactly that variable. We then apply `apply_atomics` to all these lists with an initial perforated interval of $(-infinity, infinity, nothing)$. Note that this does not do any tightening; it simply successively updates the domain so that every atomic constraint is reflected. As tightening is relatively expensive, this saves a lot of work. To then allow tightening and checking consistency, we define `tighten_doms(doms: Domains) -> Domains` and `check_domains_consistent(doms: Domains) -> bool`, which simply apply the associated perforated interval operations to every value in the map (and in the later case returns #ttrue if every single one of them is #ttrue, and #ffalse otherwise).

These operations are useful, especially when considering multiple atomic constraints at once. However, in the case of the deduction step, we must ensure, before every inference, that the domains are tight. Tightening every domain (which, if every domain is already tight, still requires a single membership check for every variable domain) is not free. For this reason, there is also `doms_apply_tighten(doms: Domains, atomic: BoundAtomic) -> option Domains`, which updates only the domain of the variable associated with the atomic, immediately tightens it again, and returns `None` if the domain becomes inconsistent. 

We do not go into detail about the various lemmas required for utilizing the domain maps, except for the primary one necessary for soundness. This is because these lemmas are mostly straightforward, albeit tedious, to prove. Furthermore, they are tightly coupled to our specific implementation. They simply generalize the detailed facts we already know of the individual perforated interval operations to apply to multiple variables, or are related specifically to using the map. Let us now consider the most interesting fact, which is when we call a domain map "valid". To do this, let us define some notation. When $D$ is a domain map, $D(x)$ [in the implementation, we use the notation `D d-> x`] is the perforated interval stored for the variable $x$, or simply $ZZ$ in case nothing is stored for $x$. Next, let `atoms_for_var(x: Id, atomics: list BoundAtomic) -> list Atomic` be the function that filters a list of `BoundAtomic` to extract only the atomic constraints for the given atomic variable. Then, we define the following function (where `initial_dom` = $(infinity, -infinity, nothing)$:

#pseudocode(title: [Specification function for domain induced by atomic constraints])[
```
Definition applied_dom(x: Id, atomics: list BoundAtomic) -> PerforatedInterval:
  apply_atomics(atoms_for_var(x, atomics), initial_dom)
```
]

The above function outputs what we would like our variable domain to look like after we construct a domain map. However, we do not actually use the above function; it simply defines the specification, which we can now state as follows:

#let applieddom = spro[applied_dom]

#definition(title: [Domain map validity])[
  Let $D$ be a domain map and $atomics$ a list of atomic constraints. Then $D$ is _valid_ for $atomics$ if, for all $x$, $D(x) domeqv applieddom(D, atomics)$.
]

We skip the precise statements and proofs of the facts related to domain map validity, again because their proof relies on very specific implementation details and is rather mechanical. We quickly summarize them here:

- The domain map produced by `domains_from_atomics` is valid for the atomics it is given.
- If a domain map is valid for some list of atomics, then the result of applying `doms_apply_tighten` will also be valid for this list of atomics, as well as the additional atomic constraint that is given.
- Since we proved that the result of `tighten_doms` is equivalent to its input, we immediately have that it also preserves domain map validity.

Before moving on to the implementation of the deduction step, we also mention how domain maps are useful for inference checking.

=== Inference checking <sec:res:infcheck>

An inference of the form $a_1 and ... and a_m -> q$ can often be verified more easily by explicitly considering the domains of variables, as opposed to looking at the atomic constraints. More precisely, inferences can be verified if their associated constraint cannot be satisfied given the domain implied by $a_1 and ... and a_m and not q$. However, it is often useful for inference checking to know which variable is mentioned in the right-hand side, as this can provide a hint that speeds up verification in some cases (this is particularly important for the cumulative checker). For this reason, we define the following functions:

#pseudocode(title: [Extract consequent variable and convert to conflict form])[```tiplang2
Definition atomics_from_fact(fact: ProofFact) -> option[Id]*list[BoundAtomic]:
  match consequent(fact):
    case None:
      return (None, premises(fact))
    case Some(consq_var, consq_atomic):
      negated := negate_bound_atomic((consq_var, consq_atomic))
      return (Some(consq_var), negated :: premises(fact))
```]
#pseudocode(title: [Infer domain map and consequent variable from fact])[```tiplang2
Definition infer_domains(fact: ProofFact) -> option[Domains*option[Id]]:
  (maybe_consq_var, atomics) := atomics_from_fact(fact)
  doms := domains_from_atomics(atomics)
  doms_tight := tighten_doms(doms)
  if check_domains_consistent(doms_tight):
    return Some(doms_tight, maybe_consq_var)
  else:
    return None
```]

We see that `infer_domains` returns exactly the domain map implied by $a_1 and ... and a_m and not q$, as well as the variable for $q$. It also checks for consistency, since that usually indicates there is something wrong with the inference. For `infer_domains` to be useful, we need a useful specification for it. For this, we introduce a second way for a domain map to be valid, but in this case with respect to a solution instead of a list of atomics. Note that this is exactly the same as in @def:assignment.

#definition(title: [Domain map consistent with solution])[
  Let $v$ be an assignment and $D$ a domain map. Then we say $v$ is consistent with respect to $D$ if for all $x$, we have $v(x) in D(x)$.
] <def:sol_ind_doms>

We now relate it to the concept of domain map validity we introduced earlier.

#lemma(title: [Domain validity and assignment consistency])[
  Let $atomics$ be a list of atomics, $v$ an assignment, and $D$ a domain map. Then, if $D$ is valid with respect to $atomics$, we have that the following are equivalent:
  1. $v$ satisfies $atomics$
  2. $v$ is consistent with respect to $D$
]

This finally gives rise to the specification of `infer_domains`:

#let fact = jmono[fact]

#lemma(title: [Specification of `infer_domains`])[
  Let $fact$ be a fact and $D$ a domain map. Then, if `infer_domains(fact) = Some (D, _)`, we have that the following are equivalent:
  1. $v$ is *not* consistent with respect to $D$
  2. $v$ satisfies $fact$
] <lem:infer_domains_correct>

To see why this is useful, consider the following generic inference checker, where we assume `domain_cannot_satisfy_my_constraint` is a function that, when it returns `true`, is indeed correct that the constraint cannot be satisfied for the particular domain:

#pseudocode(title: [Propagator inference checker structure])[```
Definition my_checker(fact: Fact, constraint: MyConstraint) -> bool:
  match infer_domains(fact):
    case None:
      return false
    case Some (doms, _):
      if domain_cannot_satisfy_my_constraint(doms, constraint):
        return true
      else:
        return false
```]

Proving soundness involves proving that if the checker returns #ttrue for a particular fact and constraint, then the fact must be satisfied by every assignment satisfying that constraint. More precisely:

#lemma(title: "Soundness for generic constraint inference checker")[
  Let $C$ be a constraint of type `MyConstraint` and let $fact$ be a fact s.t. `my_checker(fact, C) = true`. Then for all assignments $v$ that satisfy $C$, we have that they also satisfy $fact$. 
]
#proof()[
  Let $v$ be an assignment that satisfies $C$. Since `my_checker(fact, C) = true`, we see that `infer_domains(fact)` must have resulted in some domain $D$. We can then rewrite our goal using @lem:infer_domains_correct (`infer_domains` specification). We must then show that $v$ is not consistent with respect to $D$. But this is exactly what `domain_cannot_satisfy_my_constraint` tests for, which we now to be `true` because our checker returned #ttrue.
]

== Deduction implementation

The implementation of the deduction step follows @proc:deduct very closely. The premises are first converted to a domain map in one go using `domains_from_atomics`. After that, the domains are tightened so that we can efficiently check whether a premise holds for a domain. This is done by `all_premises_hold`, which relies on `check_holds` that works on perforated intervals and atomics. Finally, the consequent of each inference (after the premises are checked to hold) is applied using `doms_apply_tighten`, which ensures the domains remain tight throughout the deduction procedure. We now state the pseudocode for our implementation.

#pseudocode(title: [Deduction recursive step result])[
```
Inductive DeductStep:
  case deduct_domains(domains:  Domains)
  case deduct_valid
  case deduct_reject
```
]
#pseudocode(title: [Deduction check result])[
```
Inductive CheckDeductResult:
  case deduced
  case failed
```
]

#pseudocode(title: [Recursive step for one inference])[
```
Definition step_inference(fact: ProofFact, domains: Domains) -> DeductStep:
  if all_premises_hold(premises(fact), domains):
    match consequent(fact):
      case None:
        return deduct_valid
      case Some consequent:
        match doms_apply_tighten(domains, consequent):
          case None:
            return deduct_valid
          case Some domains':
            return deduct_domains(domains')
  else:
    return deduct_reject
```
]

#pseudocode(title: [Deduction checker with initialized domains])[
```
Recursive deduct_check_inferences(facts: list ProofFact, domains: Domains) -> CheckDeductResult:
  match facts:
    case nil:
      return deduct_failed
    case fact :: facts':
      match step_inference(fact, domains):
        case deduct_domains domains':
          return deduct_check_inferences(facts', domains')
        case deduct_valid:
          return deduced
        case deduct_reject:
          return deduct_failed
```
]

#pseudocode(title: [Deduction checker])[
```
Definition check_deduct(premises: list BoundAtomic, steps: list ProofFact) -> CheckDeductResult:
  doms := domains_from_atomics(premises)
  doms_tight := tighten_doms(doms)
  if check_domains_consistent(doms):
    return deduct_check_inferences(steps, doms_tight)
  else:
    return inconsistent_premises
```
]

Before we state the main correctness lemma, which does not actually mention domain maps as these are an implementation detail and not present in the signature of `check_deduct`, we state the lemma that specifies the correctness of `deduct_check_inferences`. This is also the main inductive proof and the most difficult part of the deduction step.

#let steps = jmono[steps]

#lemma(title: [Correctness of `deduct_check_inferences`])[
  Let $v$ be an assignment, $atomics$ a list of atomic constraints, and $D$ a domain map s.t. $D$ is valid for $atomics$. Furthermore, let $steps$ be a list of inference facts. Then, if we have that $v$ satisfies every inference $s in steps$ and if `deduct_check_inferences(steps, D) = deduced`, then $v$ satisfies the fact with premises equal to $atomics$ and an empty consequent.
] <lem:deduct_check_inferences>

We omit the proof as it follows quite easily when performing induction over $steps$, although it is still somewhat tedious. We do mention that the case where `DeductStep` is valid, but the inference has a non-empty consequence. We must then have that applying the consequent leads to an empty domain for the consequent variable. To then prove that the assignment satisfies the nogood, we use the knowledge that if an assignment satisfies a list of atomic constraints, applying these atomics must result in a consistent domain (since the assignment's value must be in the domain, so it is non-empty). This then results in the contradiction we need to verify the nogood.

With the above lemma in hand, we can state the primary lemma that is used by the checker, which does not care about how domains are actually implemented.

#lemma(title: [Correctness of `check_deduct`])[
  Let $v$ be an assignment, $atomics$ a list of atomic constraints, and $steps$ a list of inference facts. Then, if we have that $v$ satisfies every inference $s in steps$ and if `check_deduct(atomics, steps) = deduced`, then $v$ satisfies the fact with premises equal to $atomics$ and an empty consequent.
] <lem:deduct_check>

We omit the proof as it follows immediately from `deduct_check_inferences` and the properties of the domain map operations.

== Implementation considerations

=== Domain maps <sec:domainmap:impl>

The map data structure comes from the `MMaps` Rocq community library @mmaps2024 @filliatre2004functorproofprog @appel2011rbt and is a modernization of the `FMaps` file in the Rocq standard library. We expect it will, at some point, be accepted into the standard library. It was selected because it also contains an implementation based on red-black trees, which is not the case for `FMaps`. 

=== Error handling

The original implementation of the deduction step was almost identical to the pseudocode. However, it was later enhanced with the ability to propagate what exact premise causes the deduction step to fail. We removed this for the sake of clarity and because this was not an original contribution of the author.

#pagebreak(weak: true)

= Alldifferent checker <check:alldiff>

We saw in @sec:prelim:alldiff that, according to @thm:hall, there is a necessary condition for all alldifferent conflicts. Our checker exploits exactly this. We do not actually formalize the fact that this condition is necessary, as for soundness, we only need that it is a sufficient condition. We developed this proof in a way that is mostly agnostic to the actual checker implementation. We state and prove it below.

// The checker for alldifferent verifies an inference if it can identify a set of variables such that the size of the unions of their domains is smaller than the number of variables. This necessarily means we have a conflict. We will now prove this fact.

// In the below proofs, a _set_ is a list with a proof that it has no duplicates. Furthermore, there is an alldifferent constraint defined by variables _variables_. An assignment is a function that that sends variables to their assigned value.

#let vars = spro[variables]
#let domunion = spro[domain_union]
#let doms = spro[doms]
#let mapfn = jmono[map]
#let varvals = spro[vars_values]

#lemma(title: [Sufficient condition for alldifferent unsatisfiability])[Let #vars be a list of variables with no duplicates, #doms a mapping of variables to a _materialized_ domain (a finite set explicitly listing all values in a variable's domain) and #domunion a list of integers with no duplicates s.t. $forall n, n in domunion <-> exists x, x in vars and n in doms(x)$. Then, if the length of #domunion is strictly less than the length of #vars, there exists no solution $v$ that satisfies the alldifferent constraint with variables #vars and where $v(x) in doms(x)$ (for all $x in vars$).] <lem:alldiff_suff>
#proof[
  Our goal is to prove that there exists no solution. That means that if such a solution exists, there must be a contradiction. Therefore, let $v$ be an assignment that satisfies the alldifferent constraint defined by #vars and such that $forall x in vars, v(x) in doms(x)$. It is enough to show that the length of #domunion is greater than or equal to the length of #vars, since we assumed the opposite, and if this is the case, we can derive a contradiction, which is our goal. 

  Now, the length of #vars is the same as the length of $mapfn(v, vars)$, which is the list obtained by mapping all variables to their assignment according to $vars$#footnote[This fact holds for any list and function and can be proven by induction. Length is defined recursively in the natural way.]. We will call this mapped list of values #varvals. We can now replace our goal with showing that the length of #domunion is greater than or equal to the length of #varvals.

  We now use the well-known fact that states that if a list has no duplicates and every element of that list is also in another list, then the length of this list must be smaller than the list it is contained in. Applied to our goal, all that is then left to show is that #varvals has no duplicates and is indeed contained in #domunion. 

  First, we show that #varvals contains no duplicates. For this we use a lemma that states that when a function $f$ is injective (i.e., when $f(x)=f(y)$, $x=y$, also known as one-to-one) for all inputs that are elements of some list $L$, then if that list has no duplicates, $mapfn(f, L)$ will also have no duplicates. Applied to our goal of showing #varvals has no duplicates, it remains to show that $v$ is injective on #varvals. For this, let $x$ and $y$ be two variables in #vars such that $v(x) = v(y)$. The goal is then to show that $x$ and $y$ are equal. However, since $v(x) != v(y)$ because of our assumption that $v$ satisfies the alldifferent constraint defined on #vars, we are done as this conflicts with $v(x) = v(y)$. Furthermore, one of our main assumptions was that #vars had no duplicates.

  We have now proven the first subgoal, leaving only the requirement that #varvals is contained in #domunion. Let $n$ be an arbitrary element of #varvals. Then we are done if $n$ is also in #domunion. First, note that since $n$ is in a mapped list, there must exist $x$ s.t. $x in vars$ and $n = v(x)$. #footnote[This fact holds for any list and function and can again be proven through induction, through the definition of map].
  No,w based on our assumptions, $n$ is an element of $domunion$ exactly if there exists an $x'$ such that $x' in vars$ and $n in doms(x')$. Let $x$ be this $x'$. The first condition we already showed, and since $v(x) in doms(x)$, we must have that $n in doms(x)$. 
]

We now present the pseudocode for the actual checker, which we prove to be sound with the earlier lemma. We use the functions from @sec:res:infcheck (inference checking results), in particular, `infer_domains`. However, we are interested in computing the length of the union of all domains. To do this using perforated intervals would require taking the min/max of the bounds as well as the intersection of all holes. However, to simplify our proofs and implementation, we instead chose to first materialize every perforated interval into a finite set of values (as this also fits more with the previous lemma) and then compute the union. To materialize a perforated interval, we first construct a range from the upper to the lower bound and then remove every hole. An alternative would be to check first if an element in the range is a hole before adding it to the final set, but we chose the first implementation for simplicity. We will not go into detail about this implementation. We do note that any variables without a finite domain are not included in `materialize_vars_doms`, which gives a list of materialized domains for the given variables using the given domains. For this reason, we also use the length of this result, instead of directly using the number of variables in the constraint. Next, `union_sets` computes the union of a list of sets. `cardinal` is used instead of `length` because `union_sets` returns a set, not a list.

#pseudocode(title: [Alldifferent inference checker])[
```
Definition alldifferent_checker(fact: ProofFact, constraint: AlldifferentConstraint) -> bool:
  match infer_domains(fact):
    case None:
      return false
    case Some (domains, _):
      materialized_doms := materialize_vars_doms(variables(constraint), domains)
      return cardinal(union_sets(materialized_doms)) <? length(materialized_doms)
```  
]


Our checker has one significant limitation: to guarantee the fact is verified, the fact may only mention the actual conflicting variables (i.e., the variables in the tight Hall set), since our checker has no way to actually determine which variables are the conflicting ones. This would require a significantly more complex algorithm (see @proc:findhall). However, this algorithm would not have to be verified for soundness, since as long as we know which variables to look at, we can determine that the constraint has no solution. We give an example of a fact our checker cannot verify.

#example(title: [Incorrect rejection of valid fact])[
  Consider the domains $D(x) = {1, 3}, D(y) = {1, 3}, D(z) = {1, 3}, D(r) = {2, 4}$. The alldifferent constraint with variables ${x, y, z, r}$ would not have a solution, since if we take the conflicting variables ${x, y, z}$, we see there are only two values to choose from. However, if we also include the domain of $r$ into our fact, our checker would count 4 variables and 4 values, which is perfectly fine, and hence the checker would reject the fact.
]

== Implementation considerations <check:alldiff:impl>

In order to prove soundness using @lem:alldiff_suff (sufficient condition for alldifferent unsatisfiability), we must construct the required $vars$, $domunion$, and $doms$ that fulfill the lemma's requirement. As we designed the lemma to be mostly agnostic to the checker's implementation details, we cannot use the result of `infer_domains` for $doms$ (this implementation-agnostic design is discussed in more detail in @sec:rocq:twocat). Furthermore, we also cannot simply use all variables in the domain map, since the fact might include variables that are not in the constraint. While we will not provide the full checker soundness proof here, we do give our choice for these variables, as the rest is mostly straightforward and mechanical. First, let $D$ be the domain map that results from `infer_domains`. 
- For $vars$ we take all keys of $D$ and filter out those that are not bounded, after which we filter out those that are not contained in the constraint. 
- For $doms$ we define $doms(x)$ as the materialized version of $D(x)$ if $D(x)$ is finite, and an empty set either if $x$ is not in $D$ or if $D(x)$ is infinite. 
- For $domunion$ we choose exactly the union that the checker also picks, so `union_set(materialize_vars_doms(variables(constraint), domains))`. 
Note that you could use the implementation of `materialize_vars_doms` (which uses `flat_map_option`, which in one iteration performs a map but only includes those who are mapped to `Some`; for which we have a lemma that shows it is equivalent to first filtering and then mapping) to choose $vars$. While this makes showing that `length(materialized_doms)` is indeed the length of the variables easier, it must be shown to have no duplicates, which is harder than the double filter approach we take.



#pagebreak(weak: true)

= Cumulative checker <check:cumul>

For our implementation of an inference checker for a cumulative timetable propagator, we follow our method in @proc:methodinf (methodology for inference checker development), applying it to the timetable propagator we describe in @proc:timetable. This is a more detailed description of @ex:infmethod:cum. We assume in this section that the terminology of @sec:prelim:cumulative is known. However, we do not yet detail the pseudocode or proofs; these are given in @sec:check:cumul:algodesc and @sec:check:cumul:proofs, respectively. We conclude this section with a discussion of some implementation considerations in @check:cumul:impl.

== Applying @proc:methodinf

=== Step 1: Identify propagator conflict checks

*Time conflict.* We begin by examining the main conflict check of the timetable algorithm. This checks whether the resource profile exceeds the capacity. If it is exceeded, the resulting conflict is associated with only a single time $t$: Suppose we have a cumulative constraint $c$ with capacity $capacity(c)$ and activities $x, y, z$ in that constraint that are mandatory at some time $t$. Then, if the usages $usage(x) + usage(y) + usage(z) > capacity(c)$, there is a conflict. Since this conflict is associated with a single time point, we call this a _time conflict_.

=== Step 2: Propagation conflict types

*Activity conflict.* If we study the propagation performed by timetable propagators (which we described in @proc:timetable), we find another conflict type. Consider the same constraint $c$, with the same condition on the usages. Then the three activities cannot be active at the same time. Consider now that $y$ and $z$ are mandatory at all times $lower(x) <= t <= upper(x)$. That means that, no matter where $x$ is scheduled to start between its upper and lower bounds, the capacity would be exceeded. In other words, if we try to place $x$ "on top" of the resource profile with the starting time between its bounds, this will always overflow the capacity somewhere. This implies a conflict. In a more general case with more activities, there could be different activities mandatory at different times. Activity conflicts can also be seen as follows: there is an activity conflict if scheduling $x$ at any time within its bounds would cause a time conflict. 

*Relation between time and activity conflicts.* We note that a time conflict implies an activity conflict for all involved activities at that time. To see why, note that an activity being mandatory at a time $t$ means that no matter at what time it is scheduled exactly, it will be active at $t$. But we know that the other activities are mandatory at $t$ (since we had a time conflict), so no matter where we schedule the activity, there would be a time conflict at $t.$ However, in the case of an activity conflict, it is not necessary for the capacity to be exceeded at any specific time $t$. This can be seen in @ex:cum:conflicts.

*Hints.* A reason for differentiating between activity and time conflicts, despite the fact that a time conflict implies an activity conflict, is that each requires a different type of certificate to check. A time conflict only requires a time $t$, after which it can check which activities are mandatory at that time and determine if the capacity is exceeded. However, an activity conflict, given an activity $x$, must check for all possible starting times of $x$ that it cannot be started there. These certificates, which could be used to serve as hints to the checker, are not used by the checker (except when there is an activity conflict for the variable in the consequent). This is discussed further in @sec:discuss:hints.

*Propagation example.* We have now discussed the two types of conflict. In practice, the type of reasoning done to determine the existence of an activity conflict is actually the reasoning done for propagation. Such propagations, when their right-hand side is negated and added to the left-hand side of the inference, take the form of an activity conflict. //#todosm[Interesting to prove this?] 
The following example highlights this fact.

#example(title: "No time conflict")[Consider a constraint $C$ with variables $x$ and $y$, $capacity(C) = 1$ and all usages equal to 1. Let $start(y) in [1, 10]$ and $duration(y) = 2$. Next, let $start(x) in [0, 2]$ and $duration(x) = 4$. Then, $x$ is mandatory at $t = 2$ and $t = 3$. $y$ is nowhere mandatory. $y$ cannot start at $t = 1$, since then it would also be active at $t = 2$, which would conflict with $x$. Similarly, it cannot be active at $t = 2$ or $t = 3$. Therefore, $y >= 4$ would be a valid propagation. If we represent this as a fact, this would be $[x >= 0] and [x <= 2] and [y >= 1] and [y <= 10] -> [y >= 4]$. Then, the logically equivalent conflict form would be: $[x >= 0] and [x <= 2] and [y >= 1] and [y <= 3] -> bot$ (after removing the redundant upper bound for $y$). There is no time conflict, because $y$ is still nowhere mandatory. However, this _is_ an activity conflict, since for all $1 <= t <= 3$, scheduling $y$ at those times would cause a conflict.] <ex:cum:conflicts>

However, there exist (many) propagations that _can_ be verified by finding a time conflict.

#example(title: "Time conflict")[Consider a constraint $c$ with variables $x$ and $y$, $capacity(c) = 1$ and all usages equal to 1. Let $start(y) = 0$ and $duration(y) = 2$. Next, let $start(x) in [0, 10]$ and $duration(x) = 2$. Then, $x$ is nowhere mandatory, while $y$ is clearly mandatory at both $t = 0$ and $t = 1$. The resulting fact is then $[x >= 0] and [y = 0] -> [x >= 2]$. To verify this fact, we check whether the domains $x in [0, 1]$ and $y = 0$ lead to a conflict. We see that $x$ is now mandatory at $t = 1$ since $upper(x) <= 1 < lower(x) + duration(x)$ ($2 <= 1 < 2$). Consequently, there is a time conflict at $t = 1$.]

=== Step 3: Conflict checkers

Now that we know the types of conflicts our checker should find, we design two checkers, one for each conflict. We first present a high-level overview of the two fundamental function definitions. The detailed algorithm (including pseudocode) is then presented in @sec:check:cumul:algodesc. 
// The correctness specification and proofs are then given in @sec:check:cumul:proofs.

// In this subsection, we assume that a fact has already been converted from a list of atomic constraints to a list of lower and upper bound pairs, annotated also with the corresponding activity's duration and resource usage. This is discussed in more detail in the next subsection.

*Time conflict checker.* #jmono[resource_profile(capacity, times, bounded_activities)], computes a resource profile over a given set of times, reporting whether it finds a time conflict at any of the times. For each $t$, the value it reports is the capacity minus the sum of the usages of all activities mandatory at that $t$. This is the difference between the constraint capacity and the standard resource profile as defined in @sec:timetable ($P(t)$ in @proc:timetable, step 2). It works by traversing the given `times` and then computing for each activity in `bounds` whether it is mandatory based on its bounds. The computation exactly follows the definition given in @sec:timetable.

*Activity conflict checker.* #jmono[can_schedule_activity_with_profile(activity, profile)], takes as input a resource profile (as computed by #jmono[resource_profile], so with the remaining capacity instead of the used capacity) on all times from (for an activity $x$) from $lower(x)$ (inclusive) to $upper(x) + duration(x)$ (exclusive) and reports whether it is possible to schedule it at any of those time. Here, it assumes that the particular activity can be scheduled at times when it is mandatory. If it cannot find any such time, it reports an activity conflict. It works by mapping the given profile to a list of booleans, where the boolean represents whether the activity can be active at that time. This is computed (for an activity $x$) by checking as the result of $P(t) >= usage(x)$ (as in @proc:timetable, propagation) for each time, with the value always being #ttrue if $x$ is mandatory (since we assume the case where it cannot be active in that case to be caught by the time conflict checker). This list of booleans is then traversed to find $duration(x)$ number of #ttrue values in a row (so if the duration is 3, the resulting list must be a run of 3 #ttrue\s). If it can find such a run, we know we can at least schedule the activity there, and hence there is no conflict.

=== Step 4: consequent hint

Since we base the activity conflict check on the propagation performed in the timetable algorithm, we can use the variable present in the consequent to optimize our checker and run #jmono[can_schedule_activity_with_profile] for the variable in the consequent first. In fact, if the consequent contains the variable $x$, we can also perform the time conflict check (and build a resource profile) only for times $t$ s.t. $lower(x) <= t < upper(x) + duration(x)$, falling back to the entire constraint horizon in case we cannot find a conflict.

=== Step 5: infer domain and combine

Based on the two functions of step 3 and our use of the consequent as a hint, we now have all the ingredients to summarize the main steps of the checker.
+ Given a fact, checker uses `infer_domains` from @sec:res:infcheck to get the domains of the activity's starting times as perforated intervals. From these intervals, the checker extracts the lower and upper bounds and adds their capacity and usage information. See @check:cumul:impl for additional details.
+ From `infer_domains`, the checker also gets whether the fact has a consequent and the variable of that consequent. If it does, we will first seek to determine a conflict for the activity present in the consequent. It does this using the #jmono[resource_profile] function applied to the time range $[lower, upper]$. If there is a time conflict in that range, the inference is also valid. Otherwise, the profile is given to #jmono[can_schedule_activity_with_profile], which returns false in case there is a conflict. If there is no conflict, proceed to the next step.
+ If no conflict could be determined on the consequent's bounds or if there was no consequent, a resource profile will be constructed that ranges from the minimum start time among all variables to the maximum start time among all variables. If no conflict can be determined, it proceeds to the next step.
+ If the previous cases failed, the checker will seek to determine a conflict by checking all activities in the same way as it checked the one associated with the consequent. Once it finds one, it will report it. Otherwise, the checker fails to verify the inference.

In the next section, we give a more complete description of the above algorithm and also include pseudocode.

== Algorithm description <sec:check:cumul:algodesc>

In step 1 we extract the lower and upper bounds of each activity and collect them together with their other parameters (resource usage, activity duration). We call this specific type `BoundedActivity`. The procedures in this section all work on this type.

#pseudocode[Type that is used to represent an activity during checking][```tiplang
Record BoundedActivity:
  lower: int
  upper: Z
  duration: N
  usage: N
```]



#funlink(<desc:infer_cumulative_ounds>, "infer_cumulative_bounds")
#fundesc(title: [
    This function uses 
  ])[
  ```tiplang2
  Definition infer_cumulative_bounds(constraint: i32, fact: str) -> InferResult:
  ```
] <desc:infer_cumulative_bounds>


The function that performs step 1 is @fun:infer_cumulative_bounds. The result can either be that the fact is inconsistent (i.e., the atomic constraints imply an empty domain) or a `(list BoundedActivity, option BoundedActivity)` pair, where the optional activity refers to the activity associated with the variable in the consequent of the fact. The function makes use of the #jmono[infer_domains] of @sec:perfint and the parameters in the constraint.

Now, let us define the two functions from the previous section in detail.

The #jmono[resource_profile] is defined in a natural way. For each element of the range of times it receives, it simply computes what activities are mandatory and adds up their usages, subtracting them from the constraint capacity. In case this would result in something less than zero, it reports an error instead. We describe this in pseudocode, noting that some optimizations have been removed for the sake of exposition (see also @check:cumul:impl). The function #jmono[is_mandatory] computes whether an activity is mandatory at time $t$ (by checking whether, for an activity $x$, $upper(x)$ <= t < $lower(x) + duration(x)$ holds). #jmono[xn_sum(l: list (Id \* N)) -> N] takes as input a list of variable-usage pairs and adds up all the usages. It is useful to include the variable for the proof. Finally, #jmono[map_valid(f: A -> B | error, l: list A) -> list B | error] is like a standard `map`, but will report a conflict if any of the individual operations report a conflict.

```py
def abc():
  a = 3
```

```tiplang
Definition abc -> string:
  a := 3
```

#pseudocode[][```tiplang2
Definition resource_profile_t(capacity: N, bounds: list[ActivityBound], t: Z) -> N|time_conflict:
  mandatory_at_t := filter(is_mandatory(t), bounds)
  mandatory_at_t_xn_list := map(b -> (var(b), usage(b)), mandatory_at_t)
  sum := xn_sum(mandatory_at_t_xn_list)
  if capacity < sum:
    return time_conflict
  else:
    return sum

Definition resource_profile(capacity: N, times: list Z, bounds: list[ActivityBound]) -> list[N]|time_conflict:
  return map_valid(resource_profile_t(capacity, bounds), times)
```]

Given an activity $x$ and its bounds, the #jmono[cannot_schedule_activity_with_profile] works by first converting the profile given to a list of bools that correspond to whether the activity can be active at the associated time. For each profile entry (it assumes the elements correspond exactly to the times $[lower(x), lower(x) + 1, ..., upper(x)]$), it first determines whether it is mandatory at that time. If it is, the value is `true`, since it is assumed the profile was already checked and did not exceed the capacity. Otherwise, it sees if the profile value (which is the remaining amount of resources after subtracting the usage of all mandatory activities) is greater than or equal to the resource usage of the activity. If it is, then the activity can be active and the value is `true`; otherwise, it is set to `false`. The list of bools is then traversed. If it can find a set of consecutive `true` entries of length equal to the activity's processing time, the activity can be scheduled, and the function will return false. 

The pseudocode can be found below. We again use the #jmono[is_mandatory] function, but also introduce the #jmono[has_n_true(n: N, l: list bool) -> bool] function, which traverses the list and returns `true` once it finds $n$ consecutive `true` values. Again, the code is somewhat simplified.

#figure(
    image("placeholder.png", width: 40%),
    caption: [#todo[show example of the 'active list' for a particular example]],
  ) <img:cum:activelist>

#pseudocode[][```tiplang2
Definition can_be_active(bound: ActivityBound, usage_left: N, t: Z) -> bool:
  return is_mandatory(t, bound) or (usage(bound) <= usage_left)

Definition profile_to_active_list(bound: ActivityBound, profile: list[N]) -> list[bool]:
  profile_range := range_inclusive(lower(bound), lower(bound) + length(profile) - 1)
  profile_with_times := combine(profile, profile_range)
  return map(can_be_active(bound), profile_with_times)
  
Definition cannot_schedule_activity_with_profile(bound: ActivityBound, profile: list[N]) -> bool:
  active_list := profile_to_active_list(bound, profile)
  return has_n_true(duration(bound), active_list)
```]

Before we give the pseudocode of the main checker definition, we mention two additional functions. #jmono[cannot_schedule_activity(capacity: N, bounds: list ActivityBound, bound: ActivityBound) -> bool] composes the previously discussed #jmono[resource_profile] and #jmono[cannot_schedule_activity_with_profile] functions. It returns `true` if either the resource profile had a conflict or if it found an activity conflict. It builds the resource profile only on the timepoints within the activity's bounds. Finally, #jmono[resource_profile_full(capacity: N, bounds: list ActivityBound) -> bool] determines the earliest and latest possible starting times of all activities and then builds a resource profile on that interval, returning `true` if it can find a time conflict.

Written in pseudocode, the checker then looks like the following. As the name suggests, #jmono[any_true] runs a partially applied function on all elements of a list, returning `true` if any of them return `true`.

#pseudocode[```tiplang2
Definition cumulative_checker(fact: Fact, constraint: CumulativeConstraint) -> bool:
  match inferred_cumulative_bounds(constraint, fact):
    case inconsistent_fact:
      return false
    case activity_bounds, maybe_rhs_bound:
      match maybe_rhs_bound:
        case Some(rhs_bound):
          if cannot_schedule_activity(capacity(constraint), activity_bounds, 
                                      rhs_bound):
            return true
    
      if resource_profile_full(capacity(constraint), activity_bounds):
        return true
      if any_true(cannot_schedule_activity(capacity, activity_bounds), activity_bounds):
        return true
```
]

== Proofs <sec:check:cumul:proofs>

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


Furthermore, we call an optional ActivityBound $maybebound$ valid if, in the case of it not being empty, it is an element of a list of bounds that is also valid. The lemma shows, in essence, that #inferbounds negates the right-hand side of the fact and that the bounds are derived from the atomic constraints in the left-hand side of the fact.


#lemma[
  Let $bounds$, $maybebound = inferbounds$ $(C, omega)$ and let $bounds$, $maybebound$ being _valid_ for for $C$ and $A$ imply a contradiction. Then $omega$ is valid for $A$.
] <lem:inferred_cumulative_bounds_spec>

#proof[
  We omit the proof, as it relies heavily on the exact implementation (see @check:cumul:impl), but mention that it relies on the correctness proof of #inferdoms, which is discussed in @sec:perfint.
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

  We can show this by proving that #l_mandatory_t is a sublist of #l_active_t (a sublist means every element in the left list occurs less often than in the right list). For this, it is enough that #l_mandatory_t has no duplicates and that every element is in #l_active_t. The fact it has no duplicates comes from the fact it is the result of a filter (which only removes values) and a map (which preserves the variable) of #bounds, which we know is unique (every variable occurs only once). Next, since #bounds are valid, we know every bound is associated with in activity in $C$, and when an activity is mandatory, it is certainly active (if the bounds are correct, which we know they are since #bounds is valid). Therefore, every element in #l_mandatory_t is also in #l_active_t.
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
  The checker returns `true`, therefore, #inferbounds cannot have reported that $omega$ is inconsistent. This means we have #bounds, #maybebound, and we can apply @lem:inferred_cumulative_bounds_spec. Our goal is then, with #bounds, #maybebound being valid for $A$ and $C$ as assumptions, to derive a contradiction.
  
  We claim we are either in one of two cases:
  - `resource_profile_full` reported a time conflict, in which case we apply @lem:resource_profile_contradiction to derive a contradiction since no conflict should have been reported.
  - There is some $b in bounds$ s.t. #cannotsched = `true`, in which case we apply @lem:cannot_schedule_activity_valid to derive a contradiction since it should have returned `false` based on our assumptions.

  To finish the proof, observe that if #maybebound is non-empty, the fact that it is valid means it is in #bounds. If applying #cannotsched to it then returns `true`, we are in the second case.

  If either it is empty or did not return true, we could have that `resource_profile_full` reported a conflict, in which case we are in the first case. If it did not, we must have that the `any_true` found a $b in bounds$ s.t. there is an activity conflict, since otherwise the checker could not have returned `true`. So we are in the second case.
]


== Implementation considerations <check:cumul:impl>

=== Control flow and errors

The pseudocode in the previous sections is written in a style that assumes the existence of more explicit control flow than exists in the language that the checker is implemented in (Rocq). This is done to aid readability. In truth, Rocq is a purely functional language and does not have the concept of an early return or the concept of an error. Instead, the fact that a function returned an error is inferred through different means. We highlight two examples.

1. The type signature of #resprofile in reality is simply `list N`. Instead, an error case is distinguished from a non-error case by setting the list to `nil`. This is primarily to allow the use of `map_valid`. 
2. #jmono[resource_profile_t] actual return type is `option N`, where the `None` case is the error. 

=== Reversed range input

We explicitly did not write an actual invocation of #resprofile in the pseudocode, as the actual implementation expects a range of times that is in _decreasing_ order, as opposed to the final profile, which is in increasing order. This is because `map_valid` reverses its input for performance reasons (as this allows writing it as a tail-recursive function).

=== Combined steps

A number of values are computed in a single iteration, as opposed to multiple ones, again for performance reasons. An example that actually has implications for the proof is the computation of the active list in #jmono[profile_to_active_list]. Instead of building another range, then combining, and then mapping, a function called `z_map` is used that computes the time inputs as it recurses. 

#pagebreak(weak: true)

= Rocq findings <sec:rocq>


During the implementation and formal verification of a constraint programming unsatisfiability proof checker in Rocq, we noticed a number of things that we believe are useful to discuss and that we have not seen discussed elsewhere. While our discussion is specific to Rocq, we believe these findings also apply to formal verification in general, although some proof assistants/interactive theorem provers handle some things better than others (although we have not investigated this in detail). First of all, we found that there are two main categories of proof segment (where a proof segment is defined as some operation consisting of one or more proof lines): data structure manipulation and conceptual. Full proofs often interleave these two categories. The next section goes into detail on this. Closely related is the fact that developing the right specification, so the right definitions of the intended behavior of implementations, is much harder than actually proving them. We also discuss this in a separate section below. We also discuss some more details related to Rocq and proof assistants in @sec:discuss:itp as part of the Discussion.

Note: We use snippets of Rocq code more liberally in this section than in others and therefore assume some familiarity with Rocq.

== Two categories of proof <sec:rocq:twocat>

The first type of segment is what we describe as a _data structure manipulation_ segment, or _implementation-coupled manipulation_ segment. Proof segments of this type are very tightly coupled to the implementation and less so to the underlying concepts. The work is often tedious, but at the same time mechanical. Furthermore, it is very hard to read proof segments of this category. In fact, we found it nearly always takes _less_ time to simply redo the proof than to adapt it to a small change in the implementation. This category also makes up the vast majority of most proofs, when looking at the number of lines. 

#todo[Is 'conceptual' the right word?]

The second type of segment is what we describe as a _conceptual_ segment. These proofs are often shorter, but (usually) much less obvious. They take more time to develop, but are less sensitive to changing small details. Therefore, these proofs are more valuable to preserve when refactoring. Often, they are also more readable than the other type of segment.

=== Example: alldifferent checker

To test this hypothesis, we developed our alldifferent checker in such a way that each individual lemma consists mostly of one type of proof segment. This makes the core, conceptual proofs more implementation-agnostic, as was briefly mentioned in @check:alldiff:impl. 

The main conceptual proof, which is @lem:alldiff_suff, makes no mention of our implementation. First, we state the important definitions in Rocq. First, some shorthand definitions, where `sint.t` is an `MSet` with elements of type `Z`, using the `MSetRBT` set implementation (both from the standard library).

#snippet[Shorthand definitions of general concepts][
  ```
  Definition domains := string -> sint.t.
  
  Definition assignment_consistent_with_domains (doms : domains) (variables : list string) (assignment : string -> Z) : Prop :=
    forall x, In x variables -> sint.In (assignment x) (doms x).
  ```
] <snip:alldiffshorthands>

Then, the formal statements of an alldifferent constraint and when we consider an alldifferent constraint to be satisfiable given some variable domains.

#snippet[Alldifferent formal definition][
  ```
  Definition Alldifferent_l (variables : list string) (assignment : string -> Z) : Prop :=
    forall x y, 
      In x variables -> 
      In y variables -> 
        assignment x <> assignment y.
  ```
] <snip:alldiffformal>

#snippet[Formal definition of an alldifferent constraint being satisfiable][
  ```
  Definition AllDifferent_satisfiable (doms : domains) (variables : list string) :=
    exists assignment, assignment_consistent_with_domains doms variables assignment 
      /\ 
    Alldifferent_l variables assignment.
  ```
] <snip:alldiffformalsat>

Finally, the statement of @lem:alldiff_suff  in Rocq.

#snippet[Formalized statement of @lem:alldiff_suff][
  ```
  Lemma alldiff_unsatisfiable_condition (doms : domains) (variables : list string) (domain_union : list Z) :
    NoDup domain_union
      ->
    NoDup variables
      ->
    (forall n, In n domain_union <-> (exists x, In x variables /\ sint.In n (doms x)))
      ->
    List.length domain_union < List.length variables
      -> 
    ~ AllDifferent_satisfiable doms variables.
  ``` 
] <snip:alldiff_suff>

The proof of @snip:alldiff_suff is 21 lines and follows the proof as we described it in @lem:alldiff_suff almost exactly. We use only a few lemmas, all from the Rocq standard library. Although some details are specific to the fact we use lists without duplicates to model sets, we do not need to actually use the definition of a list, only some high-level facts. We claim that the proof therefore consists mostly of conceptual segments.

Then, the implementation of our checker then takes 35 lines (7 lines if we exclude the implementation of materializing perforated intervals as lists of elements). The soundness proof is then a staggering 104 lines (including 7 lines of comments), even though it mentions nothing new conceptually. This is nearly 5 times the number of lines in the conceptual proof. We will not repeat the proof here, but detail the different segments. For more information on how we actually instantiated @lem:alldiff_suff, see @check:alldiff:impl.

#todosm[Update the line numbers and proof lines for the final version]

1. We introduce variables and rewrite the proof so we have the validity of the domain map in our hypothesis (using the correctness lemma of `infer_domains`, see @sec:res:infcheck). (304-310; 6 lines)
2. We define our choices of `doms` and `variables` so that we can later apply the lemma in @snip:alldiff_suff. (311-315)
3. We show that our choice of `doms` and `variables` satisfies `assignment_consistent_with_domains` (@snip:alldiffshorthands) (316-327)
4. The definition of alldifferent from @snip:alldiffformal does not match the specification of alldifferent in our checker, because for performance reasons we do not store variables in a list, and another implementation detail we do not mention here. Therefore, we must show that it is enough to show that the definition of not being satisfied (`~ AllDifferent_satisfiable`, @snip:alldiffformalsat) by our chosen variables is enough to show that the checker's conception of alldifferent is not satisfied. This also does the job of relating it to our hypothesis, stating the validity of our domain map from the first step in the proof. (328-357)
5.  We then introduce our instantation of `domain_union`, finally allowing us to apply `alldiff_unsatisfiable_condition` (@snip:alldiff_suff) (358-360). 
6. We dispatch the conditions that our instantiations of `domain_union` and `variables` contain no duplicates. This is easy as they are either the elements of an `MSet` or the filtered keys of an `MMap` (see @sec:domainmap:impl for what `MMap` is and how we use it). (361-362)
7. The most tedious part now follows: showing that the condition `forall n, In n domain_union <-> (exists x, In x variables /\ sint.In n (doms x))` from @snip:alldiff_suff holds for our instantiations of `variables`, `doms`, and `domain_union`. This relies heavily on a few other facts (also consisting of dozens of lines of proof) of how we materialized perforated intervals in a (relatively) efficient way as lists of elements, while remembering that we only materialized them for the variables we chose. (363-396)
8. Finally, we reason over the fact that our checker returning #ttrue indicates that indeed the length of our chosen `domain_union` is strictly less than the length of our chosen `variables`. This requires yet again going into the implementation of how we materialized domains. (397-417)

We claim that all the listed proof segments save the actual application of `alldiff_`#sym.zws`unsatisfiable_`#sym.zws`condition` in step 5 are data structure manipulation segments.

We do not have a solution for this situation (we are unsure if we can even justify calling it a "problem") as we are not experts in Rocq. See @sec:discuss:automation for a discussion of proof automation, which we had initially hoped would be able to prevent the dominance of implementation-specific lines vs conceptual lines. Also see the next section.

== Choosing the right specification

We find that choosing how to describe the behavior of a particular function, or what parts to describe and which parts to ignore, is very important to achieving productivity in a proof assistant such as Rocq. Sometimes, the right choice is to actually not write a specification at all, but to simply take the actual function definition as the canonical specification and prove that other functions are equivalent to it.

#todo[Example of evolution of cumulative implementation towards using zmap and similar]

// == Building blocks

// // === Bounds <sec:bounds>

// === `sublist` <sec:sublist>

// Given two lists $l_1, l_2$ of type `(String * Nat)`, a sufficient condition for the sum of the `Nat`s in the lists (which we call `xn_sum`) would be for $l_1$ to not have duplicates and for every element of $l_1$ to also be an element of $l_2$.

// However, this is a stricter condition than necessary. We can imagine a situation where certain variables actually do occur multiple times, because they are somehow weighted. A weaker condition is to ask that $l_1$ is a `sub_list` of $l_2$, which we define as follows:

// #definition[
//   Given two lists $l_1, l_2$ of type `list A`, we say that `sub_list`($l_1$, $l_2$) iff $forall a, a in l_1, #raw("count_occ")\(a, l_1) <= #raw("count_occ")\(a, l_2)$.
// ]

// Here, `count_occ` counts the number of occurrences of an element in a particular list. This does require there to exist some way to compare the equality of items in a list, but this is always the case for our purposes. 

// We prove a number of results for this notion of `sub_list` related to using `count_occ` in inductive proofs. For this, we introduce the function `remove_once` which removes an element exactly once. We also prove that the earlier condition of $l_1$ not containing duplicates and every element in $l_1$ also existing in $l_2$ implies `sub_list`. This follows immediately when you realize that an element existing means the count is at least one and when a list has no duplicates all counts are one.

// Finally, we prove that `sub_list`($l_1$, $l_2$) indeed implies that `xn_sum`\($l_1$) $<=$ `xn_sum`\($l_2$). 

// #proof[
//   Given an arbitrary $l_1$, we aim to prove that for all $l_2$ s.t. `sub_list`($l_1$, $l_2$), we have `xn_sum`\($l_1$) $<=$ `xn_sum`\($l_2$). We prove this using induction on $l_1$.

//   Base case: Given $l_1 = "nil"$, we see that the sum is equal to zero. Since we are working only with `Nat`s, and given that `xn_sum`\($l_2$) is an arbitrary `Nat`, we have proven the base case.

//   Induction step: Given an element $a$ and arbitrary $l_1$, we must prove that `sub_list`($a :: l_1$, $l_2$) implies the sum of $a :: l_1$ is less than the sum for $l_2$ for all $l_2$. Our induction hypothesis is for our specific $l_1$ and for arbitrary $l_2$.

//   We first let $l_2$ be arbitrary. We first notice that $a$ must occur at least once in $l_2$ because fo the `sub_list` relationship. Next, notice that `sub_list`($a :: l_1$, $#raw("remove_once")\(a, l_2$)) holds. By using the induction hypothesis on this, we have that `xn_sum`\($l_1$) $<=$ `xn_sum`$\(#raw("remove_once")\(a, l_2))$ holds. But adding $a$ to both lists increases the value on both sides exactly by the number value of $a$. This proves the induction step. Therefore, we are done.
// ]

// === `build_range`, `is_range` and `is_as_range` 

#pagebreak(weak: true)

= Discussion <sec:discussion>

In the previous sections, we presented our contributions. Our goal is to determine how to develop checkers for individual proof steps in a formally verified CP unsatisfiability proof checker. Our results can be summarized as follows:
+ *(Propagator inference checker methodology)* We developed a general methodology for developing propagator inference checkers, which can be used both within the collaborative effort and by external contributors to extend the checker with support for additional constraints. The methodology's main contribution is highlighting the importance of identifying the conflict types of a particular propagator.
+ *(Perforated intervals: formalized theory and implementation)* We developed and formalized the theory of the holes+bounds-based _perforated intervals_. Perforated intervals can be used as a domain representation. It supports operations that allow updating the domain with an atomic constraint, checking whether an atomic constraint holds for the domain, and checking whether the domain is empty. Furthermore, it allows the efficient construction of a domain based on a list of atomic constraints, which is also important for inference checkers. We also define conditions under which efficient implementations of these checks actually decide the properties we are interested in (domain _tightness_). All of the theory and implementations are constructed and formalized in Rocq. We present lemmas and (partial) proofs that can be read by non-experts in Rocq.
+ *(Formally verified implementation of deduction checker)* We implemented and formalized the checker for the deduction step, which plays a critical role in the proof system. For this implementation/formalization, we also developed machinery for working with the domains of multiple variables at once. This machinery could also be reused for inference checkers.
+ *(Formally verified alldifferent checker)* We developed a formally verified checker for alldifferent reasoning. Any valid alldifferent inference without any redundant constraints can be verified by our checker. This means any propagation by a domain consistent propagator (the strongest possible propagator) can be verified.
+ *(Formally verified cumulative checker)* We developed a formally verified checker for cumulative timetable reasoning that verifies any valid inference made using a timetable propagator.
+ *(Rocq findings)* We presented findings about working with Rocq, which is the language/tool used to implement and formally verify the checker.

To prevent this section from becoming too nested, we present the discussion in a series of mostly self-contained subsections, each a full discussion of one or more of our 6 main contributions. However, we do provide a separate future work section and discuss some limitations of this work as a whole. 

// #todo[interpretations: met expectations, what was unexpected? compare with related work.]

// #todo[implications: new insights, compare to previously disscussed]

// #todo[limitations]

// #todo[recommendations]

== Propagator inference methodology and propagator inference checkers

Our primary goal is to determine how to develop formally verified checkers for checking individual proof steps in a CP unsatisfiability proof checker. We specifically do this for two types of steps: propagator inference steps and deduction steps. There is only one type of deduction step that will not require any further expansion. However, there are a practically unbounded number of different propagators and nearly as many constraints. Hence, a very important goal was making it possible for future work to develop new checkers in a mostly mechanical way based on the propagation algorithm with proofs no more difficult than pen-and-paper proofs of the propagation algorithm's correctness. In this section, we interpret our proposed methodology for developing propagator inference checkers and the construction of an alldifferent and cumulative checker, discuss the implications, compare it with related work, and discuss some limitations. 

We believe our propagator inference methodology does not fully achieve this goal, but does provide an important step that increases understanding. Furthermore, we believe our cumulative checker is one of the first instances of a truly non-trivial, formally verified checker for a very CP-specific propagation algorithm. In particular, both the alldifferent checker and the linear checker (the latter is not our contribution, but part of the collaborative effort and described by Sidorov et al. @sidorov2025checker) handle only a single conflict type and check only a single condition: Is the union of domains smaller than the number of variables (alldifferent)? Is the minimum value of the left-hand side greater than the right-hand side (linear)? Furthermore, other approaches for formally verified CP either use a generic algorithm that is not constraint specific @carlier2012certified, or encode models and reasoning in another, simpler language @gocht2022auditable. However, we cannot call our cumulative checker truly the first of its kind, as cumulative was also considered in the unpublished work of Gange et al. @gange1certifying. We do believe it is the first of its kind that is part of a checker with a fully formalized and developed proof system @sidorov2025checker. The work of Gange et al. also did not propose any general methodology for inference checkers, which we believe has been applied successfully to cumulative. 

Our methodology can bring clarity to the important elements of checking propagations through its introduction of the concept of _conflict types_ (@sec:infmethod:conflicttypes), with two clear examples in the cumulative checker: time conflicts and activity conflicts (@check:cumul).

Our alldifferent checker is, implementation-wise, a more modest result. However, we believe that it is a clear example of constraints, of which we have a very deep theoretical understanding. It implies that developing checkers for other constraints that are similarly deeply understood should be straightforward. It also provides a clear motivation to study the literature and find analogs of Hall's theorem (@thm:hall). Furthermore, with the implementation of our alldifferent checker, we tested another hypothesis related to formal verification (@sec:rocq:twocat).

We now discuss some limitations. First of all, we have only tested the methodology fully on a single constraint (cumulative) and propagator (timetable). The linear inequality checker and alldifferent checker are too simple for the methodology to fully apply. However, this can also be seen as a positive fact: we have not found a constraint to be too difficult to verify with our methodology.

A major limitation of our methodology is that it provides no guidance on the _formal verification_ part of implementing a propagator inference checker. While this was an explicit goal, we have not found any generally applicable concepts that can make formally verifying the conflict checkers any easier. Of course, our work does contribute to this (through perforated intervals and potentially re-using code from the cumulative checker for other constraints related to activities). One thing we observe is that the major difficulty comes from implementation-coupled proof segments (see @sec:rocq:twocat), which we believe is hard to generalize (as by definition it relies heavily on the specific implementation, which will always differ between constraints). 

== Perforated intervals

One of our most important and most practical contributions is the development of perforated intervals: their (formalized) theory and their (formally verified) implementation (including check and update operations). The success and generalizability of perforated intervals were unexpected, as we had no explicit goal related to it: only an idea that we wished to develop building blocks that could be reused by multiple inference checkers. To our knowledge, a holes+interval-based domain representation has not been thoroughly studied on its own merit before, nor do we know of any study about the concept of tightness. While the theory of perforated intervals is simple, this is actually a large benefit when it comes to formal verification, as simple concepts are often more easily formally verified. All of our checkers rely on perforated intervals, and due to their use at the heart of the checker (through the deduction step), they are an integral part of the proof checker implementation. Furthermore, preliminary experimental results from Sidorov et al. @sidorov2025checker indicate they are not a huge bottleneck in practice, although this requires further study. If this is confirmed, we hypothesize this can be primarily attributed to the efficient implementation of red-black trees in Rocq for our sets and maps @appel2011rbt. 

In the next section, we highlight the usages of perforated intervals in our work and the overall checker. After that, we discuss the relevance of additional results not necessary for the checker's soundness proof, followed by a discussion of some alternatives. Finally, we discuss the deduction step, as its implementation relies primarily on perforated intervals.

=== Usages

Perforated intervals are used throughout the checker, primarily at points where integer domain reasoning, bounds reasoning, and atomic constraints intersect. We list the following:

1. In the cumulative checker, they are used to extract the lower and upper bounds for each activity from a fact.
2. (Not our contribution) In the nogood equivalency checker, the two nogoods that are to be checked are converted into domains, after which each domain is checked for equivalence (currently they are required to have exactly the same holes, but this requirement could be relaxed as holes outside the bounds do not have to be considered).
3. In the alldifferent checker, they are used to first aggregate the domains of all variables in the fact. After this, the perforated intervals that are bounded on both sides are _materialized_: they are converted into element lists. This eases the computation (and subsequent formal verification) of the union of domains. In the future, materialization could be avoided by implementing a union operation over perforated intervals.
4. Critically, in the deduction checker, they are used to track the domains of each variable as inferences are checked and applied in order. As perforated intervals support efficient check functions (@sec:perfint:checks) and update functions (@sec:perfint:updates), all operations are logarithmic. If any variable has an empty domain at the end of the deduction step, we know the deduction is valid.

We expect all future propagator inference checkers to also use perforated intervals, as they allow the inference of rich domain information from facts, which are represented as lists of atomic constraints. We spent much of our time on exactly this problem, which means that future checkers can simply reuse this infrastructure. The correctness specification (see @sec:res:infcheck) of this procedure is also phrased in such a way and comes with a number of additional lemmas that simplify the proof of inference checkers by transforming it from a proof about fact validity into a proof about unsatisfiability under a domain (it thereby also performs the right-hand side negation we saw was useful already in @proc:verifystrat, propagator verification strategy).

=== Completeness

We provide additional proofs that are not necessary for proving the soundness of the proof checker: namely, the fact that the checker functions (@sec:perfint:checks) _decide_ their respective properties when the domain is tight is not necessary for this. We only need the backwards direction of @lem:check_holds_decides (check decides atomic holds) and @lem:check_consistenty_decides (check decides consistency). However, the forward direction provides strong guarantees that our implementation will not mistakenly reject valid deductions or fail to notice that the premises of an inference are already contradictory. We fully prove the second lemma, but we have two unresolved cases for @lem:check_holds_decides. The difficult case has been proven, and the other case is symmetric, but was not proven due to time constraints. 

Furthermore, while we do use the tighten function to ensure we do not reject valid deductions, for soundness, we only need that tightening does not change the logical domain (@lem:tighten_with_holes_sound). However, we actually prove that the tightening procedure causes the domain to become tight. This is actually rather involved, but critical if we want to indeed ensure we do not unnecessarily reject deductions or inferences.

Other than mistaken rejections, these proofs are also important theoretical contributions, as they are they show the power of perforated intervals by proving that the simple check functions really are enough to determine the properties we care about.

=== Alternatives <sec:discuss:perfint:alts>

Our domain representation based on perforated intervals is rather non-standard. Indeed, we know of no special term to refer to this representation (perhaps due to its simplicity) and have used the term perforated interval in this work. Instead, in CP applications, common domain representations include range sequences, just an interval, or fully enumerated domains (the latter can be implemented in numerous ways, such as with a bitvector). For example, in the Chuffed @chuffed2025 constraint solver, integers are either fully enumerated or represented as a single interval. The Gecode @gecode2025 constraint solver uses range sequences. A newer representation is that of sparse sets @leclement2013sparseset, used e.g. in MiniCP @michel2021minicp. There also exists gap interval trees @pohitos2010gaptrees. There has also been formalization work of other representations, see @ledein2020intervallist for lists of intervals and @dubois2025sparsesetverif for sparse sets. 

Some of these are clearly not feasible to fully replace the perforated interval, because they do not support infinite domains (e.g., enumerated domains). However, they _could_ be used without issue to replace the way we implement the set of holes, which relies only on the features of the `MSet`-interface in Rocq. Therefore, any implementation that satisfies this interface could serve as a drop-in replacement for our choice of an implementation based on red-black trees in the standard library.

Furthermore, we would not need perforated intervals (or at least we would not need the majority of the theory, check, and update operations) if the proof system had a richer view of domains embedded in the format instead of a list of atomic constraints. Furthermore, additional requirements such as sorting the facts by variable or in other ways could also allow replacing (at least part of) the perforated interval implementation. However, this has other drawbacks as it increases the complexity for solvers. This could be solved by moving much of the work being done by perforated intervals into the parsing stage. 

=== Deduction step

We believe the novelty of our contribution to developing a formally verified implementation of the deduction step is primarily contained in the contribution of perforated intervals and the (more straightforward) development of domain maps on top of them. If we exclude those two contributions, the soundness proof of the deduction step follows mostly from the design of the proof system. We think this is a testament to the proof system. One fact we wish to highlight is the fact that the use of domain maps in the implementation can be fully factored out from the soundness proof, compare @lem:deduct_check_inferences to @lem:deduct_check. This means that the main loop of the checker that combines all the individual proof step checkers does not need to concern itself with domain maps or perforated intervals.

When it comes to performance, the deduction step, as implemented, does not make any unnecessary traversals or make any unnecessary accesses. We expect any improvements to be found in the use of the domain map and domain implementation.

// Many propagators reason only over the bounds of variables. Therefore we can expect many facts to not contain any $!=$-constraints. 

== Building blocks and utilities

One of our supporting goals was to find building blocks and utilities that could be reused for future inference checkers. Perforated intervals are the most important ones we found and are detailed in the previous section. In this section, we quickly list a number of other useful utilities that we believe might be useful for future developments. We did not study them in detail. Hence, we only mention them briefly.

- Overall, our `Utilities.v` file consists of over 2000 lines. This is not necessarily a good thing, but it shows that a large part of our proof developments were deemed to be useful outside of the checker for which we initially needed them.
- We developed a theory of "sublists", a subset-like relationship for lists (and equivalent to it if both lists have no duplicates) that requires the existence of a list such that the permutation of this list appended to the "sublist" equals the larger list, which is equivalent to requiring that each element in the sublist occurs less than or equally as frequent in the larger list. Originally, this was a critical concept in our cumulative checker, but the role is now smaller after a refactor, so that the checker no longer relies on activity names and can have duplicates. However, it has allowed proving a number of useful facts more easily, particularly about lists having no duplicates. It is also an interesting contribution in its own right.
- We provide various "list extensions", which consist of a number of combinators and useful utilities related to lists. The most used was `flat_map_option`, which fulfills the useful function of applying a function with an optional return value to a list and only retaining elements where the function evaluates to a `Some` value. It does this in a single linear pass, but we provide an equivalence proof by first filtering all elements that will return `None` and then applying a `map` with the function. This simplifies many proofs, as we can use the extensive machinery that the Rocq standard library contains for the standard `filter` and `map` operations. It also allows defining our own lemmas in terms of `filter` in `map`, so that we do not have to create a special case for `flat_map_option` everywhere, and do not have to work from the function's definition. We also provide `map_valid`, which also works on a function with an optional return value but early returns with `None` if even a single value in the list evaluates to `None`.
- We make induction proofs using `fold_left` easier by introducing a fold induction lemma for `fold_right` that removes the need for separately defining recursive functions with a general initial value for use when we will only use one specific value. However, `fold_left` is generally more efficient as it is tail-recursive. This can often be remedied by rewriting `fold_left` in terms of `fold_right`, showing that it still holds for a reversed list and then applying our `fold_ind` lemma. We are sure there are ways to automate this, but we have not found the need or time.
- We define min and max operations over lists of integers and give formal specifications and correctness proofs.
- We provide a useful `range` function that computes the range from a starting integer to an end integer, as well as various facts about it. This function is critical for our cumulative implementation, as we rely on it to give us an ordered interval. See also @check:cumul:impl. 
- We provide `MSet` and `MMap` instantiations, as well as useful helper functions and lemmas for any type with the usual Leibniz equality (which includes the integers, strings, and many similar types), such as `build` that can construct a set given a list of elements. For `MMap` in particular, we prove many details for string maps (particularly about their keys, such as filtering the entries of a map based on keys), but these could easily be generalized.
- Our `CumulativeUtil.v` file similarly contains nearly 600 lines, which could be reused by constraints with a similar activity and usage model as cumulative. We highlight our development of `has_n_true`, used to determine if activities can be scheduled. 




== Interactive theorem proving <sec:discuss:itp>

This section discusses results related to interactive theorem provers/proof assistants such as Rocq. In particular, we discuss @sec:rocq. We believe much of what we find in that section is already known among the experts of the formal methods and programming language communities. However, as these findings were highly non-obvious to us and they are highly related to an important trade-off we discuss further in @table:veriftradeoff, we think they are important. An original goal, based on initial reading about developing large projects in Rocq (see e.g. @chlipala2013CPDT), was that automation was critical and very helpful to developing proofs. However, this is not what we experienced. We discuss this in the next subsection. 

=== Proof automation <sec:discuss:automation>

As discussed in @sec:rocq:twocat, a large part of our proofs consists of implementation-coupled proof segments. This was contrary to our (naïve) expectation that the majority of proof lines would be dedicated to conceptual proofs. This was mostly because we hoped automation could shorten the rest. However, we found that developing and understanding automation took more time than simply brute-forcing the proof by hand. Especially once one gets more experience writing the implementation-coupled proof segments, the cost of switching to automation feels higher. The author was introduced to Rocq through a course whose primary material uses the Software Foundations series by Benjamin Pierce @pierce2025lfoundations @pierce2025plfoundations. Software Foundations provides an excellent introduction to writing proofs by hand and breeds great understanding. However, while automation is extensively covered, it is mostly as an afterthought. Therefore, the author only began considering automation after he was quite familiar with Rocq. This might have shaped our difficulties with automation.

Consequently, we present no major results that make use of automation other than predefined tactics such as `lia` (which allow solving any goal involving linear arithmetic). Two small exceptions are our development of $Zext$ (although this is mostly a wrapper around `lia`) and our use of automation in proving lemmas related to tightening holes for both lower and upper bounds (again, mostly as a wrapper around `lia`). We expect Rocq experts to make better use of automation to potentially simplify many of our implementation-coupled proofs. However, we remain skeptical that this will bring huge benefits to future developments, as new checkers will use fundamentally different reasoning.

== Limitations

In addition to the limitations of each of our individual contributions, we also mention a few limitations of our work as a whole.

=== Empirical validation of practical significance <sec:discuss:empirical>

Our work contains no experimental section. Consequently, we cannot empirically validate whether our work can be used in practice. This is a significant limitation and makes it difficult to compare to approaches that are already used in practice.

The primary reason is that this thesis is part of a larger collaborative effort @sidorov2025checker, and a number of components that are necessary to run the checker on non-toy examples were missing before this work reached its final stage:

- The extraction from Rocq to OCaml has to be set up and optimized.
- A parser that can transform constraint programming models into the checker's data model. This parser will be written in OCaml.
- A parser that can parse proofs into the checker's data model (which also requires reading from a file, among other things). This parser will be written in OCaml.
- The individual proof step checkers had to be combined into a single implementation (mostly completed, but only in the late stages of this work, which also required some refactoring of our implementations).

Therefore, our results are primarily theoretical, although when the above components are completed, the results are expected to also be of practical significance, as the preliminary results are encouraging. We refer to Sidorov et al. @sidorov2025checker for the results. 

=== Formal verification trade-off

As discussed more specifically in @sec:discuss:itp, formal verification is a difficult task. Its main drawback, in our view, is the required time investment. Everything is possible, and even complex implementations and optimizations are all provable, but this often causes a nonlinear increase in proof complexity. Extending our checker with additional constraints requires implementing the entire inference checker in Rocq. We do note that richer hints, discussed in @sec:discuss:hints, might alleviate some of this. However, as an example, checking an activity conflict in a cumulative timetable propagation fundamentally requires checking a condition for many timepoints. Doing this in a reasonably efficient way requires taking into account the ordering, among other difficulties.

This compares unfavorably with an approach such as the one taken by Gocht et al. with VeriPB and CakePB @gocht2022certifying (or any approach where the verification language is more limited). In their approach, reasoning can be explained in pseudo-Boolean terms by an unverified implementation. Only the encoding must be trusted, which means that when adding an additional constraint with a similar level of trust as our checker (meaning that the checker's soundness is formally verified), only the encoding of that constraint into pseudo-Boolean constraints and variables has to be formally verified. The checker reasoning also requires implementation, but this can happen using an untrusted program and does not affect soundness.

We summarize the _formal verification trade-off_ in @table:veriftradeoff. We do not specifically list pseudo-Boolean as the approach, as it applies to any approach that encodes the proof in a language more limited than what CP is capable of. Note that in the first published version of our checker, we do not expect to formally verify the model parsing. However, since this is not an _encoding_ (it is a direct translation and we can call it parsing), it is much less complex and less prone to error. Below, we assume we would want to verify this in order to achieve the same level of trust.

#figure(
  table(
    columns: 3,
    
    // header row
    [*Criteria*], [*Limited language*], [*Sidorov et al.*],
    [Encoding verification], [Yes (+/-)], [Yes (+/-)],
    [Reasoning verification], [Only core language, not constraint-specific (+)], [Core language and for each inference rule (-)],
    [Conceptual difficulty of encoding], [Medium, must be converted into limited language (-)], [Low, can be directly modeled (+)],
    [Conceptual difficulty of reasoning], [High, must be converted into limited language reasoning ($minus minus$)], [Medium, must be translated into functional algorithm (++)],
    [Encoding performance], [Slow, verified and requires larger size due to limited language (-)], [Medium, verified but potentially same size as original model (+)],
    [Checking performance], [Medium to incomparable, reasoning must be checked by verified implementation, but can be generated by unverified implementation, which does need to do more work (+/-)], [Medium to incomparable, reasoning must be verified by verified checker, but proofs can be smaller as reasoning can be translated more directly (+/-)],
    [Formal verification complexity], [Low, only encoding and core language (++)], [High, every inference rule checker must be formally verified ($minus minus$)]
  ),
  caption: [Comparison of formal verification tradeoff between an approach that translates a CP problem into a more limited language (such as SAT or pseudo-Boolean constraints) and our approach]
) <table:veriftradeoff>

One limitation of the above table is that it is mostly a qualitative comparison. It is possible that practical concerns change the balance. We claim that our approach is lighter _conceptually_, as it can be translated more directly from pre-existing propagation algorithms, but requires more code to be formally verified (each individual inference checker). We believe this formal verification is arduous primarily due to the large amount of data structure manipulation (see @sec:rocq:twocat).

In summary, we believe the burden of formal verification to be the major limitation of this work, as it threatens the generalizability of our methods. This generalizability is simultaneously our greatest strength. Experimental results in Sidorov et al. @sidorov2025checker might reveal more practical limitations. 

== Future work

We conclude our discussion by mentioning recommendations and possible future work. We begin with more fundamental directions and finish with a number of subsections, mostly related to hypothetical performance improvements.

=== Hints <sec:discuss:hints>

In many cases, verification could be sped up or simplified significantly when provided with a hint that has richer information than just the inference rule and the constraint. Furthermore, these hints often help to characterize the conflict types we mentioned in @proc:methodinf. In the case of cumulative, if the checker knows it is supposed to look for a time conflict at a specific time, it needs to only look at which activities are mandatory at that time, which means the time complexity is suddenly only $O(n)$, where $n$ is the number of activities. In the case of an activity conflict, for cumulative, we cannot do better than just checking the activity's entire domain, and due to the fact that we have access to the right-hand side of a fact, we know which activity was propagated. However, if the consequent is empty, it is still possible for there to be an activity conflict. Currently, we must check for all activities to see if they can possibly be scheduled. Instead, if a hint containing the violating activity was provided, we could prevent this unnecessary work.

In the case of alldifferent, the set of variables that are conflicting could serve as the hint. If the solver knows this set, it should simply log a fact that includes only variables of this set, which would make this unnecessary. However, it is possible to envision a solver implementation that performs no propagation and only performs a conflict check. It could try to find a maximum matching and report a conflict if the maximum matching does not cover every variable. Only including the variables in the maximum matching would not constitute a valid fact, so the propagator could decide to simply include the domain of every variable. Since it does not do any propagation, it would not perform @proc:findhall. However, the matching is still useful information and could serve as a hint. In that case, the verification algorithm would only have to implement @proc:findhall, which is much better than also having to implement a full matching algorithm.

In the case of linear inequalities, we do not see any use for hints. This is because checking a conflict simply involves evaluating the inequality's left-hand side. This always requires knowledge of all variable bounds, which will always be carried by a valid fact.

We see that hints can provide a linear speedup in the case of particular cumulative facts (although they do not simplify the implementation); allow for a simpler checking algorithm in the case of alldifferent when we do not expect the solver to be able to provide a tight Hall set itself; and provide no benefits in the linear inequality case. More constraints would have to be evaluated to see if there is a benefit to expanding the proof system and checker.

=== New constraints and propagators

One of our core focuses was determining how to develop formally verified propagator inference checkers. For this, we introduced a general methodology (@sec:methodology). However, we were only able to fully apply it to a single constraint and propagator (cumulative, timetable). In order to fully test it, it should be applied to more constraints and propagators. The lessons from implementing support for those new constraints (and propagators) could also be used to further develop the methodology and address some of its limitations, such as the lack of guidance on how to formally verify the conflict checks.

We recommend first implementing additional propagators for cumulative, such as energetic reasoning, as these can reuse many components from cumulative while still testing the methodology. 

Furthermore, extensions of alldifferent, such as the global cardinality constraint, might be able to reuse parts of its checker. 

There are also constraints that differ significantly, which could further test the limits of our methodology. These include constraints such as element and circuit.

=== More efficient maps

Variables currently use string identifiers. If we change them to instead use the Rocq `positive` datatype (Coq's `Z` implementation is based on it), which uses a binary representation, would unlock potentially more efficient map data structures @appel2022efftrie. Furthermore, they would have the benefit of being _extensional_, meaning two maps containing the same entries equal under Coq's Leibniz equality. This can simplify proofs. However, these are currently not yet part of the `MMap` @mmaps2024 library that is used by the checker, although they have been proposed @palmskog2024mmappr10. 

=== Perforated interval unions

Currently, the alldifferent checker computes the union of domains by first materializing domains as lists of elements and then adding them all together in a new set, which is then used to determine the size of the union. However, this materialization process involves the creation of many new sets and intermediate data structures. We expect this to be the main bottleneck of the alldifferent checker.

An improved implementation would not construct any new sets, but simply update the perforated interval by computing the union in the following way:

+ Given two bounded perforated intervals $dom_1$ and $dom_2$, ensure the least upper bound and greatest upper bound between them. 
+ Then, take the perforated interval with the fewest holes. For each hole, check whether it is outside the least upper bound and greatest upper bound computed in the previous step. If it is, remove it from the domain. Then, check if the hole exists in the other domain. If it does not, remove it from the domain.  
+ Now, update the bounds of the perforated interval with the fewest holes (some of which might now have been removed) with the new least upper bound and greatest upper bound. 

Over a group of perforated intervals, the result would be equivalent to the intersection of the holes of all perforated intervals, while its lower bound would be the minimum of all lower bounds, and its upper bound the maximum of all upper bounds. While this might increase the complexity of the proofs, we believe this will improve performance by no longer requiring the construction of sets and performing fewer traversals. Furthermore, this does not require the construction of ranges, as opposed to our (naive) implementation of domain materialization.

=== Cumulative timepoints

Our implementation of a cumulative checker is based on a very simplified cumulative propagator that considers every time point. This means that more fine-grained time domains would reduce performance. Efficient implementations of cumulative timetable propagation @letort2012scalesweep @ouellet2013cumulative instead only consider the different intervals between step changes in the resource profile heights. These step changes occur because activities become mandatory or stop being mandatory at those times. The profile remains constant between those steps. Since for each activity there are at most two events (start or stop being mandatory) that can cause step changes, the computation's time complexity now depends only on the number of activities and not on the number of timepoints. 

We expect applying this optimization will not significantly affect the difficulty of computing time conflicts. However, we expect large implications for our implementation of detecting activity conflicts, because the different points of a profile will now represent different lengths of time. An activity also does not necessarily need to start only at one of the step changes; it still has the freedom to start at any time point. Therefore, our strategy of computing for every time point whether an activity can be active cannot be simplified as easily. More careful study of these efficient algorithms is needed to come up with solutions.

=== Summary of other points

We also summarize points related to future work mentioned in earlier parts of the Discussion:

- Perforated intervals could be replaced by a more compact representation in the proof format. Alternatively, parsing can convert atomic constraints into domains. This would still require modifying the proof _system_ and specification of the checker (@sec:discuss:perfint:alts).
- The implementation of the holes set could be replaced by other implementations than our enumerated set (which is itself implemented using red-black trees)  (@sec:discuss:perfint:alts).
- Proof automation could be improved, as we make little use of it other than `lia`. This could help reduce the relative amount of implementation-coupled proof lines vs. conceptual proof lines (@sec:discuss:automation).
- Empirical evaluations are missing (@sec:discuss:empirical). These will be found in Sidorov et al. @sidorov2025checker.
- The parsing of problem models into the checker's data model could be formally verified. 



#pagebreak(weak: true)

= Conclusion (extended summary)

Constraint Programming (CP) solvers have a propensity for bugs due to their use of performance engineering and complex algorithms. This reduces trust in their results, which are hard to check in the case of optimality or unsatisfiability claims. Proof logging and proof checking are a promising way to remedy this by allowing optimality and unsatisfiability claims to be verified. Previous work showed that it is possible to instrument state-of-the-art solvers to produce proofs of unsatisfiability. However, they relied on a method that requires encoding CP models into SAT or pseudo-Boolean constraints, which lack expressive power. This results in potentially larger proofs and difficulty translating specialized CP reasoning to these more limited languages. A collaborative effort, of which this work is a part, seeks to improve this by developing a proof system that allows natively expressing CP models and reasoning. To achieve the highest possible trust, given the fact that verification requires reasoning of a similar strength to solvers, the CP unsatisfiability proof checker developed by the collaborative effort is formally verified to be sound: when it accepts a proof, we know the proof's claim to be correct. Proofs in the CP proof system consist of a sequence of individual proof steps, each of which must be individually verified. This work asks _how formally verified checkers for individual proof steps can be developed_. This is challenging because one of the main proof step types -- propagator inferences -- can use any type of CP reasoning. Consequently, supporting a new constraint or propagator requires the implementation of a dedicated inference checker.

Our work makes the following main contributions:

- The development of a methodology for developing propagator inference checkers: This methodology guides the creation of a checker by studying the _conflict types_ of a particular propagation algorithm for a particular constraint, as we find (building on previous work) that checking conflicts is easier than checking specific propagation results.  
- A formalized theory and implementation of perforated intervals: perforated intervals are a domain representation consisting of bounds and holes, and support efficient check and update operations. The development also includes theoretical results that tell us under what conditions these check and update conditions are efficient and through what operation this condition (_tightness_) can be achieved. This includes formal proofs that go beyond the soundness claims necessary for the proof checker. Perforated intervals can be used to reason over domains instead of proof steps for inference checkers and form the core of the _deduction step_: which is the other main proof step type we consider.
- Deduction allows deriving new facts from previous ones. Deduction steps correspond to the learned nogoods found by learning CP solvers. Checking the deduction step requires careful tracking of variable domains using domain maps, which build on perforated intervals. We present a fully formalized implementation with a correctness proof that is abstracted from its implementation details.
- A formally verified algorithm for checking inferences made by a timetable propagator for the cumulative constraint. This checker checks two different conflict types, as identified by the methodology of our first contribution. This non-trivial checker serves as an example for future inference checkers and as a successful example of our methodology. It is based on a simplified propagator that considers individual timepoints, which leaves room for further optimization.
- A formally verified checker for alldifferent that can catch all valid alldifferent propagations, as long as inference proof steps contain no redundant information. This checker uses Hall's theorem to determine whether an alldifferent constraint is unsatisfiable. As the checker has a powerful tool (Hall's theorem) to understand the possible conflicts, it does not need our inference checker methodology.
- Findings about the usage of Rocq, which is the language and proof assistant used to implement and verify the CP proof checker. In particular, we find two types of proof segments: conceptual proofs and implementation-coupled proofs. We successfully tested this hypothesis by decoupling the two types in our alldifferent checker.

Our work is a significant step towards achieving a formally verified CP proof checker capable of verifying CP-native and integer reasoning, while also making theoretical contributions through the theory of perforated intervals. Our proposed methodology should make the checker extensible, as should our perforated intervals and library of utilities. In particular, our methodology advances our goal by tackling the checking algorithms, while perforated intervals and our examples advance the formal verification part of it. However, there are some important limitations. First of all, we identify a significant formal verification burden, which we were not able to alleviate with automation. Our proposed inference checker methodology also provides no guidance on formal verification, focusing instead only on developing the checking algorithm. We see that the approach adopted by the CP proof system used in this work increases this burden compared to earlier approaches for CP unsatisfiability proofs (that encode the problem in a more limited language, such as pseudo-Boolean constraints) by requiring a formally verified checker for every type of inference. However, the CP proof system has the major benefit that less conceptual work is required to translate propagation algorithms and constraint models, as they can be supported directly and do not have to be translated to reasoning in more limited languages. Finally, this work lacks an empirical evaluation, as the proof checker is still missing important components. This complicates judging our work's practical implications. However, this is expected to be addressed in upcoming work by the collaboration.

We see multiple avenues to further improve our work. First of all, our proposed methodology could be improved by developing guidance for the formal verification of checkers for conflict types. This would significantly advance our goal of how to develop _formally verified_ proof step checkers. Next, multiple performance improvements are possible, in particular for cumulative by not considering all timepoints and for alldifferent by computing the domain union more efficiently. Adding support for new constraints will also advance our understanding of inference checking by providing additional examples and testing our methodology. Finally, a large conceptual improvement to inference checking could be made by investigating support for richer _hints_ to the proof system. These hints can tell the inference checkers "where to look". In the case of cumulative this would be especially helpful for conflict inferences, providing significant speedups.


#pagebreak(weak: true)

#ams-biblio(bibliography: bibliography("bib.yml"))

#pagebreak(weak: true)

#nonumber[= Appendix]