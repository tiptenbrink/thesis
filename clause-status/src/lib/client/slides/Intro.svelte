<script lang="ts">
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import nurseroster from '$lib/assets/nurseroster.jpeg'
  setLastAnimation(0)
</script>

<style>
  li + li {
    margin-top: var(--present-bullet-margin);
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Constraint Programming</div>
  <div class="flex flex-col items-center text text-present">
    <ul class="list-disc">
      <li>CP is paradigm for solving combinatorial problems</li>
      <li>Problem = variables + well-defined constraints</li>
      
    </ul>
    <!-- <div class:invisible={animation === 0}>1. Model the problem with constraints</div>
    <div class:invisible={animation < 2}>Example: alldifferent constraint</div>
    <div class:invisible={animation < 3}>2. Give it to a solver</div> -->
  </div>
</div>