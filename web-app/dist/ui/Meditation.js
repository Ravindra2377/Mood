import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useEffect, useRef, useState } from 'react';
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
                setSeconds((prev) => {
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
        return () => {
            if (intervalRef.current) {
                clearInterval(intervalRef.current);
                intervalRef.current = null;
            }
        };
    }, [running]);
    const onToggle = () => setRunning((r) => !r);
    const onReset = () => {
        setRunning(false);
        setSeconds(300);
    };
    const onShort = (mins) => {
        setSeconds(mins * 60);
        setRunning(true);
    };
    return (_jsxs("div", { className: "soul-app-root", children: [_jsxs("header", { className: "app-header", children: [_jsx("div", {}), _jsxs("div", { style: { textAlign: 'center' }, children: [_jsx("div", { className: "app-title", children: "SOUL" }), _jsx("div", { className: "app-subtitle", children: "Breathing meditation" })] }), _jsx("div", {})] }), _jsx("main", { className: "meditation-main", children: _jsxs("section", { className: "med-card", role: "region", "aria-label": "Meditation session", children: [_jsx("div", { className: "med-visual", "aria-hidden": true, children: _jsxs("svg", { width: "220", height: "220", viewBox: "0 0 220 220", className: "med-svg", focusable: "false", children: [_jsx("defs", { children: _jsxs("radialGradient", { id: "g1", cx: "50%", cy: "40%", children: [_jsx("stop", { offset: "0%", stopColor: "#fef7ff" }), _jsx("stop", { offset: "100%", stopColor: "#f3eafe" })] }) }), _jsx("circle", { cx: "110", cy: "90", r: "80", fill: "url(#g1)" }), _jsx("circle", { cx: "110", cy: "90", r: "44", fill: "#fff" })] }) }), _jsxs("div", { className: "med-info", children: [_jsx("div", { className: "med-time", "aria-live": "polite", children: formatTime(seconds) }), _jsxs("div", { className: "med-controls", role: "toolbar", "aria-label": "Preset durations", children: [_jsx("button", { className: "control-btn", onClick: () => onShort(1), "aria-label": "1 minute session", children: "1m" }), _jsx("button", { className: "control-btn", onClick: () => onShort(5), "aria-label": "5 minute session", children: "5m" }), _jsx("button", { className: "control-btn", onClick: () => onShort(10), "aria-label": "10 minute session", children: "10m" })] }), _jsxs("div", { className: "med-action-row", children: [_jsx("button", { className: "med-action secondary", onClick: onReset, "aria-label": "Reset timer", children: "Reset" }), _jsx("button", { className: `med-action center ${running ? 'pause' : 'play'}`, onClick: onToggle, "aria-pressed": running, "aria-label": running ? 'Pause meditation' : 'Start meditation', children: running ? '❚❚' : '▶' }), _jsx("button", { className: "med-action secondary", onClick: () => setSeconds((s) => Math.max(30, s - 30)), "aria-label": "Skip back 30 seconds", children: "-30s" })] }), _jsx("p", { className: "med-note", children: "Follow the breath: inhale 4s, hold 4s, exhale 6s." })] })] }) }), _jsx(BottomNav, {})] }));
}
