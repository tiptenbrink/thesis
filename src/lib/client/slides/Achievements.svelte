<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Key Contributions</h1>
  
  {#if props.animation >= 0}
    <!-- Top tier: Theory -->
    <div class="text-center mb-4">
      <div class="inline-block p-5 bg-purple-100 rounded-lg">
        <p class="text-present-large font-bold text-paars">Theoretical Foundation</p>
        <p class="text-present-small mt-2">Perforated intervals • Systematic approaches</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <!-- Second tier: Implementation -->
    <div class="grid grid-cols-3 gap-4 mb-4">
      <div class="p-4 bg-blue-100 rounded-lg text-center">
        <p class="text-present font-bold text-koningsblauw">Deduction</p>
        <p class="text-present-small">Fact combination</p>
      </div>
      <div class="p-4 bg-green-100 rounded-lg text-center">
        <p class="text-present font-bold text-bosgroen">Alldifferent</p>
        <p class="text-present-small">Hall's theorem</p>
      </div>
      <div class="p-4 bg-orange-100 rounded-lg text-center">
        <p class="text-present font-bold text-oranje">Cumulative</p>
        <p class="text-present-small">Timetable reasoning</p>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 2}
    <!-- Foundation: Formal verification -->
    <div class="text-center">
      <div class="inline-block p-4 bg-gray-100 rounded-lg">
        <p class="text-present-large font-bold text-donkergrijs">Formally Verified in Rocq</p>
        <p class="text-present-small mt-1 text-donkergrijs-muted">Machine-checked correctness proofs</p>
      </div>
    </div>
    
    <div class="text-center mt-6">
      <p class="text-present-large font-semibold text-bosgroen">Systematic foundation for CP-native proof checking</p>
    </div>
  {/if}
</div>