<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-4">The CP Proof Challenge</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 0}
      <div class="p-4 bg-red-50 rounded-lg text-center">
        <p class="text-present font-semibold text-bordeaux">The Gap</p>
        <p class="text-present-small mt-1">CP solvers lack <strong>native proof checking</strong></p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present">Why this matters:</p>
        <div class="mt-2 text-present-small space-y-1">
          <p>• Trust in critical applications</p>
          <p>• Confidence in unsatisfiability claims</p>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-blue-50 rounded-lg text-center">
        <p class="text-present font-semibold text-koningsblauw">Our Project</p>
        <p class="text-present-small mt-1">TU Delft initiative for <strong>CP-native proof checking</strong></p>
      </div>
    {/if}
  </div>
</div>