# Update Plan: Restructure Presentation Flow Based on finalpresentation.md

## New Slide Structure & Animation Plan:

### 1. StepDetails Slide - Simplified
- Animation 1: Show 3 centered boxes (CP, Proof Checking, Unsatisfiability)  
- Animation 2: Show Step box (same size, below the three)
- Animation 3: Show collaboration text with names: "Part of CP proof checker project with Maarten Flippo, Konstantin Sidorov, Emir Demirović"

### 2. Research Question - Clean
- Simple question without "formally verified" initially
- Remove unused props diagnostic

### 3. ContributionsOverview - Split into 2 slides

#### Slide 3A: Contributions Introduction
- Animation 1: "We're now ready to comprehensively describe my contributions"
- Animation 2: "And also reveal one major component I haven't discussed yet"
- Animation 3: Brief overview of 4 areas

#### Slide 3B: Contributions Detail (Pyramid - Corrected Order)
- Animation 1: **Top** - Constraint checkers (Cumulative + Alldifferent) 
- Animation 2: **Middle Left** - Methodology for developing new checkers
- Animation 3: **Middle Right** - Deduction step checker  
- Animation 4: **Bottom** - Perforated intervals (foundation)

### 4. Formal Verification - Split into 2 slides

#### Slide 4A: "Now I've neglected to mention a very important fact" 
Following finalpresentation.md lines 57-66:
- Animation 1: "I used the word 'implemented' quite a few times"
- Animation 2: "But this implementation goes further than just writing code"
- Animation 3: "To understand this, let me tell you about writing code"
- Animation 4: Traditional development cycle: "informal document → implement → test → repeat"
- Animation 5: "However, no matter how hard you try, you never know if your program is fully correct"

#### Slide 4B: "But wait a second..." 
Following finalpresentation.md lines 67-80:
- Animation 1: "How do we know there's not similar mistakes in the proof checker?"
- Animation 2: "First, proof checker is simpler than solver" 
- Animation 3: "Unfortunately, that's not enough. Checker is still not simple"
- Animation 4: "Solution is 'formal verification'"
- Animation 5: "Mathematical specifications + formal proofs"
- Animation 6: "Chain of trust: Our checker → Rocq → Human review"

### 5. Updated Slide Order:
1. Title
2. Motivation  
3. Challenge
4. StepDetails (simplified)
5. ResearchQuestion
6. ContributionsIntro (new)
7. ContributionsOverview (pyramid corrected)
8. FormalVerification1 (implementation context)
9. FormalVerification2 (trust chain)
10. ProofStepTypes (move up, detail the step types)
11. ConstraintCheckers (examples)  
12. Methodology (brief)
13. PerforatedIntervals (keep as is)
14. Achievements/Discussion
15. FutureWork
16. Summary

## Key Changes:
- Split complex slides into digestible parts
- Match animation timing to spoken narrative flow
- Introduce formal verification concept gradually
- Detail step types before showing implementations
- Maintain pyramid structure but correct animation order