<script module lang="ts">
    import type { Component } from "svelte";
  import * as Slide from "../../Slide.svelte";
  import * as Slide2 from "../../Slide2.svelte";
    import type { PageProps } from "./$types";
    import { goto, preloadData } from "$app/navigation";

  type SlideComponent = Component<{ animation: number }>

  interface SlideModule {
    animations: number,
    default: Component<{ animation: number }>
  }

  const slides: SlideModule[] = [
    Slide, 
    Slide2
  ]

  function slidePositions(slides: SlideModule[]): number[] {
    let start = 0
    const starts = [0]
    for (const slide of slides) {
      start += slide.animations
      starts.push(start)
    }

    return starts
  }

  const slideComponents: SlideComponent[] = slides.map(s => s.default)
  const slideAnimations: number[] = slides.map(s => s.animations)
  const positions = slidePositions(slides)
  const end = positions.at(-1)!

  function binaryNext(above: number, below: number): number {
    return Math.floor((below - above) / 2)
  }

  function getSlide(positions: number[], pos: number): [number, number] {
    let i = positions.length
    let above = 0
    let below = i
    let current = binaryNext(above, below) 
    while (i > 0) {
      i -= 1
      if (pos === positions[current]) {
        return [current, 0]
      } else if (pos < positions[current]) {
        below = current
        current = binaryNext(above, below)
      } else {
        above = current
        current = binaryNext(above, below)
      }
    }
    return [above, pos - positions[above]]
  }

  function nextPos(slide: number, animation: number): [number, number] {
    if (animation + 1 < slideAnimations[slide]) {
      return [slide, animation + 1]
    } else if (slide + 1 < slides.length) {
      return [slide + 1, animation]
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
  //let position = $state(0)
  //let slideAnim = $derived(getSlide(positions, position))
  //let slide = $derived(slideAnim[0])
  //let animation = $derived(slideAnim[1])
  let data: PageProps = $props()
  let animation = $derived(parseInt(data.params.animation))
  let slide = $derived(parseInt(data.params.slide))
  let Visible = $derived(slideComponents[slide])

  let prev = $derived(prevPos(slide, animation))
  let next = $derived(nextPos(slide, animation))
  let prevLink = $derived(`/${prev[0]}/${prev[1]}`)
  let nextLink = $derived(`/${next[0]}/${next[1]}`)

  $effect(() => {
    preloadData(prevLink)
    preloadData(nextLink)
  })

  function handleKeyDown(event: KeyboardEvent) {
    // TODO, invalidate?
    if (event.key === 'ArrowRight' || event.key === 'PageDown' || event.key === 'ArrowDown') {
      goto(nextLink, {
        keepFocus: true
      })
    } else if (event.key === 'ArrowLeft' || event.key === 'PageUp' || event.key === 'ArrowUp') {
      goto(prevLink, {
        keepFocus: true,
      })
    }
  }
</script>

positions={JSON.stringify(positions)};end={end}
<br>
<!-- position={position} -->
<br>
slide={slide};animation={animation}
<br>
<!-- incr: <button onclick={() => position += 1}>Incr</button> <button onclick={() => position -= 1}>Decr</button> -->


<Visible {animation} />


<br>
<div>
<a href={`/${prev[0]}/${prev[1]}`}>Left</a>
<a href={`/${next[0]}/${next[1]}`}>Right</a>
</div>

<svelte:window onkeydown={(event) => handleKeyDown(event)} />