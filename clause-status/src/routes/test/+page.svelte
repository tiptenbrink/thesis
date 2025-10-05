<script lang="ts">
    import Grid from "./Grid.svelte";

  function buildInitialGrid() {
      return Array(5)
      .fill(0)
      .map(() => Array(5).fill(0))
  }
  // Initialize a 5x5 grid with empty values
  let grid = $state(
    buildInitialGrid()
  );

  let outGrid = $state(buildInitialGrid())

  function resetGrid() {
    grid = buildInitialGrid()
    outGrid = buildInitialGrid()
  }

  let input = $state("");

  function populateGrid() {
    const rows = input.trim().split("\n");
    const newGrid = rows.map((row) =>
      row.split(" ").map((cell) => (cell === "0" ? 0 : Number(cell))),
    );
    grid = newGrid;
  }

  function setGridString() {
    const gridString = outGrid
      .map((row) => row.map((cell) => (cell === 0 ? "0" : cell)).join(" "))
      .join("\n");
    input = gridString;
  }

  function updateOutGrid(gridToSet: number[][]) {
    outGrid = gridToSet
  }
</script>

<button
  class="mb-4 px-4 py-2 bg-blue-500 text-white rounded"
  onclick={populateGrid}>Populate Grid</button
>
<button
  class="mb-4 px-4 py-2 bg-blue-500 text-white rounded"
  onclick={resetGrid}>Reset</button
>
<button
  class="mb-4 px-4 py-2 bg-blue-500 text-white rounded"
  onclick={setGridString}>Paste Grid to Input</button
>

<div class="w-full">
  <div class="w-[40%]">
    {#key grid}
      <Grid initialGrid={grid} onUpdate={updateOutGrid}></Grid>
    {/key}
  </div>

  <textarea
    bind:value={input}
    class="mb-4 w-full h-24 p-2 border border-gray-400 rounded"
  ></textarea>
</div>
