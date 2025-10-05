/* Service Worker (vanilla) - handles background sync and queue processing */

/* eslint-disable no-restricted-globals */

import { getPending, markSynced } from './queue'

// Simple fetch wrapper inside SW to post moods
async function postMood(mood: any, token?: string) {
  const resp = await fetch('/api/moods', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: JSON.stringify(mood)
  })
  return resp
}

self.addEventListener('install', (event: any) => {
  self.skipWaiting()
})

self.addEventListener('activate', (event: any) => {
  event.waitUntil(self.clients.claim())
})

self.addEventListener('sync', (event: any) => {
  if (event.tag === 'mood-sync') {
    event.waitUntil(processQueue())
  }
})

async function processQueue() {
  const pending = await getPending()
  for (const item of pending) {
    try {
      // We try to get a token by messaging the client (simple approach)
      const clients = await self.clients.matchAll({ includeUncontrolled: true })
      let token: string | undefined
      if (clients && clients.length > 0) {
        const response = await new Promise<string | undefined>(resolve => {
          const messageChannel = new MessageChannel()
          messageChannel.port1.onmessage = (ev: any) => {
            resolve(ev.data?.token)
          }
          clients[0].postMessage({ type: 'GET_TOKEN' }, [messageChannel.port2])
        })
        token = response
      }

      const resp = await postMood(item, token)
      if (resp && resp.status >= 200 && resp.status < 300) {
        await markSynced(item.id!)
      } else if (resp && resp.status === 401) {
        // ask client to refresh tokens
        const clients = await self.clients.matchAll({ includeUncontrolled: true })
        if (clients && clients.length > 0) {
          clients[0].postMessage({ type: 'REFRESH_TOKEN' })
        }
      }
    } catch (e) {
      // increment attempts — simplistic
      if (item.id) {
        await db.table('moods').update(item.id, { attempts: (item.attempts || 0) + 1 })
      }
    }
  }
}

// Listen for messages from the page (e.g., to trigger sync)
self.addEventListener('message', (ev: any) => {
  const data = ev.data
  if (!data) return
  if (data.type === 'TRIGGER_SYNC') {
    self.registration.sync.register('mood-sync')
  }
})
