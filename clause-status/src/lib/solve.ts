export type Clause = ([true, string] | [false, string])[]

export type WeightedBooleanInequality = {
  // weight, boolean var name
  terms: [number, string][]
  rhs: number,
  type: 'weightedBooleanInequality'
}

export function atomName(activity: string, constant: number): string {
  return `[${activity} ≤ ${constant}]`
}