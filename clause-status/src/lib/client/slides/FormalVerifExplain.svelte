<script lang="ts">
    import { fade } from "svelte/transition";
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import Highlight from "./components/Highlight.svelte";
  
  setLastAnimation(3)

const coqCode = `
  (* ... *)
Proof.
  (* ... *)
  destruct (x1 =? x2)%string eqn:Hx1neqx2; try congruence.
  destruct (mem x1 X && mem x2 X) eqn:Hmem; try congruence.
  apply andb_prop in Hmem. destruct Hmem as [Hmemx1 Hmemx2]. 
  rewrite MSetString.mem_spec in *.
  destruct (st x1) as [| n] eqn:Hx1st; try congruence.
  destruct (st x2) as [| m] eqn:Hx2st; try congruence.
  destruct (n =? m)%Z eqn:Hnm; try congruence.
  (* ... *)
Qed.`
</script>

<style>
</style>

<div class="grid grid-rows-[1fr_6fr] h-full w-full px-10 pt-2">
<div class="font-bold text-present-large text-center flex justify-center items-center">Proof example</div>
<div class="flex flex-col items-center">
  {#if animation > 0}
  <div class="text-present">Focus on the repetition!</div>
  {/if}
  {#if animation > 1}
  <div class="text-present-small"><Highlight lang="coq" code={coqCode}></Highlight></div>
  {/if}
  {#if animation > 2}
    <div class="text-present mt-2">Automation?</div>
  {/if}
</div>

</div>