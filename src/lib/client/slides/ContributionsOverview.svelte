<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">My Contributions</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-8">
      <p class="text-present-large text-koningsblauw">Systematic foundation for CP-native proof checking</p>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="grid grid-cols-3 gap-8">
      <div class="text-center">
        <p class="text-present-large font-bold text-paars">Theory</p>
        <p class="text-present text-donkergrijs-muted mt-2">New approaches</p>
      </div>
      
      <div class="text-center">
        <p class="text-present-large font-bold text-bosgroen">Implementation</p>
        <p class="text-present text-donkergrijs-muted mt-2">Working checkers</p>
      </div>
      
      <div class="text-center">
        <p class="text-present-large font-bold text-koningsblauw">Verification</p>
        <p class="text-present text-donkergrijs-muted mt-2">Formal proofs</p>
      </div>
    </div>
  {/if}
</div>