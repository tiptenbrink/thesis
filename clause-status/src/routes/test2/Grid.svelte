<script lang="ts">
  import { analyzeFixPoint, analyzeGrid } from "./analyzeGrid";

function copyGrid(grid: number[][]): number[][] {
  return grid.map(r => [...r])
}

let { initialGrid, onUpdate }: { initialGrid: number[][], onUpdate: (updatedGrid: number[][]) => void } = $props()

let grid = $state(copyGrid(initialGrid));

let { options, removals, forced, conflict } = $derived.by(() => {
  const result = analyzeGrid(grid)
  console.log(`forced=${result.forced}`)
  const fp = analyzeFixPoint(grid)
  console.log(`fixConflict=${fp?.conflict};fixProp=${fp?.propagated}`)
  return result
});
const SIZE = initialGrid.length
const cols = SIZE === 6 ? 'grid-cols-6' : 'grid-cols-5'

function getSelectOptions(newOptions: number[], gridValue: number) {
  if (gridValue !== 0) {
    return [gridValue, ...newOptions]
  } else {
    return newOptions
  }
}

$effect(() => {
  onUpdate(grid)
})
</script>
<button onclick={() => {
  grid = analyzeFixPoint(grid)?.currentGrid ?? grid
}}>Apply fixpoint</button>
<div>forced={forced};conflict={conflict}</div>
<div class={`grid ${cols} gap-0 p-4`}>
  {#each grid as row, rowIndex}
    {#each row as cell, colIndex}
      {@const availableOptions = options[rowIndex][colIndex]}
      {@const selectOptions = getSelectOptions(availableOptions, grid[rowIndex][colIndex])}
      <div
        class="w-auto aspect-square border border-black rounded-none {selectOptions.length ===
        0
          ? 'bg-red-200'
          : ''}"
      >
        <div class="text-sm h-[10%]">
          {#each availableOptions as opt}
            {#if removals[rowIndex][colIndex].includes(opt)}
              <span class="text-red-600">{opt}&nbsp;</span>
            {:else}
              <span>{opt}&nbsp;</span>
            {/if}
          {/each}
        </div>
        <div class="w-full h-[90%]">
          <select
            class="w-full h-full text-lg text-center"
            bind:value={grid[rowIndex][colIndex]}
          >
            {#each selectOptions as option}
              <option value={option}>{option}</option>
            {/each}
          </select>
        </div>
      </div>
    {/each}
  {/each}
</div>


<style>
select {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background: none;
  padding: 0;
  margin: 0;
}
</style>