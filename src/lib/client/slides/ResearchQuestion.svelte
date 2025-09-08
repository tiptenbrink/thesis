<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  {#if props.animation >= 0}
    <div class="text-center mb-8">
      <h1 class="text-present-xl font-bold text-blue-700 mb-6">Research Question</h1>
      <div class="p-6 bg-blue-50 rounded-lg">
        <p class="text-present-large italic font-medium">
          How can we build <strong>formally verified checkers</strong> for individual proof steps?
        </p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="grid grid-cols-2 gap-8">
      <div class="text-center">
        <h2 class="text-present-large font-semibold text-green-700 mb-4">Our Focus</h2>
        <div class="space-y-2">
          <p class="text-present">Individual proof steps</p>
          <p class="text-present">Two key constraints:</p>
          <p class="text-present-small text-purple-600">Alldifferent • Cumulative</p>
        </div>
      </div>
      
      <div class="text-center">
        <h2 class="text-present-large font-semibold text-orange-700 mb-4">Approach</h2>
        <div class="space-y-2">
          <p class="text-present">Machine-checked proofs</p>
          <p class="text-present">Using Rocq theorem prover</p>
          <p class="text-present-small text-blue-600">Highest trust</p>
        </div>
      </div>
    </div>
  {/if}
</div>