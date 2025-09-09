<script module>
  export const animations = 6
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">The Challenge</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">CP solvers are complex software</p>
        <p class="text-present-small text-donkergrijs-muted mt-1">Decades of engineering + complicated algorithms</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-bordeaux text-white rounded-lg text-center">
        <p class="text-present font-semibold mb-2">We are interested in:</p>
        <p class="text-present">When solver claims problem is <strong class="text-bordeaux bg-white px-2 py-1 rounded">impossible (unsatisfiable)</strong></p>
      </div>
    {/if}
    
    {#if props.animation === 3}
      <div class="p-4 bg-yellow-50 rounded-lg text-center">
        <p class="text-present font-semibold text-oranje mb-3">Question for you:</p>
        <p class="text-present">Why is this harder to check than when we <em>do</em> get a solution?</p>
      </div>
    {:else if props.animation === 4}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-semibold mb-3">Answer:</p>
        <p class="text-present">We can just check if solution satisfies all constraints!</p>
      </div>
    {:else if props.animation >= 5}
      <div class="p-4 bg-koningsblauw text-white rounded-lg text-center">
        <p class="text-present font-semibold mb-2">Solution:</p>
        <p class="text-present">Solvers record reasoning = <strong>proof</strong></p>
        {#if props.animation >= 6}
          <p class="text-present mt-2">Then check proof step by step</p>
        {/if}
      </div>
    {/if}
  </div>
</div>