# Title slide (slide 1)

Hi, everyone. Great to see all of you. Today I'll be presenting my thesis, titled "Proof Step Checking in a Constraint Programming Unsatisfiability Solver".

Like many academic titles, it's quite a mouthful, so let's break it down. And don't worry, we'l discuss everything in more detail later. First, Constraint Programming is a paradigm for modeling and solving optimization problems. Unsatisfiability is when a problem has no solution; turns out, it's hard to check this. Proof Checking involves, as the name implies, checking a proof. A proof of what? Well, proofs that problems have no solutions. OR, and that's what I did, proofs of small steps that in the end, together form the proof of unsatisfiability.

TODO? make already clear that step is my contribution!

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
- Answer: we can just check whether solution satisfies all constraints
- How do we solve this problem? We make sovlers record their reasoning, this record forms a proof
- Then we check that proof

---

<--- 4 minutes

