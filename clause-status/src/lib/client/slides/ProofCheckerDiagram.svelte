<script lang="ts">
  import Highlight from "./components/Highlight.svelte";
  // import diagram from '$lib/assets/checker.drawio.svg'
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(0)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-cols-[7fr_2fr] h-full w-full p-10">
  <img alt="diagram" class="w-[85%]" src='/checker.drawio.svg'>
  <div class="text-present flex flex-col gap-4">
    <span>Blue/shaded components: my contribution</span>
    <span>Arrows: sent to/delegated to</span>
    <span>Arrows with dashed lines: is used by</span>
  </div>
</div>

<style>
  li + li {
    margin-top: var(--present-bullet-margin);
  }
  .highlight {
    font-weight: bold;
    color: #ff6347; /* Tomato color */
  }
  .highlight2 {
    font-weight: bold;
  }

  .box {
    border: 2px solid #ff6347;
    padding: 0.5rem;
    margin-top: var(--box-margin);
    border-radius: 8px;
  }
</style>