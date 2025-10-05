<script>
  import nurseroster from '$lib/assets/nurseroster.jpeg'
</script>

<style>
  li + li {
    margin-top: var(--present-bullet-margin);
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Constraint Programming</div>
  <div class="flex flex-col items-center text text-present">
    <ul class="list-disc">
      <li>CP is paradigm for solving combinatorial problems</li>
      <li>Problem = variables, set of well-defined constraints</li>
    </ul>
    <div class="p-4 h-[300px]">
      <p><em>Example:</em> nurse roster</p>
      <img class="h-[90%]" src={nurseroster} alt="nurseroster">
    </div>
  </div>
</div>