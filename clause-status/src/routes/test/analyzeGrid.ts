import { analyzeMatchings } from "./analyzeMatchings";

function copyGrid(grid: number[][]): number[][] {
  return grid.map(r => [...r])
}

function buildSingleOptions(): number[][] {
  return Array(5)
  .fill(0).map(_ => [1, 2, 3, 4, 5])
}

function buildOptions(): number[][][] {
  return Array(5)
  .fill(0)
  .map(() => Array(5).fill(0).map(_ => [1, 2, 3, 4, 5]));
}

function buildRemovals(): number[][][] {
  return Array(5)
  .fill(0)
  .map(() => Array(5).fill(0).map(_ => []));
}

function indices(): [number, number][] {
  const out = [] as [number, number][]
  for (let row = 0; row < 5; row++) {
    for (let col = 0; col < 5; col++) {
      out.push([row, col])
    }
  }
  return out
}

export function shuffle<T>(arr: T[]): T[] {
  for (let i = arr.length - 1; i > 0; i--) {
    // Pick a random index from 0 to i (inclusive)
    const j = Math.floor(Math.random() * (i + 1));

    // Swap elements arr[i] and arr[j]
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

// export function analyzeAllMoves(grid: number[][]) {
//   const result = analyzeFixPoint(grid)

//   if (result.conflict) {
//     return { conflict: true, by: result.propagated }
//   }

//   const availableIndices = shuffle(indices())

//   for (const [r, c] of availableIndices) {
//     for (const i of result.options[r][c]) {
//       const newGrid = copyGrid(result.currentGrid)
//       analyzeFixPoint(newGrid)
//     }
    
    
    
//   }

  



// } 

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
  const diagOptions = buildSingleOptions()
  const antiDiagOptions = buildSingleOptions()

  let forced: [number, number, number] | undefined = undefined
  let conflict = false

  for (let row = 0; row < 5; row++) {
    for (let col = 0; col < 5; col++) {
      const availableNumbers = new Set([1, 2, 3, 4, 5]);

      if (grid[row][col] !== 0) {
        rowsOptions[row][col] = [grid[row][col]]
        colsOptions[col][row] = [grid[row][col]]
        // if (row === col) {
        //   diagOptions[row] = [grid[row][col]]
        // } else if (row === (4 - col)) {
        //   antiDiagOptions[row] = [grid[row][col]]
        // }
        continue
      }

      // if (row === col) {
      //   for (let i = 0; i < 5; i++) {
      //     if (grid[i][i] !== 0) {
      //       availableNumbers.delete(grid[i][i]);
      //     }
      //   }
      // }
      // if (row === (4 - col)) {
      //   for (let i = 0; i < 5; i++) {
      //     if (grid[i][4-i] !== 0) {
      //       availableNumbers.delete(grid[i][4-i]);
      //     }
      //   }
      // }

      for (let c = 0; c < 5; c++) {
        if (grid[row][c] !== 0) {
          availableNumbers.delete(grid[row][c]);
        }
      }

      for (let r = 0; r < 5; r++) {
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
      // if (row === col) {
      //   diagOptions[row] = [...availableNumbers]
      // } else if (row === (4 - col)) {
      //   antiDiagOptions[row] = [...availableNumbers]
      // }
    }
  }

  const removals = buildRemovals()

  if (conflict) {
    return { options: rowsOptions, removals, conflict }
  } else if (forced !== undefined) {
    //return { options: rowsOptions, removals, forced, conflict }
  }

  
  for (let cr = 0; cr < 5; cr++) {
    const rowRemovals = analyzeMatchings(rowsOptions[cr]).removals
    rowRemovals.forEach(([i, v]) => {
      removals[cr][i].push(v)
    })

    const colRemovals = analyzeMatchings(colsOptions[cr]).removals
    colRemovals.forEach(([i, v]) => {
      removals[i][cr].push(v)
    })
  }
  // console.log(`rem=${JSON.stringify(removals)}`)
  // console.log(`options=${JSON.stringify(diagOptions)}`)
  const diagRemovals = analyzeMatchings(diagOptions).removals
  // for (let row = 0; row < 5; row++) {
  //   for (let col = 0; col < 5; col++) {
  //     if (removals[row][col].length > 0) {
  //       console.log(`rem${row}${col}=${removals[row][col]}`)
  //     }
  //   }
  // }
  // console.log(`diagRem ${JSON.stringify(diagRemovals)}`)
  // console.log(`rem4,4=${JSON.stringify(removals[4][4])}`)
  // diagRemovals.forEach(([i, v]) => {
  //   //console.log(`pushed to ${i},${i}; v=${v}`)
  //   removals[i][i].push(v)
  // })
  // console.log(`rem4,4=${JSON.stringify(removals[4][4])}`)
  // console.log(`rem3,4=${JSON.stringify(removals[3][4])}`)
  // console.log(`rem=${JSON.stringify(removals)}`)
  const antiDiagRemovals = analyzeMatchings(antiDiagOptions).removals
  // antiDiagRemovals.forEach(([i, v]) => {
  //   removals[i][4-i].push(v)
  // })
  // console.log(`pushed removals`)
  for (let row = 0; row < 5; row++) {
    for (let col = 0; col < 5; col++) {
      if (grid[row][col] !== 0) {
        rowsOptions[row][col] = []
        continue
      }
      // if (removals[row][col].length > 0) {
      //   console.log(`rem${row}${col}=${removals[row][col]}`)
      // }
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