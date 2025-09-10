# Title slide (slide 1)

Hi, everyone. Great to see all of you. Today I'll be presenting my thesis, titled "Proof Step Checking in a Constraint Programming Unsatisfiability Solver".

Like many academic titles, it's quite a mouthful, so let's break it down. And don't worry, we'll discuss everything in more detail later. First, Constraint Programming is a paradigm for modeling and solving optimization problems. Unsatisfiability is when a problem has no solution; turns out, it's hard to check this. Proof Checking involves, as the name implies, checking a proof. A proof of what? Well, proofs that problems have no solutions. OR, and that's what I did, proofs of small steps that in the end, together form the proof of unsatisfiability.

todo? make more clear that step signifies my contribution!

# Motivation (slide 2)

As I promised, let's now look at this in more detail. In particular, I want to explain why this is even useful.

Well, as I said, Constraint Programming (CP) is a paradigm for solving optimization problems. What kind of problems? Let's look at a problem that CP is good at.

As the name suggests, in CP you describe problems using constraints. How does that look like? Well, consider we have, in some time window in a hospital, 2 doctors available at a given moment and we need to perform 3 different operations. Operations a, b need 1 doctor. c needs 2 doctor. 

We've now described a common constraint, and one that I studied at length in my thesis: a cumulative constraint, which basically ensures that given some capacity, we never exceed that capacity at any timepoint. Here is a possible schedule, where the height represents the number of doctors needed.

--

So what is now our main challenge? What's the problem that I'm helping to solve?
- CP solvers are software. Decades of engineering, squeezing out performance, as well as a lot of complicated algorithms developed over many years, have made CP solvers very complex. However, writing complex code is hard and as a result solvers can make mistakes. 
- The type of mistake _we_ are interested in is when a solver claims that a problem is impossible (or unsatisfiable).
- Question for you, I hope the CS students here know the answer, why is this harder to check than when you do get a solution?
- Answer: we can just check whether solution satisfies all constraints. In our doctor example, 
- Okay, so we focus on claims that problems are unsatisfiable. How do we check those? We make solvers record their reasoning, this record forms a proof
- Then we check that proof, going step by step and seeing if the solver made mistakes

---

todo? am i explaining research gap enough?

I've given more detail on CP, unsatisfiability and proof checking (animations) in more detail. Let's move on to the element that makes clear what _my_ contribution is: "step".

Creating an entire proof checker is a large undertaking. This idea of a proof checker already existed before I started my thesis: my work is part of what is currently called: "the CP proof checker project"; led by my supervisor and two PhD'ers, Maarten Flippo and Konstantin Sidorov.

Alright, so what is my part. Proofs consist of a sequence of steps. Each little bit of reasoning performed by a solver to derive unsatisfiability can be seen as a step. Each of these steps needs to be checked individually. There are also different types of steps. So what I focused on in my thesis is checking these individual checks is not : collecting all the steps to see if the claim is true ; but checking the steps themselves.

todo? diagram to explain this

Research question: how can we developed (hidden: formally verified) proof checkers for individual steps?

---

We're now ready to comprehensively describe my contributions, and also reveal one major component of my work that I have not yet discussed.
- I have implemented two constraint-specific checkers, one for cumulative and one for alldifferent. Cumulative we already saw at the beginning of this presentation. Alldifferent is a constraint that requires a list of values to all be distinct; i.e., all different. 
- Of course, my research question was _how_  can we develop checkers for individual steps. So
- I have developed a methodology for developing new constraint-specific checkers. Since there are many different types of constraints, we want to add support for more of them. Future work can now use my methodology to make this easier.
- Furthermore, I implemented a checker for what is called the "deduction step". Other than the constraint-specific steps, which capture reasoning a solver makes to rule off possibilities since they don't satisfy a particular constraint, the deduction step _combines_ previous steps to, well, _deduce_ new facts. 

- To make these developments possible, we needed some building blocks. In these problems we have so-called variables: things that are not fixed and we want to find the value of. If you remember our doctor/operation problem, the starting time of each particular operation was the variable. In practice, we work only with _integer_ variables, so variables that are either -2, -1, 0, 1, 2, etc. Variables can have domains, which are sets of values the variable can take. Almost all the reasoning we do includes reasoning over these domains. For that reason, I developed a specialized integer domain representation known as perforated intervals. We will discuss them in more detail later.

- I also developed many other building blocks and code that can be reused in future developments, but due to lack of time I won't discuss them any further.

--- 

Now, I've actually neglected to mention a very important fact. I used the word "implemented" quite a few times. But this implementation goes further than just writing code that does what you want it do. 

To understand this, let me tell you a bit more about writing code. When you develop software, it might work something like this:

- You write a document describing what you want the software to do. Maybe this is not even written by the software engineer, but by a manager. This is usually quite informal. For example, it might not consider a lot of edge cases.
- Then, you start implementing it. You write actually write the problem.
- Once that's done, you let the computer run the program. You then check whether the program actually behaved according to how you want it to behave. Often, you discover there are edge cases you didn't think, so you go back to implementing the program. You repeat this until you are confident it works.

However, no matter how hard you try, in practice you never know if your program is fully correct. There might always be an edge case that you weren't able to test. Usually, it's impossible to test all possible inputs and outputs.

Let's return to the problem at hand. As I said at the start, solvers are complex and make mistakes. We can't eliminate all those mistakes precisely because of what I just said.

Okay, but wait a second. How do we know there's not similar mistakes in the proof checker? Well, first of all, the proof checker is simpler than the solver. Because the solver has already examined all the possibilities, the checker _knows_ where to look. It needs to simply follow the steps the solver recorded and see if by the end, indeed all the possibilities were eliminated. 

Unfortunately, that's not enough. Because while it's _simpler_, the checker is still not _simple_. In particular, implementation for the constraint-specific checkers I mentioned that I implemented, are only a little bit simpler than the corresponding constraint-specific logic in the solver. So we need to do better.

The solution is "formal verification". When we do formal verification, that "design document" becomes what is called a "specification". Furthermore, it's not informal. Every desired behavior needs to be precisely described, using mathematical language. Programs are no longer bytes in a computer, they become mathematical objects. 

Then, we write a proof, a mathematical proof, that our implementation satisfies the precise specification. Again, this proof needs to be very precise, hence the world "formal". 

Alright, are we done now? After writing a proof, are we sure that there's no more mistakes? 

Well, no. Because what if _my_ proof, the mathematical proof, is wrong? Well, we use another proof checker. But how do we know that _that_ proof checker, which, by the way, is known as Rocq, is correct? Well, that proof checker is even simpler! Simple enough that, because hundreds of humans use it and have looked at its code, we at some point trust that it is correct. Furthermore, Rocq is not just used by us, but by many projects all over the world, some that require an even greater degree of trust than we do.

# Maybe more in depth contributions

Alright, so now you have a full idea of what I've done, let's go over each of my contributions in more detail.

## Checkers and methodology

I will now highlight some important details of the two constraint-specific checkers I implemented.

First of all, my cumulative checker. This was the most difficult of all the things I implemented, by far. I will use it as an example to explain my methodology.

For that ...

## Perforated interval

Let's now look at perforated intervals. Remember, they represent an integer domain, so a set of integers. They can represent any finite set of integers, and even some infinite ones.

They work 

# Discussion

In summary, what have I achieved and what does it mean?

First of all, I have demonstrated the feasibility of a formally verified CP unsatisfiability checker, by implementing support for two constraints, for the deduction step. I have developed a methodology for developing new constraint-specific checkers, which makes it easier to further extend the checker. I have developed a theory of perforated intervals, with a formally verified implementation, which form an important building block of many checker components. Furthermore, they could see more widespread use in other formally verified programs as integer domain representations.

However, there are of course, some limitations. In particular, when we compare this approach of using the constraint-specific logic to verify solver reasoning to related work, we see that we have a much higher formal verification burden. Other approaches usually describe the constraint-specific reasoning done by the solver in terms of simpler reasoning. This means your checker is also simpler and there is less to formally verify. 

Furthermore, my work did not contain an empirical validation. This was because the full checker, developed by others in the project, was not yet finished by the time I was nearly done. Therefore, no large problems could be tested. Thankfully, this situation has since improved and the results are very promising!

# Future work

Finally, let's discuss some possible future work.

First of all, once the full checker is finished, we can empirically test proofs produced by CP solvers and see if the performance of the checker is acceptable. As I mentioned, this is already underway!

Next, there are many possible optimizations possible in my checker implementations. I implemented the simplest possible logic for reasoning over cumulative constraints, but algorithms used in solvers use a number of tricks to increase performance. These could also be applied to my checker.

Solvers could record so-called "hints", additional information that could speed up checkers and simplify them further. 

The simple methodology I proposed could be expanded, in particular by also including methods to help the formal verification part, since that is currently the biggest difficulty.

# Summary

To summarize 