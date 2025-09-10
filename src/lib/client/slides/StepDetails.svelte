<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
  
  // Different versions to choose from
  let version = "A" // Options: A (Structure-first), B (Problem-first), C (Component-first)
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  {#if version === "A"}
    <!-- Version A: Structure-first approach -->
    <!-- <h1 class="text-present-xl font-bold text-center mb-6 text-paars">What is a Step?</h1> -->
    
    <div class="flex flex-col justify-center h-full space-y-6">
      {#if props.animation >= 0}
        <div class="grid grid-cols-3 gap-6">
          <div class="p-4 bg-green-100 rounded-lg text-center flex items-center justify-center h-28">
            <p class="text-present font-bold text-bosgroen">Constraint Programming</p>
          </div>
          <div class="p-4 bg-red-100 rounded-lg text-center flex items-center justify-center h-28">
            <p class="text-present font-bold text-bordeaux">Unsatisfiability</p>
          </div>
          <div class="p-4 bg-blue-100 rounded-lg text-center flex items-center justify-center h-28">
            <p class="text-present font-bold text-koningsblauw">Proof Checking</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="grid grid-cols-3 gap-6">
          <div></div>
          <div class="p-4 bg-purple-100 rounded-lg text-center flex flex-col items-center justify-center h-28">
            {#if props.animation == 1}
            <p class="text-present font-bold text-paars">Step</p>
            {:else if props.animation >= 2}
            <p class="text-present font-bold text-paars">Step</p><p class="text-present-small">My contribution!</p>

            {/if}
                      </div>
          <div></div>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="text-center">
          <p class="text-present-small">CP proof checker project with:</p>
          <p class="text-present-small"><strong>Maarten Flippo, Konstantin Sidorov, Emir Demirović</strong></p>
        </div>
      {/if}
    </div>
    
  {:else if version === "B"}
    <!-- Version B: Problem-first approach -->
    <h1 class="text-present-xl font-bold text-center mb-6 text-paars">Understanding Steps</h1>
    
    <div class="space-y-4">
      {#if props.animation >= 0}
        <div class="text-center">
          <p class="text-present-large">Proofs aren't monolithic - they have internal structure</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-4 bg-purple-50 rounded-lg">
          <p class="text-present font-semibold text-paars mb-2">Think of it like:</p>
          <p class="text-present-small">Mathematical proof = sequence of logical steps</p>
          <p class="text-present-small">Each step: "From A and B, we can conclude C"</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="grid grid-cols-3 gap-4">
          <div class="p-3 bg-green-100 rounded-lg text-center">
            <p class="text-present font-bold text-bosgroen">CP</p>
          </div>
          <div class="p-3 bg-blue-100 rounded-lg text-center">
            <p class="text-present font-bold text-koningsblauw">Proof Checking</p>
          </div>
          <div class="p-3 bg-red-100 rounded-lg text-center">
            <p class="text-present font-bold text-bordeaux">Unsatisfiability</p>
          </div>
        </div>
        
        <div class="text-center">
          <p class="text-present">+ <span class="font-bold text-paars">Individual Steps</span></p>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="text-center">
          <p class="text-present-small text-donkergrijs-muted">Challenge: Each step needs verification</p>
        </div>
      {/if}
    </div>
    
  {:else}
    <!-- Version C: Component-first approach -->
    <h1 class="text-present-xl font-bold text-center mb-6 text-paars">The Step Component</h1>
    
    <div class="space-y-4">
      {#if props.animation >= 0}
        <div class="text-center">
          <p class="text-present-large">Our title mentions four key concepts</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="grid grid-cols-2 gap-6">
          <div>
            <p class="text-present font-semibold mb-3">We understand these three:</p>
            <div class="space-y-2">
              <div class="p-2 bg-green-100 rounded text-center">
                <span class="text-present-small font-bold text-bosgroen">Constraint Programming</span>
              </div>
              <div class="p-2 bg-blue-100 rounded text-center">
                <span class="text-present-small font-bold text-koningsblauw">Proof Checking</span>
              </div>
              <div class="p-2 bg-red-100 rounded text-center">
                <span class="text-present-small font-bold text-bordeaux">Unsatisfiability</span>
              </div>
            </div>
          </div>
          
          <div>
            <p class="text-present font-semibold mb-3 text-paars">But what is a Step?</p>
            <div class="p-4 bg-purple-100 rounded-lg text-center">
              <p class="text-present-large font-bold text-paars">?</p>
            </div>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="p-4 bg-purple-50 rounded-lg text-center">
          <p class="text-present font-semibold text-paars">Proofs = Sequences of Steps</p>
          <p class="text-present-small mt-1">Each step: reasoning building toward conclusion</p>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="text-center">
          <p class="text-present text-donkergrijs-muted">Our focus: verify these individual building blocks</p>
        </div>
      {/if}
    </div>
  {/if}
</div>