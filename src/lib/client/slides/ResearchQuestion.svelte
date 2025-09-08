<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  {#if props.animation >= 0}
    <div class="p-6 bg-purple-50 rounded-lg text-center mb-6">
      <p class="text-present-large font-semibold text-paars mb-4">Why Individual Steps?</p>
      <p class="text-present">Proof logs contain many individual reasoning steps</p>
      <p class="text-present-small text-donkergrijs-muted mt-2">Each step must be individually verified for trust</p>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="text-center">
      <h1 class="text-present-xl font-bold text-koningsblauw mb-6">Research Question</h1>
      <div class="p-6 bg-blue-50 rounded-lg">
        <p class="text-present-large italic font-medium">
          How can we build <strong>formally verified checkers</strong> for individual proof steps?
        </p>
      </div>
    </div>
  {/if}
</div>