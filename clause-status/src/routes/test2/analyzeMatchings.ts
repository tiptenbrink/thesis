/**
 * Enumerate every perfect bipartite matching on a tiny graph and
 * return pruning information:
 *
 *   removals: array of [variable, value] pairs, meaning that edge
 *             (variable,value) can be safely deleted from `options`.
 *
 * Rules for building `removals`:
 *   • If an edge is NEVER used in any perfect matching → remove it.
 *   • If an edge is ALWAYS used (and |options[var]| > 1) → remove
 *     *all other* values for that variable.
 *
 * The function keeps returning aggregate stats (`alwaysUsed`,
 * `neverUsed`, etc.) because they may still be useful.
 */

type EdgeKey = `${number}-${number}`;       // e.g. "0-3"
type EdgeMap = Record<EdgeKey, number>;

interface AnalysisResult {
  totalMatchings: number;
  alwaysUsed: EdgeKey[];
  neverUsed: EdgeKey[];
  used: EdgeMap;
  removals: [number, number][];             // NEW — the requested output
}

/* ------------------------------------------------------------------ */
/* Public API                                                         */
/* ------------------------------------------------------------------ */

export function analyzeMatchings(options: number[][]): AnalysisResult {
  const n = options.length;
  if (n === 0) {
    return {
      totalMatchings: 0,
      alwaysUsed: [],
      neverUsed: [],
      used: {},
      removals: [],
    };
  }

  const values = Array.from({ length: n }, (_, i) => i + 1); // [1 … n]

  /* --------------------------------------------------------------- */
  /* 0.  Graph data                                                  */
  /* --------------------------------------------------------------- */
  const edgeExists: Record<EdgeKey, boolean> = {};
  for (let i = 0; i < n; i++) for (const v of options[i]) edgeExists[`${i}-${v}`] = true;

  /* --------------------------------------------------------------- */
  /* 1.  Initialise edge counters                                    */
  /* --------------------------------------------------------------- */
  const used: EdgeMap = {};
  for (let i = 0; i < n; i++) for (const v of values) used[`${i}-${v}`] = 0;

  /* --------------------------------------------------------------- */
  /* 2.  Enumerate all n! permutations, keep only legal matchings    */
  /* --------------------------------------------------------------- */
  let total = 0;
  permute(values, perm => {
    for (let i = 0; i < n; i++) if (!edgeExists[`${i}-${perm[i]}`]) return;
    total++;
    for (let i = 0; i < n; i++) used[`${i}-${perm[i]}`]++;
  });

  /* --------------------------------------------------------------- */
  /* 3.  Derive alwaysUsed / neverUsed                               */
  /* --------------------------------------------------------------- */
  const alwaysUsed: EdgeKey[] = [];
  const neverUsed: EdgeKey[] = [];

  for (let i = 0; i < n; i++) {
    for (const v of values) {
      const key = `${i}-${v}` as EdgeKey;
      const cnt = used[key];

      if (edgeExists[key] && cnt === 0) neverUsed.push(key);

      // edge is always used AND variable has >1 option (not trivial)
      if (
        total > 0 &&
        edgeExists[key] &&
        cnt === total &&
        options[i].length !== 1
      ) {
        alwaysUsed.push(key);
      }
    }
  }

  /* --------------------------------------------------------------- */
  /* 4.  Build the removals list                                     */
  /* --------------------------------------------------------------- */
  const removals: [number, number][] = [];
  const alwaysUsedForVar = new Map<number, number>();

  // Map each variable to its always‑used value (if any)
  for (const e of alwaysUsed) {
    const [iStr, vStr] = e.split("-");
    alwaysUsedForVar.set(+iStr, +vStr);
  }

  for (let i = 0; i < n; i++) {
    const forcedValue = alwaysUsedForVar.get(i);

    if (forcedValue !== undefined) {
      // Remove *all other* values that are present in options[i]
      for (const v of options[i]) {
        if (v !== forcedValue) removals.push([i, v]);
      }
    } else {
      // No always‑used edge → remove every never‑used edge for this var
      for (const v of options[i]) {
        if (used[`${i}-${v}`] === 0) removals.push([i, v]);
      }
    }
  }

  return { totalMatchings: total, alwaysUsed, neverUsed, used, removals };
}

/* ------------------------------------------------------------------ */
/* Helpers                                                            */
/* ------------------------------------------------------------------ */

/** Heap's algorithm — generate every permutation */
function permute<T>(arr: T[], cb: (perm: T[]) => void): void {
  const n = arr.length;
  const c = Array(n).fill(0) as number[];
  cb(arr.slice());

  let i = 0;
  while (i < n) {
    if (c[i] < i) {
      const k = i % 2 === 0 ? 0 : c[i];
      [arr[i], arr[k]] = [arr[k], arr[i]];
      cb(arr.slice());

      c[i]++;
      i = 0;
    } else {
      c[i] = 0;
      i++;
    }
  }
}
