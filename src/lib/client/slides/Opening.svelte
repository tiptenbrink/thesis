<script module>
  export const animations = 1
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  import tudelftLogo from '$lib/assets/TUDelft_logo_descriptor_rgb.svg'
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="text-center space-y-8">
    <h1 class="text-present-xl font-bold text-koningsblauw">MSc Defense</h1>
    
    <div class="space-y-4">
      <p class="text-present-large font-semibold">Tip ten Brink</p>
      <div class="grid grid-cols-2 gap-4 mx-auto">
        <div class="text-right">
          <p class="text-present-small">Thesis committee:</p>
        </div>
        <div class="text-left">
          <p class="text-present-small">Emir Demirović (supervisor)</p>
          <p class="text-present-small">Benedikt Ahrens</p>
        </div>
      </div>
      
    </div>
    
    <div class="flex justify-center">
      <img src={tudelftLogo} alt="TU Delft Logo" class="w-[30vw]">
    </div>
  </div>
</div>