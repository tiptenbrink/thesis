<script>

</script>

<style>
 li + li {
    margin-top: 1rem;
  }
  .highlight {
    font-weight: bold;
    color: #ff6347; /* Tomato color */
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-5xl text-center flex justify-center items-center">CP Proof Checking Challenges</div>
  <div class="flex flex-col justify-center text text-present">
     <ul class="list-disc ml-8 mt-4">
        <li>SAT: One type of constraint</li>
        <li>CP: <span class="highlight">Many</span> constraint types (400+ in global constraint catalog)</li>
        <li>CP Solvers: Specialized reasoning per constraint</li>
        <li>CP checkers need to <span class="highlight">know</span> the reasoning used</li>
      </ul>
      <p class="mt-8 text-center italic text-gray-600">"Checker needs to know, or it's too expensive."</p>
  </div>
</div>