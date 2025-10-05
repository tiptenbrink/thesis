import { PUBLIC_ORIGIN } from "$env/static/public"

const PRESENTATION_API_URL = `${PUBLIC_ORIGIN}/presentation/api`

export async function requestPage() {
  const result = await fetch(PRESENTATION_API_URL)

  const j = await result.json() as {
    page: number
    animation: number
  }

  return j
}

export async function requestSetPage(page: number, type: 'page' | 'animation' = 'page') {
  return await fetch(PRESENTATION_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ set: page, type })
  })
}

export async function requestPageIncrement(by: number, type: 'page' | 'animation' = 'page') {
  return await fetch(PRESENTATION_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ increment: by, type })
  })
}