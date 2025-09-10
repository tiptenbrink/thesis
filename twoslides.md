# Cumulative Checker using the Methodology

Now let me tell you about one of the most challenging parts of my work: creating a checker for cumulative constraints using my methodology. This was by far the hardest thing I implemented.

Remember our hospital example with doctors and operations? The cumulative constraint ensures we never exceed our capacity - in this case, the number of available doctors. When a solver claims there's no valid schedule, how do we check if that's actually true?

My methodology breaks this down into manageable pieces. The key insight is focusing on _conflict types_ - different ways the constraint can be violated. For cumulative, I identified two main types:

First, "time conflicts" - imagine at 2pm we need three doctors but only have two available. That's a clear conflict at a specific timepoint. 

Second, "activity conflicts" - more subtle! An operation might be impossible to schedule anywhere in its allowed window because it would always cause problems somewhere. It's like trying to fit a large piece into a puzzle - no matter where you put it, something doesn't fit.

The beauty is that checking conflicts is simpler than figuring out what the solver should deduce. Instead of deriving exact new bounds, I just verify: "Does this claimed conflict actually exist?" 

My checker examines individual timepoints, checking whether mandatory activities exceed capacity. It's not the most efficient approach possible, but it's formally verified to be correct. Sometimes simplicity wins over optimization, especially when you need mathematical certainty.

# Perforated Intervals

Let me introduce something I'm particularly excited about: perforated intervals. They might sound technical, but they solve a very practical problem elegantly.

In constraint programming, variables have domains - sets of allowed values. As solving progresses, we learn certain values are impossible. A variable might start allowing 1 to 100, but then we discover it can't be 17, or 45-50, leaving us with something like {1,2,3,...,16,18,...,44,51,...,100}.

Traditional approaches either enumerate every allowed value (memory-intensive) or use multiple intervals (complex to manage). Perforated intervals offer a third way: represent the domain as a single interval with "holes" - forbidden values within the bounds.

So {1,2,3,5,6,7,9,10,11} becomes [1,11] with holes {4,8}. Simple, yet powerful!

The magic happens with "tightness." A perforated interval is tight when the bounds truly matter - when the first and last values aren't holes. This enables efficient operations crucial for proof checking: we can quickly determine if a domain is empty or if constraints hold just by checking bounds.

These intervals proved invaluable everywhere: tracking variable domains during deduction, extracting bounds for constraint checking, building enumerated domains for alldifferent. Their simplicity made formal verification much easier than alternatives, while their expressiveness handled all practical cases I encountered. Sometimes the best solutions are surprisingly simple!