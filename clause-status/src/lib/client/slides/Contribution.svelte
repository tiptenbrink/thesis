<script lang="ts">
let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

setLastAnimation(4)
</script>

<style>
  .highlight {
    font-weight: bold;
    color: #ff6347;
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-present-title flex justify-center items-center">My Contribution</div>
  <div class="flex flex-col justify-center w-full items-center text-present ml-8">
    <div>Goal: make supporting new constraints easier. How?</div>
    <ul class="list-disc">
      <li class:invisible={animation < 1}>Extend proof checker with <span class="highlight">alldifferent</span> (partial) and <span class="highlight">cumulative</span></li>
      <li class:invisible={animation < 2}>Building blocks for other constraints</li>
      <li class:invisible={animation < 3}>Domain reasoning machinery</li>
      <li class:invisible={animation < 4}>Contributions to redesign (implement deduction step)</li>
    </ul>
  </div>
</div>