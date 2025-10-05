<script lang="ts">
  import { activeName } from "$lib/problem";

  const {
    times,
    min,
    max,
    propagated,
    color,
    activity,
    maxTime
  }: {
    times: number[];
    propagated: Map<string, boolean>;
    min: number;
    max: number;
    color: string;
    activity: string;
    maxTime: number
  } = $props();

  function classes(active: boolean, maybeActive: boolean, color: string) {
    if (active) {
      return color;
    } else if (maybeActive) {
      return `${color} bg-opacity-50`;
    } else {
      return "";
    }
  }
</script>

<div class="grid grid-rows-1 grid-flow-col justify-start">
  {#each times as t}
    {@const active = propagated.get(activeName(activity, t))!}
    {@const maybeActive = t >= min && t < max}
    {@const beyondMax = t > maxTime}
    <span
      class={"w-16 h-16 border flex justify-center items-center " +
        classes(active, maybeActive, color)}>{active ? activity : (beyondMax ? 'X' : '')}</span
    >
  {/each}
</div>
