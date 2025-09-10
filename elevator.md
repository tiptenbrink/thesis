? in elevator pitch: unsatifiability vs optimal
? maybe already just bad that the requirements cannot be met

? pitch vs begin with numeric example

? don't do 2 examples in the first part
? maybe stick to harm

? within 5 minutes at least good idea

? summary, try to do wow.
? for formal verif, you really ahve to explain everything to compuer, blank box.


# elevator pitch version

Computers have become better at solving many real-world problems, like finding optimal schedules for nurses and doctors in health care, or verifying that a new, faster chip design behaves the same as the previous design. Computers are simply able to evaluate many more possibilities than humans can and are able to leverage all kinds of algorithmic tricks. However, what if a solver program incorrectly claims that it has found the best possible health care schedule?
In the best case this just means wasting precious resources. In the worst case, maybe one fewer nurse is scheduled on a night shift where multiple patients suddenly require urgent care. Or in the case of the new chip design, if the chip is already installed somewhere, maybe an edge case not caught by the solver program could cause an elevator to fail or a plane sensor to report erroneous data.

Today, I am presenting my research, which makes more and better verification options available to a large class of these solver programs, allowing them to catch erroneous results before they have a chance to cause harm. Other than preventing harm, verification enables solvers to further improve their speed, as with verification they can worry less about these improvements causing harms. 

My work relies on solver programs producing proofs of their claims. So solvers don't simply claim that a particular solution is optimal or that no solution exists, they have to actually "show their work", so to speak. 

These proofs, which always concern proofs of optimality, or equivalently, unsatisfiability (meaning no problem exists), are very large! We therefore don't check them by hand, but develop a new program, called a "proof checker", that goes through it step by step. My specific contribution then involves these individual steps. 
If that sounds vague, don't worry, I will go into more detail later.

My research goal was not just to directly contributing to this proof checker, which is developed here at the TU Delft by my supervisor and two PhD students, but to better understand some specific components and make it easier to extend it in the future.

I achieved this with two further contributions: the first is a methodology to ease future contributions, the second is a building block that is used by multiple components of the checker and supports reasoning over sets of possible integer values, so (potentially infinite) sets consisting of values like -10, -4, 0, 2, 8...

?todo quickly mention formal verification

Now, after this high-level overview of the motivation and my contributions, let us dive in deeper.

My thesis is titled "Proof Step Checking in a Constraint Programming Unsatisfiability Proof Checker".

?todo: where to mention 

We already saw that usatisfiability refers to problems having no solution. We also already discussed that we are checking proofs of unsatisfiability. However, I said nothing yet of "Constraint Programming". Furthermore, I mentioned that proofs consist of steps and that my contribution focuses on them, but not in a lot of detail.

Before we expand on that, I want to consider a more specific example problem. This problem will help clarify the concept of CP and serve as a useful example when we zoom in on proofs.

Remember the problem of finding an optimal schedule for nurses and doctors? Imagine we have, in some time window in a hospital, 2 doctors available at a given moment and we need to perform 3 different operations. Operations a, b need 1 doctor. c needs 2 doctor. 

For a schedule to be valid, it will need to satisfy some constraints. In this case, we only have 2 doctors available at a given time. So at any time during our schedule, we cannot use more than two doctors.

Here is a possible schedule, where the height represents the numbers of doctors needed.

We can use the concept 

This is a common constraint, and one that I studied at length in my thesis: a cumulative constraint, which basically ensures that given some capacity, in this case 2 doctor, we never exceed that capacity at any timepoint. Here is a possible schedule, where the height represents the number of doctors needed.

What is the optimization aspect? In this case that could be minimizing the total time. Here we're taking 5 units of time. Clearly, a better solution is the following schedule.




zoom in on proofs to understand what they consist of. 

---

Constraint Programming refers to a paradigm to model and solve optimization programs and is the class of solvers that I mentioned my work makes improved verifications options available for.

Why do we only do it for one class of solvers? Why can't proof checking work for all solvers? Well, first of all, a lot of problems can, often in quite a straightforward way, be modeled using CP. Next, modern CP solvers can be very easily modified to produce proofs in a format that works well for us. So, let's understand CP a little better.

Let us look at a more specific example so we can better understand what this is about.

As the name suggests, in CP you describe problems using constraints. How does that look like? Well, consider we have, in some time window in a hospital, 2 doctors available at a given moment and we need to perform 3 different operations. Operations a, b need 1 doctor. c needs 2 doctor. 

This is a common constraint, and one that I studied at length in my thesis: a cumulative constraint, which basically ensures that given some capacity, in this case 2 doctor, we never exceed that capacity at any timepoint. Here is a possible schedule, where the height represents the number of doctors needed.

What is the optimization aspect? In this case that could be minimizing the total time. Here we're taking 5 units of time. Clearly, a better solution is the following schedule.

---

Okay, so in CP we model problems by describing them in terms of constraints. 