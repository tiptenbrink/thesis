<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  import cumulFigure from '$lib/assets/cumulFigure.svg'
  
  // Toggle between different motivation approaches
  let motivationOption = "A" // Options: A (Healthcare-first), B (Problem-first), C (Trust-first)
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  {#if motivationOption === "A"}
    <!-- Option A: Healthcare-first approach -->
    <h1 class="text-present-xl font-bold text-center mb-4 text-bosgroen">Constraint Programming (CP)</h1>
    
    <div class="space-y-4">
      {#if props.animation >= 0}
        <div class="text-center">
          <p class="text-present-large">Paradigm for modeling and solving optimization problems</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-4 bg-groen-muted-light rounded-lg min-h-[18vw]">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <p class="text-present font-semibold mb-2">Example</p>
              <p class="text-present-small">2 doctors, 3 operations</p>
              {#if props.animation >= 2}
                <p class="text-present-small mt-1">Operations a, b need 1 doctor • Operation c needs 2 doctors</p>
              {/if}
              {#if props.animation >= 3}
                <p class="text-present-small mt-1"><strong>Cumulative constraint (studied in my thesis)</strong>: never exceed capacity</p>
              {/if}
            </div>
            <div class={(props.animation >= 4 ? "" : "invisible ") + "flex items-center justify-center"}>
              <img src={cumulFigure} alt="cumul figure" class="max-w-full h-[90%]">
            </div>
          </div>
        </div>
      {/if}
      
    </div>
    
  {:else if motivationOption === "B"}
    <!-- Option B: Problem-first approach -->
    <h1 class="text-present-xl font-bold text-center mb-4">The Trust Problem</h1>
    
    <div class="space-y-4">
      {#if props.animation >= 0}
        <div class="text-center">
          <p class="text-present-large">Complex solvers solve hard problems</p>
          <p class="text-present-small text-donkergrijs-muted mt-1">But can we trust their answers?</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-4 bg-blue-50 rounded-lg text-center">
          <p class="text-present font-semibold text-koningsblauw">The Challenge</p>
          <p class="text-present-small mt-1">When solver says <strong>"impossible"</strong> — how can we be sure?</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="text-center">
          <p class="text-present font-semibold text-geel">Solution</p>
          <p class="text-present-small text-donkergrijs-muted mt-1">Solvers record their reasoning</p>
        </div>
      {/if}
    </div>
    
  {:else}
    <!-- Option C: Trust-first approach -->
    <h1 class="text-present-xl font-bold text-center mb-4">Why Verification Matters</h1>
    
    <div class="space-y-4">
      {#if props.animation >= 0}
        <div class="text-center">
          <p class="text-present-large">Solvers make critical decisions</p>
          <p class="text-present-small text-donkergrijs-muted mt-1">Healthcare • Circuits • Resources</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-4 bg-blue-50 rounded-lg text-center">
          <p class="text-present font-semibold text-koningsblauw">The Challenge</p>
          <p class="text-present-small mt-1">When solver says <strong>"impossible"</strong> — how can we be sure?</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="text-center">
          <p class="text-present font-semibold text-geel">Solution</p>
          <p class="text-present-small text-donkergrijs-muted mt-1">Solvers record their reasoning</p>
        </div>
      {/if}
    </div>
  {/if}
</div>