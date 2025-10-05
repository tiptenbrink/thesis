import { requestPage } from '$lib/client/state';
import { getPage } from '$lib/server/state';
import type { PageServerLoad } from './$types';

export const load = (async () => {
    const page = getPage()

    return { 
      page
    }
}) satisfies PageServerLoad;