import type { Component } from "svelte"
import * as Title from "$lib/client/slides/Title.svelte";
import * as Motivation from "$lib/client/slides/Motivation.svelte";
import * as Challenge from "$lib/client/slides/Challenge.svelte";
import * as ResearchQuestion from "$lib/client/slides/ResearchQuestion.svelte";
import * as OurApproach from "$lib/client/slides/OurApproach.svelte";
import * as ContributionsOverview from "$lib/client/slides/ContributionsOverview.svelte";
import * as PerforatedIntervals from "$lib/client/slides/PerforatedIntervals.svelte";
import * as ProofStepTypes from "$lib/client/slides/ProofStepTypes.svelte";
import * as ConstraintCheckers from "$lib/client/slides/ConstraintCheckers.svelte";
import * as Achievements from "$lib/client/slides/Achievements.svelte";
import * as FutureWork from "$lib/client/slides/FutureWork.svelte";
import * as Summary from "$lib/client/slides/Summary.svelte";

export type SlideComponent = Component<{ animation: number }>

export interface SlideModule {
    animations: number,
    default: Component<{ animation: number }>
}

export const slides: SlideModule[] = [
    Title,
    Motivation,
    Challenge,
    ResearchQuestion,
    OurApproach,
    ContributionsOverview,
    PerforatedIntervals,
    ProofStepTypes,
    ConstraintCheckers,
    Achievements,
    FutureWork,
    Summary
  ]