<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Summary</h1>
  
  {#if props.animation >= 0}
    <!-- Main achievement - more compact -->
    
    <!-- Three pillars - more compact -->
    <div class="grid grid-cols-3 gap-4 mb-4">
      <div class="p-3 bg-purple-100 rounded-lg text-center">
        <p class="text-present font-bold text-paars">Building block</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">Perforated intervals</p>
      </div>
      <div class="p-3 bg-green-100 rounded-lg text-center">
        <p class="text-present font-bold text-bosgroen">Implementation</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">2 constraints+deduction</p>
      </div>
      <div class="p-3 bg-blue-100 rounded-lg text-center">
        <p class="text-present font-bold text-koningsblauw">Formal verification</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">Rocq</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="text-center mb-4">
      <div class="p-4 bg-bosgroen text-white rounded-lg">
        <p class="text-present font-semibold">Bright future ahead for CP solvers</p>
        <p class="text-present-small mt-2">Can fearlessly improve algorithms - we will catch incorrect results!</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 2}
    <!-- Credits - more compact -->
    <div class="text-center border-t-2 border-gray-200 pt-4">
      <p class="text-present font-bold mb-1">Tip ten Brink</p>
      <p class="text-present-small text-koningsblauw mb-2">Proof Step Checking in a Constraint Programming Unsatisfiability Proof Checker</p>
      <p class="text-present-small">Supervisor: E. Demirović</p>
    </div>
  {/if}
</div>