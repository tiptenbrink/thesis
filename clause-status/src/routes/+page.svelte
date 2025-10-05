<script lang="ts">
  import {
    activeName,
    c2,
    cActTimeName,
    cleq,
    cMax,
    resourceRequirements,
    resourceTimeName,
  } from "$lib/problem";
  import {
    atomName,
    type Clause,
    type WeightedBooleanInequality,
  } from "$lib/solve";
  import cytoscape from "cytoscape";
  // @ts-ignore
  import dagre from "cytoscape-dagre";
  import ActivityRange from "./ActivityRange.svelte";
  import { onMount } from "svelte";

  let trailGraph: HTMLDivElement | undefined = $state();

  type Value = true | false | "𝔲";

  const vars = new Map<string, Value>();

  const TIME = 6;
  const MAX_TIME = 5;
  const times = [...Array(TIME).keys()];
  const RESOURCE_MAX = 2;

  // MAX TIME = 5, 
  // ["A", 5, 1],
  // ["V", 3, 1],
  // ["G", 2, 1],
  // ["D", 2, 1],
  // D4 = true, -> D <= 1 = false

  // MAX TIME = 4, 
  // ["A", 4, 1],
  // ["V", 2, 1],
  // ["G", 2, 1],
  // ["D", 2, 1],
  // most decision immediate proof

  const activityInput: [string, number, number][] = [
    // ['A', 3, 1],
    ["P", 5, 1],
    ["V", 3, 1],
    ["B", 2, 1],
    ["O", 2, 1],
    // ["E", 2, 1],
  ];

  const activities = activityInput.map(([name, _1, _2]) => name);
  const durations = new Map(
    activityInput.map(([name, duration, _]) => [name, duration]),
  );
  const usages = new Map(
    activityInput.map(([name, _, usage]) => [name, usage]),
  );

  for (const a of activities) {
    for (let i = 0; i < TIME + 1; i++) {
      vars.set(`${a}${i}`, "𝔲");
      let aAtomName = atomName(a, i);
      vars.set(aAtomName, "𝔲");
    }
  }

  function showClause(c: Clause): string {
    return c
      .map(([c, v]) => {
        if (c) {
          return v;
        } else {
          return `¬${v}`;
        }
      })
      .join("∨");
  }

  function showIneq(ineq: WeightedBooleanInequality): string {
    const terms = ineq.terms
      .map(([c, v]) => {
        if (c) {
          return v;
        } else {
          return `${c}⋅${v}`;
        }
      })
      .join("+");

    return `${terms} ≤ ${ineq.rhs}`;
  }

  function resolveValue(
    literal: [boolean, string],
    state: Map<string, boolean>,
  ): Value {
    const [c, v] = literal;
    const vValue = state.get(v) ?? "𝔲";

    if (vValue === "𝔲") {
      return vValue;
    } else if (c) {
      return vValue;
    } else {
      return !vValue;
    }
  }

  type PropagatorStatus =
    | {
        status: true;
      }
    | {
        status: false;
        nogood: Nogood;
      }
    | {
        status: "propagating";
        unresolved: string[];
        reason: Reason;
        implications: { name: string; value: boolean }[];
      }
    | {
        status: "propagated";
        reason: Reason;
        implications: { name: string; value: boolean }[];
      }
    | {
        status: "unresolved";
        unresolved: string[];
      };

  type Propagator = WeightedBooleanInequality | Clause;

  function weightedBooleanInequalityResolve(
    ineq: WeightedBooleanInequality,
    state: Map<string, boolean>,
  ): PropagatorStatus {
    const implications: { name: string; value: boolean }[] = [];
    const unknown: [number, string][] = [];
    const unresolved: string[] = [];
    const reason: Reason = [];
    let sum: number = 0;

    ineq.terms.forEach(([weight, variable]) => {
      const value = state.get(variable);

      if (value === undefined) {
        unknown.push([weight, variable]);
      } else if (value === true) {
        sum += weight;
        reason.push([variable, true]);
      }
    });

    unknown.forEach(([weight, variable]) => {
      if (sum + weight > ineq.rhs) {
        implications.push({ name: variable, value: false });
      } else {
        unresolved.push(variable);
      }
    });

    if (sum > ineq.rhs) {
      return {
        // all those that are true are in the reason, so it's also the nogood because assigning them causes it to be too large
        nogood: reason,
        status: false,
      };
    } else if (implications.length === 0 && unresolved.length === 0) {
      return {
        status: true,
      };
    } else if (implications.length === 0) {
      return {
        status: "unresolved",
        unresolved,
      };
    } else if (unresolved.length === 0) {
      return {
        status: "propagated",
        implications,
        reason,
      };
    } else {
      return {
        status: "propagating",
        implications,
        unresolved,
        reason,
      };
    }
  }

  function clauseResolve(
    clause: Clause,
    state: Map<string, boolean>,
  ): PropagatorStatus {
    let unresolved: string[] = [];
    // In case there is one unresolved (when clause is unit), only that will have set this value
    let unitPropagatedValue = false;
    let trues: string[] = [];
    const reason: Reason = [];

    clause.forEach(([constant, variable]) => {
      const vValue = resolveValue([constant, variable], state);
      if (vValue === false) {
        // It could contribute to the reason
        // Suppose we have ¬x = false
        // Then the reason is x = true
        // Otherwise if x = false
        // Then the reason is x = false
        // So the reason constant is the opposite of the literal constant in the clause
        reason.push([variable, !constant]);
      } else if (vValue === true) {
        trues.push(variable);
      } else {
        unresolved.push(variable);
        unitPropagatedValue = constant;
      }
    });

    if (trues.length === 0 && unresolved.length === 1) {
      return {
        status: "propagated",
        reason,
        implications: [{ name: unresolved[0], value: unitPropagatedValue }],
      };
      // trues.length != 0 || unresolved.length != 1
    } else if (unresolved.length >= 1) {
      return {
        status: "unresolved",
        unresolved,
      };
      // trues.length != 0 || unresolved.length == 0
    } else if (trues.length > 0) {
      return {
        status: true,
      };
    } else {
      return {
        // suppose ¬x or y resolves to false
        // then the nogood is x=true and y=false, so the opposite of how the clause is defined
        nogood: clause.map(([c, v]) => [v, !c]),
        status: false,
      };
    }
  }

  const cleqClauses = cleq(activities, TIME);
  const c2Clauses = c2(activities, durations, TIME);
  // const c3Clauses = c3()
  const cMaxClauses = cMax(activities, MAX_TIME);
  const weightedBooleanInequalities = [
    ...resourceRequirements(TIME, RESOURCE_MAX, usages),
  ];
  const weightedBooleanInequalityMap = new Map(weightedBooleanInequalities);
  const clauses = [
    ...cleqClauses.entries(),
    ...c2Clauses.entries(),
    ...cMaxClauses.entries(),
  ];
  const clauseMap = new Map(clauses);

  function showImplied(status: PropagatorStatus): string[] {
    if (status.status === "propagating" || status.status === "propagated") {
      return status.implications.map(({ name, value }) => {
        return `➛ ${name}=${value}`;
      });
    } else {
      return [status.status.toString()];
    }
  }

  const conflictExample1: [string, boolean][] = [
    ["[D ≤ 2]", true],
    ["[V ≤ 1]", true],
    ["A0", true],
    ["E5", true],
    ["[G ≤ 1]", true],
  ];
  const conflictExample2: [string, boolean][] = [
    ["[D ≤ 2]", true],
    ["[V ≤ 1]", true],
    ["[G ≤ 1]", true],
  ];

  type SolveState = {
    searchStack: [string, boolean][];
    learnedClauses: [string, Clause][];
    rupResult: [string, Value][];
    processResult: boolean | undefined;
  };
  let solveState: SolveState = $state({
    ...defaultSolveState(),
    searchStack: conflictExample2,
  });

  function defaultSolveState(): SolveState {
    return {
      searchStack: [],
      learnedClauses: [],
      rupResult: [],
      processResult: undefined,
    };
  }

  const learnedClauseMap = $derived(new Map(solveState.learnedClauses));

  const lastSearch: [string, boolean] | undefined = $derived(
    solveState.searchStack.at(-1),
  );
  type AntecedentType = "clause" | "weightedBooleanInequality" | "none";
  // Basically a list of assignments
  type Reason = [string, boolean][];
  type Propagation = {
    antecedent: string;
    antecedentType: AntecedentType;
    implied: { name: string; value: boolean };
    reason: Reason;
    decisionLevel: number;
  };

  const problemPropagators = (clauses as [string, Propagator][]).concat(
    weightedBooleanInequalities,
  );
  const propagators = $derived(
    problemPropagators.concat(solveState.learnedClauses),
  );

  /**
   * Based on the given state, run all propagators once. Does not modify the state, only returns the propagations implied by the current state.
   * If a conflict is detected, it returns the conflicting propagator. Since the other propagations are not yet applied, the conflict can be
   * fully explained by propagations already present in the state.
   */
  function propagate(
    state: Map<string, boolean>,
    propagators: [string, Propagator][],
    decisionLevel?: number,
  ):
    | { emptyClause: true; nogood: Nogood; propagator: [string, Propagator] }
    | Propagation[] {
    const propagations: Propagation[] = [];

    for (const [propName, propagator] of propagators) {
      let result: PropagatorStatus;
      let antecedentType: AntecedentType = "clause";
      if (
        "type" in propagator &&
        propagator.type === "weightedBooleanInequality"
      ) {
        result = weightedBooleanInequalityResolve(propagator, state);
        antecedentType = "weightedBooleanInequality";
      } else if (!("type" in propagator)) {
        result = clauseResolve(propagator, state);
      } else {
        throw new Error("Unreachable!");
      }
      if (result.status === "propagated" || result.status === "propagating") {
        propagations.push(
          ...result.implications.map((i) => {
            return {
              antecedent: propName,
              antecedentType,
              implied: i,
              reason: result.reason,
              decisionLevel: decisionLevel == null ? -1 : decisionLevel,
            };
          }),
        );
      } else if (result.status === false) {
        return {
          emptyClause: true,
          nogood: result.nogood,
          propagator: [propName, propagator],
        };
      }
    }
    return propagations;
  }

  function showConjunction(conjunction: [string, boolean][]): string {
    return conjunction
      .map(([v, c]) => {
        if (c) {
          return v;
        } else {
          return `¬${v}`;
        }
      })
      .join("∧");
  }

  function traverseTrail(
    trail: Propagation[],
    until: number,
    map: Map<string, number>,
    target: string,
  ): [Propagation, number] | null {
    if (until > trail.length) {
      throw new Error("Cannot start beyond trail length!");
    }

    for (let i = until - 1; i >= 0; i--) {
      const trailEntry = trail[i];
      map.set(trailEntry.implied.name, i);
      if (trailEntry.implied.name === target) {
        return [trailEntry, i];
      }
    }

    return null;
  }

  type ConflictNode = {
    variable: string;
    value: boolean;
    decisionLevel: number;
  };
  type ConflictEdge = { source: string; target: string; propName: string };
  // reasonFor is the variable the variables are reasons for, reasonPropName is the propagator in which they propagate as reasons
  type ReasonPropagation = Propagation & {
    reasonFor: string;
    reasonPropName: string;
  };

  /**
   * This function takes in a partially completed `trailMap`, which maps variables to the index in the trail
   * where they are assigned, and finds each variable and returns the propagation that assigned that variable.
   * Note that it never retraverses anything, it just keeps recording everything in the map, meaning any variable
   * it passed will be in the map and require no further traversal.
   * `reasonFor` is the variable name that was propagated due to the assignments of the variables in the `variables`, while `reasonPropName` is the propagator that did that propagation.
   */
  function getPropagations(
    trailMap: Map<string, number>,
    trail: Propagation[],
    trailPosition: number,
    reasonFor: string,
    reasonPropName: string,
    variables: string[],
  ): { propagations: ReasonPropagation[]; newTrailPosition: number } {
    let propagations: ReasonPropagation[] = [];
    let newTrailPosition = trailPosition;
    for (const variable of variables) {
      let trailIndex = trailMap.get(variable);
      let reasonPropagation: Propagation;
      if (trailIndex == null) {
        const traverseResult = traverseTrail(
          trail,
          newTrailPosition,
          trailMap,
          variable,
        );
        if (traverseResult == null) {
          throw new Error(`Cannot find ${variable}`);
        }
        reasonPropagation = traverseResult[0];
        newTrailPosition = traverseResult[1];
        trailIndex = newTrailPosition;
      } else {
        reasonPropagation = trail[trailIndex];
      }
      propagations.push({ ...reasonPropagation, reasonFor, reasonPropName });
    }

    return { propagations, newTrailPosition };
  }

  function updateGraph(
    nodes: ConflictNode[],
    edges: ConflictEdge[],
    usedPropagators: Set<string>,
    finalNogood: Nogood,
    seenVariables: Set<string>,
    propagations: ReasonPropagation[],
    conflictDecisionLevel: number,
    state: {
      backjumpLevel: number;
      uipDone: boolean;
    },
  ): ReasonPropagation[] {
    const unseenDecisionPropagations: ReasonPropagation[] = [];

    for (const p of propagations) {
      edges.push({
        source: p.implied.name,
        target: p.reasonFor,
        propName: p.reasonPropName,
      });
      usedPropagators.add(p.reasonPropName);

      if (seenVariables.has(p.implied.name)) {
        continue;
      }

      seenVariables.add(p.implied.name);

      nodes.push({
        variable: p.implied.name,
        value: p.implied.value,
        decisionLevel: p.decisionLevel,
      });

      if (!state.uipDone && p.decisionLevel < conflictDecisionLevel) {
        // These are always part of the UIP nogood
        finalNogood.push([p.implied.name, p.implied.value]);
        // We want to go to jump as far back as possible while our nogood propagates, so every part of the nogood must be assigned
        // So if was assigned at decision level X, we need to jump to at least X or later to ensure it's assigned
        state.backjumpLevel = Math.max(p.decisionLevel, state.backjumpLevel);
      } else if (p.decisionLevel === conflictDecisionLevel) {
        unseenDecisionPropagations.push(p);
      }
    }

    return unseenDecisionPropagations;
  }

  /**
   * `nogood` is the is the list of variable assignments that results in a conflict and `propName` is the name
   * of the propagator that results in the conflict. Note that this can be anything, it's only used to build
   * the returned record.
   */
  function analyzeConflict(
    nogood: Nogood,
    propName: string,
    trail: Propagation[],
  ) {
    // This implementation of conflict analysis, in the worst case, traverses the entire trail once
    let reasonTrailPosition = trail.length;
    const conflictDecisionLevel = trail.at(-1)!.decisionLevel;
    // Map of variable names to the index in the trail where they are assigned
    const trailMap = new Map<string, number>();

    // It gets the propagations that assigned the variables mentioned in the nogood
    const { propagations, newTrailPosition } = getPropagations(
      trailMap,
      trail,
      reasonTrailPosition,
      "empty",
      propName,
      nogood.map(([v]) => v),
    );
    // All entries in the trail after `reasonTrailPosition` have already been recorded in the trail map
    reasonTrailPosition = newTrailPosition;

    const nodes: ConflictNode[] = [
      { variable: "empty", value: false, decisionLevel: conflictDecisionLevel },
    ];
    const edges: ConflictEdge[] = [];
    const usedPropagators = new Set([propName]);
    const seenVariables = new Set<string>();
    const finalNogood: Nogood = [];

    // Put in object so it can be mutated
    const state = {
      uipDone: false,
      backjumpLevel: 0,
    };

    const newUnseen = updateGraph(
      nodes,
      edges,
      usedPropagators,
      finalNogood,
      seenVariables,
      propagations,
      conflictDecisionLevel,
      state,
    );

    const unseenCurrentAssignments = new Map<string, boolean>(
      newUnseen.map((p) => [p.implied.name, p.implied.value]),
    );

    for (let i = trail.length - 1; i >= 0; i--) {
      const trailEntry = trail[i];

      if (!unseenCurrentAssignments.has(trailEntry.implied.name)) {
        continue;
      }

      unseenCurrentAssignments.delete(trailEntry.implied.name);

      const { propagations, newTrailPosition } = getPropagations(
        trailMap,
        trail,
        reasonTrailPosition,
        trailEntry.implied.name,
        trailEntry.antecedent,
        trailEntry.reason.map(([v]) => v),
      );
      if (trailEntry.reason.length === 0) {
        usedPropagators.add(trailEntry.antecedent);
      }
      reasonTrailPosition = newTrailPosition;

      const newUnseen = updateGraph(
        nodes,
        edges,
        usedPropagators,
        finalNogood,
        seenVariables,
        propagations,
        conflictDecisionLevel,
        state,
      );
      for (const u of newUnseen) {
        unseenCurrentAssignments.set(u.implied.name, u.implied.value);
      }

      if (!state.uipDone && unseenCurrentAssignments.size === 1) {
        let [variable, value] = unseenCurrentAssignments
          .entries()
          .next().value!;
        finalNogood.push([variable, value]);
        // We still want to record the rest for the sake of the graph
        state.uipDone = true;
      }
    }

    // learned clause is the negation of a nogood
    const learnedClause: Clause = finalNogood.map(([v, c]) => [!c, v]);

    console.log(
      `analyzed used: ${[...usedPropagators.entries()].map(([v]) => v)}`,
    );

    return {
      nodes,
      edges,
      usedPropagators,
      finalNogood,
      backjumpLevel: state.backjumpLevel,
      learnedClause,
    };
  }

  function updateTrailState(
    propagations: Propagation[],
    state: Map<string, boolean>,
    trail: Propagation[],
  ) {
    for (const p of propagations) {
      let currentValue = state.get(p.implied.name);
      if (currentValue === undefined) {
        // In case the currentValue matches, no problem and we don't need to set again
        // If it doesn't match, then it should lead to a conflict when we propagate again

        // return { ...p, conflict: true }
        state.set(p.implied.name, p.implied.value);
        trail.push(p);
      }
    }
  }

  type Nogood = [string, boolean][];

  /** The propagation round that leads to a conflict is not reflected in the state. It mutates the provided
   * `state` and `trail`. If there is a conflict, the `state` will immediately lead to a conflict in a single
   * propagation round and `trail` contains all entries that lead to the `state`.
   */
  function propagateFixpoint(
    state: Map<string, boolean>,
    propagators: [string, Propagator][],
    trail: Propagation[],
    decisionLevel?: number,
  ):
    | { emptyClause: true; nogood: Nogood; propagator: [string, Propagator] }
    | "success" {
    let propagationResult = propagate(state, propagators, decisionLevel);

    const consistentPropagations: Propagation[] = [];

    // After you do a propagate, you know the entries in the trail make a consistent state

    const newState = new Map([...state.entries()]);

    if ("emptyClause" in propagationResult) {
      return propagationResult;
    } else {
      updateTrailState(propagationResult, newState, consistentPropagations);
    }

    while (propagationResult.length > 0) {
      propagationResult = propagate(newState, propagators, decisionLevel);
      if ("emptyClause" in propagationResult) {
        trail.push(...consistentPropagations);
        return propagationResult;
      } else {
        updateTrailState(propagationResult, newState, consistentPropagations);
      }
    }

    updateTrailState(consistentPropagations, state, trail);
    return "success";
  }

  const [propagated, trail, conflict] = $derived.by(() => {
    const state = new Map<string, boolean>();
    let i = 0;
    const trail: Propagation[] = [];
    const result = propagateFixpoint(state, propagators, trail, 0);
    if (result !== "success") {
      return [state, trail, result];
    }

    for (const [name, value] of solveState.searchStack) {
      i += 1;
      trail.push({
        antecedent: "search",
        antecedentType: "none",
        reason: [],
        decisionLevel: i,
        implied: { name, value },
      });
      state.set(name, value);

      const result = propagateFixpoint(state, propagators, trail, i);
      if (result !== "success") {
        return [state, trail, result];
      }
    }

    return [state, trail, null];
  });

  const activitiesByDurationDesc = [...durations.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([activity, duration], index) => {
      return { activity, duration, index };
    });
  const activityIndexMap = new Map(
    activitiesByDurationDesc.map((a) => [a.activity, a.index]),
  );

  const levels = $derived.by(() => {
    // based on index
    const levels = activitiesByDurationDesc.map((_) => 0);

    for (const t of times) {
      // indexes that are active, sorted from low to high index
      const active = activitiesByDurationDesc.flatMap((a) => {
        if (propagated.get(activeName(a.activity, t)) ?? false) {
          return [a.index];
        } else {
          return [];
        }
      });

      if (active.length > 1) {
        const usedLevels = new Set<number>();
        for (const a of active) {
          if (usedLevels.has(levels[a])) {
            levels[a] += 1;
          }
          usedLevels.add(levels[a]);
        }
      }
    }

    return new Map(
      activitiesByDurationDesc.map((a) => {
        return [a.activity, levels[a.index]];
      }),
    );
  });

  const activityColors = [
    "bg-red-600",
    "bg-blue-600",
    "bg-green-600",
    "bg-purple-600",
    "bg-yellow-600",
    "bg-teal-600",
  ];

  function showPropagator(propagator: Propagator) {
    if ("type" in propagator) {
      return showIneq(propagator);
    } else {
      return showClause(propagator);
    }
  }

  function showPropagation(propagation: Propagation) {
    let showValue = `${propagation.implied.name}=${propagation.implied.value}`;
    if (propagation.antecedentType === "clause") {
      let antecedentClause = clauseMap.get(propagation.antecedent);
      if (antecedentClause === undefined) {
        antecedentClause = learnedClauseMap.get(propagation.antecedent);
      }
      if (antecedentClause !== undefined) {
        return `${showClause(antecedentClause)} ➛ ${showValue} @ ${propagation.decisionLevel}`;
      }
    } else if (propagation.antecedentType === "weightedBooleanInequality") {
      const antecedentIneq = weightedBooleanInequalityMap.get(
        propagation.antecedent,
      );
      if (antecedentIneq !== undefined) {
        return `${showIneq(antecedentIneq)} ➛ ${showValue} @ ${propagation.decisionLevel}`;
      }
    }

    return `search ➛ ${showValue} @ ${propagation.decisionLevel}`;
  }

  function normalizeClause(clause: Clause): Clause {
    console.log(`to normalize: ${JSON.stringify(clause)}`);
    const srtd = clause.toSorted(([_1, l1], [_2, l2]) => {
      return l1.localeCompare(l2);
    });
    console.log(`sorted: ${JSON.stringify(srtd)}`);
    return srtd;
  }

  /** If `rup`, `propName` is the name of the propagator that propagated the final conflict. */
  function checkRUP(clause: Clause, propagators: [string, Propagator][]) {
    // A clause is RUP w.r.t a formula (the other propagators), if unit propagation (or just general propagation in our case) derives a conflict
    // on the negation of the clause conjunct with the formula
    const negatedLiteralClauses: [string, Clause][] = clause.map(
      ([c, v], i) => [`rup_${i}`, [[!c, v]]],
    );

    const state = new Map<string, boolean>();
    const trail: Propagation[] = [];
    const result = propagateFixpoint(
      state,
      [...propagators, ...negatedLiteralClauses],
      trail,
      0,
    );

    if (result !== "success") {
      return {
        rup: true as true,
        trail,
        nogood: result.nogood,
        propName: result.propagator[0],
      };
    } else {
      return { rup: false as false };
    }
  }

  let graphInstance: cytoscape.Core | undefined = $state();

  onMount(() => {
    cytoscape.use(dagre);
  });

  function disableGraph() {
    graphInstance = undefined;
  }

  function renderGraph(
    container: HTMLDivElement,
    nodes: ConflictNode[],
    edges: ConflictEdge[],
  ) {
    const elements: {
      data: { id: string; source?: string; target?: string; label?: string };
    }[] = [];

    for (const n of nodes) {
      let label;
      if (n.variable === "empty") {
        label = "⊥";
      } else {
        label = `${n.value ? "" : "¬"}${n.variable} @ ${n.decisionLevel}`;
      }
      elements.push({ data: { id: n.variable, label } });
    }
    for (const e of edges) {
      elements.push({
        data: {
          id: `${e.source}-${e.target}`,
          source: e.source,
          target: e.target,
          label: e.propName,
        },
      });
    }

    graphInstance = cytoscape({
      container,
      elements,
      style: [
        {
          selector: "node",
          style: {
            label: "data(label)",
            "font-size": 8,
          },
        },
        {
          selector: "edge",
          style: {
            label: "data(label)",
            width: 4,
            "font-size": 7,
            "curve-style": "bezier",
            "line-color": "#ccc",
            "target-arrow-color": "#ccc",
            "target-arrow-shape": "triangle",
          },
        },
      ],
      layout: {
        name: "dagre",
        // directed: true,
        // circle: true
      },
    });
  }

  const propagatedDomain = $derived.by(() => {
    const activityBounds: { activity: string; min: number; max: number }[] = [];
    for (const activity of activities) {
      let max = TIME;
      for (let t = TIME; t >= 0; t--) {
        const value = propagated.get(atomName(activity, t));
        if (value === true) {
          max = t;
        }
      }
      let min = 0;
      for (let t = 0; t <= TIME; t++) {
        const value = propagated.get(atomName(activity, t));
        if (value === false) {
          min = t + 1;
        }
      }
      activityBounds.push({ activity, min, max });
    }

    return activityBounds;
  });

  function parseRawClauses(
    text: string,
  ):
    | { parsed: true; parsedClauses: Clause[] }
    | { parsed: false; reason: string } {
    const parsedClauses: Clause[] = [];
    const lines = text.split("\n");
    for (let lnI = 0; lnI < lines.length; lnI++) {
      const ln = lines[lnI];
      const clause: Clause = [];
      const literals = ln.split(" v ");
      for (const l of literals) {
        const negated = l.startsWith(`~`);
        const vName = negated ? l.slice(1) : l;
        const exists = vars.has(vName);
        if (!exists) {
          return {
            parsed: false,
            reason: `Variable with name ${vName} at line ${lnI} does not exist!`,
          };
        }
        clause.push([!negated, vName]);
      }

      const normalizedClause = normalizeClause(clause);
      parsedClauses.push(normalizedClause);
    }

    return { parsed: true, parsedClauses };
  }

  function convertClausesToRaw(clauses: Clause[]): string {
    return clauses
      .map((c) => c.map(([c, v]) => (c ? v : `~${v}`)).join(" v "))
      .join("\n");
  }

  const undetermined = $derived(
    [...vars.values()].filter((v) => v === "𝔲").length,
  );
  const isUnsat = $derived(
    conflict !== null && solveState.searchStack.length === 0,
  );
  const isSat = $derived(undetermined === 0 && conflict === null);
  const inConflict = $derived(conflict !== null);

  function processLearnedClauses() {
    // For now this does nothing if we are not UNSAT

    // We assume all learned clauses are normalized!

    // For the algorithm see Flippo 2024
    // There they analyze nogoods, here we analyze learned clauses, which is analagous

    const processedLearnedClauses: [string, Clause][] = [];

    const propagators: [string, Propagator][] = [
      ...problemPropagators,
      ...solveState.learnedClauses,
      ["empty", []],
    ];
    let marked = new Set(["empty"]);

    // We have to add the empty clause so that we check which ones were needed to derive it
    const clausesToCheck: [string, Clause][] = [
      ...solveState.learnedClauses,
      ["empty", []],
    ];

    for (let i = clausesToCheck.length - 1; i >= 0; i--) {
      const [cName, learnedClause] = clausesToCheck[i];
      console.log(`proc ${cName}`);
      console.log(`marked ${[...marked.entries()].map(([e1, _]) => e1)}`);
      // Remove the current propagator from the list of propagators
      const removed = propagators.pop()!;
      if (removed[0] !== cName) {
        throw new Error(
          "programming error: we should always remove the one we are iterating on",
        );
      }
      if (!marked.has(cName)) {
        continue;
      }

      const checkResult = checkRUP(learnedClause, propagators);

      //console.log(`trail: ${checkResult.trail?.map(e => JSON.stringify(e)).join('\n')}`)

      if (checkResult.rup) {
        const { usedPropagators } = analyzeConflict(
          checkResult.nogood,
          checkResult.propName,
          checkResult.trail,
        );
        marked = marked.union(usedPropagators);
        // We don't want the empty clause in our result list
        if (cName !== "empty") {
          processedLearnedClauses.push([cName, learnedClause]);
        }
      } else {
        return { rup: false as false };
      }
    }

    // They are now in the opposite order, so we reverse them back
    processedLearnedClauses.reverse();

    return { rup: true as true, processedLearnedClauses };
  }

  function verifyLearnedClauses(): {
    correct: boolean;
    result: [string, Value][];
  } {
    // Note in the verify step we don't do trimming, so we just go through it in forward direction
    // We assume all learnedClauses are necessary
    const propagators = [...problemPropagators];

    const rupResult: [string, Value][] = [
      ...new Array(solveState.learnedClauses.length).keys(),
    ].map((i) => [solveState.learnedClauses[i][0], "𝔲"]);

    let correct = true;
    for (let i = 0; i < solveState.learnedClauses.length; i++) {
      const [cName, learnedClause] = solveState.learnedClauses[i];
      const checkResult = checkRUP(learnedClause, propagators);
      rupResult[i] = [cName, checkResult.rup];
      // Include the clause so the next clause can use it
      propagators.push([cName, learnedClause]);

      correct = checkResult.rup;
    }

    return { correct, result: rupResult };
  }

  let editLearnedClauses = $state(false);
  let learnedClausesTextArea = $state("");

  const parsedLearnedClauses = $derived(
    parseRawClauses(learnedClausesTextArea),
  );

  let showConstraints = $state(false);
</script>

<div class="lg:mx-auto lg:max-w-4xl mx-8 rounded p-2 bg-white">
  {#each vars as [varName, _]}
    {@const propagateValue = propagated.get(varName) ?? "𝔲"}
    {@const lastValue =
      lastSearch !== undefined && lastSearch[0] === varName
        ? lastSearch[1]
        : "𝔲"}
    {@const isLastSearch =
      lastSearch !== undefined && lastSearch[0] === varName}
    {@const enabled = isLastSearch || (!inConflict && propagateValue === "𝔲")}
    <button
      disabled={!enabled}
      class={"p-1 rounded w-28 disabled:cursor-not-allowed " +
        (enabled
          ? "bg-gray-200"
          : propagateValue === "𝔲"
            ? "bg-gray-400"
            : "bg-gray-500")}
      onclick={() => {
        let next: boolean;
        if (lastValue === true) {
          next = false;
        } else if (lastValue === "𝔲") {
          next = false;
        } else {
          next = true;
        }

        if (lastValue === "𝔲") {
          solveState.searchStack.push([varName, next]);
        } else {
          solveState.searchStack[solveState.searchStack.length - 1] = [
            varName,
            next,
          ];
        }
      }}>{varName}={propagateValue}</button
    >
  {/each}
  <br /><br />

  <div class="flex flex-row gap-1">
    <button
      onclick={() => {
        solveState = defaultSolveState();
      }}
      class="bg-gray-200 p-1 rounded w-20 h-28 disabled:bg-gray-500 disabled:cursor-not-allowed"
      >Reset</button
    >
    <button
      onclick={() => {
        solveState = {
          ...defaultSolveState(),
          searchStack: conflictExample1,
        };
      }}
      class="bg-gray-200 p-1 rounded w-20 h-28 disabled:bg-gray-500 disabled:cursor-not-allowed"
      >Set to conflict example 1</button
    >
    <button
      onclick={() => {
        solveState = {
          ...defaultSolveState(),
          searchStack: conflictExample2,
        };
      }}
      class="bg-gray-200 p-1 rounded w-20 h-28 disabled:bg-gray-500 disabled:cursor-not-allowed"
      >Set to conflict example 2</button
    >
  </div>

  <div class="mt-4 flex flex-col gap-2">
    <button
      class="bg-gray-200 p-1 rounded w-36"
      onclick={() => {
        solveState = {
          ...solveState,
          rupResult: verifyLearnedClauses().result,
          processResult: undefined,
        };
      }}>Verify RUP learned clauses</button
    >
    {#if isUnsat}
      <button
        class="bg-gray-200 p-1 rounded w-36"
        onclick={() => {
          const processResult = processLearnedClauses();
          // Note we don't provide feedback if not RUP
          if (processResult.rup) {
            solveState = {
              ...solveState,
              processResult: true,
              learnedClauses: processResult.processedLearnedClauses,
              rupResult: processResult.processedLearnedClauses.map(
                ([cName, _]) => [cName, true],
              ),
            };
          } else {
            solveState = {
              ...solveState,
              processResult: false,
              rupResult: [],
            };
          }
        }}>Process learned clauses</button
      >
      {#if solveState.processResult === true}
        <span>Processed succesfully!</span>
      {:else if solveState.processResult === false}
        <span>Failed to process!</span>
      {/if}
      <strong class="text-lg"
        >Status: Conflict by propagation with learned clauses at root level.
        UNSAT!</strong
      >
    {:else if inConflict}
      <strong
        >Status: Conflict by propagation with learned clauses and search!</strong
      >
    {:else if isSat}
      <strong class="text-lg"
        >Status: All variables determined without conflicts. SAT!</strong
      >
    {/if}
  </div>

  <div class="mt-4">
    <div class="mb-2">
      Learned clauses: <button
        onclick={() => {
          if (editLearnedClauses && parsedLearnedClauses.parsed) {
            solveState = {
              ...solveState,
              rupResult: [],
              learnedClauses: parsedLearnedClauses.parsedClauses.map((c) => [
                showClause(c),
                c,
              ]),
            };
            editLearnedClauses = false;
          } else if (!editLearnedClauses) {
            learnedClausesTextArea = convertClausesToRaw(
              solveState.learnedClauses.map(([_, c]) => c),
            );
            editLearnedClauses = true;
          }
        }}
        class="bg-gray-200 p-1 rounded w-16"
        >{editLearnedClauses ? "Load" : "Edit"}</button
      >
    </div>
    {#if !editLearnedClauses}
      <div class="flex flex-col">
        {#each solveState.learnedClauses as [clauseShow, _], i}
          {@const rupResult = solveState.rupResult[i] ?? [clauseShow, "𝔲"]}
          {@const isRup = rupResult[0] === clauseShow ? rupResult[1] : "𝔲"}
          <div>
            <span>{clauseShow}</span>
            <span class="ml-2">
              {#if isRup === true}
                <span class="text-green-600">RUP ✓</span>
              {:else if isRup === false}
                <span class="text-red-400">not RUP! ✗</span>
              {/if}
            </span>
          </div>
        {:else}
          None.
        {/each}
      </div>
    {:else}
      <textarea
        rows="20"
        cols="80"
        class="border-2 bg-gray-50"
        bind:value={learnedClausesTextArea}
      ></textarea>
      <div class="text-red-400">
        {parsedLearnedClauses.parsed ? "" : parsedLearnedClauses.reason}
      </div>
    {/if}
  </div>

  <br /><br />

  <div>
    Stack:

    <div class="flex flex-col">
      {#each solveState.searchStack as [varName, varValue]}
        <span>{varName}={varValue}</span>
      {/each}
    </div>
  </div>

  <br />

  <button
    onclick={() => solveState.searchStack.pop()}
    class="bg-gray-200 p-1 rounded w-24 disabled:bg-gray-500 disabled:cursor-not-allowed"
    >Backtrack</button
  >

  <br /><br /><br />

  <!-- Ensure number of rows matches max resource usage -->
  <div class="grid grid-rows-2 grid-flow-col justify-start">
    {#each times as t}
      {#each [...Array(RESOURCE_MAX).keys()] as _, i}
        {@const rowNumber = RESOURCE_MAX - i - 1}
        {@const allActive = activitiesByDurationDesc.filter((a) => {
          return (
            (propagated.get(activeName(a.activity, t)) ?? false) &&
            levels.get(a.activity) === rowNumber
          );
        })}
        {@const beyondMax = t > MAX_TIME}
        <span
          class={"w-16 h-16 border flex justify-center items-center " +
            (allActive.length > 0 ? activityColors[allActive[0].index] : "")}
          >{allActive.length > 0
            ? allActive[0].activity
            : beyondMax
              ? "X"
              : ""}</span
        >
      {/each}
    {/each}
  </div>

  <br /><br />

  <div class="flex flex-col">
    {#each propagatedDomain as { activity, min, max }}
      {@const duration = durations.get(activity)!}
      {@const activityIndex = activityIndexMap.get(activity)!}
      <div>{min} {"<="} {activity} {"<="} {max}; duration={duration}</div>
      <ActivityRange
        {times}
        {propagated}
        {min}
        max={max + duration}
        {activity}
        color={activityColors[activityIndex]}
        maxTime={MAX_TIME}
      ></ActivityRange>
    {/each}
  </div>

  <br /><br />

  <div>
    Trail:

    <div class="flex flex-col">
      {#each trail as trailEntry}
        {@const showString = showPropagation(trailEntry)}
        <span>
          {#if showString.includes("search")}
            <strong>{showString}</strong>
          {:else if learnedClauseMap.has(trailEntry.antecedent)}
            <em>{showString}</em>
          {:else}
            {showString}
          {/if}
        </span>
      {/each}
      {#if conflict !== null}
        {@const {
          nogood,
          propagator: [propName, propagator],
        } = conflict}
        {@const { nodes, edges, finalNogood, backjumpLevel, learnedClause } =
          analyzeConflict(nogood, propName, trail)}
        <span>{propName}: {showPropagator(propagator)}</span>
        <span class="text-lg text-red-500 font-bold"> leads to conflict! </span>
        {#if solveState.searchStack.length !== 0}
          <span>
            conflict nogood: {showConjunction(nogood)}
          </span>
          <span>
            uip nogood: {showConjunction(finalNogood)}
          </span>
          <span>
            backjump to level: {backjumpLevel}
          </span>
          <strong>
            with learned clause: {showClause(learnedClause)}
          </strong>
          <button
            onclick={() => {
              const normalizedLearnedClause = normalizeClause(learnedClause);
              const clauseEntry: [string, Clause] = [
                showClause(normalizedLearnedClause),
                normalizedLearnedClause,
              ];

              solveState = {
                ...defaultSolveState(),
                learnedClauses: [...solveState.learnedClauses, clauseEntry],
                searchStack: solveState.searchStack.slice(0, backjumpLevel),
                rupResult: [],
              };
            }}
            class="bg-gray-200 p-1 rounded w-24 h-14">Learn clause</button
          >
        {:else}
          <div><strong>Root conflict. UNSAT!</strong></div>
        {/if}
        <div class="flex flex-row gap-1">
          <button
            onclick={() =>
              trailGraph !== undefined
                ? renderGraph(trailGraph, nodes, edges)
                : {}}
            class="bg-gray-200 p-1 rounded w-24 h-14">Rerender graph</button
          >
          {#if graphInstance != null}
            <button
              onclick={disableGraph}
              class="bg-gray-200 p-1 rounded w-24 h-14">Close graph</button
            >
          {/if}
        </div>
        <div
          class={"mt-2 w-full h-[900px] bg-white " +
            (graphInstance !== undefined ? "" : "invisible")}
          bind:this={trailGraph}
        ></div>
      {/if}
    </div>
  </div>

  <br /><br />

  <button
    onclick={() => (showConstraints = !showConstraints)}
    class="bg-gray-200 p-1 rounded w-24 disabled:bg-gray-500 disabled:cursor-not-allowed"
    >Toggle constraints</button
  >
  {#if showConstraints}
    <div class="grid grid-cols-[1fr_3fr]">
      {#each clauses as [cName, clause]}
        {@const resolved = clauseResolve(clause, propagated)}
        <span>
          {cName}:
        </span>
        <span>
          {showClause(clause)} : {showImplied(resolved)}
        </span>
      {/each}
      {#each weightedBooleanInequalities as [ineqName, ineq]}
        {@const resolved = weightedBooleanInequalityResolve(ineq, propagated)}
        <span>
          {ineqName}:
        </span>
        <span>
          {showIneq(ineq)} : {showImplied(resolved)}
        </span>
      {/each}
    </div>
  {/if}
</div>
