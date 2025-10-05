<script module>
  import Highlight from "../components/Highlight.svelte";

	export { rules, solutionExample, model, unsat, inferences, inference2, conflSet };

  const modelCode = `alldifferent(A1, B1, .., E1)\nalldifferent(A2, B2, ..., E2)\n...\nalldifferent(A1, A2, ..., A5)\n...`

  const inferences1 = [`A3 = 2 → A5 ≠ 2`,
  `A3 = 2 → A2 ≠ 2`,
  `A5 = 5 → A2 ≠ 5`,
  `A2 = 3 → A4 ≠ 3`,
  `A3 = 2 → A4 ≠ 2`]

  const deductionImm = `T → ⊥ (conflict set)\n-----\nT → ⊥`

  /**
   * @param {number} infStep
   */
  function addInferences(infStep) {
    return inferences1.map((s, i) => {
      if (i >= infStep) {
        return ''
      } else {
        return s
      }
    }).join('\n')
  }
  const deduction1 = `(1) A3 = 2 → ⊥`
  const deduction2 = `(2) A3 = 5 → ⊥`
</script>

<style>
  .box {
    border: 2px solid #ff6347;
    padding: 0.5rem;
    margin-top: var(--box-margin);
    border-radius: 8px;
  }
</style>

{#snippet rules()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="font-bold text-present-large text-center flex justify-center items-center">Example CP Problem</div>
  <div class="flex flex-col justify-center text-present ml-8">
    <ul class="list-disc pl-5">
      <li class="mb-4">Latin square: like Sudoku</li>
      <li class="mb-4">Each cell: 1, 2, 3, 4, or 5</li>
      <li class="mb-4">Some values already filled</li>
      <li>No duplicate values in row/column</li>
    </ul>
  </div>
</div>
{/snippet}

{#snippet solutionExample()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="flex flex-col justify-center text-present ml-8">
    <ul class="list-disc pl-5">
      <li class="mb-4">Example solution</li>
    </ul>
  </div>
</div>
{/snippet}

{#snippet inference2()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="flex flex-col justify-center text-present ml-8">
    <span><Highlight lang="txt" code={`${addInferences(0)}\n`}></Highlight></span>
    <Highlight lang="txt" code={deduction2}></Highlight>
  </div>
</div>
{/snippet}

{#snippet inferences(/** @type {number} */ step)}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="flex flex-col justify-center text-present ml-8">
    <span>Inferences</span>
    <span><Highlight lang="txt" code={`${addInferences(step)}\n`}></Highlight></span>
    <span>Fact</span>
    <Highlight lang="txt" code={deduction1}></Highlight>
  </div>
</div>
{/snippet}

{#snippet conflSet()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="flex flex-col justify-center text-present ml-8">
    <span class="font-bold">Alldifferent checker: stronger reasoning</span>
    <span>Domain union: {`{2, 3, 5}`}</span>
    <span>Variables: {`{A2, A3, A4, A5}`}</span>
    <span class="mt-4">{`|union of variable domains| <`}</span>
    <span>{`|variables| → ⊥`}</span>
    <!-- <span>&nbsp;</span>
    <Highlight lang="txt" code={deductionImm}></Highlight> -->
  </div>
</div>
{/snippet}

{#snippet unsat()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="flex flex-col justify-center text-present ml-8">
    <ul class="list-disc pl-5">
      <li class="mb-4">No solution: <em>unsatisfiable</em></li>
    </ul>
  </div>
</div>
{/snippet}

{#snippet model()}
<div class="flex flex-col justify-center gap-4 pl-6">
  <div class="text-present-large font-bold text-center flex justify-center items-center">Model</div>
  <div class="ml-8 box">
    <div class="text-present">
      <code class="font-bold">alldifferent(x1, x2, ...)</code>
      <div>All variables x1, x2, ... must take distinct values</div>
    </div>
  </div>
  <div class="flex flex-col justify-center text-present ml-8">
    <Highlight lang="txt" code={modelCode}>

    </Highlight>
    <!-- <ul class="list-disc pl-5 mt-4">
      <li class="mb-4">Pairwise reasoning</li>
    </ul> -->
  </div>
</div>
{/snippet}