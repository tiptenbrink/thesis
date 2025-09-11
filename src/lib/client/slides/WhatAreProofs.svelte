<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-koningsblauw">What are proofs?</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">• Record of solver's "work"</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large">CP solvers progressively learn more things</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="p-4 bg-koningsblauw-muted rounded-lg text-center">
        <p class="text-present font-semibold">Proof = sequence of mini-claims</p>
        <p class="text-present-small mt-2">Mini-claim about knowledge being true</p>
        <p class="text-present-small mt-2">Each step is a mini-claim</p>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="text-center">
        <p class="text-present">Mini-claim: statement that particular knowledge is true</p>
      </div>
    {/if}
  </div>
</div>