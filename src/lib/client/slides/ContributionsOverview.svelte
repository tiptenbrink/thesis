<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  
  // Toggle between different design approaches
  let designVersion = "A" // Options: A (Grid), B (Timeline), C (Pyramid), D (Circular), E (Stylish)
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-paars">My Contributions</h1>
  
  {#if designVersion === "A"}
    <!-- Design A: Grid Layout -->
    <div class="grid grid-cols-2 gap-6">
      {#if props.animation >= 1}
        <div class="p-4 bg-bosgroen-muted rounded-lg text-center shadow-md">
          <p class="text-present font-bold">Constraint checkers</p>
          <p class="text-present-small mt-1">Cumulative + Alldifferent</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="p-4 bg-koningsblauw-muted rounded-lg text-center shadow-md">
          <p class="text-present font-bold">Methodology</p>
          <p class="text-present-small mt-1">For developing new checkers</p>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="p-4 bg-bordeaux-muted rounded-lg text-center shadow-md">
          <p class="text-present font-bold">Deduction checker</p>
          <p class="text-present-small mt-1">Combines previous steps</p>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="p-4 bg-geel-muted rounded-lg text-center shadow-md">
          <p class="text-present font-bold">Perforated intervals</p>
          <p class="text-present-small mt-1">Domain representation theory</p>
        </div>
      {/if}
    </div>
    
  {:else if designVersion === "B"}
    <!-- Design B: Timeline Layout -->
    <div class="relative">
      <div class="absolute left-1/2 top-0 bottom-0 w-px bg-gray-300 transform -translate-x-1/2"></div>
      
      <div class="space-y-6">
        {#if props.animation >= 1}
          <div class="flex items-center">
            <div class="w-1/2 pr-8 text-right">
              <div class="p-3 bg-gray-50 rounded-lg">
                <p class="text-present font-bold">Constraint checkers</p>
                <p class="text-present-small">Cumulative + Alldifferent</p>
              </div>
            </div>
            <div class="w-4 h-4 bg-gray-400 rounded-full relative z-10"></div>
            <div class="w-1/2 pl-8"></div>
          </div>
        {/if}
        
        {#if props.animation >= 2}
          <div class="flex items-center">
            <div class="w-1/2 pr-8"></div>
            <div class="w-4 h-4 bg-gray-400 rounded-full relative z-10"></div>
            <div class="w-1/2 pl-8">
              <div class="p-3 bg-gray-50 rounded-lg">
                <p class="text-present font-bold">Methodology</p>
                <p class="text-present-small">For developing new checkers</p>
              </div>
            </div>
          </div>
        {/if}
        
        {#if props.animation >= 3}
          <div class="flex items-center">
            <div class="w-1/2 pr-8 text-right">
              <div class="p-3 bg-gray-50 rounded-lg">
                <p class="text-present font-bold">Deduction checker</p>
                <p class="text-present-small">Combines previous steps</p>
              </div>
            </div>
            <div class="w-4 h-4 bg-gray-400 rounded-full relative z-10"></div>
            <div class="w-1/2 pl-8"></div>
          </div>
        {/if}
        
        {#if props.animation >= 4}
          <div class="flex items-center">
            <div class="w-1/2 pr-8"></div>
            <div class="w-4 h-4 bg-gray-400 rounded-full relative z-10"></div>
            <div class="w-1/2 pl-8">
              <div class="p-3 bg-gray-50 rounded-lg">
                <p class="text-present font-bold">Perforated intervals</p>
                <p class="text-present-small">Domain representation theory</p>
              </div>
            </div>
          </div>
        {/if}
      </div>
    </div>
    
  {:else if designVersion === "C"}
    <!-- Design C: Pyramid Layout -->
    <div class="flex flex-col items-center space-y-4">
      {#if props.animation >= 1}
        <div class="text-center">
          <div class="inline-block p-4 bg-gray-50 rounded-lg">
            <p class="text-present font-bold">Constraint checkers</p>
            <p class="text-present-small">Cumulative + Alldifferent</p>
          </div>
        </div>
      {/if}
      
      <div class="flex space-x-8">
        {#if props.animation >= 2}
          <div class="p-3 bg-gray-50 rounded-lg text-center">
            <p class="text-present font-bold">Methodology</p>
            <p class="text-present-small">Development approach</p>
          </div>
        {/if}
        
        {#if props.animation >= 3}
          <div class="p-3 bg-gray-50 rounded-lg text-center">
            <p class="text-present font-bold">Deduction checker</p>
            <p class="text-present-small">Combines steps</p>
          </div>
        {/if}
      </div>
      
      {#if props.animation >= 4}
        <div class="text-center">
          <div class="inline-block p-4 bg-gray-50 rounded-lg">
            <p class="text-present font-bold">Perforated intervals</p>
            <p class="text-present-small">Foundation: Domain theory</p>
          </div>
        </div>
      {/if}
    </div>
    
  {:else if designVersion === "D"}
    <!-- Design D: Circular Layout -->
    <div class="relative w-full h-96 flex items-center justify-center">
      <div class="absolute w-48 h-48 border-2 border-gray-300 rounded-full"></div>
      
      {#if props.animation >= 1}
        <div class="absolute top-8 left-1/2 transform -translate-x-1/2 p-3 bg-gray-50 rounded-lg text-center">
          <p class="text-present font-bold">Constraint checkers</p>
          <p class="text-present-small">Cumulative + Alldifferent</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="absolute right-8 top-1/2 transform -translate-y-1/2 p-3 bg-gray-50 rounded-lg text-center">
          <p class="text-present font-bold">Methodology</p>
          <p class="text-present-small">Development approach</p>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 p-3 bg-gray-50 rounded-lg text-center">
          <p class="text-present font-bold">Deduction checker</p>
          <p class="text-present-small">Combines steps</p>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="absolute left-8 top-1/2 transform -translate-y-1/2 p-3 bg-gray-50 rounded-lg text-center">
          <p class="text-present font-bold">Perforated intervals</p>
          <p class="text-present-small">Domain theory</p>
        </div>
      {/if}
      
      <div class="text-center">
        <p class="text-present-large font-bold">4 Key</p>
        <p class="text-present-large font-bold">Contributions</p>
      </div>
    </div>
    
  {:else}
    <!-- Design E: Stylish Modern Layout -->
    <div class="relative bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 rounded-2xl p-6 h-full">
      {#if props.animation >= 1}
        <div class="mb-6 relative">
          <div class="absolute -inset-1 bg-gradient-to-r from-cyan-400 via-blue-500 to-indigo-600 rounded-xl blur opacity-20"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-xl p-6 shadow-xl border border-white/50">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-gradient-to-br from-cyan-500 to-blue-600 rounded-full flex items-center justify-center">
                <div class="w-6 h-6 bg-white rounded-sm"></div>
              </div>
              <div>
                <p class="text-present font-bold text-gray-800">Constraint Checkers</p>
                <p class="text-present-small text-gray-600">Cumulative • Alldifferent</p>
              </div>
            </div>
          </div>
        </div>
      {/if}
      
      <div class="grid grid-cols-2 gap-4 mb-6">
        {#if props.animation >= 2}
          <div class="relative">
            <div class="absolute -inset-1 bg-gradient-to-r from-purple-400 to-pink-400 rounded-lg blur opacity-20"></div>
            <div class="relative bg-white/80 rounded-lg p-4 shadow-lg">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                  <div class="w-3 h-3 bg-white rounded-full"></div>
                </div>
                <div>
                  <p class="text-present font-bold text-gray-800">Methodology</p>
                  <p class="text-present-small text-gray-600">Development framework</p>
                </div>
              </div>
            </div>
          </div>
        {/if}
        
        {#if props.animation >= 3}
          <div class="relative">
            <div class="absolute -inset-1 bg-gradient-to-r from-emerald-400 to-teal-400 rounded-lg blur opacity-20"></div>
            <div class="relative bg-white/80 rounded-lg p-4 shadow-lg">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-gradient-to-br from-emerald-500 to-teal-500 rounded-full flex items-center justify-center">
                  <div class="w-3 h-3 bg-white rounded-full"></div>
                </div>
                <div>
                  <p class="text-present font-bold text-gray-800">Deduction Checker</p>
                  <p class="text-present-small text-gray-600">Step combination</p>
                </div>
              </div>
            </div>
          </div>
        {/if}
      </div>
      
      {#if props.animation >= 4}
        <div class="relative">
          <div class="absolute -inset-1 bg-gradient-to-r from-amber-400 via-orange-400 to-red-400 rounded-xl blur opacity-20"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-xl p-4 shadow-xl border border-white/50">
            <div class="flex items-center space-x-4">
              <div class="w-10 h-10 bg-gradient-to-br from-amber-500 to-red-500 rounded-full flex items-center justify-center">
                <div class="w-4 h-4 bg-white rounded-sm"></div>
              </div>
              <div>
                <p class="text-present font-bold text-gray-800">Perforated Intervals</p>
                <p class="text-present-small text-gray-600">Domain theory foundation</p>
              </div>
            </div>
          </div>
        </div>
      {/if}
    </div>
  {/if}
</div>