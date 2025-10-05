// Simple client-side token proxy that listens for SW GET_TOKEN/REFRESH_TOKEN messages

export function setupTokenProxy(getToken: () => Promise<string | undefined>, refresh: () => Promise<void>) {
  navigator.serviceWorker.addEventListener('message', async (ev: any) => {
    const data = ev.data
    if (!data) return
    if (data.type === 'GET_TOKEN') {
      const token = await getToken()
      ev.ports?.[0]?.postMessage({ token })
    } else if (data.type === 'REFRESH_TOKEN') {
      try {
        await refresh()
        ev.ports?.[0]?.postMessage({ ok: true })
      } catch (e) {
        ev.ports?.[0]?.postMessage({ ok: false })
      }
    }
  })
}
