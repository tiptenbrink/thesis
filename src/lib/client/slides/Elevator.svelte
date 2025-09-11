<script module>
  export const animations = 5  // 0: nothing, 1: question, 2: best case, 3: worst case, 4: my research
</script>

<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="grid grid-cols-3 gap-8 items-center">
    <!-- Left: Doctor and nurse scheduling box (always visible) -->
    <div class="bg-white rounded-lg p-6 border-2 border-koningsblauw text-center space-y-4">
      <div class="text-present-xl">👨🏻‍⚕️</div>
      <div class="text-present-large font-bold text-koningsblauw">Doctor and nurse scheduling</div>
      <div class="text-present">
        Computer solvers are getting good
      </div>
    </div>

    <!-- Right two-thirds: Text content -->
    <div class="col-span-2 space-y-4">
      {#if props.animation >= 1}
        <div class="text-center">
          <p class="text-present-large">What if solver incorrectly says a schedule isn't possible?</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="grid grid-cols-2 gap-4">
          <div class="p-4 bg-bordeaux-muted rounded-lg text-center">
            <p class="text-present font-bold">Best case:</p>
            <p class="text-present-small mt-2">Delaying treatment</p>
          </div>
          <div class="p-4 bg-bordeaux text-white rounded-lg text-center {props.animation >= 3 ? '' : 'invisible'}">
            <p class="text-present font-bold">Worst case:</p>
            <p class="text-present-small mt-2">Fewer nurses on the night shift</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="text-center mt-6">
          <p class="text-present-large font-bold text-oranje">My research</p>
          <p class="text-present mt-2">New solver tools</p>
          <p class="text-present">Catch erroneous results before harm</p>
        </div>
      {/if}
    </div>
  </div>
</div>