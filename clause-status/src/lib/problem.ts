import { atomName, type Clause, type WeightedBooleanInequality } from "./solve"


export function cActTimeName(type: string, activity: string, time: number | ''): string {
  return `𝔠(${type})(${activity}${time})`
}

export function resourceTimeName(time: number): string {
  return `resource(${time})`
}

export function activeName(activity: string, t: number): string {
  return `${activity}${t}`
}

/**
 * These will be defined for 0 <= t <= max_time
 */
export function c2(activities: string[], durations: Map<string, number>, max_time: number): Map<string, Clause> {
  let clauses = new Map<string, Clause>()
  for (const activity of activities) {
    const duration = durations.get(activity)!
    for (let t = 0; t <= max_time; t++) {
      if (t >= duration) {
        clauses.set(cActTimeName('act', activity, t), [[true, activeName(activity, t)], [false, atomName(activity, t)], [true, atomName(activity, t - duration)]])
        clauses.set(cActTimeName('remove', activity, t), [[false, activeName(activity, t)], [false, atomName(activity, t - duration)]])
      } else {
        clauses.set(cActTimeName('act', activity, t), [[true, activeName(activity, t)], [false, atomName(activity, t)]])
      }
      clauses.set(cActTimeName('start', activity, t), [[false, activeName(activity, t)], [true, atomName(activity, t)]])
    }
  }

  return clauses
}

/**
 * Will be defined for 0 <= t < max_time.
 */
export function cleq(activities: string[], max_time: number): Map<string, Clause> {
  let clauses = new Map<string, Clause>()
  for (const activity of activities) {
    for (let t = 0; t < max_time; t++) {
      clauses.set(cActTimeName('leq', activity, t), [[false, atomName(activity, t)], [true, atomName(activity, t+1)]])
    }
  }
  
  return clauses
}

/**
 * Will be defined for 0 <= t < max_time.
 */
export function resourceRequirements(max_time: number, resource_max: number, usages: Map<string, number>): [string, WeightedBooleanInequality][] {
  const ineqs: [string, WeightedBooleanInequality][] = []
  
  for (let t = 0; t < max_time; t++) {
    const terms: [number, string][] = [...usages.entries()].map(([activity, usage]) => [usage, activeName(activity, t)] as [number, string])
    ineqs.push([resourceTimeName(t), { terms, rhs: resource_max, type: 'weightedBooleanInequality' }])
  }

  return ineqs
}

export function cMax(activities: string[], max_active: number): Map<string, Clause> {
  let clauses = new Map<string, Clause>()

  for (const activity of activities) {
    clauses.set(cActTimeName('max', activity, ''), [[false, activeName(activity, max_active+1)]])
    clauses.set(cActTimeName('schedule', activity, ''), [[true, atomName(activity, max_active)]])
  }

  return clauses
}