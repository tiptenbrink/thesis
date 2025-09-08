<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Proof Step Types</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-6">
      <p class="text-present-large">Proof logs consist of two types of steps:</p>
    </div>
  {/if}
  
  <div class="grid grid-cols-2 gap-8">
    {#if props.animation >= 1}
      <div class="p-4 bg-green-50 rounded-lg text-center">
        <p class="text-present-large font-bold text-bosgroen mb-3">Inferences</p>
        <p class="text-present">Solver reasoning over constraints</p>
        <p class="text-present-small text-donkergrijs-muted mt-2">Example: Alldifferent propagation</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-blue-50 rounded-lg text-center">
        <p class="text-present-large font-bold text-koningsblauw mb-3">Deductions</p>
        <p class="text-present">Combining facts to derive new conclusions</p>
        <p class="text-present-small text-donkergrijs-muted mt-2">Example: Variable domain updates</p>
      </div>
    {/if}
  </div>
  
  {#if props.animation >= 2}
    <div class="text-center mt-6">
      <p class="text-present text-donkergrijs-muted">Both types need individual verification</p>
    </div>
  {/if}
</div>