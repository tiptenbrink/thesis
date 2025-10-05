import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPage, incrementPage, setPage } from '$lib/server/state';

export const GET: RequestHandler = async () => {
  const page = getPage()
  const animation = getPage('animation')

  return json({ page, animation });
};

type PostRequest = ({
  set: number
} | {
  increment: number
}) & { type: 'page' | 'animation' }

export const POST: RequestHandler = async ({ request }) => {
  const j = await request.json() as PostRequest

  if ("set" in j) {
    setPage(j.set, j.type)
  } else if ("increment" in j) {
    incrementPage(j.increment, j.type)
  }

  return new Response();
};