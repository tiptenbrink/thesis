<script lang="ts">
  let { notAllowed, gridInput, colorInput, blockedInput, noInference }: {
    notAllowed?: number[][][],
    gridInput: string,
    colorInput: string,
    blockedInput?: string,
    noInference?: boolean
  } = $props()

  function readGrid<T>(inputTxt: string, f: (cell: string) => T) {
    const rows = inputTxt.trim().split("\n");
    const newGrid: T[][] = rows.map((row) => {
      return row.trim().split(" ").map(cell => f(cell))
    }
    );
    return newGrid
  }

  const notAllowedResolved = notAllowed === undefined ?
    [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ]
  : notAllowed


  const blockedGrid = readGrid(blockedInput !== undefined ? blockedInput : `
      0 b b b b
      0 0 b b b
      0 b 0 b 0
      0 b 0 0 b
      0 b b 0 0
  `, cell => cell === 'b')

  let grid = $state(
    readGrid(gridInput, cell => (cell === "0" ? null : Number(cell))),
  );

  const gridColored = readGrid<'g' | 'y' | 'g2' | 'r' | null>(colorInput, (cell) => {
    if (cell === 'g' || cell === 'y' || cell === 'g2' || cell === 'r') {
      return cell
    } else {
      return null
    }
  })

  const gridOptions = $derived.by(() => {
    const options: number[][][] = Array(5)
      .fill(0)
      .map(() => Array(5).fill([1, 2, 3, 4, 5]));

    for (let row = 0; row < 5; row++) {
      for (let col = 0; col < 5; col++) {
        const usedNumbers = new Set();

        for (let c = 0; c < 5; c++) {
          let currentRowCell = grid[row][c]
          if (currentRowCell !== null) {
            usedNumbers.add(currentRowCell);
          }
        }

        // Check the current column
        for (let r = 0; r < 5; r++) {
          let currentColumnCell = grid[r][col]
          if (currentColumnCell !== null) {
            usedNumbers.add(currentColumnCell);
          }
        }

        // Filter out used numbers from options
        options[row][col] = options[row][col].filter(
          (option) => grid[row][col] === option || !usedNumbers.has(option),
        );
      }
    }

    return options;
  });

  function getColor(options: number[], row: number, col: number) {
    if (options.length === 0) {
      return 'bg-red-200'
    }
    if (blockedGrid[row][col]) {
      return 'bg-gray-200'
    }
    const color = gridColored[row][col]
    if (color === 'g') {
      return 'bg-green-800'
    } else if (color === 'g2') {
      return 'bg-green-200'
    } else if (color === 'y') {
      return 'bg-yellow-200'
    } else if (color === 'r') {
      return 'bg-red-200'
    }

    return ''
      
  }
</script>


  <div class="grid grid-cols-[1fr_2fr_2fr_2fr_2fr_2fr] gap-0 p-4">
    {#each grid as row, rowIndex}
      <div class="text-right flex items-center text-present-small justify-end pr-4">{rowIndex+1}</div>
      {#each row as cell, colIndex}
        {@const availableOptions = gridOptions[rowIndex][colIndex]}
        <div
          class="w-auto aspect-square border border-black rounded-none {getColor(availableOptions, rowIndex, colIndex)}"
        >
          <div class="text-present-xs h-[10%]">
            {#if grid[rowIndex][colIndex] === null && !blockedGrid[rowIndex][colIndex] && noInference !== true}
              {#each availableOptions as opt}
                {#if notAllowedResolved[rowIndex][colIndex].includes(opt)}
                  <s class="text-present-small text-red-600">{opt}&nbsp;</s>
                {:else}
                  <span>{opt}&nbsp;</span>
                {/if}
              {/each}
            {/if}
          </div>
          <div class="w-full h-[90%]">
            <div
              class="w-full h-full text-present-small font-bold flex items-center justify-center"
            >
              <span>{grid[rowIndex][colIndex]}</span>
          </div>
          </div>
        </div>
      {/each}
    {/each}
    {#each ['', 'A', 'B', 'C', 'D', 'E'] as colName}
        <div class="text-center text-present-small mt-4">{colName}</div>
    {/each}
  </div>