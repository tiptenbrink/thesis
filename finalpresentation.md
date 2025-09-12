#### elevator pitch version

###### Checking a Solver's Work

First of all, it's great to see all of you. Let's dive straight in.



Finding optimal schedules for nurses and doctors is a prime example of a problem computers have become very good at solving. 

Computer solvers are able to evaluate many more possibilities than humans can and are able to leverage all kinds of algorithmic tricks. 

However, what if a solver program incorrectly claims that some important constraints, like a minimum amount of staffing on a shift, can't be met?

In the best case this means delaying treatments. 

In the worst case, one fewer nurse is scheduled on a night shift where multiple patients suddenly require urgent care. You can imagine the consequences. 

Today, I am presenting my research, which will

* make new tools available for a large class of solvers 
* that can catch these erroneous results before they have a chance to cause harm.



~1 min



###### How

How does my research achieve this? In short: by not trusting solvers on their word alone. 

When they make a claim that a particular problem has no solution, we require them to "show their work", so to speak. More specifically, we require them to "prove" their claim by recording their reasoning in a proof. 

These proofs can be very large. Therefore, they are not checked by hand, instead this work is delegated to another program, called a "proof checker".

Such a proof checker is developed here at the TU Delft by my supervisor and two PhD students. 

My research goal was not just to directly contribute to this proof checker, but to also better understand some specific components and make it easier to extend it in the future.

~2 min



I achieved these goals in four main ways:

* Implementing support to check "the work" done by a solver for two common subproblems. We'll see an example of such a subproblem later.
* Implementing support to check a solver combining knowledge it gathered from different subproblems
  ~2 min
* A methodology for extending the checker so that it can handle more subproblems in the future
* A reusable component that is used throughout the checker and can be used also by future extensions. This component allows efficient reasoning over sets of integer (so -1, -5, 0, 1) values, like checking what the maximum and minimum is.



Great, now that you have a high-level overview, let's dive deeper.



At the start I said we are worried about when a solver incorrectly claims a problem has no solutions. But why are we not worried about the case when the solver returns a solution that is actually not a solution? 

Try to think about it and see if you can figure it out by the end of the presentation! I hope the CS students out there know the answer!



Next, let's look at the actual title of my thesis:
"Proof Step Checking in a Constraint Programming Unsatisfiability Proof Checker".

Unsatisfiability is just another word for not having any solutions. So a problem that has no solutions is unsatisfiable. Proof checking: We're checking proofs of unsatisfiability claims, that all makes sense. But what's the "step" in proof step checking about, then? And what is Constraint Programming?

Let's get into that, which will allow us to get to the heart of my contributions.

~4

###### Proofs

Remember, proofs are a record of the "work" performed by a solver. 

For the solvers I'm looking at, which are, all Constraint Programming (CP) solvers -- more on that in a minute, this work involves learning progressively more things about the problems. 

This combined knowledge can then be used to show that a problem has no solution. 

Therefore, a proof that aims to show that a problem has no solution should contain exactly this knowledge. 

More specifically, proofs are a sequence of subclaims: where each subclaim is a statement that a particular piece of knowledge is true. Each step in a proof is then such a subclaim!



###### subclaim example

To clarify this, let's look at an example of a subclaim:

Remember the problem of finding a schedule for nurses and doctors? Imagine we have, in some time window in a hospital, 2 doctors available at a given moment and we need to perform 3 different operations. Operations for Alice and Bob need 1 doctor each. The operation for Carol needs 2 doctor. Next, operations for Bob and Carol take 2 hours, as opposed to Alice's operation needing only 1 hour.

Remember, we have only two doctors available. That means that at any given timepoint we can never use more doctors. This requirement, or "constraint", distinguishes valid schedules from invalid ones. This particular constraint, which has some set activities (the operations in our case) that make use of a resource (the doctors) with a fixed capacity (2), is known as cumulative. I studied it at length in my thesis, and it will come up again later.

Okay, so based on this constraint, here is a possible schedule, where the height represents the numbers of doctors needed.

Then a possible schedule would look like this.


Now there are actually multiple subclaims we could make based on this situation. Can anyone come up with a subclaim?

~6

Example: Well, suppose that we know that Alice's operation is scheduled at t=0, and Bob's operation is scheduled at t=1, and Carol's operation is scheduled somewhere between t=0 and t=2. Then this would be impossible, because no matter where we place Carol's operation in between t=0 and t=2, it would violate the constraint!

So what exactly is this subclaim claiming? It claims that, given the particular possibility, the constraint is surely violated and hence that possiblity is ruled out!

? todo improve!!!!!

A proof checker then needs to do two things:

* Check that every subclaim is true
* Check that all subclaims being true imply the main claim

What I looked at in my thesis is only that first thing: checking all these individual subclaims.

Before we move on, let's clarify one more thing: the Constraint Programming (or CP) in my thesis title. As we saw in the example, we can describe problems using general *constraints*. In this case it was operations, but it could also be jobs in a factory. The Constraint Programming paradigm describes problems using these constraints and then uses constraint-specific reasoning to solve them. It's been particularly succesful in scheduling problems, including the health care scheduling problem we have been considering.

We're now ready to present my main research question and discuss my contributions in full detail.
~8

###### Research question

Research question: how can we develop (hidden: formally verified) proof checkers for individual proof steps in a CP unsatisfiability proof checker?

Oops, you can see one part is still hidden! We'll get to that in a minute, but first, a more detailed overview of my contributions.

###### List contributions

(start with previous overview, then expand each one with the full details, then make it a simple block)

* I have implemented two constraint-specific checkers, which check subclaims that involve specific constraints; these are the subproblems. One for cumulative and one for another constraint: alldifferent. Alldifferent is a constraint that requires a list of values to all be distinct
* Earlier, I mentioned a methodology that makes it easier to extend the checker. With extend I meant support for verifying subclaims involving new constraints, other than alldifferent cumulative
* Furthermore, I implemented a checker for a subclaim that is known as "deduction". As opposed to the constraint-specific claims, deduction subclaims refer to previous subclaims to support new subclaims. So they combine them.

? todo: temporarily expand to show the details here

* It turns out, these checkers share a lot of common logic. A big chunk of this logic is related to dealing w/ "domains". A domain is a set of possible values. For example, if you remember our doctor/operation example fact, Carol's operation could either occur at t=0, or t=1 or t=2. So the domain in that case is the set \[0, 1, 2]. To deal with these domains: I developed a specialized integer domain representation known as perforated intervals.

~10 min

* I also developed many other building blocks and code that can be reused in future developments, but due to lack of time I won't discuss them any further.

Remember I hid a part of the research question? Let's get into that.
I used the word "implemented" quite a few times. But this implementation goes further than just writing code that does what you want it do.

To understand this, let me tell you a bit more about writing code. When you develop software, it might work something like this:

* You write a document describing what you want the software to do.
* Then, you actually implement the program.
* Then, you let the computer run the program. You then check whether the program actually behaved according to how you want it to behave. Often, you discover there are edge cases you didn't think of, so you go back to implementing the program. You repeat this until you are confident it works.

However, no matter how hard you try, in practice you never know if your program is fully correct. There might always be an edge case that you weren't able to test. Usually, it's impossible to test all possible inputs and outputs.

All this applies to writing solvers. Which is exactly why we developed a proof checker.

?todo: this is not yet in slide

Okay, but wait a second. How do we know there's not similar mistakes in the proof checker?

That's because the proof checker is what we call "formally verified". When we do formal verification, that "design document" becomes what is called a "specification". Furthermore, it's not just some word document. Everything needs to be precisely described, using mathematical language. And with everything, I mean everything! A computer is a blank, it doesn't know everything. It needs to be taught the precise definition of a number, of addition. Programs are no longer bytes in a computer, they become mathematical objects.

Then, we write a proof, a mathematical proof, that our implementation satisfies the precise specification. Again, this proof needs to be very precise, hence the world "formal".

Alright, are we done now? After writing a proof, are we sure that there's no more mistakes?

Well, no. Because what if *my* proof, the mathematical proof, is wrong? Well, we use another proof checker. But how do we know that *that* proof checker, which, by the way, is known as Rocq, is correct? Well, that proof checker is designed to be very simple. Simple enough that, because hundreds of humans use it and have looked at its code, we at some point trust that it is correct. Furthermore, Rocq is not just used by us, but by many projects all over the world, some that require an even greater degree of trust than we do.

? objection to formally verifying the full solver?

~3

# Key contributions

Alright, so now you have a complete picture of what I've done, there's two contributions that I want to discuss in more depth.

~13

## Checkers and methodology

First, we're looking at my checker that verifies subclaims about the cumulative constraint.

Remember the example I gave of a subclaim? Let me write it in a more structured way:

```
CLAIM: the following domains lead to a violation
- operation A starting time domain \[0]
- operation B starting time domain \[1]
- operation C starting time domain \[0,1,2]
```

So Alice and Bob's are fixed to respectively 0 and 1. So schedule looks at least like THIS. Carol's could start at any of the listed times.

Actually, every subclaim can be written like that: so a claim that some combination of domains will lead to a constraint violation!

My cumulative checker groups every claim it encounters into one of two categories and uses a different strategy for each. This is guided by my methodology, which can be summarized as:

1. find the different categories
2. determine a separate strategy for each one.

Here, there are two categories. The earlier example is a so-called "operation conflict". I will now show you another one, called a "time conflict".

```
CLAIM: the following domains lead to a violation
- operation A starting time domain \[0]
- operation C starting time domain \[0]
```

Can you spot how they are different?

Alright, in case 1, as the name suggests, we need to look from the perspective of a particular operation, in this case Carol's operation. This allows us to see that no matter where we put it, we'll cause a violation.

In case 2, however, we need to look at a particular timepoint, where we will immediately see that there already is a violation.



~2.5 min

## Perforated interval

The last piece of the puzzle we will look at is the domain representation used throughout this thesis: perforated intervals. They are quite simple, but solve a lot of practical problems.

All they are are an interval, so a lower bound and upper bound, for example \[0, 5], which is all the numbers \[0, 1, 2, 3, 4, 5]; and a set of holes (or perforations, hence the name). So you could imagine the set \[0, 1, 4, 6] would be represented by \[1, 6] \\ {2, 3, 5}.

Now, representing a domain like this has been done before, and is not new at all. What is new, is that my implementation is formally verified, and that I precisely described a condition in which case you can efficiently check the lower and upper bound of an interval.

I've called this condition tightness. A perforated interval is tight when it doesn't have a hole at one of the bounds of the interval. For example, \[1, 3] \\ {1} is not tight. When a perforated interval isn't tight, we could use a simpler representation. In this case that would be just \[1, 2].

When a perforated interval is tight, you can just check its lower and upper bounds by inspecting the bounds of the interval. So for \[1, 2] clearly the lower bound is 1 and upper bound is 2. But if we had \[1, 3] \\ {1}, we would have to think a bit before we could figure out the lower bound is 2!

Again, I'm not claiming that nobody ever thought of this. However, it's never been described in any kind of detail.

~2 min

~start from 0

# Discussion

In summary, what have I achieved and what does it mean?

First of all, I have demonstrated the feasibility of a formally verified CP unsatisfiability checker, by implementing support for two constraints, for the deduction step. I have developed a methodology for developing new constraint-specific checkers, which makes it easier to further extend the checker. I have developed a theory of perforated intervals, with a formally verified implementation, which form an important building block of many checker components. Furthermore, they could see more widespread use in other formally verified programs as integer domain representations.

However, there are of course, some limitations. In particular, when we compare this approach of using the constraint-specific logic to verify solver reasoning to related work, we see that we have a much higher formal verification burden. Other approaches usually describe the constraint-specific reasoning done by the solver in terms of simpler reasoning. This means your checker is also simpler and there is less to formally verify.

Futhermore, my methodology does not provide any guidance on how to do formal verification.

~2 min

# Future work

Finally, let's discuss some possible future work.

First of all, once the full checker is finished, we can empirically test proofs produced by CP solvers and see if the performance of the checker is acceptable. As I mentioned, this is already underway!

Next, there are many possible optimizations possible in my checker implementations. I implemented the simplest possible logic for reasoning over cumulative constraints, but algorithms used in solvers use a number of tricks to increase performance. These could also be applied to my checker.

Solvers could record so-called "hints", additional information that could speed up checkers and simplify them further.

# Summary

To summarize

~2 min



With my contributions, I'm sure there's a bright future ahead for CP solvers, as they can fearlessly seek to improve their algorithms, without having to worry about being incorrect, since we will be able to catch that!

