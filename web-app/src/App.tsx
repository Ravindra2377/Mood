// @ts-nocheck
import React from 'react'
import { registerServiceWorker } from './sw/register'
import MoodEntry from './ui/MoodEntry'
import DiaryView from './ui/DiaryView'
import HomeView from './ui/HomeView'
import MetricsDocs from './pages/MetricsDocs'
import DocsIndex from './pages/DocsIndex'
import ToastProvider from './ui/Toast'

export default function App() {
  React.useEffect(() => {
    registerServiceWorker()
  }, [])

  const path = typeof window !== 'undefined' ? window.location.pathname : '/'
  const [currentPath, setCurrentPath] = React.useState(typeof window !== 'undefined' ? window.location.pathname : '/')

  React.useEffect(() => {
    function onPop() {
      setCurrentPath(window.location.pathname)
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])

  const isDocsMetrics = currentPath.startsWith('/docs/metrics')
  const isDocsIndex = currentPath === '/docs' || currentPath === '/docs/'

  function navigate(to) {
    if (window.location.pathname !== to) {
      history.pushState({}, '', to)
      // update state and notify any listeners
      setCurrentPath(to)
      window.dispatchEvent(new PopStateEvent('popstate'))
    }
  }

  return (
    <ToastProvider>
      <div style={{ padding: 24 }}>
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 }}>
          <div>
            <h1 style={{ margin: 0 }}>SOUL</h1>
            <div style={{ color: 'var(--muted)' }}>your mental health companion</div>
          </div>
          <nav style={{ display: 'flex', gap: 12 }}>
            <a href="/" onClick={(e) => { e.preventDefault(); navigate('/'); }}>Home</a>
            <a href="/docs" onClick={(e) => { e.preventDefault(); navigate('/docs'); }}>Docs</a>
          </nav>
        </header>

        {isDocsMetrics ? <MetricsDocs /> : isDocsIndex ? <DocsIndex /> : <HomeView />}
      </div>
    </ToastProvider>
  )
}
