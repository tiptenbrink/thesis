<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Limitations & Future Work</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-6">
      <p class="text-present-large text-bordeaux font-semibold">Current Challenge</p>
      <p class="text-present text-donkergrijs-muted mt-3">High verification effort for each constraint</p>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="grid grid-cols-2 gap-8">
      <div class="text-center">
        <p class="text-present-large font-semibold text-koningsblauw">Next Steps</p>
        <div class="mt-4 space-y-2">
          <p class="text-present">Verification automation</p>
          <p class="text-present">Performance improvements</p>
          <p class="text-present">More constraints</p>
        </div>
      </div>
      
      <div class="text-center">
        <p class="text-present-large font-semibold text-bosgroen">Big Opportunity</p>
        <div class="mt-4">
          <p class="text-present">Richer proof hints</p>
          <p class="text-present-small text-donkergrijs-muted mt-2">Guide checkers efficiently</p>
        </div>
      </div>
    </div>
  {/if}
</div>