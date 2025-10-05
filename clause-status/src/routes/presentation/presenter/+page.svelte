<script lang="ts">
  import { requestPage, requestPageIncrement, requestSetPage } from '$lib/client/state';
    import { lastSlide } from '$lib/content/order';
    import PageSwitch from '../PageSwitch.svelte';
    import { createPage } from '../pageswitch.svelte';
  import type { PageProps } from './$types';

  let { data }: PageProps = $props();

  const loadedPage = Number(data.page)

  let pageState = createPage(loadedPage)
  let setPageInput = $state('')

  async function setPage() {
    const newPage = parseInt(setPageInput, 10);
    if (!isNaN(newPage)) {
      await requestSetPage(newPage-1);
      await requestSetPage(0, 'animation');
      pageState.syncPage().then()
    }
    setPageInput = ''
  }

</script>

<PageSwitch {pageState}></PageSwitch>

<main class="bg-gray-100 w-screen min-h-screen pt-4">
  <div class="lg:mx-auto lg:max-w-4xl mx-8 rounded p-2 bg-white">
    <div class="flex flex-col">
      <button class="px-4 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition w-fit cursor-pointer" onclick={() => pageState.incrPage(false)}>Plus</button>
      <button class="px-4 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition w-fit cursor-pointer" onclick={() => pageState.decrPage()}>Minus</button>
      Page: {pageState.page+1}

      <div class="flex items-center mt-2">
        <input
          type="number"
          class="border rounded px-2 py-1 mr-2"
          placeholder="Set page number"
          bind:value={setPageInput}
        />
        <button class="px-4 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition w-fit cursor-pointer" onclick={setPage}>Set Page</button>
      </div>
    </div>
  </div>
</main>
