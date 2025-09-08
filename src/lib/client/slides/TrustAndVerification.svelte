<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Why "Formally Verified"?</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 0}
      <div class="p-4 bg-yellow-50 rounded-lg text-center">
        <p class="text-present font-semibold text-oranje mb-2">The Problem</p>
        <p class="text-present">We need to trust our checker as much as the original solver</p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="p-4 bg-red-50 rounded-lg text-center">
        <p class="text-present font-semibold text-bordeaux mb-2">If checker has bugs...</p>
        <p class="text-present-small">We might accept invalid proofs</p>
        <p class="text-present-small">→ Trust problem remains unsolved</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-koningsblauw text-white rounded-lg text-center">
        <p class="text-present font-semibold mb-2">Solution: Formal Verification</p>
        <p class="text-present">Machine-checked mathematical proof that checker is correct</p>
        <p class="text-present-small mt-2">Highest possible level of trust</p>
      </div>
    {/if}
  </div>
</div>