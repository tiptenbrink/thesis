<script lang="ts">
    import Highlight from "./components/Highlight.svelte";

    let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  
    setLastAnimation(1)

    const inferences1 = `inferences...\n\n\n\n`
  const deduction1 = `-----\n(1) A3 = 2 → ⊥`


const inferences2 = `...\n\n\n\n`
  const deduction2 = `-----\n(2) A3 = 5 → ⊥`

const conclusion = `-----\nT → ⊥ by [1,2]`;
  </script>
  
  <div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
    <div class="font-bold text-present-title text-center flex justify-center items-center">
      Proof log
    </div>
    <div class="flex flex-col gap-8 items-center justify-center text text-present">
      <div class="w-full flex flex-wrap justify-between">
        <div class="flex flex-col gap-1">
          <span class='invisible'><Highlight lang="txt" code={inferences1}></Highlight></span>
          <Highlight lang="txt" code={deduction1}></Highlight>
        </div>
        <div class="flex flex-col gap-1">
          <span class='invisible'><Highlight lang="txt" code={inferences2}></Highlight></span>
          <Highlight lang="txt" code={deduction2}></Highlight>
        </div>
        <div class="flex flex-col gap-1">
          <span class="invisible"><Highlight lang="txt" code={inferences2}></Highlight></span>
          <Highlight lang="txt" code={conclusion}></Highlight>
        </div>
      </div>
      <ul class="list-disc pl-5 mt-4">
        <li class="mb-4">Sequence of facts</li>
        <li class="mb-4" class:invisible={animation < 1}>Model, step 1, step 2, ..., step i → step i + 1 (in polynomial time)</li>
      </ul>
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
  