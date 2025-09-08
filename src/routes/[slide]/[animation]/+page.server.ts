import type { PageServerLoad } from './$types';

export const load = (async ({ params }) => {
	return {
		slide: parseInt(params.slide),
		animation: parseInt(params.animation)
	};
}) satisfies PageServerLoad;