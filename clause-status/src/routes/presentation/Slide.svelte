<script lang="ts">
    import GridSlide from "$lib/client/slides/GridSlide.svelte";
    import InnerSlide from "$lib/client/slides/InnerSlide.svelte";
    import Intro from "$lib/client/slides/Intro.svelte";
    import Title from "$lib/client/slides/Title.svelte";
    import { lastSlide, order } from "$lib/content/order";
    import gridcontent from "$lib/client/slides/grids/gridcontent";
    import Complexity from "$lib/client/slides/Wrong1.svelte";
    import UnsatProof from "$lib/client/slides/UnsatProof.svelte";
    import CertificationIntro from "$lib/client/slides/CertificationIntro.svelte";
    import AfterProof from "$lib/client/slides/AfterProof.svelte";
    import MidSummary from "$lib/client/slides/MidSummary.svelte";
    import NotDone from "$lib/client/slides/NotDone.svelte";
    import AllDifferent from "$lib/client/slides/ProofHow.svelte";
    import FormalVerif from "$lib/client/slides/FormalVerif.svelte";
    import FormalVerifExplain from "$lib/client/slides/FormalVerifExplain.svelte";
    import FormalVerifExample from "$lib/client/slides/FormalVerifExample.svelte";
    import FormalLimits from "$lib/client/slides/FormalLimits.svelte";
    import Contribution from "$lib/client/slides/Contribution.svelte";
    import Goals from "$lib/client/slides/Goals.svelte";
    import Summary from "$lib/client/slides/Summary.svelte";
    import NurseRoster from "$lib/client/slides/NurseRoster.svelte";
    import Wrong2 from "$lib/client/slides/Wrong2.svelte";
    import Wrong1 from "$lib/client/slides/Wrong1.svelte";
    import Wrong3 from "$lib/client/slides/Wrong3.svelte";
    import Wrong4 from "$lib/client/slides/Wrong4.svelte";
    import ProofLogging from "$lib/client/slides/ProofLogging.svelte";
    import ProofChecker from "$lib/client/slides/ProofChecker.svelte";
    import ProofExample from "$lib/client/slides/ProofExample.svelte";
    import AllDifferentDef from "$lib/client/slides/AllDifferentDef.svelte";
    import ProofHow from "$lib/client/slides/ProofHow.svelte";
    import Proof from "$lib/client/slides/Proof.svelte";
    import ProofExPre from "$lib/client/slides/ProofExPre.svelte";
    import Hook from "$lib/client/slides/Hook.svelte";
    import Plan from "$lib/client/slides/Plan.svelte";
    import Pipeline from "$lib/client/slides/Pipeline.svelte";
    import ContributionFocus1 from "$lib/client/slides/ContributionFocus1.svelte";
    import ProofCheckerDiagram from "$lib/client/slides/ProofCheckerDiagram.svelte";

  interface Props {
    page: number,
    animation: number,
    setLastAnimation: (n: number) => void,
  }

  let { page, animation, setLastAnimation }: Props = $props();

  let shown = $derived(order[page])
</script>

<div class="w-full h-auto aspect-video bg-cover bg-no-repeat bg-[url(/tudelft.svg)] grid grid-rows-[1fr_10fr_2fr]">
  <div class=""></div>
  <div class="bg-white">
    <InnerSlide {shown} id='hook' ><Hook {animation} {setLastAnimation}></Hook></InnerSlide>
    <InnerSlide {shown} id='title' ><Title></Title></InnerSlide>
    <InnerSlide {shown} id='intro' ><Intro {animation} {setLastAnimation}></Intro></InnerSlide>
    <!-- <InnerSlide {shown} id='nurseroster' ><NurseRoster></NurseRoster></InnerSlide>
    <InnerSlide {shown} id='wrong1' ><Wrong1></Wrong1></InnerSlide>
    <InnerSlide {shown} id='wrong2' ><Wrong2></Wrong2></InnerSlide>
    <InnerSlide {shown} id='wrong3' ><Wrong3></Wrong3></InnerSlide>
    <InnerSlide {shown} id='wrong4' ><Wrong4></Wrong4></InnerSlide> -->
    <InnerSlide {shown} id='certintro' ><CertificationIntro {animation} {setLastAnimation}></CertificationIntro></InnerSlide>
    <InnerSlide {shown} id='prooflogging' ><ProofLogging {animation} {setLastAnimation}></ProofLogging></InnerSlide>
    <InnerSlide {shown} id='proofchecker' ><ProofChecker {animation} {setLastAnimation}></ProofChecker></InnerSlide>
    <InnerSlide {shown} id='plan'><Plan {animation} {setLastAnimation}></Plan></InnerSlide>
    <InnerSlide {shown} id='contribution'><Contribution {animation} {setLastAnimation}></Contribution></InnerSlide>
    <InnerSlide {shown} id='pipeline' ><Pipeline {animation} {setLastAnimation}></Pipeline></InnerSlide>
    <InnerSlide {shown} id='proofexpre' ><ProofExPre {animation} {setLastAnimation}></ProofExPre></InnerSlide>
    {#each gridcontent as { notAllowed, gridInput, colorInput, name, knowledge, check, blockedInput, noInference, leftSide, inputNoInference, infStep } }
      <InnerSlide {shown} id={name} ><GridSlide {infStep} {notAllowed} {gridInput} {colorInput} {knowledge} {check} {blockedInput} {noInference} {leftSide} {inputNoInference}></GridSlide></InnerSlide>
    {/each}
    <InnerSlide {shown} id='proofex' ><ProofExample {animation} {setLastAnimation}></ProofExample></InnerSlide>
    <InnerSlide {shown} id='proofcheckerdiagram' ><ProofCheckerDiagram {animation} {setLastAnimation}></ProofCheckerDiagram></InnerSlide>
    <!-- <InnerSlide {shown} id='afterproof'><AfterProof></AfterProof></InnerSlide>
    <InnerSlide {shown} id='midsummary'><MidSummary></MidSummary></InnerSlide>
    <InnerSlide {shown} id='notdone'><NotDone></NotDone></InnerSlide> -->
    
    <InnerSlide {shown} id='formalverif'><FormalVerif {animation} {setLastAnimation}></FormalVerif></InnerSlide>
    <InnerSlide {shown} id='proof'><Proof {animation} {setLastAnimation}></Proof></InnerSlide>
    <InnerSlide {shown} id='alldiffdef'><AllDifferentDef {animation} {setLastAnimation}></AllDifferentDef></InnerSlide>
    <InnerSlide {shown} id='proofhow'><ProofHow {animation} {setLastAnimation}></ProofHow></InnerSlide> 
    <InnerSlide {shown} id='formalverifexample'><FormalVerifExample {animation} {setLastAnimation}></FormalVerifExample></InnerSlide>
    <InnerSlide {shown} id='formalverifexpl'><FormalVerifExplain {animation} {setLastAnimation}></FormalVerifExplain></InnerSlide>
    <InnerSlide {shown} id='contributionfocus1'><ContributionFocus1 {animation} {setLastAnimation}></ContributionFocus1></InnerSlide>
    <!-- <InnerSlide {shown} id='formallimits'><FormalLimits></FormalLimits></InnerSlide>
      
    <InnerSlide {shown} id='goals'><Goals></Goals></InnerSlide> -->
    <InnerSlide {shown} id='summary'><Summary {animation} {setLastAnimation}></Summary></InnerSlide>
  </div>
  <div class="grid grid-cols-[25fr_1fr_1fr_1fr_25fr] pt-4 text-present-small">
    <span></span>
    <span>{page+1}</span>
    <span>/</span>
    <span>{lastSlide+1}</span>
    <span></span></div>
</div>