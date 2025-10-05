<script lang="ts">
  import Slide from "./Slide.svelte";
  import { requestPage } from '$lib/client/state';
  import type { PageProps } from './$types';
    import { createPage } from "./pageswitch.svelte";
    import PageSwitch from "./PageSwitch.svelte";
    import { untrack } from "svelte";

  let { data }: PageProps = $props();

  const loadedPage = Number(data.page)

  let lastAnimation = $state(0)

  function onPageChange(pre: number, post: number) {
    lastAnimation = 0
  }

  function setLastAnimation(n: number) {
    lastAnimation = n
  }

  let pageState = createPage(loadedPage, onPageChange)

  setInterval(() => pageState.syncPage(), 50);

  $effect(() => {
    if (pageState.animation > untrack(() => lastAnimation)) {
      pageState.incrPage(true).then()
    }
  })
</script>

<PageSwitch {pageState}></PageSwitch>

<div class="bg-gray-white flex flex-col justify-center w-dvw h-dvh font-[Zilla_Slab]">
  <!-- <div class="grow"></div> -->
  <Slide page={pageState.page} animation={pageState.animation} {setLastAnimation}></Slide>
  <!-- <div class="grow"></div> -->
</div>