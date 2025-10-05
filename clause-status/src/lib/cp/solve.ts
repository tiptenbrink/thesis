
import { atomName, type BooleanDomain, type Domain, type IntegerDomain, type Constraint, type LinearInequality, type ConstraintType, type Clause } from "./problem";

type Reason = [string, boolean][]

// type PropagatorStatus =
//     | {
//         status: true;
//       }
//     | {
//         status: false;
//         nogood: [string, boolean][];
//       }
//     | {
//         status: "propagating";
//         unresolved: string[];
//         reason: Reason;
//         implications: { name: string; value: boolean }[];
//       }
//     | {
//         status: "propagated";
//         reason: Reason;
//         implications: { name: string; value: boolean }[];
//       }
//     | {
//         status: "unresolved";
//         unresolved: string[];
//       };

function resolveValue(
  literal: [boolean, string],
  state: Map<string, boolean>,
): boolean | "𝔲" {
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

function clauseResolve(
  clause: Clause,
  state: Map<string, boolean>,
): PropagationResult {
  let unresolved: string[] = [];
  // In case there is one unresolved (when clause is unit), only that will have set this value
  let unitPropagatedValue = false;
  let trues: string[] = [];
  const reason: Reason = [];

  clause.literals.forEach(([constant, variable]) => {
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
      result: "noConflict",
      propagated: [{
        antecedent: {
          name: clause.name,
          type: "clause"
        },
        reason,
        result: { name: unresolved[0], value: unitPropagatedValue },
      }]
    };
    // trues.length != 0 || unresolved.length != 1
  } else if (unresolved.length >= 1) {
    return {
      result: "noConflict",
      propagated: []
    };
    // trues.length != 0 || unresolved.length == 0
  } else if (trues.length > 0) {
    return {
      result: "noConflict",
      propagated: []
    };
  } else {
    return {
      result: "conflict",
      conflict: {
        antecedent: {
          name: clause.name,
          type: "clause"
        },
        // suppose ¬x or y resolves to false
        // then the nogood is x=true and y=false, so the opposite of how the clause is defined
        reason: clause.literals.map(([c, v]) => [v, !c]),
      }
    };
  }
}

// function setBound(bound: "ub" | "lb", variable: string, value: number, domain: BooleanDomain | IntegerDomain | undefined = undefined): [boolean, string] | null {
//   // For now we don't check conflicts
//   if (domain?.type === 'integer') {
//     if (bound === 'ub') {
//       if (value >= domain.max) {
//         return null
//       }
//       return atomName(variable, value, 'leq')
//     } else if (bound === 'lb') {
//       if (value <= domain.min) {
//         return null
//       }
//       return atomName(variable, value, 'geq')
//     } else {
//       throw new Error("invalid bound")
//     }
//   } else if (domain?.type === 'boolean' || domain === undefined) {
//     if (bound === 'lb') {
//       if (value === 0) {
//         return null
//       }
//       return [true, variable]
//     } else if (bound === 'ub') {

//     } else {
//       throw new Error("invalid bound")
//     }

//     if (bound === 'lb' && value === 1) {
//       return [true, variable]
//     } else if (value === 0) {
//       return null
//     } else {
//       throw new Error("not implemented")
//     }
//   } else {
//     throw new Error("invalid domain")
//   }
// }

// Some truths
// If integer lower bound was set to be c, we must have representation of [x >= c] is propagated
// Similarly, if upper bound was set to c, we must have [x <= c] is propagated

function variableBounds(variable: string, domains: Map<string, Domain>, state: Map<string, boolean>): {
  lb: number,
  ub: number,
  lbReason: [string, boolean] | null,
  ubReason: [string, boolean] | null
} {
  const domain = domains.get(variable)

  if (domain === undefined || domain.type === 'boolean') {
    let value = (domain !== undefined ? domain.state : state.get(variable)) ?? '𝔲'

    if (value === '𝔲') {
      return { lb: 0, ub: 1, lbReason: null, ubReason: null }
    } else if (value) {
      return { lb: 1, ub: 1, lbReason: [variable, true], ubReason: null }
    } else {
      return { lb: 0, ub: 0, lbReason: null, ubReason: [variable, false] }
    }
  } else if (domain.type === 'integer') {
    let atomUb = atomName(variable, domain.max, "leq")
    let atomLb = atomName(variable, domain.min, "geq")
    return { lb: domain.min, ub: domain.max, lbReason: [atomLb[1], atomLb[0]], ubReason: [atomUb[1], atomUb[0]] }
  } else {
    throw new Error("invalid domain")
  }
}

// We assume the caller checks that the value is consistent, it does not have to check if it's different/redundant
function setVariableBound(bound: 'ub' | 'lb', variable: string, value: number, domains: Map<string, Domain>, state: Map<string, boolean>): [string, boolean] | null {
  const domain = domains.get(variable)

  if (domain === undefined || domain.type === 'boolean') {
    let currentValue = (domain !== undefined ? domain.state : state.get(variable)) ?? '𝔲'
    if (currentValue !== '𝔲') {
      return null
    }

    if (bound === 'lb' && value === 1) {
      return [variable, true]
    } else if (bound === 'ub' && value === 0) {
      return [variable, false]
    }

    return null
  } else if (domain.type === 'integer') {
    if (bound === 'ub' && value < domain.max) {
      let atom = atomName(variable, value, "leq")

      return [atom[1], atom[0]]
    } else if (bound === 'lb' && value > domain.min) {
      let atom = atomName(variable, value, "geq")

      return [atom[1], atom[0]]
    }
    
    return null
  } else {
    throw new Error("invalid domain")
  }
}

export function propagateLinearInequality(
  ineq: LinearInequality,
  domains: Map<string, Domain>,
  state: Map<string, boolean>
): PropagationResult {
  let minSum = 0;
  const reason: Reason = []
  for (const [weight, v] of ineq.lhs) {
    let { lb, ub, lbReason, ubReason } = variableBounds(v, domains, state) 
    if (weight >= 0) {
      if (lb < 0) {
        throw new Error("not implemented")
      }

      // Above assumptions means further vars can only increase the lhs, so if we are above rhs we surely will be at the end
      const added = (lb * weight)
      if (added > 0 && lbReason !== null) {
        reason.push(lbReason)
      }

      minSum += added

      if (minSum > ineq.rhs) {
        return {
          result: "conflict",
          conflict: {
            antecedent: {
              name: ineq.name,
              type: "linearInequality"
            },
            reason,
          }
        }
      } else if (minSum < ineq.rhs) {
        const upAdded = (ub * weight)
        // remove what we added, then add upAdded
        if (minSum - added + upAdded > ineq.rhs) {
          const space = ineq.rhs - minSum + added
          const maxUb = Math.floor(space / weight)
          if (maxUb < lb) {
            // logic error sanity check, this should have already caused minSum > ineq.rhs
            throw new Error("logic error!")
          }

          let propagatedBound = setVariableBound('ub', v, maxUb, domains, state)

          let propagated: Propagation[] = propagatedBound !== null ? [{
            antecedent: {
              name: ineq.name,
              type: "linearInequality"
            },
            reason,
            result: {
              name: propagatedBound[0],
              value: propagatedBound[1]
            }
          }] : []

          return {
            result: "noConflict",
            propagated
          }
        }
      }
    } else {
      throw new Error("not implemented")
    }
  }

  return {
    result: "noConflict",
    propagated: []
  }
}

// Our solver for now only works on Boolean variables, so linear inequality can also only contain boolean variables and atomic constraints

function propagate(domains: Map<string, Domain>, state: Map<string, boolean>, constraints: [ConstraintType, Constraint[]][]) {

  for (const [_, typeConstraints] of constraints) {
    for (const c of typeConstraints) {
      let result: PropagationResult
      if ("literals" in c) {
        result = clauseResolve(c, state)
      } else if ("lhs" in c) {
        result = propagateLinearInequality(c, domains, state)
      } else {
        throw new Error("not implemented: unknown constraint")
      }

      if (result.result === 'conflict') {
        
      }
    }
  }
}

type PropagatorReason = {
  antecedent: { name: string, type: ConstraintType }
  reason: Reason;
};

type Propagation = PropagatorReason & {
  result: { name: string; value: boolean };
}


type PropagationResult = {
  result: "noConflict"
  propagated: Propagation[]
} | {
  result: "conflict"
  conflict: PropagatorReason
}