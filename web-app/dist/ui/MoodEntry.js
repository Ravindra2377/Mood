import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React, { useState } from 'react';
import { enqueueMood } from '../sw/queue';
import { useToast } from './Toast';
import BottomNav from './BottomNav';
export default function MoodEntry() {
    const [rating, setRating] = useState(3);
    const [note, setNote] = useState('');
    const [status, setStatus] = useState('');
    const btnRefs = React.useRef([]);
    const toast = (() => { try {
        return useToast();
    }
    catch (_) {
        return null;
    } })();
    async function save() {
        try {
            await enqueueMood({ rating, note, timestamp: new Date().toISOString() });
            setStatus('Saved locally');
            try {
                toast?.show('Saved');
            }
            catch (e) { }
        }
        catch (e) {
            setStatus('Save failed');
        }
    }
    React.useEffect(() => {
        function onKey(e) {
            const active = document.activeElement;
            if (active) {
                const tag = active.tagName?.toLowerCase();
                if (tag === 'input' || tag === 'textarea' || active.isContentEditable)
                    return;
            }
            if (/^[1-5]$/.test(e.key)) {
                const val = Number(e.key);
                setRating(val);
                btnRefs.current[val - 1]?.focus();
            }
        }
        window.addEventListener('keydown', onKey);
        return () => window.removeEventListener('keydown', onKey);
    }, []);
    return (_jsxs("div", { style: { paddingBottom: 110 }, children: [_jsxs("header", { className: "app-header", children: [_jsxs("div", { children: [_jsx("div", { className: "app-title", children: "SOUL" }), _jsx("div", { className: "app-subtitle", children: "How are you feeling?" })] }), _jsx("div", { "aria-hidden": true, children: _jsx("div", { style: { width: 40, height: 40, borderRadius: 20, background: '#fff', boxShadow: '0 4px 10px rgba(2,6,23,0.06)' } }) })] }), _jsxs("main", { style: { padding: 16 }, children: [_jsx("div", { style: { marginBottom: 8 }, children: "Rating:" }), _jsxs("div", { style: { display: 'flex', alignItems: 'center', gap: 12 }, children: [_jsx("div", { role: "radiogroup", "aria-label": "Daily SOUL rating", style: { display: 'flex', gap: 12, alignItems: 'center' }, children: [1, 2, 3, 4, 5].map((i) => {
                                    const isSelected = rating === i;
                                    return (_jsxs("div", { style: { display: 'flex', flexDirection: 'column', alignItems: 'center' }, children: [_jsx("button", { ref: (el) => (btnRefs.current[i - 1] = el), role: "radio", "aria-checked": isSelected, tabIndex: isSelected ? 0 : -1, onClick: () => setRating(i), "aria-label": `Rate ${i}`, style: {
                                                    width: 48,
                                                    height: 48,
                                                    borderRadius: 24,
                                                    border: isSelected ? '2px solid var(--soul-accent)' : '1px solid #e2e8f0',
                                                    background: 'white',
                                                    cursor: 'pointer',
                                                    display: 'inline-flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center'
                                                }, children: i }), _jsx("div", { style: { fontSize: 11, color: '#6b7280', marginTop: 6 }, children: i })] }, i));
                                }) }), _jsx("div", { style: { marginLeft: 8, color: '#6b7280', fontSize: 13 }, title: "Keyboard shortcuts", children: _jsxs("span", { style: { display: 'inline-flex', alignItems: 'center', gap: 8 }, children: [_jsx("kbd", { style: { background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }, children: "1" }), _jsx("span", { style: { opacity: 0.8 }, children: ".." }), _jsx("kbd", { style: { background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }, children: "5" }), _jsx("span", { style: { marginLeft: 6 }, children: "press 1\u20135 to set" })] }) })] }), _jsx("div", { style: { marginTop: 12 }, children: _jsx("textarea", { value: note, onChange: (e) => setNote(e.target.value), style: { width: '100%', minHeight: 120, padding: 12, borderRadius: 12, border: '1px solid #e6eef8' } }) }), _jsxs("div", { style: { display: 'flex', gap: 8, marginTop: 12 }, children: [_jsx("button", { onClick: save, style: { background: 'var(--soul-accent)', color: 'white', padding: '10px 16px', borderRadius: 10, border: 'none', cursor: 'pointer' }, children: "Save" }), _jsx("button", { onClick: () => { setNote(''); setRating(3); }, style: { background: '#fff', border: '1px solid #e6eef8', padding: '10px 12px', borderRadius: 10 }, children: "Reset" })] }), _jsx("div", { role: "status", "aria-live": "polite", style: { marginTop: 8, minHeight: 18 }, children: status })] }), _jsx(BottomNav, {})] }));
}
