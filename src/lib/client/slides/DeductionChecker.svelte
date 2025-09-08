<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-8">Deduction Step Checker</h1>
  
  <div class="space-y-8">
    {#if props.animation >= 0}
      <div class="text-center">
        <p class="text-present-large">Combines multiple facts into new conclusions</p>
        <p class="text-present text-gray-600 mt-3">Uses domain maps built on perforated intervals</p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="grid grid-cols-2 gap-8">
        <div class="p-6 bg-blue-50 rounded-lg text-center">
          <p class="text-present font-semibold text-blue-800">What it does</p>
          <p class="text-present-small mt-2">Verifies learned clauses</p>
        </div>
        
        <div class="p-6 bg-green-50 rounded-lg text-center">
          <p class="text-present font-semibold text-green-800">Achievement</p>
          <p class="text-present-small mt-2">Formalized in Rocq</p>
        </div>
      </div>
    {/if}
  </div>
</div>