import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React, { useEffect, useRef, useState } from 'react';
import BottomNav from './BottomNav';
import '../styles/meditation.css';
const formatTime = (s) => {
    const mm = Math.floor(s / 60).toString().padStart(2, '0');
    const ss = Math.floor(s % 60).toString().padStart(2, '0');
    return `${mm}:${ss}`;
};
export default function Meditation() {
    const [seconds, setSeconds] = useState(300);
    const [running, setRunning] = useState(false);
    const intervalRef = useRef(null);
    useEffect(() => {
        if (running && intervalRef.current === null) {
            intervalRef.current = window.setInterval(() => {
                setSeconds(prev => {
                    if (prev <= 1) {
                        setRunning(false);
                        if (intervalRef.current) {
                            clearInterval(intervalRef.current);
                            intervalRef.current = null;
                        }
                        return 0;
                    }
                    return prev - 1;
                });
            }, 1000);
        }
        if (!running && intervalRef.current !== null) {
            clearInterval(intervalRef.current);
            intervalRef.current = null;
        }
        return () => { if (intervalRef.current) {
            clearInterval(intervalRef.current);
            intervalRef.current = null;
        } };
    }, [running]);
    const onToggle = () => setRunning(r => !r);
    const onReset = () => { setRunning(false); setSeconds(300); };
    const onShort = (mins) => { setSeconds(mins * 60); setRunning(true); };
    return (_jsxs("div", { className: "soul-app-root", children: [_jsxs("header", { className: "app-header", children: [_jsx("div", {}), _jsxs("div", { style: { textAlign: 'center' }, children: [_jsx("div", { className: "app-title", children: "SOUL" }), _jsx("div", { className: "app-subtitle", children: "Breathing meditation" })] }), _jsx("div", {})] }), _jsx("main", { className: "meditation-main", children: _jsxs("section", { className: "med-card", role: "region", "aria-label": "Meditation session", children: [_jsx("div", { className: "med-visual", "aria-hidden": true, children: _jsxs("svg", { width: "220", height: "220", viewBox: "0 0 220 220", className: "med-svg", focusable: "false", children: [_jsx("defs", { children: _jsxs("radialGradient", { id: "g1", cx: "50%", cy: "40%", children: [_jsx("stop", { offset: "0%", stopColor: "#fef7ff" }), _jsx("stop", { offset: "100%", stopColor: "#f3eafe" })] }) }), _jsx("circle", { cx: "110", cy: "90", r: "80", fill: "url(#g1)" }), _jsx("circle", { cx: "110", cy: "90", r: "44", fill: "#fff" })] }) }), _jsxs("div", { className: "med-info", children: [_jsx("div", { className: "med-time", "aria-live": "polite", children: formatTime(seconds) }), _jsxs("div", { className: "med-controls", role: "toolbar", "aria-label": "Preset durations", children: [_jsx("button", { className: "control-btn", onClick: () => onShort(1), "aria-label": "1 minute session", children: "1m" }), _jsx("button", { className: "control-btn", onClick: () => onShort(5), "aria-label": "5 minute session", children: "5m" }), _jsx("button", { className: "control-btn", onClick: () => onShort(10), "aria-label": "10 minute session", children: "10m" })] }), _jsxs("div", { className: "med-action-row", children: [_jsx("button", { className: "med-action secondary", onClick: onReset, "aria-label": "Reset timer", children: "Reset" }), _jsx("button", { className: `med-action center ${running ? 'pause' : 'play'}`, onClick: onToggle, "aria-pressed": running, "aria-label": running ? 'Pause meditation' : 'Start meditation', children: running ? '❚❚' : '▶' }), _jsx("button", { className: "med-action secondary", onClick: () => setSeconds(s => Math.max(30, s - 30)), "aria-label": "Skip back 30 seconds", children: "-30s" })] }), _jsx("p", { className: "med-note", children: "Follow the breath: inhale 4s, hold 4s, exhale 6s." })] })] }) }), _jsx(BottomNav, {})] }));
}
export default function Meditation() {
    const [running, setRunning] = React.useState(false);
    const [seconds, setSeconds] = React.useState(90);
    React.useEffect(() => {
        let id;
        if (running) {
            id = window.setInterval(() => setSeconds(s => Math.max(0, s - 1)), 1000);
        }
        return () => { if (id)
            window.clearInterval(id); };
    }, [running]);
    function toggle() {
        setRunning(r => !r);
    }
    function reset() {
        setRunning(false);
        setSeconds(90);
    }
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return (_jsxs("div", { style: { paddingBottom: 110 }, children: [_jsxs("header", { className: "app-header", children: [_jsxs("div", { children: [_jsx("div", { className: "app-title", children: "SOUL" }), _jsx("div", { className: "app-subtitle", children: "Breathing meditation" })] }), _jsx("div", { "aria-hidden": true, style: { width: 40, height: 40 } })] }), _jsx("main", { style: { padding: 16, display: 'flex', flexDirection: 'column', gap: 16, alignItems: 'center' }, children: _jsxs("div", { style: { width: '100%', maxWidth: 420, background: 'linear-gradient(180deg,#fbf8ff,#f2f8ff)', borderRadius: 16, padding: 20, textAlign: 'center', boxShadow: '0 8px 28px rgba(2,6,23,0.06)' }, children: [_jsx("div", { style: { fontSize: 14, color: 'var(--muted)', marginBottom: 12 }, children: "5 minutes" }), _jsx("div", { style: { fontSize: 22, fontWeight: 700, marginBottom: 8 }, children: "Breathing meditation" }), _jsx("div", { style: { width: 180, height: 180, borderRadius: 90, background: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '12px auto', boxShadow: '0 8px 24px rgba(2,6,23,0.08)' }, children: _jsx("div", { style: { fontSize: 28, fontWeight: 700 }, children: `${mins}:${secs.toString().padStart(2, '0')}` }) }), _jsxs("div", { style: { display: 'flex', gap: 12, justifyContent: 'center' }, children: [_jsx("button", { onClick: toggle, style: { padding: '10px 18px', borderRadius: 12, border: 'none', background: running ? '#f3f4f6' : 'var(--soul-accent)', color: running ? '#111' : '#fff', cursor: 'pointer' }, children: running ? 'Pause' : 'Start' }), _jsx("button", { onClick: reset, style: { padding: '10px 18px', borderRadius: 12, border: '1px solid #e6eef8', background: '#fff' }, children: "Reset" })] })] }) }), _jsx(BottomNav, {})] }));
}
