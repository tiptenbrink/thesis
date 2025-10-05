<script lang="ts">
  let proofText = $state('')
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

  function handleProofResponse(res: Result) {
    console.log(res)
    if ("error" in res) {
      proofText = res.error
      steps = ''
    } else {
      proofText = `${res.context}\n===\n${res.first_goal}`
      steps = res.steps.slice(-3).join('\n')
    }
  }
</script>