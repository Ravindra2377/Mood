import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React, { useState } from 'react';
import { enqueueMood } from '../sw/queue';
import { useToast } from './Toast';
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
            // show centralized toast if available
            try {
                toast?.show('Saved');
            }
            catch (e) { }
        }
        catch (e) {
            setStatus('Save failed');
        }
    }
    // keyboard shortcuts (1-5) — ignore when focused on input/textarea or contentEditable
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
                // focus the corresponding button for accessibility
                btnRefs.current[val - 1]?.focus();
            }
        }
        window.addEventListener('keydown', onKey);
        return () => window.removeEventListener('keydown', onKey);
    }, []);
    // no local toast cleanup required when using centralized provider
    return (_jsxs("div", { children: [_jsx("div", { style: { marginBottom: 8 }, children: "Rating:" }), _jsxs("div", { style: { display: 'flex', alignItems: 'center', gap: 12 }, children: [_jsx("div", { role: "radiogroup", "aria-label": "Daily SOUL rating", style: { display: 'flex', gap: 12, alignItems: 'center' }, children: [1, 2, 3, 4, 5].map((i) => {
                            const isSelected = rating === i;
                            return (_jsxs("div", { style: { display: 'flex', flexDirection: 'column', alignItems: 'center' }, children: [_jsx("button", { ref: (el) => (btnRefs.current[i - 1] = el), role: "radio", "aria-checked": isSelected, tabIndex: isSelected ? 0 : -1, onClick: () => setRating(i), onKeyDown: (e) => {
                                            // keyboard navigation: arrows, Home/End and activate
                                            const idx = i - 1;
                                            if (e.key === 'ArrowRight') {
                                                const newIdx = Math.min(4, idx + 1);
                                                setRating(newIdx + 1);
                                                btnRefs.current[newIdx]?.focus();
                                                e.preventDefault();
                                            }
                                            else if (e.key === 'ArrowLeft') {
                                                const newIdx = Math.max(0, idx - 1);
                                                setRating(newIdx + 1);
                                                btnRefs.current[newIdx]?.focus();
                                                e.preventDefault();
                                            }
                                            else if (e.key === 'Home') {
                                                setRating(1);
                                                btnRefs.current[0]?.focus();
                                                e.preventDefault();
                                            }
                                            else if (e.key === 'End') {
                                                setRating(5);
                                                btnRefs.current[4]?.focus();
                                                e.preventDefault();
                                            }
                                            else if (e.key === 'Enter' || e.key === ' ') {
                                                setRating(i);
                                                e.preventDefault();
                                            }
                                        }, "aria-label": `Rate ${i}`, style: {
                                            width: 40,
                                            height: 40,
                                            borderRadius: 20,
                                            border: isSelected ? '2px solid #36b37e' : '1px solid #e2e8f0',
                                            padding: 0,
                                            background: `url(/mood-${i}.png), url(/moods-inline.png)`,
                                            backgroundRepeat: 'no-repeat, no-repeat',
                                            backgroundSize: 'contain, 500% 100%',
                                            backgroundPosition: 'center, ' + `${(i - 1) * 25}% center`,
                                            cursor: 'pointer',
                                            transition: 'transform 140ms ease, box-shadow 140ms ease, border-color 140ms ease',
                                            transform: isSelected ? 'scale(1.08)' : 'scale(1)',
                                            boxShadow: isSelected ? '0 4px 10px rgba(0,0,0,0.08)' : 'none',
                                        }, onMouseEnter: (e) => {
                                            e.currentTarget.style.transform = 'scale(1.12)';
                                            e.currentTarget.style.boxShadow = '0 6px 16px rgba(0,0,0,0.12)';
                                        }, onMouseLeave: (e) => {
                                            e.currentTarget.style.transform = isSelected ? 'scale(1.08)' : 'scale(1)';
                                            e.currentTarget.style.boxShadow = isSelected ? '0 4px 10px rgba(0,0,0,0.08)' : 'none';
                                        }, onFocus: (e) => {
                                            e.currentTarget.style.transform = 'scale(1.12)';
                                            e.currentTarget.style.boxShadow = '0 6px 20px rgba(0,0,0,0.12)';
                                            e.currentTarget.style.borderColor = '#2b8a6b';
                                        }, onBlur: (e) => {
                                            e.currentTarget.style.transform = isSelected ? 'scale(1.08)' : 'scale(1)';
                                            e.currentTarget.style.boxShadow = isSelected ? '0 4px 10px rgba(0,0,0,0.08)' : 'none';
                                            e.currentTarget.style.borderColor = isSelected ? '#36b37e' : '#e2e8f0';
                                        } }, i), _jsx("div", { style: { fontSize: 11, color: '#6b7280', marginTop: 6 }, children: i })] }, i));
                        }) }), _jsx("div", { style: { marginLeft: 8, color: '#6b7280', fontSize: 13 }, title: "Keyboard shortcuts", children: _jsxs("span", { style: { display: 'inline-flex', alignItems: 'center', gap: 8 }, children: [_jsx("kbd", { style: { background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }, children: "1" }), _jsx("span", { style: { opacity: 0.8 }, children: ".." }), _jsx("kbd", { style: { background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }, children: "5" }), _jsx("span", { style: { marginLeft: 6 }, children: "press 1\u20135 to set" })] }) })] }), _jsx("div", { children: _jsx("textarea", { value: note, onChange: (e) => setNote(e.target.value) }) }), _jsx("button", { onClick: save, style: { marginTop: 8 }, children: "Save" }), _jsx("div", { role: "status", "aria-live": "polite", style: { marginTop: 8, minHeight: 18 }, children: status })] }));
}
