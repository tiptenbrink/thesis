<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="text-center">
    <h1 class="text-present-xl font-bold text-koningsblauw mb-6">Research Question</h1>
    <div class="p-6 bg-blue-50 rounded-lg">
      <p class="text-present-large italic font-medium">
        How can we build{#if props.animation >= 1} <strong>formally verified</strong>{/if} checkers for individual proof steps?
      </p>
    </div>
  </div>
</div>