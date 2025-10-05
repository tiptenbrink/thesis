<script lang="ts">
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(4)
</script>

<style>
  .highlight {
    font-weight: bold;
    color: #ff6347;
  }
  .box {
    border: 2px solid #ff6347;
    padding: 1rem;
    margin-top: 1rem;
    border-radius: 8px;
  }
    .nested {
      margin-left: 1.5rem;
  }
</style>

<div class="grid grid-rows-[1fr_9fr] h-full w-full px-5 pt-2">
  <div class="text-present-large flex justify-center font-bold">Summary</div>
  <div class="grid grid-cols-[3fr_4fr] h-full">
    <div class="flex flex-col p-4 h-full text-present-small">
      <div class={"box " + (animation > 0 ? '' : 'invisible')}>
        <p class="highlight">Complexity causes bugs</p>
        <p>• We want to verify optimality/infeasibility claims</p>
        <p>• Proof certification can do this for CP</p>
      </div>
      <div class={"box " + (animation > 1 ? '' : 'invisible')}>
        <p class="highlight">Certification</p>
        <p>• Proving correctness of a program</p>
        <p>• All details must be there</p>
        <p>• Don't verify the solver; verify the checker</p>
      </div>
      
    </div>
    <div class="flex flex-col p-4  text-present-small">
      <div class={"box " + (animation > 2 ? '' : 'invisible')}>
        <p class="highlight">CP Proof Checker</p>
        <p>• Solver outputs proof log</p>
        <p>• Proof logs are checked step by step</p>
        <p>• Delegation to individual constraint checkers</p>
        <p>• Stronger reasoning: shorter proofs</p>
      </div>
      <div class={"box " + (animation > 3 ? '' : 'invisible')}>
        <p class="highlight">Contribution</p>
        <p>• Support constraints (alldifferent, cumulative)</p>
        <p>• Building blocks</p>
        <p>• Domain machinery</p>
        <p>• Implementation help with checker redesign</p>
      </div>
    </div>
    <div class="flex flex-col justify-between p-4">

    </div>
    <!-- <div class="box">
      <span class="highlight">Proof Checking</span>
      <ul class="list-disc ml-8 mt-4">
        <li>Easier than solving</li>
        <li>Increases reliability</li>
      </ul>
    </div>

    <div class="box">
        <span class="highlight">CP Challenges</span>
        <ul class="list-disc ml-8 mt-4">
          <li>Many constraint types</li>
          <li>Complex propagation</li>
        </ul>
      </div>

    <div class="box">
      <span class="highlight">Formal Verification</span>
       <ul class="list-disc ml-8 mt-4">
          <li>Proves absence of bugs</li>
          <li>Uses Rocq (Coq)</li>
            <div class = "nested">✔ Proofs as Programs</div>
            <div class = "nested">✔ Type checking = Proof</div>
        </ul>
    </div>

      <div class="box">
      <span class="highlight">Goal</span>
       <ul class="list-disc ml-8 mt-4">
          <li>Accessible Constraint Formalization</li>
        </ul>
    </div> -->

  </div>
</div>