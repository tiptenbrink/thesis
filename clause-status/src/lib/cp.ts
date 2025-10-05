
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


// function traverseTrail(
//   trail: Propagation[],
//   until: number,
//   map: Map<string, number>,
//   target: string,
// ): [Propagation, number] | null {
//   if (until > trail.length) {
//     throw new Error("Cannot start beyond trail length!");
//   }

//   for (let i = until - 1; i >= 0; i--) {
//     const trailEntry = trail[i];
//     map.set(trailEntry.implied.name, i);
//     if (trailEntry.implied.name === target) {
//       return [trailEntry, i];
//     }
//   }

//   return null;
// }

// type ConflictNode = {
//   variable: string;
//   value: boolean;
//   decisionLevel: number;
// };
// type ConflictEdge = { source: string; target: string; propName: string };
// // reasonFor is the variable the variables are reasons for, reasonPropName is the propagator in which they propagate as reasons
// type ReasonPropagation = Propagation & {
//   reasonFor: string;
//   reasonPropName: string;
// };

// /**
//  * This function takes in a partially completed `trailMap`, which maps variables to the index in the trail
//  * where they are assigned, and finds each variable and returns the propagation that assigned that variable.
//  * Note that it never retraverses anything, it just keeps recording everything in the map, meaning any variable
//  * it passed will be in the map and require no further traversal.
//  * `reasonFor` is the variable name that was propagated due to the assignments of the variables in the `variables`, while `reasonPropName` is the propagator that did that propagation.
//  */
// function getPropagations(
//   trailMap: Map<string, number>,
//   trail: Propagation[],
//   trailPosition: number,
//   reasonFor: string,
//   reasonPropName: string,
//   variables: string[],
// ): { propagations: ReasonPropagation[]; newTrailPosition: number } {
//   let propagations: ReasonPropagation[] = [];
//   let newTrailPosition = trailPosition;
//   for (const variable of variables) {
//     let trailIndex = trailMap.get(variable);
//     let reasonPropagation: Propagation;
//     if (trailIndex == null) {
//       const traverseResult = traverseTrail(
//         trail,
//         newTrailPosition,
//         trailMap,
//         variable,
//       );
//       if (traverseResult == null) {
//         throw new Error(`Cannot find ${variable}`);
//       }
//       reasonPropagation = traverseResult[0];
//       newTrailPosition = traverseResult[1];
//       trailIndex = newTrailPosition;
//     } else {
//       reasonPropagation = trail[trailIndex];
//     }
//     propagations.push({ ...reasonPropagation, reasonFor, reasonPropName });
//   }

//   return { propagations, newTrailPosition };
// }

// function updateGraph(
//   nodes: ConflictNode[],
//   edges: ConflictEdge[],
//   usedPropagators: Set<string>,
//   finalNogood: Nogood,
//   seenVariables: Set<string>,
//   propagations: ReasonPropagation[],
//   conflictDecisionLevel: number,
//   state: {
//     backjumpLevel: number;
//     uipDone: boolean;
//   },
// ): ReasonPropagation[] {
//   const unseenDecisionPropagations: ReasonPropagation[] = [];

//   for (const p of propagations) {
//     edges.push({
//       source: p.implied.name,
//       target: p.reasonFor,
//       propName: p.reasonPropName,
//     });
//     usedPropagators.add(p.reasonPropName);

//     if (seenVariables.has(p.implied.name)) {
//       continue;
//     }

//     seenVariables.add(p.implied.name);

//     nodes.push({
//       variable: p.implied.name,
//       value: p.implied.value,
//       decisionLevel: p.decisionLevel,
//     });

//     if (!state.uipDone && p.decisionLevel < conflictDecisionLevel) {
//       // These are always part of the UIP nogood
//       finalNogood.push([p.implied.name, p.implied.value]);
//       // We want to go to jump as far back as possible while our nogood propagates, so every part of the nogood must be assigned
//       // So if was assigned at decision level X, we need to jump to at least X or later to ensure it's assigned
//       state.backjumpLevel = Math.max(p.decisionLevel, state.backjumpLevel);
//     } else if (p.decisionLevel === conflictDecisionLevel) {
//       unseenDecisionPropagations.push(p);
//     }
//   }

//   return unseenDecisionPropagations;
// }

// /**
//  * `nogood` is the is the list of variable assignments that results in a conflict and `propName` is the name
//  * of the propagator that results in the conflict. Note that this can be anything, it's only used to build
//  * the returned record.
//  */
// function analyzeConflict(
//   nogood: Nogood,
//   propName: string,
//   trail: Propagation[],
// ) {
//   // This implementation of conflict analysis, in the worst case, traverses the entire trail once
//   let reasonTrailPosition = trail.length;
//   const conflictDecisionLevel = trail.at(-1)!.decisionLevel;
//   // Map of variable names to the index in the trail where they are assigned
//   const trailMap = new Map<string, number>();

//   // It gets the propagations that assigned the variables mentioned in the nogood
//   const { propagations, newTrailPosition } = getPropagations(
//     trailMap,
//     trail,
//     reasonTrailPosition,
//     "empty",
//     propName,
//     nogood.map(([v]) => v),
//   );
//   // All entries in the trail after `reasonTrailPosition` have already been recorded in the trail map
//   reasonTrailPosition = newTrailPosition;

//   const nodes: ConflictNode[] = [
//     { variable: "empty", value: false, decisionLevel: conflictDecisionLevel },
//   ];
//   const edges: ConflictEdge[] = [];
//   const usedPropagators = new Set([propName]);
//   const seenVariables = new Set<string>();
//   const finalNogood: Nogood = [];

//   // Put in object so it can be mutated
//   const state = {
//     uipDone: false,
//     backjumpLevel: 0,
//   };

//   const newUnseen = updateGraph(
//     nodes,
//     edges,
//     usedPropagators,
//     finalNogood,
//     seenVariables,
//     propagations,
//     conflictDecisionLevel,
//     state,
//   );

//   const unseenCurrentAssignments = new Map<string, boolean>(
//     newUnseen.map((p) => [p.implied.name, p.implied.value]),
//   );

//   for (let i = trail.length - 1; i >= 0; i--) {
//     const trailEntry = trail[i];

//     if (!unseenCurrentAssignments.has(trailEntry.implied.name)) {
//       continue;
//     }

//     unseenCurrentAssignments.delete(trailEntry.implied.name);

//     const { propagations, newTrailPosition } = getPropagations(
//       trailMap,
//       trail,
//       reasonTrailPosition,
//       trailEntry.implied.name,
//       trailEntry.antecedent,
//       trailEntry.reason.map(([v]) => v),
//     );
//     if (trailEntry.reason.length === 0) {
//       usedPropagators.add(trailEntry.antecedent);
//     }
//     reasonTrailPosition = newTrailPosition;

//     const newUnseen = updateGraph(
//       nodes,
//       edges,
//       usedPropagators,
//       finalNogood,
//       seenVariables,
//       propagations,
//       conflictDecisionLevel,
//       state,
//     );
//     for (const u of newUnseen) {
//       unseenCurrentAssignments.set(u.implied.name, u.implied.value);
//     }

//     if (!state.uipDone && unseenCurrentAssignments.size === 1) {
//       let [variable, value] = unseenCurrentAssignments
//         .entries()
//         .next().value!;
//       finalNogood.push([variable, value]);
//       // We still want to record the rest for the sake of the graph
//       state.uipDone = true;
//     }
//   }

//   // learned clause is the negation of a nogood
//   const learnedClause: Clause = finalNogood.map(([v, c]) => [!c, v]);

//   console.log(
//     `analyzed used: ${[...usedPropagators.entries()].map(([v]) => v)}`,
//   );

//   return {
//     nodes,
//     edges,
//     usedPropagators,
//     finalNogood,
//     backjumpLevel: state.backjumpLevel,
//     learnedClause,
//   };
// }

// function updateTrailState(
//   propagations: Propagation[],
//   state: Map<string, boolean>,
//   trail: Propagation[],
// ) {
//   for (const p of propagations) {
//     let currentValue = state.get(p.implied.name);
//     if (currentValue === undefined) {
//       // In case the currentValue matches, no problem and we don't need to set again
//       // If it doesn't match, then it should lead to a conflict when we propagate again

//       // return { ...p, conflict: true }
//       state.set(p.implied.name, p.implied.value);
//       trail.push(p);
//     }
//   }
// }

// type Nogood = [string, boolean][];

// /** The propagation round that leads to a conflict is not reflected in the state. It mutates the provided
//  * `state` and `trail`. If there is a conflict, the `state` will immediately lead to a conflict in a single
//  * propagation round and `trail` contains all entries that lead to the `state`.
//  */
// function propagateFixpoint(
//   state: Map<string, boolean>,
//   propagators: [string, Propagator][],
//   trail: Propagation[],
//   decisionLevel?: number,
// ):
//   | { emptyClause: true; nogood: Nogood; propagator: [string, Propagator] }
//   | "success" {
//   let propagationResult = propagate(state, propagators, decisionLevel);

//   const consistentPropagations: Propagation[] = [];

//   // After you do a propagate, you know the entries in the trail make a consistent state

//   const newState = new Map([...state.entries()]);

//   if ("emptyClause" in propagationResult) {
//     return propagationResult;
//   } else {
//     updateTrailState(propagationResult, newState, consistentPropagations);
//   }

//   while (propagationResult.length > 0) {
//     propagationResult = propagate(newState, propagators, decisionLevel);
//     if ("emptyClause" in propagationResult) {
//       trail.push(...consistentPropagations);
//       return propagationResult;
//     } else {
//       updateTrailState(propagationResult, newState, consistentPropagations);
//     }
//   }

//   updateTrailState(consistentPropagations, state, trail);
//   return "success";
// }