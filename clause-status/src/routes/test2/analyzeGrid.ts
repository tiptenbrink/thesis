import { analyzeMatchings } from "./analyzeMatchings";

function copyGrid(grid: number[][]): number[][] {
  return grid.map(r => [...r])
}

function buildSingleOptions(): number[][] {
  return Array(6)
  .fill(0).map(_ => [1, 2, 3, 4, 5, 6])
}

function buildOptions(): number[][][] {
  return Array(6)
  .fill(0)
  .map(() => Array(6).fill(0).map(_ => [1, 2, 3, 4, 5, 6]));
}

function buildRemovals(): number[][][] {
  return Array(6)
  .fill(0)
  .map(() => Array(6).fill(0).map(_ => []));
}

export function analyzeFixPoint(grid: number[][]) {
  let currentGrid = copyGrid(grid)
  const propagated = [] as [number, number, number][]
  let maxIter = 100
  let i = 0
  while (i < maxIter) {
    const result = analyzeGrid(currentGrid)
    if (result.conflict) {
      return { conflict: true, propagated, currentGrid, options: result.options, removals: result.removals }
    } else if (result.forced !== undefined) {
      currentGrid = copyGrid(currentGrid)
      const [r, c, v] = result.forced
      currentGrid[r][c] = v
      propagated.push([r, c, v])
    } else {
      return { conflict: false, propagated, currentGrid, options: result.options, removals: result.removals }
    }
    i++;
  }

  throw new Error("unreachable!")
}

export function analyzeGrid(grid: number[][]): { options: number[][][], removals: number[][][], forced?: [number, number, number], conflict: boolean } {
  const rowsOptions = buildOptions()
  const colsOptions = buildOptions()

  let forced: [number, number, number] | undefined = undefined
  let conflict = false

  for (let row = 0; row < 6; row++) {
    for (let col = 0; col < 6; col++) {
      const availableNumbers = new Set([1, 2, 3, 4, 5, 6]);

      if (grid[row][col] !== 0) {
        rowsOptions[row][col] = [grid[row][col]]
        colsOptions[col][row] = [grid[row][col]]
        continue
      }

      for (let c = 0; c < 6; c++) {
        if (grid[row][c] !== 0) {
          availableNumbers.delete(grid[row][c]);
        }
      }

      for (let r = 0; r < 6; r++) {
        if (grid[r][col] !== 0) {
          availableNumbers.delete(grid[r][col]);
        }
      }

      if (availableNumbers.size === 1 && forced === undefined) {
        forced = [row, col, [...availableNumbers.values()][0]]
      } else if (availableNumbers.size === 0) {
        conflict = true
      }

      rowsOptions[row][col] = [...availableNumbers]
      colsOptions[col][row] = [...availableNumbers]
    }
  }

  const removals = buildRemovals()

  if (conflict) {
    return { options: rowsOptions, removals, conflict }
  } else if (forced !== undefined) {
    //return { options: rowsOptions, removals, forced, conflict }
  }

  
  for (let cr = 0; cr < 6; cr++) {
    const rowRemovals = analyzeMatchings(rowsOptions[cr]).removals
    rowRemovals.forEach(([i, v]) => {
      removals[cr][i].push(v)
    })

    const colRemovals = analyzeMatchings(colsOptions[cr]).removals
    colRemovals.forEach(([i, v]) => {
      removals[i][cr].push(v)
    })
  }

  for (let row = 0; row < 6; row++) {
    for (let col = 0; col < 6; col++) {
      if (grid[row][col] !== 0) {
        rowsOptions[row][col] = []
        continue
      }

      const elRemovals = removals[row][col]
      const newOptions = rowsOptions[row][col].filter(v => !elRemovals.includes(v))
      if (newOptions.length === 0) {
        conflict = true
      } else if (newOptions.length === 1 && forced === undefined) {
        forced = [row, col, [...newOptions.values()][0]]
      }
    }
  }

  return { options: rowsOptions, removals, forced, conflict }
}