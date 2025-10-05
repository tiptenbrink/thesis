<script lang="ts">
  import AllDiffSvg from "$lib/assets/AllDiffSvg.svelte";
let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
import Highlight from "./components/Highlight.svelte";

setLastAnimation(6)

const codeFn = `alldifferent_is_conflict(X, st)`
</script>

<style>
.highlight {
  font-weight: bold;
  color: #ff6347;
}
 .code {
  font-family: 'Courier New', Courier, monospace;
  background-color: #f0f0f0;
  padding: 0.5rem;
  border-radius: 4px;
  font-size: 1.1rem;
}
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
<div class="font-bold text-present-title text-center flex justify-center items-center">How to prove?</div>
<div class="flex flex-col items-center text-present gap-2">
  <ul class="list-disc pl-6 space-y-2 text-gray-800">
    <li class:invisible={animation < 1}>
      <span class="italic">A</span>: <code>String -&gt; ℤ</code> satisfies <code>alldifferent</code> with <span class="italic">variables</span>
    </li>
    <li class:invisible={animation < 2}>
      <span class="italic">A</span> is injective for <span class="italic">variables</span>: <span class="italic">A(x) = A(y) → x = y</span>
    </li>
    <li class:invisible={animation < 3}>
      Then, <code>map(A, <span class="italic">variables</span>)</code> has no duplicates if <span class="italic">variables</span> has no duplicates
    </li>
    <li class:invisible={animation < 4}>
      <code>map(A, <span class="italic">variables</span>)</code> has same length as <span class="italic">variables</span>
    </li>
    <li class:invisible={animation < 5}>
      Every element in this map is in <span class="italic">union of variable domains</span>
    </li>
    <li class:invisible={animation < 6}>
      Therefore, <span class="font-mono">|<span class="italic">union of variable domains</span>| ≥ |<span class="italic">variables</span>|</span>
    </li>
  </ul>  
</div>
</div>