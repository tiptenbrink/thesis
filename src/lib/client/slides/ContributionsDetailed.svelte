<script module>
  export const animations = 10
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Contributions</h1>
  
  <!-- 2x2 Grid -->
  <div class="grid grid-cols-2 gap-6">
    <!-- Box 1: Top-left -->
    {#if props.animation >= 1}
      <div class="p-4 bg-blue-50 rounded-lg text-center">
        {#if props.animation === 1}
          <!-- Initial Achievement title -->
          <p class="text-present font-bold text-koningsblauw">Check solver work</p>
          <p class="text-present mt-1">Two common subproblems</p>
        {:else if props.animation === 2}
          <!-- Expanded with details -->
          <p class="text-present font-bold text-koningsblauw">Check constraint-specific mini-claims</p>
          <p class="text-present-small mt-1">• <strong>Cumulative:</strong> activities using limited capacity</p>
          <p class="text-present-small">• <strong>Alldifferent:</strong> all values distinct</p>
        {:else}
          <!-- Final compact form -->
          <p class="text-present font-bold text-koningsblauw">Two constraint mini-claim checkers</p>
          <p class="text-present mt-1">Cumulative + Alldifferent</p>
        {/if}
      </div>
    {/if}
    
    <!-- Box 2: Top-right -->
    {#if props.animation >= 3}
      <div class="p-4 bg-red-50 rounded-lg text-center">
        {#if props.animation === 3}
          <!-- Initial Achievement title -->
          <p class="text-present font-bold text-bordeaux">Extend the checker</p>
          <p class="text-present mt-1">Handle more subproblems</p>
        {:else if props.animation === 4}
          <!-- Expanded with details -->
          <p class="text-present font-bold text-bordeaux">Constraint checker methodology</p>
          <p class="text-present-small mt-1">Support new constraint-specific mini-claim checkers beyond cumulative and alldifferent</p>
        {:else}
          <!-- Final compact form -->
          <p class="text-present font-bold text-bordeaux">Constraint checker methodology</p>
          <p class="text-present mt-1">New constraint support</p>
        {/if}
      </div>
    {/if}
    
    <!-- Box 3: Bottom-left -->
    {#if props.animation >= 5}
      <div class="p-4 bg-purple-50 rounded-lg text-center">
        {#if props.animation === 5}
          <!-- Initial Achievement title -->
          <p class="text-present font-bold text-paars">Combine knowledge</p>
          <p class="text-present mt-1">From different subproblems</p>
        {:else if props.animation === 6}
          <!-- Expanded with details -->
          <p class="text-present font-bold text-paars">Deduction checker</p>
          <p class="text-present-small mt-1">Refers to previous mini-claims to support new mini-claims</p>
        {:else}
          <!-- Final compact form -->
          <p class="text-present font-bold text-paars">Deduction checker</p>
          <p class="text-present mt-1">Combines previous steps</p>
        {/if}
      </div>
    {/if}
    
    <!-- Box 4: Bottom-right -->
    {#if props.animation >= 7}
      <div class="p-4 bg-green-50 rounded-lg text-center">
        {#if props.animation === 7}
          <!-- Initial Achievement title -->
          <p class="text-present font-bold text-bosgroen">Reusable component</p>
          <p class="text-present mt-1">Integer (-1, 0, 4, etc.) set reasoning, maximum, minimum</p>
        {:else if props.animation === 8}
          <!-- Expanded with details -->
          <p class="text-present font-bold text-bosgroen">Perforated intervals</p>
          <p class="text-present-small mt-1">• Set of possible values (domains)</p>
          <p class="text-present-small">• Example: Carol's operation at t=0, t=1, or t=2 → domain [0,1,2]</p>
          <p class="text-present-small">• Efficient reasoning over sets: checking max/min values</p>
        {:else}
          <!-- Final compact form (this won't show since animation 8 is the last) -->
          <p class="text-present font-bold text-bosgroen">Perforated intervals</p>
          <p class="text-present mt-1">Integer domain representation</p>
        {/if}
      </div>
    {/if}
  </div>
</div>