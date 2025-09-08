<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>
<div class="grid grid-rows-[5fr_1fr_1fr_2fr] h-full w-full">
  <div class="text-center flex items-center justify-center px-6">
    <div class="space-y-4">
      <div class="text-present-xl leading-relaxed">
        <span class="font-bold text-koningsblauw relative">
          <span class="px-2 py-1 rounded {props.animation === 3 ? 'bg-donkergrijs-muted text-white' : ''}">Proof</span>
          <span class="font-semibold text-paars px-2 py-1 rounded {props.animation === 4 ? 'bg-donkergrijs-muted text-white' : ''}">Step</span>
          <span class="px-2 py-1 rounded {props.animation === 3 ? 'bg-donkergrijs-muted text-white' : ''}">Checking</span>
        </span>
        <span class="text-donkergrijs-muted font-light">in a</span>
        <span class="font-semibold text-bosgroen relative">
          <span class="px-2 py-1 rounded {props.animation === 1 ? 'bg-donkergrijs-muted text-white' : ''}">Constraint Programming</span>
        </span>
        <span class="font-semibold text-bordeaux relative">
          <span class="px-2 py-1 rounded {props.animation === 2 ? 'bg-donkergrijs-muted text-white' : ''}">Unsatisfiability</span>
        </span>
        <span class="font-bold text-koningsblauw relative">
          <span class="px-2 py-1 rounded {props.animation === 3 ? 'bg-donkergrijs-muted text-white' : ''}">Proof Checker</span>
        </span>
      </div>
    </div>
  </div>
  
  <div class="m-auto text-present-large font-semibold">
    Tip ten Brink
  </div>
  <div class="m-auto text-present font-medium">
    Supervisor: E. Demirović
  </div>
  <div></div>
</div>
