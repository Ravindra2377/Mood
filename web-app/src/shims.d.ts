declare module 'react'
declare module 'react-dom/client'
declare module 'workbox-window'
declare module 'dexie'
declare module 'react/jsx-runtime'

// Basic JSX fallback for the editor - real projects should install @types/react
declare namespace JSX {
  interface IntrinsicElements {
    [elemName: string]: any
  }
}

declare module './App'
