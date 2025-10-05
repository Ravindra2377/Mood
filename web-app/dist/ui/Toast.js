import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React from 'react';
const ToastContext = React.createContext(null);
export function useToast() {
    const ctx = React.useContext(ToastContext);
    if (!ctx)
        throw new Error('useToast must be used inside ToastProvider');
    return ctx;
}
export function ToastProvider({ children }) {
    const [message, setMessage] = React.useState('');
    const [visible, setVisible] = React.useState(false);
    const timerRef = React.useRef(null);
    function show(msg) {
        setMessage(msg);
        setVisible(true);
        if (timerRef.current)
            window.clearTimeout(timerRef.current);
        timerRef.current = window.setTimeout(() => setVisible(false), 2000);
    }
    React.useEffect(() => () => { if (timerRef.current)
        window.clearTimeout(timerRef.current); }, []);
    return (_jsxs(ToastContext.Provider, { value: { show }, children: [children, _jsx("div", { "aria-hidden": !visible, style: {
                    position: 'fixed',
                    right: 20,
                    bottom: 24,
                    padding: '10px 14px',
                    background: '#111827',
                    color: 'white',
                    borderRadius: 8,
                    boxShadow: '0 6px 20px rgba(0,0,0,0.18)',
                    transform: visible ? 'translateY(0) scale(1)' : 'translateY(10px) scale(0.98)',
                    opacity: visible ? 1 : 0,
                    transition: 'opacity 220ms ease, transform 220ms ease',
                    pointerEvents: visible ? 'auto' : 'none',
                }, children: message })] }));
}
export default ToastProvider;
