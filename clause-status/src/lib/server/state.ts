import { lastSlide } from '$lib/content/order';
import { open } from 'lmdb'; // or require

const lmdb = open({
	path: 'kv.lmdb',
});

function validNumber(result: any): number | null {
	if (typeof result === 'number' && Number.isSafeInteger(result)) {
		return result
	}
	
	return null
}

export function getPage(key: 'page' | 'animation' = 'page'): number {
	const result = lmdb.get(key)
	const resultNumber = validNumber(result)
	if (resultNumber === null || resultNumber < 0) {
		lmdb.putSync(key, 0)
		return 0
	} else if (key === 'page' && resultNumber > lastSlide) {
		lmdb.putSync(key, lastSlide)
		return lastSlide
	}

	return resultNumber
}

export function setPage(page: number, key: 'page' | 'animation' = 'page') {
	const numberResult = validNumber(page)
	let newPage;
	if (numberResult === null) {
		// silently do nothing
		console.error(`${JSON.stringify(page)} is not a valid page number!`)
		return
	} else if (numberResult < 0) {
		newPage = 0
	} else if (key === 'page' && numberResult > lastSlide) {
		newPage = lastSlide
	}

	lmdb.putSync(key, page)
}

export function incrementPage(by: number, key: 'page' | 'animation' = 'page') {
	if (validNumber(by) === null) {
		// silently do nothing
		console.error(`${JSON.stringify(by)} is not a valid page increment!`)
		return
	}
	lmdb.transactionSync(() => {
		const current = getPage(key)
		const newPage = current + by
		if (newPage >= 0 && (key !== 'page' || newPage <= lastSlide)) {
			lmdb.putSync(key, newPage)
		}
	})
}