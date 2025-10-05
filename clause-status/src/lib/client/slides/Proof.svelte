<script lang="ts">
  import { untrack } from "svelte";
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import Highlight from "./components/Highlight.svelte";

  let context = $state('')
  let goal = $state('')
  let steps = $state('')

  interface State {
    info: string
    context: string
    first_goal: string
    other_goals: string[],
    steps: string[]
  }

  type Result = State | { error: string }

  async function proofNext() {
    const res = await fetch('/presentation/proof/next')
    return await res.json() as Result
  }

  async function proofBack() {
    const res = await fetch('/presentation/proof/back')
    return await res.json() as Result
  }

  async function proofReset() {
    const res = await fetch('/presentation/proof/reset')
    return await res.json() as Result
  }

  function splitAtFirstWhitespaceAfter35(str: string, length: number) {
    if (str.length <= length) return [str, ''];
    console.log(`spl;len=${length};str=${str}`)

    // Find first whitespace after index 35
    const index = str.slice(length).search(/\s/);
    if (index === -1) return [str, '']; // No whitespace found after index 35

    const splitIndex = length + index + 1; // +1 to skip the space itself
    if (splitIndex > 35) {
      return splitAtFirstWhitespaceAfter35(str, length-5)
    }
    const firstPart = str.slice(0, splitIndex);
    const secondPart = str.slice(splitIndex);

    return [firstPart, secondPart];
  }

  function handleProofResponse(res: Result) {
    if ("error" in res) {
      goal = res.error
      context = ''
      steps = ''
    } else {
      const mapped = res.context.split('\n').flatMap(l => {
        const parts = []
        let current = l
        while (current.length > 35) {
          const [left, right] = splitAtFirstWhitespaceAfter35(current, 30)
          current = `   ${right}`
          parts.push(left)
        }
        parts.push(current)
        return parts
      })
      context = mapped.join('\n')
      
      goal = `${res.first_goal}`

      let stepsJoined = res.steps.slice(-3).join('\n')
      if (res.steps.length > 3) {
        stepsJoined = `...\n${stepsJoined}`
      }
      steps = stepsJoined
    }
  }
  
  setLastAnimation(39)

  let lastAnimation = $state(0)

  $effect(() => {
    let result = animation - untrack(() => lastAnimation)
    lastAnimation = animation
    if (animation === 0) {
      proofReset().then((r) => handleProofResponse(r))
    } else if (result > 0) {
      proofNext().then((r) => handleProofResponse(r))
    } else if (result < 0) {
      proofBack().then((r) => handleProofResponse(r))
    }
  })
</script>

<style>
  /* .fill-auto {
    column-count: 2;
    column-fill: balance;
    white-space: pre-wrap;
  }

  #pre {
    white-space: pre-wrap;
  } */

  .highlight {
    font-weight: bold;
    color: #ff6347;
  }
  .nested {
      margin-left: 1.5rem;
  }
</style>

<div class="grid grid-rows-[6fr_2fr_3fr] h-full p-10 text-present-sx">
      <!-- <ul class="list-disc">
          <li>Prove theorem of correctness</li>
      </ul> -->
      <div class="columns-2 overflow-x-hidden whitespace-pre-wrap">
        <Highlight lang="coq" code={context}></Highlight>
      </div>
      <div class="flex flex-col items-center">
        <span class="text-present">Goal:</span><Highlight lang="coq" code={goal}></Highlight>
      </div>
      <div>
        <span class="text-present-small">Steps ({animation}):</span>
        <Highlight lang="coq" code={steps}></Highlight>
      </div>
      <!-- {#if animation > 0}
        <div class="flex justify-center text-present-large mt-4">Tricky! Proof log:</div>
        <Highlight lang="txt" {code}></Highlight>
      {/if}
      {#if animation > 1}
        <ul class="list-disc mt-4">
          <li>Alldifferent reasoning in checker also needs to be correct</li>
      </ul>
      {/if} -->
</div>