<script lang="ts">
    import { type PageState } from "./pageswitch.svelte";

    let { pageState }: { pageState: PageState } = $props()
</script>

<svelte:window onkeydown={(event) => pageState.handleKeyDown(event, false)} />