<script>
  
</script>

<style>
  li + li {
    margin-top: 1rem;
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

  .floating {
    font-size: 1.5rem;
    font-style: italic;
    text-align: center;
    margin-top: 1rem;
    color: #555;
  }

  .nested {
    margin-left: 2rem;
    font-size: 0.9em;
    color: #444;
  }

</style>

<div class="grid grid-rows-[2fr_26fr] h-full w-full p-10">
  <div class="font-bold text-5xl text-center flex justify-center items-center">Proof checking summary</div>
  <div class="flex flex-col justify-center text text-present">
    <div class="box">
      <span class="highlight">SAT vs UNSAT</span>
      <ul class="list-disc ml-8 mt-4">
        <li>Validity is easy</li>
        <li>Optimal or unsatisfiable is hard</li>
      </ul>
    </div>

    <div class="box mt-8">
      <span class="highlight">Modern CP solvers and proofs</span>
      <ul class="list-disc ml-8 mt-4">
        <li>CDCL-based solvers can be modified to produce unsatisfiability proofs
          <div class="nested">✔ Consist of verifiable step-by-step facts</div>
          <div class="nested">✔ Verified by <span class="highlight2">proof checkers</span></div>
        </li>
      </ul>
    </div>

    <div class="box mt-8">
      <span class="highlight">Proof checkers</span>
      <ul class="list-disc ml-8 mt-4">
        <li>Simpler</li>
        <li>No search or heavy optimization</li>
        <li>Checkers alone increase reliability</li>
      </ul>
    </div>
  </div>
</div>
