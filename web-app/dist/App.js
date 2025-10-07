import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// @ts-nocheck
import React from 'react';
import { registerServiceWorker } from './sw/register';
import HomeView from './ui/HomeView';
import Meditation from './ui/Meditation';
import MetricsDocs from './pages/MetricsDocs';
import DocsIndex from './pages/DocsIndex';
import ToastProvider from './ui/Toast';
export default function App() {
    React.useEffect(() => {
        registerServiceWorker();
    }, []);
    const path = typeof window !== 'undefined' ? window.location.pathname : '/';
    const [currentPath, setCurrentPath] = React.useState(typeof window !== 'undefined' ? window.location.pathname : '/');
    React.useEffect(() => {
        function onPop() {
            setCurrentPath(window.location.pathname);
        }
        window.addEventListener('popstate', onPop);
        return () => window.removeEventListener('popstate', onPop);
    }, []);
    const isDocsMetrics = currentPath.startsWith('/docs/metrics');
    const isDocsIndex = currentPath === '/docs' || currentPath === '/docs/';
    function navigate(to) {
        if (window.location.pathname !== to) {
            history.pushState({}, '', to);
            // update state and notify any listeners
            setCurrentPath(to);
            window.dispatchEvent(new PopStateEvent('popstate'));
        }
    }
    return (_jsx(ToastProvider, { children: _jsxs("div", { style: { padding: 24 }, children: [_jsxs("header", { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 }, children: [_jsxs("div", { children: [_jsx("h1", { style: { margin: 0 }, children: "SOUL" }), _jsx("div", { style: { color: 'var(--muted)' }, children: "your mental health companion" })] }), _jsxs("nav", { style: { display: 'flex', gap: 12 }, children: [_jsx("a", { href: "/", onClick: (e) => { e.preventDefault(); navigate('/'); }, children: "Home" }), _jsx("a", { href: "/meditation", onClick: (e) => { e.preventDefault(); navigate('/meditation'); }, children: "Meditation" }), _jsx("a", { href: "/timer", onClick: (e) => { e.preventDefault(); navigate('/timer'); }, children: "Timer" }), _jsx("a", { href: "/docs", onClick: (e) => { e.preventDefault(); navigate('/docs'); }, children: "Docs" })] })] }), isDocsMetrics ? _jsx(MetricsDocs, {}) : isDocsIndex ? _jsx(DocsIndex, {}) : currentPath === '/meditation' || currentPath === '/timer' ? _jsx(Meditation, {}) : _jsx(HomeView, {})] }) }));
}
