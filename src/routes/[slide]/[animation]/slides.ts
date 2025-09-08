import type { Component } from "svelte"
import * as Title from "$lib/client/slides/Title.svelte";
import * as Motivation from "$lib/client/slides/Motivation.svelte";
import * as CPChallenge from "$lib/client/slides/CPChallenge.svelte";
import * as ResearchQuestion from "$lib/client/slides/ResearchQuestion.svelte";
import * as Methodology from "$lib/client/slides/Methodology.svelte";
import * as PerforatedIntervals from "$lib/client/slides/PerforatedIntervals.svelte";
import * as DeductionChecker from "$lib/client/slides/DeductionChecker.svelte";
import * as AlldifferentChecker from "$lib/client/slides/AlldifferentChecker.svelte";
import * as CumulativeChecker from "$lib/client/slides/CumulativeChecker.svelte";
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
    CPChallenge,
    ResearchQuestion,
    Methodology,
    PerforatedIntervals,
    DeductionChecker,
    AlldifferentChecker,
    CumulativeChecker,
    Achievements,
    FutureWork,
    Summary
  ]