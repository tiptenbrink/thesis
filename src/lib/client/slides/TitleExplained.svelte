<script module>
  export const animations = 7
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center space-y-6">
  {#if props.animation >= 1}
    <div class="p-4 bg-yellow-50 rounded-lg text-center">
      <p class="text-present">Why aren't we worried about <strong> solution</strong> case?</p>
    </div>
  {/if}

  {#if props.animation >= 2}
    <div class="text-center flex items-center justify-center">
      <div class="space-y-4">
        <div class="text-present-xl leading-relaxed">
          <span class="font-bold text-koningsblauw relative">
            <span class="px-2 py-1 rounded {props.animation === 4 ? 'bg-donkergrijs-muted text-white' : ''}">Proof</span>
            <span class="font-semibold text-paars px-2 py-1 rounded {props.animation === 5 ? 'bg-donkergrijs-muted text-white' : ''}">Step</span>
            <span class="px-2 py-1 rounded {props.animation === 4 ? 'bg-donkergrijs-muted text-white' : ''}">Checking</span>
          </span>
          <span class="text-donkergrijs-muted font-light">in a</span>
          <span class="font-semibold text-bosgroen relative">
            <span class="px-2 py-1 rounded {props.animation === 6 ? 'bg-donkergrijs-muted text-white' : ''}">Constraint Programming</span>
          </span>
          <span class="font-semibold text-bordeaux relative">
            <span class="px-2 py-1 rounded {props.animation === 3 ? 'bg-donkergrijs-muted text-white' : ''}">Unsatisfiability</span>
          </span>
          <span class="font-bold text-koningsblauw relative">
            <span class="px-2 py-1 rounded {props.animation === 4 ? 'bg-donkergrijs-muted text-white' : ''}">Proof Checker</span>
          </span>
        </div>
        <div class="text-present mt-4 {props.animation === 3 ? '' : 'invisible'}">
          Unsatisfiable = problem has no solution
        </div>
      </div>
    </div>
  {/if}
</div>