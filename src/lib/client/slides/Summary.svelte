<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Summary</h1>
  
  {#if props.animation >= 0}
    <!-- Main achievement - more compact -->
    <div class="text-center mb-6">
      <div class="p-6 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg">
        <p class="text-present-large text-koningsblauw font-bold mb-2">Systematic Foundation for CP-Native Proof Checking</p>
        <p class="text-present-small text-donkergrijs">Theoretical framework + working implementations + formal verification</p>
      </div>
    </div>
    
    <!-- Three pillars - more compact -->
    <div class="grid grid-cols-3 gap-4 mb-4">
      <div class="p-3 bg-purple-100 rounded-lg text-center">
        <p class="text-present font-bold text-paars">Theory</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">Perforated intervals</p>
      </div>
      <div class="p-3 bg-green-100 rounded-lg text-center">
        <p class="text-present font-bold text-bosgroen">Implementation</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">3 checkers</p>
      </div>
      <div class="p-3 bg-blue-100 rounded-lg text-center">
        <p class="text-present font-bold text-koningsblauw">Verification</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">Rocq proofs</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <!-- Credits - more compact -->
    <div class="text-center border-t-2 border-gray-200 pt-4">
      <p class="text-present font-bold mb-1">Tip ten Brink</p>
      <p class="text-present-small text-koningsblauw mb-2">Proof Step Checking in a Constraint Programming Unsatisfiability Proof Checker</p>
      <p class="text-present-small text-donkergrijs-muted">Supervisor: E. Demirović</p>
    </div>
  {/if}
</div>