<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">CP Needs Proof Checking</h1>
  
  <div class="space-y-5">
    {#if props.animation >= 0}
      <div class="text-center">
        <p class="text-present-large">SAT solvers use proof logging successfully</p>
        <p class="text-present text-gray-600 mt-2">Competition standard since 2013</p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="p-5 bg-red-50 rounded-lg text-center">
        <p class="text-present-large font-semibold text-red-800">CP Gap</p>
        <p class="text-present mt-2">No <strong>native proof checking</strong></p>
        <p class="text-present-small text-gray-600">Current: translate to simpler formats</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large text-purple-700 font-semibold">Our Vision</p>
        <p class="text-present mt-2">Direct CP verification with <strong>formal guarantees</strong></p>
      </div>
    {/if}
  </div>
</div>