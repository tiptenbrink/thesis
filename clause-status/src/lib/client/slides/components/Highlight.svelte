<script>
  import { highlighter } from "$lib/client/highlighter";

  let { lang, code } = $props()

  function highlight() {
    return highlighter.codeToHtml(code, {
      lang,
      theme: "github-light",
    })
  }
  
</script>

{@html highlight()}