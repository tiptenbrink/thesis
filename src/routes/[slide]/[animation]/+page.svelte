<script module lang="ts">
  import type { PageProps } from "./$types";
  import { goto, preloadData } from "$app/navigation";
  import { slides, type SlideComponent } from "./slides"
  
  const slideComponents: SlideComponent[] = slides.map(s => s.default)
  const slideAnimations: number[] = slides.map(s => s.animations)

  function nextPos(slide: number, animation: number): [number, number] {
    if (animation + 1 < slideAnimations[slide]) {
      return [slide, animation + 1]
    } else if (slide + 1 < slides.length) {
      return [slide + 1, 0]
    } else {
      return [slide, animation]
    }
  }

  function prevPos(slide: number, animation: number): [number, number] {
    if (animation > 0) {
      return [slide, animation - 1]
    } else if (slide > 0) {
      return [slide - 1, slideAnimations[slide - 1] - 1]
    } else {
      return [0, 0]
    }
  }

</script>

<script lang="ts">
  let data: PageProps = $props()
  let animation = $derived(parseInt(data.params.animation))
  let slide = $derived(parseInt(data.params.slide))
  let Visible = $derived(slideComponents[slide])

  let prev = $derived(prevPos(slide, animation))
  let next = $derived(nextPos(slide, animation))
  let prevLink = $derived(`/${prev[0]}/${prev[1]}`)
  let nextLink = $derived(`/${next[0]}/${next[1]}`)

  let prevSlideLink = $derived(`/${Math.max(0, slide-1)}/0`)
  let nextSlideLink = $derived(`/${Math.min(slide+1, slides.length-1)}/0`)

  $effect(() => {
    preloadData(prevLink)
    preloadData(nextLink)
    preloadData(prevSlideLink)
    preloadData(nextSlideLink)
  })

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'ArrowRight' || event.key === 'PageDown' || event.key === 'ArrowDown') {
      goto(nextLink, {
        keepFocus: true
      })
    } else if (event.key === 'ArrowLeft' || event.key === 'PageUp' || event.key === 'ArrowUp') {
      goto(prevLink, {
        keepFocus: true,
      })
    } else if (event.key === 'a') {
      goto(prevSlideLink)
    } else if (event.key === 'd') {
      goto(nextSlideLink)
    }
  }
</script>

<svelte:window onkeydown={(event) => handleKeyDown(event)} />

<!-- incr: <button onclick={() => position += 1}>Incr</button> <button onclick={() => position -= 1}>Decr</button> -->
<div class="bg-gray-white flex flex-col justify-center w-dvw h-dvh font-[Zilla_Slab]">
  <div class="w-full h-auto aspect-video bg-cover bg-no-repeat bg-[url(/tudelft.svg)] grid grid-rows-[1fr_10fr_2fr]">
  <div class=""></div>
  <div class="bg-white">
    <div class="grid grid-cols-[2fr_12fr_2fr] w-full h-full">
      <div class="bg-gray-white"></div>
      <div class="contents"><Visible {animation} /></div>
      <div class="bg-gray-white"></div>
    </div>
  </div>
  <div class="grid grid-cols-[25fr_1fr_1fr_1fr_25fr] pt-4 text-present-small">
    <span></span>
    <span>{slide+1}</span>
    <span>/</span>
    <span>{slides.length}</span>
    <span></span></div>
  </div>
</div>