<script module>
  export const animations = 14
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="max-w-4xl mx-auto">
    
    <div class="space-y-5">
      {#if props.animation >= 1 && props.animation < 8}
        <div class="bg-geel-muted rounded-lg p-6 shadow-md">
          <p class="text-present text-center font-medium">How do we know there's not similar mistakes in the <em>proof checker</em>?</p>
        </div>
      {/if}
      
      {#if props.animation >= 2 && props.animation < 8}
        <div class="bg-koningsblauw-muted rounded-lg p-6 shadow-md">
          <p class="text-present text-center font-bold">The proof checker is "formally verified"</p>
        </div>
      {/if}
      
      {#if props.animation === 3}
        <div class="p-6 bg-blue-50 rounded-lg">
          <p class="text-present-large italic font-medium text-center">
            How can we develop <span class="font-bold text-koningsblauw">formally verified</span> checkers for individual proof steps in a CP unsatisfiability proof checker?
          </p>
        </div>
      {/if}
      
      {#if props.animation >= 4 && props.animation < 8}
        <div class="p-4 bg-blue-50 rounded-lg">
          <p class="text-present font-semibold">Formal verification:</p>
          <p class="text-present-small mt-2 {props.animation >= 4 ? '' : 'invisible'}">• Design document → mathematical "specification"</p>
          <p class="text-present-small {props.animation >= 5 ? '' : 'invisible'}">• Everything precisely described in mathematical language</p>
          <p class="text-present-small {props.animation >= 6 ? '' : 'invisible'}">• Programs become mathematical objects</p>
        </div>
      {/if}
      
      {#if props.animation >= 7}
        <div class="text-center">
          <p class="text-present">We write a mathematical proof that implementation satisfies specification</p>
        </div>
      {/if}
      
      {#if props.animation >= 8}
        <div class="p-4 bg-yellow-50 rounded-lg text-center">
          <p class="text-present font-semibold text-oranje">But what if my proof is wrong?</p>
        </div>
      {/if}
      
      {#if props.animation >= 9}
        <div class="text-center">
          <p class="text-present">We use another proof checker: <strong>Rocq</strong></p>
        </div>
      {/if}
      
      {#if props.animation >= 10}
        <div class="p-4 bg-bosgroen text-white rounded-lg">
          <p class="text-present font-semibold">Why trust Rocq?</p>
          <p class="text-present-small mt-2 {props.animation >= 11 ? '' : 'invisible'}">• Designed to be very simple</p>
          <p class="text-present-small {props.animation >= 12 ? '' : 'invisible'}">• Hundreds of humans use it and have reviewed it</p>
          <p class="text-present-small {props.animation >= 13 ? '' : 'invisible'}">• Used by many projects worldwide requiring high trust</p>
        </div>
      {/if}
      
     
    </div>
  </div>
</div>