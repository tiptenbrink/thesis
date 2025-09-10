<script module>
  export const animations = 1
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="text-center">
    <h1 class="text-present-xl font-bold text-koningsblauw mb-6">Research Question</h1>
    <div class="p-6 bg-blue-50 rounded-lg">
      <p class="text-present-large italic font-medium">
        How can we develop <span class="bg-donkergrijs rounded-2xl"><span class="invisible">formally verified</span></span> checkers for individual proof steps in a CP unsatisfiability proof checker?
      </p>
    </div>
  </div>
</div>