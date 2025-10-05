<script lang="ts">
  import Highlight from "./components/Highlight.svelte";
  import diagram from '$lib/assets/simple.drawio.svg'
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(0)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="text-present-title flex justify-center font-bold">Proof Checker</div>
  <div class="flex flex-col justify-center items-center">
    <img alt="diagram" class="w-[50%]" src='/simple.drawio.svg'>
    
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
    padding: 1rem;
    margin-top: 2rem;
    border-radius: 8px;
  }
</style>