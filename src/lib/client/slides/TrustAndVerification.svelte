<script module>
  export const animations = 6
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Why "Formally Verified"?</h1>
  
  <div class="space-y-3">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present">Traditional development: informal spec → implement → test → repeat</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-3 bg-gray-50 rounded-lg text-center">
        <p class="text-present font-semibold mb-1">Problem:</p>
        <p class="text-present-small">Never know if program is fully correct</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="text-center">
        <p class="text-present-small">But how do we trust the proof checker itself?</p>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="p-3 bg-gray-50 rounded-lg text-center">
        <p class="text-present font-semibold mb-1">Solution: Formal Verification</p>
        <p class="text-present-small">Mathematical proof that implementation satisfies specification</p>
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="text-center">
        <p class="text-present-small">Chain: Our checker → Rocq → Human review</p>
      </div>
    {/if}
  </div>
</div>