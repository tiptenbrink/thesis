import type { Component } from "svelte"
import * as Opening from "$lib/client/slides/Opening.svelte";
import * as Elevator from "$lib/client/slides/Elevator.svelte";
import * as SolutionApproach from "$lib/client/slides/SolutionApproach.svelte";
import * as TitleExplained from "$lib/client/slides/TitleExplained.svelte";
import * as WhatAreProofs from "$lib/client/slides/WhatAreProofs.svelte";
import * as MiniClaimExample from "$lib/client/slides/MiniClaimExample.svelte";
import * as ProofCheckerTasks from "$lib/client/slides/ProofCheckerTasks.svelte";
import * as ConstraintProgramming from "$lib/client/slides/ConstraintProgramming.svelte";
import * as ResearchQuestion from "$lib/client/slides/ResearchQuestion.svelte";
import * as ContributionsDetailed from "$lib/client/slides/ContributionsDetailed.svelte";
import * as FormalVerification1 from "$lib/client/slides/FormalVerification1.svelte";
import * as FormalVerification2 from "$lib/client/slides/FormalVerification2.svelte";
import * as CumulativeChecker from "$lib/client/slides/CumulativeChecker.svelte";
import * as Discussion from "$lib/client/slides/Discussion.svelte";
import * as FutureWorkDetailed from "$lib/client/slides/FutureWorkDetailed.svelte";
import * as SummaryFinal from "$lib/client/slides/SummaryFinal.svelte";
import * as PerforatedIntervals from "$lib/client/slides/PerforatedIntervals.svelte";
import * as Tightness from "$lib/client/slides/Tightness.svelte";
import * as Achievements from "$lib/client/slides/Achievements.svelte";

export type SlideComponent = Component<{ animation: number }>

export interface SlideModule {
    animations: number,
    default: Component<{ animation: number }>
}

export const slides: SlideModule[] = [
    Opening,
    Elevator,
    SolutionApproach,
    Achievements,
    TitleExplained,
    WhatAreProofs,
    MiniClaimExample,
    ProofCheckerTasks,
    // ConstraintProgramming,
    ResearchQuestion,
    ContributionsDetailed,
    FormalVerification1,
    FormalVerification2,
    CumulativeChecker,
    PerforatedIntervals,
    Tightness,
    Discussion,
    FutureWorkDetailed,
    SummaryFinal
  ]