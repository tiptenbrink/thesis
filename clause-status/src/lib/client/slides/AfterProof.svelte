<script>
  
</script>

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

  .floating {
    font-size: 1.5rem;
    font-style: italic;
    text-align: center;
    margin-top: 1rem;
    color: #555;
  }

</style>

<div class="grid grid-rows-[2fr_14fr] h-full w-full p-10">
  <div class="font-bold text-present-xl text-center flex justify-center items-center">Less complexity: more reliability</div>
  <div class="flex flex-col justify-center items-c text text-present">
    <ul class="list-disc pl-8">
      <li>Simple steps</li>
      <li>No heuristics or advanced optimizations necessary</li>
      <li>More reliability</li>
    </ul>
    <div class="box">
      <span class="highlight">Questions:</span>
      <ul class="list-disc ml-8">
        <li>Solutions are proofs of <em>satisfiability</em></li>
        <li>Solution for Z=10, unsatisfiable for Z&lt;10<p class="ml-8">→ Optimal</p></li>
        <li>Many modern CP solvers are <span class="highlight">Conflict Driven Clause Learning (CDCL)</span> solvers:
          <p class="ml-8">
            → Facts generated during solving
          </p>
        </li>
      </ul>
    </div>
    <div class="floating">
      
    </div>
  </div>
</div>
