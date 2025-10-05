import type { RequestHandler } from './$types';

export const GET: RequestHandler = ({ url, params }) => {
	return fetch(`http://localhost:7373/${params.path + url.search}`);
};