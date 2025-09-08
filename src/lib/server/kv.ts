import { open } from 'lmdb'; // or require

const lmdb = open({
  path: 'kv.lmdb',
  sharedStructuresKey: Symbol.for('structures')
});

export function kvGet<T>(key: string): T {
  return lmdb.get(key) as T;
}

export async function kvPut<T>(key: string, value: T): Promise<void> {
  await lmdb.put(key, value)
}

export async function kvAdd(key: string, add: number): Promise<void> {
  await lmdb.transaction(() => {
      const value = lmdb.get(key) as number;
      lmdb.put(key, value + add)
  })
}