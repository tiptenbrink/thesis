<script module>
  export const animations = 4
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
          <p class="text-present {props.animation >= 3 ? 'bg-geel-muted p-2 rounded' : ''}">• Check that every subclaim is true</p>
          {#if props.animation >= 2}
            <p class="text-present">• Check that all subclaims being true imply the main claim</p>
          {/if}
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="text-center text-present">
        <span class="inline-block p-3 bg-groen-muted-light text-black rounded-lg font-bold ">
          My contribution!
        </span>
      </div>
    {/if}
  </div>
</div>