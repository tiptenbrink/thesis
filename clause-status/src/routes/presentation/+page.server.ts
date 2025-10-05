import { compileAll } from '$lib/server/compileTypst';
import { getPage } from '$lib/server/state';
import type { PageServerLoad } from './$types';

export const load = (async () => {
    const page = getPage()
    const animation = getPage('animation')

    //await compileAll([])

    return { 
      page,
      animation
    }
}) satisfies PageServerLoad;