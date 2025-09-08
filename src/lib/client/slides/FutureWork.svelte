<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-8">Limitations & Future Work</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-8">
      <p class="text-present-large text-red-700 font-semibold">Current Challenge</p>
      <p class="text-present text-gray-600 mt-3">High verification effort for each constraint</p>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="grid grid-cols-2 gap-8">
      <div class="text-center">
        <p class="text-present-large font-semibold text-blue-700">Next Steps</p>
        <div class="mt-4 space-y-2">
          <p class="text-present">Verification automation</p>
          <p class="text-present">Performance improvements</p>
          <p class="text-present">More constraints</p>
        </div>
      </div>
      
      <div class="text-center">
        <p class="text-present-large font-semibold text-green-700">Big Opportunity</p>
        <div class="mt-4">
          <p class="text-present">Richer proof hints</p>
          <p class="text-present-small text-gray-600 mt-2">Guide checkers efficiently</p>
        </div>
      </div>
    </div>
  {/if}
</div>