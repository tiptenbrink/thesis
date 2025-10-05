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
    padding: 1rem;
    margin-top: var(--box-margin);
    border-radius: 8px;
  }

</style>

<div class="grid grid-rows-[2fr_10fr] h-full w-full p-10">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Proofs of unsatisfiability</div>
  <div class="flex flex-col items-c text text-present">
    <ul class="list-disc pl-20">
      <li>Proof that problem <em>instance</em> is unsatisfiable</li>
      <li>Requires elimination of entire search space: hard!</li>
      <li>CP solvers do search and <span class="highlight">propagation</span></li>
    </ul>
    <p class="mt-2">Proof is:</p>
    <div class="box">
      <ul class="list-disc pl-5">
      <li>List of steps</li>
      <li>Each step can be checked using previous steps</li>
      <li>Final line concludes unsatisfiability</li>
      </ul>
    </div>
    <p class="pl-20 mt-2">No search in proofs.</p>
  </div>
</div>