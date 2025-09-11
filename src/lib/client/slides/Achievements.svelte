<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="space-y-6">
    <div class="text-center">
      <p class="text-present-xl font-bold">How I achieved this</p>
    </div>
    
    <div class="space-y-4">
      {#if props.animation >= 1}
        <div class="text-center">
          <p class="text-present-large"><strong class="text-koningsblauw">Check solver work</strong></p>
          <p class="text-present-small">For two common subproblems</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="text-center">
          <p class="text-present-large"><strong class="text-paars">Check solver work</strong></p>
          <p class="text-present-small">Combine knowledge from different subproblems</p>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="text-center">
          <p class="text-present-large"><strong class="text-bordeaux">Methodology</strong></p>
          <p class="text-present-small">Handle more subproblems</p>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="text-center">
          <p class="text-present-large"><strong class="text-bosgroen">Reusable component</strong></p>
          <p class="text-present-small">Integer (-1, 0, 4, etc.) set reasoning, maximum, minimum </p>
        </div>
      {/if}
    </div>
  </div>
</div>