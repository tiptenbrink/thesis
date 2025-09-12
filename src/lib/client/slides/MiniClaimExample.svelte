<script module>
  export const animations = 11
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  import cumulFigure from '$lib/assets/cumulFigure.svg'
  import cumulFigureClaim from '$lib/assets/cumulFigureClaim.svg'
  import cumulFigureBad from '$lib/assets/cumulFigureBad.svg'
  import cumulFigureBad2 from '$lib/assets/cumulFigureBad2.svg'
  import cumulFigureBad3 from '$lib/assets/cumulFigureBad3.svg'

</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-4">Subclaim example</h1>
  
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
            {#if props.animation === 3}
            <p class="text-present-small"><strong>Cumulative constraint:</strong> tasks that must be scheduled and use fixed capacity resource</p>
            {/if}
          </div>
          <div class={(props.animation >= 4 ? "" : "invisible ") + "flex items-center justify-center"}>
            <img src={props.animation < 6 ? cumulFigure : (props.animation === 6 ? cumulFigureClaim : (props.animation === 7 ? cumulFigureBad : (props.animation === 8 ? cumulFigureBad2 : cumulFigureBad3)))} alt="cumul figure" class="max-w-full h-[90%]">
          </div>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="grid grid-cols-2 gap-4">
        <div class="p-4 bg-yellow-50 rounded-lg text-center">
          <p class="text-present font-semibold text-oranje">Example scenario:</p>
          <p class="text-present-small">Alice at t=0, Bob at t=1, Carol between t=0 and t=2</p>
        </div>
        <div class={"p-4 bg-bordeaux text-white rounded-lg text-center " + (props.animation >= 10 ? '' : 'invisible')}>
          <p class="text-present font-semibold">Subclaim:</p>
          <p class="text-present-small mt-2">This scenario violates constraint</p>
          <p class="text-present-small">Useful: possibility is eliminated</p>
        </div>
      </div>
    {/if}
    
  </div>
</div>