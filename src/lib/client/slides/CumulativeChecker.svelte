<script module>
  export const animations = 7
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  import cumulFigureClaim from '$lib/assets/cumulFigureClaim.svg'
  import cumulFigureConfl from '$lib/assets/cumulFigureConfl.svg'
</script>

<div class="h-full w-full p-3 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-2 text-bosgroen">Cumulative Checker</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="p-4 bg-yellow-50 rounded-lg">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-present-small font-semibold">Mini-claim: domains lead to violation</p>
            <p class="text-present-small">• Operation A starting time domain {'{'}0{'}'}</p>
            <p class="text-present-small">• Operation B starting time domain {'{'}1{'}'}</p>
            <p class="text-present-small">• Operation C starting time domain {'{'}0,1,2{'}'}</p>
            <div class="mt-3 bg-bosgroen-light rounded-lg text-center {props.animation >= 5 ? '' : 'invisible'}">
              <p class="text-present-small font-semibold">Operation violation</p>
              <p class="text-present-small">Focus on specific operation</p>
            </div>
          </div>
          <div class="flex items-center justify-center">
            <img src={cumulFigureClaim} alt="claim example" class="w-full h-auto">
          </div>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 2 && props.animation < 4}
      <div class="text-center">
        <p class="text-present-large">Every mini-claim: domains → conflict</p>
      </div>
    {/if}
    
    {#if props.animation === 3}
      <div class="p-4 bg-koningsblauw text-white rounded-lg text-center">
        <p class="text-present font-semibold">My methodology:</p>
        <p class="text-present-small mt-2">1. Find different categories</p>
        <p class="text-present-small">2. Determine separate strategy for each</p>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="p-4 bg-red-50 rounded-lg">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-present-small font-semibold text-bordeaux">Mini-claim: domains lead to violation</p>
            <p class="text-present-small">• Operation A starting time domain {'{'}0{'}'}</p>
            <p class="text-present-small">• Operation C starting time domain {'{'}0{'}'}</p>
            <div class="mt-3 bg-bordeaux-light rounded-lg text-center {props.animation >= 6 ? '' : 'invisible'}">
              <p class="text-present-small font-semibold text-bordeaux">Time violation</p>
              <p class="text-present-small">Focus on specific timepoint</p>
            </div>
          </div>
          <div class="flex items-center justify-center">
            <img src={cumulFigureConfl} alt="time conflict example" class="w-full h-auto">
          </div>
        </div>
      </div>
    {/if}
    
    
    {#if props.animation >= 7}
      <div class="text-center">
        <p class="text-present-small text-donkergrijs-muted">Different categories → different verification strategies</p>
      </div>
    {/if}
  </div>
</div>