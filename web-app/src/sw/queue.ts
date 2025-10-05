import Dexie from 'dexie'

export interface QueuedMood {
  id?: number
  rating: number
  note?: string
  timestamp: string
  attempts?: number
  synced?: boolean
}

const db = new Dexie('MoodDB')
db.version(1).stores({ moods: '++id,timestamp,synced,attempts' })

export const enqueueMood = async (m: Omit<QueuedMood, 'id' | 'attempts' | 'synced'>) => {
  return await db.table('moods').add({ ...m, attempts: 0, synced: false })
}

export const getPending = async () => {
  return await db.table('moods').where('synced').equals(false).toArray()
}

export const markSynced = async (id: number) => {
  return await db.table('moods').update(id, { synced: true })
}

export default db
