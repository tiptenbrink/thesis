<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-koningsblauw">Proof checker tasks</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 1}
      <div class="p-4 bg-koningsblauw-muted rounded-lg">
        <p class="text-present-large font-semibold mb-3">A proof checker needs to do two things:</p>
        <div class="space-y-3">
          <p class="text-present">• Check that every mini-claim is true</p>
          {#if props.animation >= 2}
            <p class="text-present">• Check that all mini-claims being true imply the main claim</p>
          {/if}
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-semibold">My thesis focus:</p>
        <p class="text-present mt-2">Only the first thing - checking individual mini-claims</p>
      </div>
    {/if}
  </div>
</div>