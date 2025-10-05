export interface IntegerDomain {
  type: "integer",
  min: number,
  max: number,
  // sorted
  holes: number[] | null
}

export interface BooleanDomain {
  type: "boolean",
  state: true | false | "𝔲"
}

export interface ValueDomain {
  type: "value",
  // sorted
  values: number[]
}

export type Domain = IntegerDomain | ValueDomain | BooleanDomain

function addConstraint(constraints: [string, Constraint[]][], c: Constraint) {
  // first one is always clause
  if (constraints.length === 0) {
    constraints.push(["clause", []])
  }
  if ("literals" in c) {
    for (const [cType, typeConstraints] of constraints) {
      if (cType === "clause") {
        typeConstraints.push(c)
      }
    }
  }
  if ("lhs" in c) {
    for (const [cType, typeConstraints] of constraints) {
      if (cType === "linearInequality") {
        typeConstraints.push(c)
      }
    }
  }
}

export interface FdProblem {
  variables: string[]
  domains: Map<string, Domain>
  // variable to problem
  problems: Map<string, Problem>

  // ordered by group
  constraints: [ConstraintType, Constraint[]][]
}

type Problem = CumulativeProblem | { name: "other" }

interface CumulativeProblem {
  name: "cumulative"
  activities: string[]
  durations: number[]
  usages: { all: number } | number[]
  startTime: number
  endTime: number
  resources: number
  propagator: "global" | "timeDecomposed"
}

type AtomicOp = "leq" | "geq" | "neq" | "eq"

interface AtomicConstraint {
  var: string
  op: AtomicOp
  c: number
}

// string should be variable or AtomicConstraint
export type Clause = {
  name: string,
  literals: [boolean, string][]
}

export type LinearInequality = {
  name: string,
  lhs: [number, string][],
  rhs: number
}

export type ConstraintType = "clause" | "linearInequality"
export type Constraint = Clause | LinearInequality

function atomNameForConstraint(atom: AtomicConstraint): [boolean, string] {
  return atomName(atom.var, atom.c, atom.op)
}

function atomNameNameLeq(variable: string, c: number): string {
  return atomName(variable, c)[1]
}

export function atomName(variable: string, c: number, op: AtomicOp = "leq"): [boolean, string] {
  if (op === "leq") {
    return [true, `[${variable} ≤ ${c}]`]
  } else if (op === "geq") {
    return [false, `[${variable} ≤ ${c - 1}]`]
  } else if (op === "neq") {
    throw new Error("not implemented")
  } else if (op === "eq") {
    throw new Error("not implemented")
  } else {
    throw new Error(`invalid atomic op: ${op} not in [leq, geq, neq, eq]`)
  }
}

function createCumulativeProblem(activities: string[], durations: number[], resources: number, startTime: number, endTime: number, usages: { all: number } | number[] = { all: 1 }, propagator: "global" | "timeDecomposed" = "global"): CumulativeProblem {
  return {
    name: "cumulative",
    activities,
    durations,
    startTime,
    endTime,
    usages,
    resources,
    propagator
  }
}

export function cActTimeName(type: string, activity: string, time: number | ''): string {
  return `𝔠(${type})(${activity}${time})`
}

export function activeName(activity: string, t: number): string {
  return `${activity}${t}`
}

function createFdProblem(problems: Problem[]): FdProblem {
  const variables: FdProblem['variables'] = []
  const domains = new Map()
  const varToProblems = new Map()
  const constraints: FdProblem['constraints'] = []

  for (const p of problems) {
    if (p.name === "cumulative") {
      if (p.propagator === 'timeDecomposed') {
        for (let t = p.startTime; t <= p.endTime; t++) {
          const lhs: LinearInequality['lhs'] = []
          for (let i = 0; i < p.activities.length; i++) {
            let usage: number;
            if ("all" in p.usages) {
              usage = p.usages.all
            } else {
              usage = p.usages[i]
            }
            lhs.push([usage, p.activities[i]])
          }
          const c: LinearInequality = {
            name: `resource(${t})`,
            lhs,
            rhs: p.resources
          }
          addConstraint(constraints, c)
        }
      } else {
        throw new Error("not implemented")
      }

      for (let i = 0; i < p.activities.length; i++) {
        const v = p.activities[i]
        const duration = p.durations[i]
        variables.push(v)
        const iDomain: IntegerDomain = {
          type: "integer",
          min: p.startTime,
          max: p.endTime - 1,
          holes: null
        }
        domains.set(v, iDomain)
        varToProblems.set(v, p)

        if (p.propagator === 'timeDecomposed') {
          for (let t = p.startTime; t <= p.endTime; t++) {
            const activeVar = activeName(v, t)
            variables.push(activeVar)
            const bDomain: BooleanDomain = {
              type: "boolean",
              state: '𝔲'
            }
            domains.set(activeVar, bDomain)
            varToProblems.set(activeVar, p)

            if (t >= duration) {
              const actClause: Clause = {
                name: cActTimeName('act', v, t),
                literals: [[true, activeVar], [false, atomNameNameLeq(v, t)], [true, atomNameNameLeq(v, t - duration)]]
              }
              const removeClause: Clause = {
                name: cActTimeName('remove', v, t),
                literals: [[false, activeVar], [false, atomNameNameLeq(v, t - duration)]]
              }
              addConstraint(constraints, actClause)
              addConstraint(constraints, removeClause)
            } else {
              const actClause: Clause = {
                name: cActTimeName('act', v, t),
                literals: [[true, activeVar], [false, atomNameNameLeq(v, t)]]
              }
              addConstraint(constraints, actClause)
            }
            const startClause: Clause = {
              name: cActTimeName('start', v, t),
              literals: [[false, activeVar], [true, atomNameNameLeq(v, t)]]
            }
            addConstraint(constraints, startClause)
          }
        } else {
          throw new Error("not implemented")
        }
      }
    }
  }

  return {
    variables,
    problems: varToProblems,
    domains,
    constraints
  }
}

export function createCookingProblem(activities: [string, number][], cookTops: number, startTime: number, endTime: number, propagator: "global" | "timeDecomposed" = "global"): CumulativeProblem {
  const activityNames = []
  const durations = []
  for (const [a, d] of activities) {
    activityNames.push(a)
    durations.push(d)
  }

  return createCumulativeProblem(activityNames, durations, cookTops, startTime, endTime, { all: 1 }, propagator)
}