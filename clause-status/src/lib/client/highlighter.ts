import { createJavaScriptRawEngine } from '@shikijs/engine-javascript'
import { createHighlighterCore } from '@shikijs/core'

export const highlighter = await createHighlighterCore({ 
    engine: createJavaScriptRawEngine(),
    themes: [
        import('@shikijs/themes/github-light')
    ],
    langs: [
        import('@shikijs/langs-precompiled/coq')
    ]
 })