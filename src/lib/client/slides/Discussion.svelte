<script module>
  export const animations = 7
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Discussion</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 1}
      <div class="p-4 bg-bosgroen text-white rounded-lg">
        <p class="text-present font-semibold">Demonstrated feasibility of formally verified CP checker through:</p>
        {#if props.animation >= 2}
          <p class="text-present-small mt-2">• Implementation: two constraints + deduction step</p>
          <p class="text-present-small">• Making it extensible: methodology + building blocks</p>
        {/if}
        {#if props.animation >= 3}

        <p class="text-present font-semibold">Advanced understanding of miniclaim checkers</p>
        {/if}
        {#if props.animation >= 4}

        <p class="text-present font-semibold">Perforated intervals can be used outside proof checking</p>
        {/if}
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="p-4 bg-bordeaux-light rounded-lg">
        <p class="text-present font-semibold text-bordeaux">Limitations:</p>
        <p class="text-present-small mt-2">• Higher formal verification burden than other approaches</p>
        {#if props.animation >= 6}
          <p class="text-present-small">• No guidance for formal verification in methodology</p>
        {/if}
      </div>
    {/if}
    
  </div>
</div>