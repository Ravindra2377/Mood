// @ts-nocheck
import React from 'react'

export default function DocsIndex() {
  return (
    <div style={{ padding: 28, fontFamily: 'Inter, system-ui, Roboto, Arial' }}>
      <h1>Documentation</h1>
      <p style={{ color: '#475569' }}>Welcome to the SOUL docs. Select a page below:</p>
      <ul style={{ color: '#475569' }}>
        <li><a href="/docs/metrics" onClick={(e) => { e.preventDefault(); history.pushState({}, '', '/docs/metrics'); window.dispatchEvent(new PopStateEvent('popstate')) }}>Sleep percent metric</a></li>
      </ul>
      <p style={{ marginTop: 18 }}><a href="/">← Back to app</a></p>
    </div>
  )
}
