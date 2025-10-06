import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// @ts-nocheck
import React, { useEffect, useState } from 'react';
import '../styles/theme.css';
import JournalEditor from './JournalEditor';
import Popover from './Popover';
function AnimatedDonut({ percent = 78, duration = 900 }) {
    const radius = 60;
    const stroke = 12;
    const r = radius;
    const circumference = 2 * Math.PI * r;
    const [offset, setOffset] = React.useState(circumference);
    const [display, setDisplay] = React.useState(0);
    React.useEffect(() => {
        // animate stroke-dashoffset from full to target only when a numeric percent is provided
        if (percent === null || percent === undefined) {
            setOffset(circumference);
            setDisplay(null);
            return;
        }
        const safePct = Math.min(Math.max(percent, 0), 100);
        const target = circumference * (1 - safePct / 100);
        const start = circumference;
        const startTime = performance.now();
        function frame(now) {
            const t = Math.min(1, (now - startTime) / duration);
            const eased = 1 - Math.pow(1 - t, 3);
            setOffset(start + (target - start) * eased);
            setDisplay(Math.round(eased * safePct));
            if (t < 1)
                requestAnimationFrame(frame);
            else
                setDisplay(Math.round(safePct));
        }
        requestAnimationFrame(frame);
    }, [percent, circumference, duration]);
    return (_jsx("svg", { width: (r + stroke) * 2, height: (r + stroke) * 2, viewBox: `0 0 ${(r + stroke) * 2} ${(r + stroke) * 2}`, children: _jsxs("g", { transform: `translate(${r + stroke},${r + stroke})`, children: [_jsx("circle", { r: r + 6, fill: "none", stroke: "#e6eef8", strokeWidth: 2, strokeDasharray: "2 6", opacity: 0.9 }), _jsx("circle", { r: r, fill: "none", stroke: display == null ? '#bfdbfe' : '#eef2ff', strokeWidth: stroke }), _jsx("circle", { r: r, fill: "none", stroke: display == null ? '#a5b4fc' : '#60a5fa', strokeWidth: stroke, strokeDasharray: `${circumference}`, strokeDashoffset: offset, transform: "rotate(-90)", style: { transition: 'stroke-dashoffset 280ms linear' } }), _jsx("circle", { r: r - 6, fill: "white" }), _jsx("text", { x: "0", y: "6", textAnchor: "middle", fontSize: 22, fontWeight: 700, fill: "#0f172a", children: display == null ? '—' : `${display}%` })] }) }));
}
export default function HomeView() {
    const [latest, setLatest] = useState(null);
    const [editing, setEditing] = useState(null);
    const [sleepPercent, setSleepPercent] = useState(null);
    const [sleepMeta, setSleepMeta] = useState(null);
    const [sleepWindow, setSleepWindow] = useState('last');
    useEffect(() => {
        async function loadLatest() {
            try {
                const res = await fetch('/api/journals?limit=1', { credentials: 'include' });
                if (res.ok) {
                    const data = await res.json();
                    setLatest(data && data.length ? data[0] : null);
                }
            }
            catch (e) {
                console.error(e);
            }
        }
        loadLatest();
        (async function fetchSleep() {
            try {
                const qs = sleepWindow === '7d' ? '?window=7d' : '';
                const r = await fetch(`/api/sleep/metric${qs}`, { credentials: 'include' });
                if (r.ok) {
                    const j = await r.json();
                    if (j && typeof j.percent === 'number') {
                        setSleepPercent(j.percent);
                        setSleepMeta(j);
                    }
                    else {
                        setSleepPercent(null);
                        setSleepMeta(j ?? null);
                    }
                }
            }
            catch (e) {
                console.error(e);
            }
        })();
    }, []);
    useEffect(() => {
        // refetch when window changes
        ;
        (async function fetchSleepWindow() {
            try {
                const qs = sleepWindow === '7d' ? '?window=7d' : '';
                const r = await fetch(`/api/sleep/metric${qs}`, { credentials: 'include' });
                if (r.ok) {
                    const j = await r.json();
                    if (j && typeof j.percent === 'number') {
                        setSleepPercent(j.percent);
                        setSleepMeta(j);
                    }
                    else {
                        setSleepPercent(null);
                        setSleepMeta(j ?? null);
                    }
                }
            }
            catch (e) {
                console.error(e);
            }
        })();
    }, [sleepWindow]);
    return (_jsxs("div", { className: "home-root", children: [_jsxs("div", { className: "nav-slab", children: [_jsx("div", { style: { height: 48, width: 48, borderRadius: 12, background: '#111827', marginBottom: 12 } }), _jsx("div", { style: { height: 48, width: 48, borderRadius: 12, background: '#fff', border: '1px solid #e6eef8', marginBottom: 8 } }), _jsx("div", { style: { height: 48, width: 48, borderRadius: 12, background: '#fff', border: '1px solid #e6eef8' } })] }), _jsxs("div", { className: "main", children: [_jsxs("div", { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' }, children: [_jsxs("div", { children: [_jsx("div", { style: { fontSize: 20, color: '#0f172a', fontWeight: 700 }, children: "Hi, Olivia" }), _jsx("div", { style: { color: '#475569' }, children: "How are you doing today?" })] }), _jsxs("div", { style: { display: 'flex', alignItems: 'center', gap: 12 }, children: [_jsx("input", { placeholder: "Search", style: { padding: '8px 12px', borderRadius: 22, border: '1px solid #e6eef8', width: 300 } }), _jsx("div", { style: { width: 40, height: 40, borderRadius: 20, background: '#fff', border: '1px solid #e6eef8' } })] })] }), _jsxs("div", { style: { display: 'flex', gap: 18 }, children: [_jsxs("div", { style: { flex: 1, display: 'flex', flexDirection: 'column', gap: 18 }, children: [_jsxs("div", { children: [_jsx("div", { style: { fontWeight: 700, color: '#0f172a', marginBottom: 12 }, children: "Activities" }), _jsx("div", { className: "activities-row", children: ['Yoga', 'Journal', 'Practices', 'Journal'].map((t, i) => (_jsx("div", { className: `activity-card ${i === 0 ? 'activity-primary' : 'activity-secondary'} fade-up`, children: _jsx("div", { style: { fontWeight: 700 }, children: t }) }, t))) })] }), _jsxs("div", { children: [_jsx("div", { style: { fontWeight: 700, marginBottom: 8 }, children: "Self Help" }), _jsx("div", { style: { background: 'linear-gradient(90deg,#fbcff4,#f2f8ff)', padding: 22, borderRadius: 12, color: '#111827', boxShadow: '0 6px 18px rgba(2,6,23,0.04)' }, children: _jsx("div", { style: { fontStyle: 'italic', textAlign: 'center', fontWeight: 600 }, children: "\u201CSuccess is not final, failure is not fatal: it is the courage to continue that counts.\u201D" }) }), _jsxs("div", { style: { display: 'flex', gap: 12, marginTop: 12 }, children: [_jsx("button", { className: "card", children: "Journal" }), _jsx("button", { className: "card", children: "Practices" })] }), _jsxs("div", { style: { marginTop: 12 }, className: "content-list", children: [_jsxs("div", { className: "card", children: ["How to find balance in life despite... ", _jsx("span", { style: { float: 'right', color: 'var(--muted)' }, children: "Article \u2022 4 min" })] }), _jsxs("div", { className: "card", children: ["It's okay to ask for help, you're not alone ", _jsx("span", { style: { float: 'right', color: 'var(--muted)' }, children: "Video \u2022 8 min" })] })] })] })] }), _jsxs("div", { style: { width: 420, display: 'flex', flexDirection: 'column', gap: 18 }, children: [_jsxs("div", { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' }, children: [_jsx("div", { style: { fontWeight: 700 }, children: "Physical state" }), _jsxs("div", { style: { display: 'flex', gap: 8 }, children: [_jsxs("div", { style: { padding: '8px 10px', borderRadius: 10, background: 'white', border: '1px solid #e6eef8' }, children: ["Sleep Goal", _jsx("br", {}), _jsx("strong", { children: "8h Target" })] }), _jsxs("div", { style: { padding: '8px 10px', borderRadius: 10, background: 'white', border: '1px solid #e6eef8' }, children: ["Last night", _jsx("br", {}), _jsx("strong", { children: "7.5h Achieved" })] })] })] }), _jsxs("div", { className: "donut-row", children: [_jsx("div", { className: "fade-up", children: _jsx(AnimatedDonut, { percent: sleepPercent ?? 78 }) }), _jsxs("div", { style: { flex: 1 }, children: [_jsx("div", { style: { marginBottom: 6 }, children: sleepPercent == null ? (_jsx("div", { style: { color: 'var(--muted)', fontSize: 13 }, children: "No sleep data" })) : (_jsx("div", { style: { color: 'var(--muted)', fontSize: 13 }, children: sleepMeta && sleepMeta.window && String(sleepMeta.window).includes('7') ? (
                                                            // Avg 7d: 7.2h (5 nights)
                                                            `Avg 7d: ${sleepMeta.hours ?? '—'}h (${sleepMeta.count ?? 0} nights)`) : (
                                                            // Last night: 7.5h
                                                            `Last night: ${sleepMeta && sleepMeta.hours ? `${sleepMeta.hours}h` : '—'}`) })) }), _jsxs("div", { style: { marginBottom: 8, display: 'flex', gap: 8, alignItems: 'center' }, children: [_jsxs("div", { style: { display: 'flex', alignItems: 'center', gap: 6 }, children: [_jsx("div", { style: { fontSize: 13, color: 'var(--muted)' }, children: "Metric" }), _jsxs(Popover, { id: "sleep-metric-pop", children: [_jsx("div", { style: { width: 14, height: 14, borderRadius: 7, background: '#eef2ff', color: '#2563eb', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700 }, children: "i" }), _jsxs("div", { children: [_jsx("div", { style: { fontWeight: 700, marginBottom: 6 }, children: "How the sleep percent is calculated" }), _jsx("div", { children: "Percent = (hours / 8h) capped at 100%. For 7-day average we compute the mean nightly duration across the last 7 days (only nights with an end time are counted)." }), _jsx("a", { className: "popover-link", href: "/docs/metrics#sleep-percent", onClick: (e) => { e.preventDefault(); history.pushState({}, '', '/docs/metrics#sleep-percent'); window.dispatchEvent(new PopStateEvent('popstate')); }, children: "View docs" })] })] })] }), _jsxs("div", { style: { display: 'flex', gap: 6 }, children: [_jsx("button", { className: `card ${sleepWindow === 'last' ? 'activity-primary' : ''}`, onClick: () => setSleepWindow('last'), children: "Last night" }), _jsx("button", { className: `card ${sleepWindow === '7d' ? 'activity-primary' : ''}`, onClick: () => setSleepWindow('7d'), children: "7-day avg" })] })] }), _jsx("div", { className: "card", children: latest ? latest.content : 'Sometimes it feels like no matter what we do, things only get worse.' }), _jsx("div", { style: { textAlign: 'right', color: 'var(--muted)', fontSize: 12, marginTop: 6 }, children: latest ? `${(latest.content || '').length}/240` : '68/240' }), latest && _jsx("div", { style: { marginTop: 8 }, children: _jsx("button", { className: "card", onClick: () => setEditing(latest), children: "Quick Edit" }) })] })] })] })] })] }), editing && (_jsxs(_Fragment, { children: [_jsx("div", { className: "overlay", onClick: () => setEditing(null) }), _jsx("div", { className: "modal fade-up", children: _jsx(JournalEditor, { date: (editing.entry_date || '').slice(0, 10), initial: editing, onSaved: (entry) => {
                                // entry === null means deleted
                                if (entry === null) {
                                    setLatest(null);
                                }
                                else if (entry) {
                                    setLatest(entry);
                                }
                                setEditing(null);
                            } }) })] }))] }));
}
