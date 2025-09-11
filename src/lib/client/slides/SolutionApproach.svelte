<script module>
  export const animations = 10
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large font-bold">How?</p>
        <p class="text-present">Don't trust a solver's <strong>word</strong></p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present">We <strong>"check their work"</strong></p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="p-4 border-2 border-koningsblauw rounded-lg text-center">
        <p class="text-present-large">Solver produces <strong class="text-koningsblauw">proof</strong></p>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="text-center">
        <p class="text-present">Proofs can be very large → need a <strong class="text-koningsblauw">proof checker</strong></p>
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="grid grid-cols-2 gap-6">
        <div class="p-4 bg-blue-50 rounded-lg">
          <p class="text-present font-semibold text-center mb-2">Project</p>
          <p class="text-present-small">Proof checker collaboration at TU Delft</p>
          <p class="text-present-small"><strong>Supervisor + Konstantin Sidorov + Maarten Flippo</strong></p>
        </div>
        
        {#if props.animation >= 6}
          <div class="p-4 bg-bosgroen-muted rounded-lg">
            <p class="text-present font-semibold text-center mb-2">My research goals</p>
            <p class="text-present-small {props.animation >= 7 ? '' : 'invisible'}">• Contribute to proof checker</p>
            <p class="text-present-small {props.animation >= 8 ? '' : 'invisible'}">• Understand specific components</p>
            <p class="text-present-small {props.animation >= 9 ? '' : 'invisible'}">• Make it easier to extend</p>
          </div>
        {/if}
      </div>
    {/if}
  </div>
</div>