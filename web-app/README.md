# Mood Web (PWA) - Minimal scaffold

This folder contains a minimal React + Vite scaffold and a service worker + Dexie queue implementation for offline-first mood entry sync.

Quick start (requires Node.js):

1. cd web-app
2. npm install
3. npm run dev

Dev notes:
- Service worker file is at `src/sw/sw.ts`. The SW expects the page to respond to `GET_TOKEN` and `REFRESH_TOKEN` messages via `navigator.serviceWorker.postMessage`.
- Queue is implemented using Dexie in `src/sw/queue.ts`.

Security note:
- For real deployments prefer httpOnly cookie-based refresh tokens so the SW can rely on cookie-based refresh without exposing refresh tokens to JS.
