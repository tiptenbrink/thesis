<script module>
  export const animations = 7
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  import cumulFigure from '$lib/assets/cumulFigure.svg'
  import cumulFigureClaim from '$lib/assets/cumulFigureClaim.svg'
  import cumulFigureBad from '$lib/assets/cumulFigureBad.svg'
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-4">Mini-claim example</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="p-4 bg-groen-muted-light rounded-lg">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-present font-semibold mb-2">Hospital scheduling:</p>
            <p class="text-present-small">• 2 👨‍⚕️👩‍⚕️ doctors available</p>
            {#if props.animation >= 2}
              <p class="text-present-small">• Alice: 1 👨‍⚕️, 1 ⏰ hour</p>
              <p class="text-present-small">• Bob: 1 👩‍⚕️, 2 ⏰⏰ hours</p>
              <p class="text-present-small">• Carol: 2 👩‍⚕️👨‍⚕️, 2 ⏰⏰ hours</p>
            {/if}
          </div>
          <div class={(props.animation >= 3 ? "" : "invisible ") + "flex items-center justify-center"}>
            <img src={props.animation >= 5 ? cumulFigureClaim : cumulFigure} alt="cumul figure" class="max-w-full h-[90%]">
          </div>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="grid grid-cols-2 gap-4">
        <div class="p-4 bg-yellow-50 rounded-lg text-center">
          <p class="text-present font-semibold text-oranje">Example scenario:</p>
          <p class="text-present-small">Alice at t=0, Bob at t=1, Carol between t=0 and t=2</p>
        </div>
        {#if props.animation >= 6}
        <div class="p-4 bg-bordeaux text-white rounded-lg text-center">
          <p class="text-present font-semibold">Mini-claim:</p>
          <p class="text-present-small mt-2">This scenario violates constraint!</p>
        </div>
        {/if}
      </div>
    {/if}
    
  </div>
</div>