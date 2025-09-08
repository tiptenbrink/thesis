<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<!-- Full-screen emphasis layout -->
<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-8">Summary</h1>
  
  {#if props.animation >= 0}
    <!-- Main achievement - full width emphasis -->
    <div class="text-center mb-8">
      <div class="p-8 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg">
        <p class="text-present-xl text-blue-800 font-bold mb-4">Systematic Foundation for CP-Native Proof Checking</p>
        <p class="text-present text-gray-700">Complete theoretical framework + working implementations + formal verification</p>
      </div>
    </div>
    
    <!-- Three pillars - asymmetric layout -->
    <div class="grid grid-cols-[2fr_1fr_1fr] gap-4 mb-6">
      <div class="p-4 bg-purple-100 rounded-lg">
        <p class="text-present font-bold text-purple-800">Methodology & Theory</p>
        <p class="text-present-small text-gray-600">Inference checker methodology, perforated intervals, conflict types</p>
      </div>
      <div class="p-4 bg-green-100 rounded-lg text-center">
        <p class="text-present font-bold text-green-800">Implementation</p>
        <p class="text-present-small text-gray-600">3 working checkers</p>
      </div>
      <div class="p-4 bg-blue-100 rounded-lg text-center">
        <p class="text-present font-bold text-blue-800">Verification</p>
        <p class="text-present-small text-gray-600">Rocq proofs</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <!-- Credits - clean separation -->
    <div class="text-center border-t-2 border-gray-200 pt-6">
      <p class="text-present-large font-bold mb-2">Tip ten Brink</p>
      <p class="text-present text-blue-700 mb-1">Proof Step Checking in a Constraint Programming</p>
      <p class="text-present text-blue-700 mb-3">Unsatisfiability Proof Checker</p>
      <p class="text-present-small text-gray-600">Supervisor: E. Demirović</p>
    </div>
  {/if}
</div>